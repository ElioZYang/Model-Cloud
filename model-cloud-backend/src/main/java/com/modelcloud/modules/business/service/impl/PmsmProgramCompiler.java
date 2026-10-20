package com.modelcloud.modules.business.service.impl;

import com.modelcloud.common.exception.BusinessException;
import com.modelcloud.modules.business.model.dto.MatlabComponentVO;
import java.util.*;
import java.util.function.Function;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.*;

/** Compiles editable PMSM entry scenes as callable programs, never outer DAG leaves. */
final class PmsmProgramCompiler {
    record Prepared(Map<String,Object> payload, List<Map<String,Object>> programs) {}

    static Prepared prepare(Map<String,Object> input, Function<String,MatlabComponentVO> lookup) {
        if (!input.containsKey("scenes")) return new Prepared(input,List.of());
        Map<String,Object> payload=copyMap(input);
        Map<String,Object> scenes=new LinkedHashMap<>();
        if (payload.get("scenes") instanceof Map<?,?> rawScenes) {
            rawScenes.forEach((key,value)->scenes.put(String.valueOf(key),value));
        } else for(Object item:listValue(payload.get("scenes"))) {
            Map<String,Object> scene=asObject(item);
            String sceneId=stringValue(scene.get("id"));
            if (scenes.putIfAbsent(sceneId,scene)!=null) throw new BusinessException("场景 ID 重复: "+sceneId);
        }
        List<Map<String,Object>> owners=new ArrayList<>();
        visit(stringValue(payload.get("rootSceneId")),scenes,new HashSet<>(),owners);
        List<Map<String,Object>> programs=new ArrayList<>();
        int total=0;
        for (Map<String,Object> owner:owners) {
            String id=stringValue(owner.get("id"));
            MatlabComponentVO component=lookup.apply(stringValue(owner.get("componentId")));
            if (component==null || !"pmsm.subsystem.hpcgv".equals(component.getId()))
                throw new BusinessException("计算子图仅支持可信 PMSM 子系统: "+id);
            Map<String,Object> entries=asObject(owner.get("modelEntrypoints"));
            Set<String> descendants=new HashSet<>();
            collect(stringValue(owner.get("childSceneId")),scenes,descendants,new HashSet<>());
            Map<String,Object> compiled=new LinkedHashMap<>();
            for (String mode:List.of("design","offdesign","thermal")) {
                String sceneId=stringValue(entries.get(mode));
                if (sceneId.isBlank() || !descendants.contains(sceneId))
                    throw new BusinessException("PMSM 计算入口必须引用内部子场景: "+id+"."+mode);
                Map<String,Object> request=specialize(scenes,sceneId,mode,id);
                Map<String,Object> graph=new MatlabTrustedGraphCompiler(lookup::apply).buildTrustedGraph(request);
                graph.put("analysisMode",mode);
                long inputCount=0;
                for (Object item:listValue(graph.get("nodes"))) {
                    Map<String,Object> node=asObject(item);
                    if ("pmsm.program.input".equals(node.get("componentId"))) inputCount++;
                    if (!stringValue(node.get("functionName")).startsWith("mc_pmsm_")
                            || "pmsm.program.execute".equals(node.get("componentId")))
                        throw new BusinessException("PMSM 子图只能使用 PMSM 计算组件: "+node.get("componentId"));
                    Map<String,Object> invocation=asObject(node.get("invocation"));
                    for(Object argument:listValue(invocation.get("arguments")))
                        if(!"input".equals(asObject(argument).get("source")))
                            throw new BusinessException("PMSM 子图需要显式输入接口，配置资源应在外部准备");
                }
                for (Object item:listValue(graph.get("nodes"))) {
                    @SuppressWarnings("unchecked") Map<String,Object> node=(Map<String,Object>)item;
                    List<Object> origin=new ArrayList<>(List.of(id,mode));
                    origin.addAll(listValue(node.get("originPath"))); node.put("originPath",origin);
                }
                if (inputCount!=1) throw new BusinessException("PMSM 子图必须且只能包含一个子图输入: "+id+"."+mode);
                for (Object item:listValue(graph.get("nodes"))) {
                    Map<String,Object> node=asObject(item);
                    if (!"pmsm.program.input".equals(node.get("componentId"))) continue;
                    if (listValue(graph.get("edges")).stream().anyMatch(edge ->
                            Objects.equals(node.get("id"),asObject(edge).get("targetNodeId"))))
                        throw new BusinessException("PMSM 子图输入由调用上下文注入，不能连接内部来源: "+id+"."+mode);
                }
                if (listValue(graph.get("publicOutputs")).stream().filter(item ->
                    "OUTPUT".equals(first(asObject(item),"displayName","name"))).count()!=1)
                    throw new BusinessException("PMSM 子图必须暴露唯一 OUTPUT: "+id+"."+mode);
                total+=listValue(graph.get("nodes")).size();
                if (total>MAX_NODES) throw new BusinessException("PMSM 计算子图总规模超过限制");
                compiled.put(mode,graph);
            }
            programs.add(new LinkedHashMap<>(Map.of("id",id,"entries",compiled)));
            owner.put("componentId","pmsm.program.execute");
            owner.put("nodeKind","matlabFunction"); owner.put("executionKind","matlabFunction");
            owner.remove("childSceneId"); owner.remove("modelEntrypoints"); owner.remove("boundaryPorts");
            Map<String,Object> values=asObject(owner.get("values")); values.put("program_id",id); owner.put("values",values);
        }
        payload.put("scenes",scenes);
        return new Prepared(payload,programs);
    }

