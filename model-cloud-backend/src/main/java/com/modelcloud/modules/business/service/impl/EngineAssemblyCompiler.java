package com.modelcloud.modules.business.service.impl;

import com.alibaba.fastjson2.JSON;
import com.modelcloud.common.exception.BusinessException;
import com.modelcloud.modules.business.model.dto.MatlabComponentVO;

import java.util.ArrayList;
import java.util.ArrayDeque;
import java.util.HashSet;
import java.util.Set;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;

import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.MAX_NODES;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.append;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.copyMap;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.copyValue;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.first;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.listValue;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.mergeMap;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.safeId;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.stringValue;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.normalizedKind;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.isWorkflowSubsystem;

/**
 * 发动机装配编译器（V3）：根据工程显式声明的 physicalAssemblies 生成
 * {@code engine.physical-scene.v1} 装配数据，并沿可见数据 DAG 与子系统边界
 * 将其注入对应 DP 组装节点的 {@code assembly_json} 输入。
 *
 * 不依赖 Scene 类型；只依赖：
 * 1. 工程的 physicalAssemblies（成员/关系/defaults；initializerBinding 仅为兼容摘要）；
 * 2. 可信目录中部件的 physicalCapabilities；
 * 3. 展开后图节点携带的 __sourceNodeId（项目唯一节点 ID）。
 *
 * 不计算发动机语义（F/SHAFT/EXT/NS/NW 由 MATLAB ENGINE_SCENE_ASSEMBLY 推导）。
 */
final class EngineAssemblyCompiler {

    private EngineAssemblyCompiler() {
    }

    /**
     * 把装配数据注入由数据 DAG 唯一解析出的 DP 组装节点。
     *
     * @param expandedNodes      层级展开后的执行节点（含 __sourceNodeId）
     * @param physicalAssemblies 工程装配定义（来自前端 payload 透传）
     * @param componentLookup    可信目录查找（校验部件能力）
     */
    static void applyAssemblies(List<Map<String, Object>> expandedNodes,
                                Object physicalAssemblies,
                                Map<String, Map<String, Object>> scenes,
                                java.util.function.Function<String, MatlabComponentVO> componentLookup) {
        if (physicalAssemblies == null) return;
        if (!(physicalAssemblies instanceof Map<?, ?> assemblies)) {
            throw new BusinessException("physicalAssemblies 必须是对象");
        }
        if (assemblies.isEmpty()) return;

        // 项目唯一节点 ID（__sourceNodeId）→ 展开后节点
        Map<String, Map<String, Object>> nodesBySourceId = new LinkedHashMap<>();
        for (Map<String, Object> node : expandedNodes) {
            String sourceNodeId = stringValue(node.get("__sourceNodeId"));
            if (!sourceNodeId.isBlank()) nodesBySourceId.put(sourceNodeId, node);
        }

        Set<String> boundInitializers = new HashSet<>();
        for (Map.Entry<?, ?> entry : assemblies.entrySet()) {
            String assemblyId = String.valueOf(entry.getKey());
            if (!(entry.getValue() instanceof Map<?, ?> rawAssembly)) {
                throw new BusinessException("发动机装配格式不正确: " + assemblyId);
            }
            Map<String, Object> assembly = copyMap(rawAssembly);

            // The visible data graph is authoritative. initializerBinding is retained as a
            // compatibility summary only; it may be stale after wrapping/unwrapping scenes.
            String bindingNodeId = resolveInitializerFromDataGraph(assemblyId, scenes);
            if (bindingNodeId.isBlank()) {
                throw new BusinessException("装配关系的 assembly_json 未通过数据连线连接到 DP 组装: " + assemblyId);
            }
            Map<String, Object> initializerNode = nodesBySourceId.get(bindingNodeId);
            if (initializerNode == null) {
                throw new BusinessException("装配初始化绑定节点不存在: " + assemblyId + "." + bindingNodeId);
            }
            String inputPort = "assembly_json";
            if (!boundInitializers.add(bindingNodeId)) {
                throw new BusinessException("多个装配不能覆盖同一初始化节点: " + bindingNodeId);
            }
            validateAssemblyDescriptor(assembly, assemblyId, bindingNodeId, scenes);
            if (componentLookup != null) {
                MatlabComponentVO initializer = componentLookup.apply(stringValue(initializerNode.get("componentId")));
                if (initializer == null || initializer.getInputs() == null
                        || initializer.getInputs().stream().noneMatch(port -> inputPort.equals(port.getName()))) {
                    throw new BusinessException("初始化绑定节点没有 assembly_json 输入: " + bindingNodeId);
                }
            }

            Map<String, Object> sceneAssembly = buildPhysicalScene(assembly, assemblyId,
                    nodesBySourceId, scenes, componentLookup);

            Map<String, Object> values = MatlabGraphSupport.asObject(initializerNode.get("values"));
            values.put("assembly_json", JSON.toJSONString(sceneAssembly));
            initializerNode.put("values", values);
        }
    }