    /** Prunes the editable mode branches and resolves the compile-time model merge before DAG compilation. */
    private static Map<String,Object> specialize(Map<String,Object> scenes,String root,String mode,String ownerId) {
        Set<String> reachable=new LinkedHashSet<>();
        collect(root,scenes,reachable,new HashSet<>());
        Map<String,Object> selected=new LinkedHashMap<>();
        for(String sceneId:reachable) selected.put(sceneId,copyMap(asObject(scenes.get(sceneId))));
        for(Map.Entry<String,Object> sceneEntry:selected.entrySet()) {
            String sceneId=sceneEntry.getKey();
            Map<String,Object> scene=asObject(sceneEntry.getValue());
            List<Map<String,Object>> original=new ArrayList<>();
            for(Object item:listValue(scene.get("nodes"))) original.add(asObject(item));
            Set<String> keep=new HashSet<>();
            for(Map<String,Object> node:original) {
                Object rawModes=node.get("activeModes");
                if(rawModes==null || modeList(rawModes,stringValue(node.get("id"))).contains(mode)) keep.add(stringValue(node.get("id")));
            }
            List<Map<String,Object>> nodes=new ArrayList<>();
            for(Map<String,Object> node:original) if(keep.contains(stringValue(node.get("id")))) {
                node.remove("activeModes"); nodes.add(node);
            }
            List<Map<String,Object>> edges=new ArrayList<>();
            // Saved projects use dataEdges; canvas submissions use edges.
            Object sceneEdges=scene.containsKey("dataEdges") ? scene.get("dataEdges") : scene.get("edges");
            for(Object item:listValue(sceneEdges)) {
                Map<String,Object> edge=asObject(item);
                if(keep.contains(stringValue(edge.get("sourceNodeId"))) && keep.contains(stringValue(edge.get("targetNodeId")))) edges.add(edge);
            }
            scene.put("nodes",nodes); scene.put("dataEdges",edges); scene.remove("edges");
            if(sceneId.equals(root)) resolveModelMerge(scene,mode,ownerId);
            pruneBoundaryMappings(scene,keep);
            selected.put(sceneId,scene);
        }
        Map<String,Object> request=new LinkedHashMap<>();
        request.put("schemaVersion",2); request.put("rootSceneId",root); request.put("scenes",selected);
        return request;
    }

    private static List<String> modeList(Object raw,String nodeId) {
        if(!(raw instanceof List<?> values) || values.isEmpty()) throw new BusinessException("PMSM 分支 activeModes 必须是非空数组: "+nodeId);
        List<String> result=new ArrayList<>();
        for(Object value:values) {
            String mode=stringValue(value);
            if(!List.of("design","offdesign","thermal").contains(mode) || result.contains(mode))
                throw new BusinessException("PMSM 分支 activeModes 无效: "+nodeId);
            result.add(mode);
        }
        return result;
    }

    private static void resolveModelMerge(Map<String,Object> scene,String mode,String ownerId) {
        List<Map<String,Object>> nodes=new ArrayList<>();
        for(Object item:listValue(scene.get("nodes"))) nodes.add(asObject(item));
        List<Map<String,Object>> merges=nodes.stream().filter(n->"pmsm.c.merge".equals(n.get("componentId"))).toList();
        if(merges.isEmpty()) return;
        if(merges.size()!=1) throw new BusinessException("PMSM 主流程必须且只能有一个模型合流节点: "+ownerId+"."+mode);
        Map<String,Object> merge=merges.get(0); String mergeId=stringValue(merge.get("id"));
        String selectedPort=switch(mode) { case "design" -> "designModel"; case "offdesign" -> "offdesignModel"; default -> "existingModel"; };
        List<Map<String,Object>> edges=new ArrayList<>();
        for(Object item:listValue(scene.get("dataEdges"))) edges.add(asObject(item));
        List<Map<String,Object>> selected=edges.stream().filter(e->mergeId.equals(e.get("targetNodeId")) && selectedPort.equals(e.get("targetPort"))).toList();
        long activeSources=edges.stream().filter(e->mergeId.equals(e.get("targetNodeId"))).count();
        if(selected.size()!=1 || activeSources!=1) throw new BusinessException("PMSM 当前模式必须恰有一个有效电机模型输入: "+ownerId+"."+mode);
        Map<String,Object> incoming=selected.get(0); String source=stringValue(incoming.get("sourceNodeId")); String sourcePort=stringValue(incoming.get("sourcePort"));
        if(!"motorModel".equals(sourcePort)) throw new BusinessException("PMSM 模型合流输入必须来自 motorModel: "+ownerId+"."+mode);
        List<Map<String,Object>> rewritten=new ArrayList<>();
        for(Map<String,Object> edge:edges) {
            if(mergeId.equals(edge.get("targetNodeId"))) continue;
            if(mergeId.equals(edge.get("sourceNodeId"))) {
                edge.put("sourceNodeId",source); edge.put("sourcePort",sourcePort);
            }
            rewritten.add(edge);
        }
        scene.put("dataEdges",rewritten);
        nodes.remove(merge); scene.put("nodes",nodes);
    }

    private static void pruneBoundaryMappings(Map<String,Object> scene,Set<String> keep) {
        for(Object item:listValue(scene.get("boundaryPorts"))) {
            Map<String,Object> boundary=asObject(item);
            if(boundary.get("mapping") instanceof Map<?,?> raw) {
                Map<String,Object> mapping=asObject(raw);
                if(!keep.contains(stringValue(mapping.get("childNodeId")))) boundary.remove("mapping");
            }
            if(boundary.get("mappings") instanceof List<?> rawMappings) {
                List<Object> mappings=new ArrayList<>();
                for(Object value:rawMappings) { Map<String,Object> m=asObject(value); if(keep.contains(stringValue(m.get("childNodeId")))) mappings.add(m); }
                boundary.put("mappings",mappings);
                if(boundary.get("mapping")==null && !mappings.isEmpty()) boundary.put("mapping",mappings.get(0));
            }
        }
    }

    @SuppressWarnings("unchecked")
    private static void visit(String id,Map<String,Object> scenes,Set<String> active,List<Map<String,Object>> owners) {
        if (!active.add(id)) throw new BusinessException("PMSM 子系统场景存在循环引用: "+id);
        if (!(scenes.get(id) instanceof Map<?,?>)) throw new BusinessException("PMSM 场景不存在: "+id);
        Map<String,Object> scene=(Map<String,Object>)scenes.get(id);
        for (Object item:listValue(scene.get("nodes"))) {
            Map<String,Object> node=(Map<String,Object>)item;
            if (node.containsKey("modelEntrypoints")) owners.add(node);
            else if (!stringValue(node.get("childSceneId")).isBlank())
                visit(stringValue(node.get("childSceneId")),scenes,active,owners);
        }
        active.remove(id);
    }

    private static void collect(String id,Map<String,Object> scenes,Set<String> result,Set<String> active) {
        if (!active.add(id)) throw new BusinessException("PMSM 计算入口场景存在循环引用: "+id);
        if (!scenes.containsKey(id)) throw new BusinessException("PMSM 子场景不存在: "+id);
        result.add(id);
        for(Object item:listValue(asObject(scenes.get(id)).get("nodes"))) {
            String child=stringValue(asObject(item).get("childSceneId"));
            if(!child.isBlank()) collect(child,scenes,result,active);
        }
        active.remove(id);
    }
}