    /** Validate the descriptor and resolve its visible assembly_json route through nested wrappers. */
    private static void validateAssemblyDescriptor(Map<String, Object> assembly,
                                                   String assemblyId,
                                                   String initializerNodeId,
                                                   Map<String, Map<String, Object>> scenes) {
        Map<String, Object> descriptor = null;
        String descriptorId = "";
        for (Map<String, Object> scene : scenes.values()) {
            for (Object item : listValue(scene.get("nodes"))) {
                if (!(item instanceof Map<?, ?> rawNode)
                        || !assemblyId.equals(stringValue(first(rawNode, "physicalAssemblyId")))) continue;
                if (descriptor != null) throw new BusinessException("同一物理装配存在多个装配关系节点: " + assemblyId);
                descriptor = copyMap(rawNode);
                descriptorId = stringValue(first(rawNode, "id", "nodeId"));
            }
        }
        if (descriptor == null || descriptorId.isBlank()) {
            throw new BusinessException("找不到物理装配对应的装配关系节点: " + assemblyId);
        }
        if (!"project.subsystem.engine-assembly-relations".equals(stringValue(descriptor.get("componentId")))) {
            throw new BusinessException("装配关系节点组件身份无效: " + assemblyId);
        }
        String childSceneId = stringValue(first(descriptor, "childSceneId"));
        Map<String, Object> relationScene = scenes.get(childSceneId);
        if (childSceneId.isBlank() || relationScene == null) {
            throw new BusinessException("装配关系节点引用的子场景不存在: " + assemblyId + "." + childSceneId);
        }
        Set<String> relationNodeIds = new HashSet<>();
        collectSceneNodeIds(relationScene, scenes, relationNodeIds, new HashSet<>());
        for (Object item : listValue(assembly.get("memberNodeIds"))) {
            String memberId = String.valueOf(item);
            if (!relationNodeIds.contains(memberId)) {
                throw new BusinessException("装配关系子场景缺少成员部件: " + assemblyId + "." + memberId);
            }
        }

        // The descriptor's route can pass through any number of ordinary subsystem boundary mappings.
        Set<String> targets = resolveInitializerFromDataGraph(assemblyId, scenes, descriptorId);
        if (targets.size() != 1 || !targets.contains(initializerNodeId))
            throw new BusinessException("assembly_json 数据连线必须唯一连接到对应 DP 组装: " + assemblyId
                    + "，解析到 " + targets);
    }

    static String resolveInitializerFromDataGraph(String assemblyId,
                                                  Map<String, Map<String, Object>> scenes) {
        Set<String> targets = resolveInitializerFromDataGraph(assemblyId, scenes, null);
        return targets.size() == 1 ? targets.iterator().next() : "";
    }

    /**
     * Build a temporary endpoint graph from persisted data edges and subsystem BoundaryPort
     * mappings. Inputs map outer->inner; outputs map inner->outer. This is compile-time routing,
     * not a second saved graph representation.
     */
    private static Set<String> resolveInitializerFromDataGraph(String assemblyId,
                                                               Map<String, Map<String, Object>> scenes,
                                                               String expectedDescriptorId) {
        Map<String, Map<String, Object>> nodeById = new LinkedHashMap<>();
        Map<String, String> nodeScene = new LinkedHashMap<>();
        for (Map.Entry<String, Map<String, Object>> sceneEntry : scenes.entrySet()) {
            for (Object item : listValue(sceneEntry.getValue().get("nodes"))) {
                if (!(item instanceof Map<?, ?> rawNode)) continue;
                Map<String, Object> node = copyMap(rawNode);
                String id = stringValue(first(node, "id", "nodeId"));
                if (id.isBlank()) continue;
                nodeById.put(id, node);
                nodeScene.put(id, sceneEntry.getKey());
            }
        }
        String descriptorId = expectedDescriptorId;
        if (descriptorId == null) {
            for (Map<String, Object> node : nodeById.values()) {
                if (assemblyId.equals(stringValue(node.get("physicalAssemblyId")))) {
                    if (descriptorId != null) throw new BusinessException("同一物理装配存在多个装配关系节点: " + assemblyId);
                    descriptorId = stringValue(first(node, "id", "nodeId"));
                }
            }
        }
        if (descriptorId == null || descriptorId.isBlank()) return Set.of();

        Map<String, List<String>> graph = new LinkedHashMap<>();
        for (Map.Entry<String, Map<String, Object>> sceneEntry : scenes.entrySet()) {
            Map<String, Object> scene = sceneEntry.getValue();
            List<?> edges = listValue(scene.get("dataEdges")).isEmpty()
                    ? listValue(scene.get("edges")) : listValue(scene.get("dataEdges"));
            for (Object item : edges) {
                if (!(item instanceof Map<?, ?> edge)) continue;
                String source = stringValue(first(edge, "sourceNodeId", "source"));
                String sourcePort = stringValue(first(edge, "sourcePort", "sourceHandle"));
                String target = stringValue(first(edge, "targetNodeId", "target"));
                String targetPort = stringValue(first(edge, "targetPort", "targetHandle"));
                if (!source.isBlank() && !sourcePort.isBlank() && !target.isBlank() && !targetPort.isBlank()) {
                    link(graph, endpoint(source, sourcePort), endpoint(target, targetPort));
                }
            }
            for (Object item : listValue(scene.get("nodes"))) {
                if (!(item instanceof Map<?, ?> wrapper) || !isWorkflowWrapper(wrapper)) continue;
                String wrapperId = stringValue(first(wrapper, "id", "nodeId"));
                String childId = stringValue(first(wrapper, "childSceneId"));
                Map<String, Object> child = scenes.get(childId);
                if (wrapperId.isBlank() || child == null) continue;
                List<Map<String, Object>> wrapperPorts = boundaryPorts(wrapper);
                if (wrapperPorts.isEmpty()) wrapperPorts = boundaryPorts(child);
                for (Map<String, Object> boundary : wrapperPorts) {
                    if (boundary.containsKey("kind") && !"data".equals(boundary.get("kind"))) continue;
                    String outerPort = stringValue(first(boundary, "id", "portId", "name"));
                    String direction = stringValue(first(boundary, "direction"));
                    if (outerPort.isBlank()) continue;
                    for (Map<String, Object> mapping : boundaryMappings(boundary)) {
                        String innerNode = stringValue(first(mapping, "childNodeId", "innerNodeId", "nodeId"));
                        String innerPort = stringValue(first(mapping, "childPortId", "innerPortId", "port", "portId"));
                        if (innerNode.isBlank() || innerPort.isBlank()
                                || !childId.equals(nodeScene.get(innerNode))) continue;
                        if ("input".equals(direction)) link(graph, endpoint(wrapperId, outerPort), endpoint(innerNode, innerPort));
                        else if ("output".equals(direction)) link(graph, endpoint(innerNode, innerPort), endpoint(wrapperId, outerPort));
                    }
                }
            }
        }

        ArrayDeque<String> queue = new ArrayDeque<>();
        Set<String> visited = new HashSet<>();
        queue.add(endpoint(descriptorId, "assembly_json"));
        Set<String> initializers = new LinkedHashSet<>();
        while (!queue.isEmpty()) {
            String current = queue.removeFirst();
            if (!visited.add(current)) continue;
            int split = current.indexOf('\u0000');
            if (split < 0) continue;
            String nodeId = current.substring(0, split);
            String port = current.substring(split + 1);
            Map<String, Object> node = nodeById.get(nodeId);
            if ("engine.stage.initialize-configuration".equals(stringValue(first(node, "componentId")))
                    && "assembly_json".equals(port)) initializers.add(nodeId);
            for (String next : graph.getOrDefault(current, List.of())) queue.addLast(next);
        }
        return initializers;
    }

    private static boolean isWorkflowWrapper(Map<?, ?> node) {
        String componentId = stringValue(first(node, "componentId"));
        String kind = stringValue(first(node, "nodeKind", "sceneNodeKind"));
        return !stringValue(first(node, "childSceneId")).isBlank()
                && !"project.subsystem.engine-assembly-relations".equals(componentId)
                && ("composite".equals(kind) || isWorkflowSubsystem(node, normalizedKind(node)));
    }

    private static List<Map<String, Object>> boundaryPorts(Map<?, ?> node) {
        Object value = node.get("boundaryPorts");
        List<Map<String, Object>> result = new ArrayList<>();
        if (value instanceof List<?> list) for (Object item : list)
            if (item instanceof Map<?, ?> map) result.add(copyMap(map));
        return result;
    }

    private static List<Map<String, Object>> boundaryMappings(Map<?, ?> boundary) {
        List<Map<String, Object>> result = new ArrayList<>();
        Object mappings = boundary.get("mappings");
        if (mappings instanceof List<?> list) for (Object item : list)
            if (item instanceof Map<?, ?> map) result.add(copyMap(map));
        if (result.isEmpty() && boundary.get("mapping") instanceof Map<?, ?> map) result.add(copyMap(map));
        return result;
    }

    private static String endpoint(String nodeId, String port) { return nodeId + "\u0000" + port; }
    private static void link(Map<String, List<String>> graph, String from, String to) {
        graph.computeIfAbsent(from, ignored -> new ArrayList<>()).add(to);
    }

    private static void collectSceneNodeIds(Map<String, Object> scene,
                                            Map<String, Map<String, Object>> scenes,
                                            Set<String> nodeIds,
                                            Set<String> visitedScenes) {
        String sceneId = stringValue(first(scene, "id", "sceneId"));
        if (!visitedScenes.add(sceneId)) return;
        for (Object item : listValue(scene.get("nodes"))) {
            if (!(item instanceof Map<?, ?> node)) continue;
            nodeIds.add(stringValue(first(node, "id", "nodeId")));
            String childId = stringValue(first(node, "childSceneId"));
            Map<String, Object> child = scenes.get(childId);
            if (child != null) collectSceneNodeIds(child, scenes, nodeIds, visitedScenes);
        }
    }

    /** 组装 engine.physical-scene.v1 结构（与既有 MATLAB 消费形状一致）。 */
    private static Map<String, Object> buildPhysicalScene(
            Map<String, Object> assembly,
            String assemblyId,
            Map<String, Map<String, Object>> nodesBySourceId,
            Map<String, Map<String, Object>> scenes,
            java.util.function.Function<String, MatlabComponentVO> componentLookup) {

        List<?> memberIds = listValue(assembly.get("memberNodeIds"));
        if (memberIds.isEmpty()) {
            throw new BusinessException("发动机装配没有成员部件: " + assemblyId);
        }
        if (memberIds.size() > MAX_NODES) {
            throw new BusinessException("发动机装配成员超过限制: " + assemblyId);
        }

        // 成员从工程场景展平（项目唯一节点 ID；场景为纯数据容器）
        Map<String, Map<String, Object>> membersById = new LinkedHashMap<>();
        if (scenes != null) {
            for (Map<String, Object> scene : scenes.values()) {
                for (Object item : listValue(scene.get("nodes"))) {
                    if (!(item instanceof Map<?, ?> node)) continue;
                    String id = stringValue(node.containsKey("id") ? node.get("id") : node.get("nodeId"));
                    if (!id.isBlank() && membersById.putIfAbsent(id, copyMap(node)) != null) {
                        throw new BusinessException("工程节点 ID 必须全局唯一: " + id);
                    }
                }
            }
        }

        List<Map<String, Object>> sceneNodes = new ArrayList<>();
        Set<String> assemblyMembers = new HashSet<>();
        Map<String, MatlabComponentVO> memberComponents = new LinkedHashMap<>();
        for (Object memberId : memberIds) {
            String nodeId = String.valueOf(memberId);
            if (!assemblyMembers.add(nodeId)) {
                throw new BusinessException("装配成员重复: " + assemblyId + "." + nodeId);
            }
            Map<String, Object> node = membersById.get(nodeId);
            if (node == null) {
                throw new BusinessException("装配成员节点不存在: " + assemblyId + "." + nodeId);
            }
            Map<String, Object> sceneNode = new LinkedHashMap<>();
            sceneNode.put("id", nodeId);
            sceneNode.put("componentId", node.get("componentId"));
            MatlabComponentVO component = validateMemberCapability(node, componentLookup, assemblyId, nodeId);
            if (component != null) memberComponents.put(nodeId, component);
            sceneNode.put("legacyName", component != null ? component.getLegacyName() : node.get("legacyName"));
            sceneNode.put("legacyOrder", node.get("legacyOrder"));
            sceneNode.put("values", copyValue(node.get("values")));
            Map<String, Object> parameters = component == null ? new LinkedHashMap<>()
                    : MatlabGraphSupport.asObject(copyValue(component.getAssemblyDefaults()));
            mergeMap(parameters, MatlabGraphSupport.asObject(node.get("assemblyDefaults")));
            sceneNode.put("assemblyDefaults", parameters);
            sceneNode.put("resources", copyValue(node.get("resources")));
            // 能力校验：发动机部件必须在可信目录中声明气路能力
            sceneNodes.add(sceneNode);
        }

        List<Map<String, Object>> sceneEdges = new ArrayList<>();
        List<?> flowRelations = listValue(assembly.get("flowRelations"));
        for (Object item : flowRelations) {
            if (!(item instanceof Map<?, ?> rawRelation)) continue;
            Map<String, Object> relation = copyMap(rawRelation);
            String sourceNodeId = stringValue(first(relation, "sourceNodeId"));
            String targetNodeId = stringValue(first(relation, "targetNodeId"));
            if (!assemblyMembers.contains(sourceNodeId) || !assemblyMembers.contains(targetNodeId)) {
                throw new BusinessException("气路关系引用不存在的成员: " + sourceNodeId + " -> " + targetNodeId);
            }
            validateFlowPort(memberComponents.get(sourceNodeId), stringValue(relation.get("sourcePortId")), "outputs");
            validateFlowPort(memberComponents.get(targetNodeId), stringValue(relation.get("targetPortId")), "inputs");
            Map<String, Object> edge = new LinkedHashMap<>();
            edge.put("id", safeId(stringValue(first(relation, "id"))));
            edge.put("source", sourceNodeId);
            edge.put("sourceHandle", stringValue(first(relation, "sourcePortId")));
            edge.put("target", targetNodeId);
            edge.put("targetHandle", stringValue(first(relation, "targetPortId")));
            edge.put("relation", "flow");
            edge.put("sourceNodeId", sourceNodeId);
            edge.put("sourcePort", stringValue(first(relation, "sourcePortId")));
            edge.put("targetNodeId", targetNodeId);
            edge.put("targetPort", stringValue(first(relation, "targetPortId")));
            Object streamRole = first(relation, "streamRole");
            if (streamRole != null) {
                Map<String, Object> data = new LinkedHashMap<>();
                data.put("streamRole", streamRole);
                edge.put("data", data);
                edge.put("streamRole", streamRole);
            }
            sceneEdges.add(edge);
        }

        List<Map<String, Object>> relationGroups = new ArrayList<>();
        relationGroups.addAll(convertGroups(listValue(assembly.get("shaftGroups")), "shaft", assemblyMembers, memberComponents));
        relationGroups.addAll(convertGroups(listValue(assembly.get("bleedGroups")), "bleed", assemblyMembers, memberComponents));
        // V1 MATLAB reads group membership from anchor + same-group edges.
        // This is a contract projection only; MATLAB still derives SHAFT/EXT.
        for (Map<String, Object> group : relationGroups) {
            List<?> members = listValue(group.get("memberNodeIds"));
            for (int index = 1; index < members.size(); index++) {
                Map<String, Object> edge = new LinkedHashMap<>();
                edge.put("id", safeId(stringValue(group.get("id"))) + "_member_" + index);
                edge.put("source", members.get(0));
                edge.put("target", members.get(index));
                edge.put("relation", group.get("relation"));
                edge.put("groupId", group.get("id"));
                sceneEdges.add(edge);
            }
        }

        Map<String, Object> sceneAssembly = new LinkedHashMap<>();
        sceneAssembly.put("schemaVersion", "engine.physical-scene.v1");
        sceneAssembly.put("sceneId", safeId(assemblyId));
        Map<String, Object> defaults = assembly.get("defaults") instanceof Map<?, ?> rawDefaults
                ? copyMap(rawDefaults) : new LinkedHashMap<>();
        sceneAssembly.put("assemblyDefaults", defaults);
        sceneAssembly.put("nodes", sceneNodes);
        sceneAssembly.put("edges", sceneEdges);
        sceneAssembly.put("relationGroups", relationGroups);
        if (assembly.containsKey("motorBindings")) {
            List<Map<String,Object>> bindings=new ArrayList<>();
            Set<String> motors=new HashSet<>();
            for(Object item:listValue(assembly.get("motorBindings"))) {
                Map<String,Object> binding=MatlabGraphSupport.asObject(item);
                String motor=stringValue(binding.get("motorNodeId"));
                String shaft=stringValue(binding.get("shaftGroupId"));
                MatlabComponentVO motorComponent=memberComponents.get(motor);
                if(!assemblyMembers.contains(motor)||!motors.add(motor)
                        ||(motorComponent!=null&&!"hpcgv pmsm".equals(motorComponent.getLegacyName()))
                        ||relationGroups.stream().noneMatch(group->shaft.equals(group.get("id"))&&"shaft".equals(group.get("relation"))))
                    throw new BusinessException("PMSM 电机与轴绑定无效: "+motor+" -> "+shaft);
                bindings.add(binding);
            }
            sceneAssembly.put("motorBindings",bindings);
        }
        return sceneAssembly;
    }

    private static List<Map<String, Object>> convertGroups(List<?> rawGroups, String relation,
            Set<String> assemblyMembers, Map<String, MatlabComponentVO> memberComponents) {
        List<Map<String, Object>> result = new ArrayList<>();
        Set<String> groupIds = new HashSet<>();
        for (Object item : rawGroups) {
            if (!(item instanceof Map<?, ?> rawGroup)) continue;
            Map<String, Object> group = copyMap(rawGroup);
            String id = stringValue(first(group, "id"));
            if (id.isBlank() || !groupIds.add(id)) throw new BusinessException("关系组 ID 为空或重复: " + relation);
                List<?> members = listValue(group.get("memberNodeIds"));
                for (Object member : members) {
                    String memberId = String.valueOf(member);
                    if (!assemblyMembers.contains(memberId)) throw new BusinessException("关系组引用装配外部件: " + memberId);
                    MatlabComponentVO component = memberComponents.get(memberId);
                    if (component != null) {
                        Map<String, Object> capability = MatlabGraphSupport.asObject(component.getPhysicalCapabilities().get(relation));
                        if (!Boolean.TRUE.equals(capability.get("joinable"))) {
                            throw new BusinessException("部件不支持 " + relation + " 关系: " + memberId);
                        }
                    }
                }
                Map<String, Object> converted = new LinkedHashMap<>();
                converted.put("id", safeId(id));
                converted.put("relation", relation);
                converted.put("name", stringValue(first(group, "name")));
                converted.put("order", group.get("order"));
                // Empty bleed rows are meaningful: INPUT_TURBO can declare NW
                // rows that contain no extracted-air components.
                converted.put("anchorNodeId", members.isEmpty() ? "" : members.get(0));
                converted.put("memberNodeIds", copyValue(members));
                converted.put("parameters", copyValue(group.get("parameters")));
                result.add(converted);
        }
        return result;
    }

    /** 校验成员部件在可信目录中声明了对应物理能力；普通组件不得加入装配。 */
    private static MatlabComponentVO validateMemberCapability(Map<String, Object> node,
                                                 java.util.function.Function<String, MatlabComponentVO> componentLookup,
                                                 String assemblyId, String nodeId) {
        if (componentLookup == null) return null;
        String componentId = stringValue(node.get("componentId"));
        MatlabComponentVO component;
        try {
            component = componentLookup.apply(componentId);
        } catch (Exception e) {
            throw new BusinessException("装配成员部件不在可信目录中: "
                    + assemblyId + "." + nodeId + " (" + componentId + ")");
        }
        if (component == null || component.getPhysicalCapabilities() == null
                || (!component.getPhysicalCapabilities().containsKey("flow")
                    && !Boolean.TRUE.equals(component.getPhysicalCapabilities().get("assemblyMember")))) {
            throw new BusinessException("装配成员部件缺少物理能力声明（普通组件不能加入发动机装配）: "
                    + assemblyId + "." + nodeId + " (" + componentId + ")");
        }
        return component;
    }

    private static void validateFlowPort(MatlabComponentVO component, String portId, String direction) {
        if (component == null) return;
        Map<String, Object> flow = MatlabGraphSupport.asObject(component.getPhysicalCapabilities().get("flow"));
        boolean exists = listValue(flow.get(direction)).stream().anyMatch(item ->
                item instanceof Map<?, ?> port && portId.equals(stringValue(port.get("id"))));
        if (!exists) throw new BusinessException("部件气路端口不存在: " + component.getId() + "." + portId);
    }

}
