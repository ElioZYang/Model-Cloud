package com.modelcloud.modules.business.service.impl;

import com.modelcloud.common.exception.BusinessException;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.Endpoint;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.MAX_EDGES;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.MAX_NODES;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.MAX_SCENE_DEPTH;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.append;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.asObject;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.boundaryDirection;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.boundaryPortAlias;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.boundaryPortId;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.boundaryPorts;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.copyMap;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.copyValue;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.first;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.firstMap;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.isWorkflowSubsystem;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.listValue;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.normalizedKind;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.originSegment;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.resolveChildSceneId;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.safeId;
import static com.modelcloud.modules.business.service.impl.MatlabGraphSupport.stringValue;

/**
 * 层级图编译器：从根 Scene 开始递归展开通用 subsystem，
 * 重写边界端口映射并生成稳定执行 ID、originPath 与 publicOutputs。
 *
 * 显式装配数据由 {@link EngineAssemblyCompiler} 注入；本类不解释发动机语义。
 */
final class MatlabHierarchyCompiler {
    private MatlabHierarchyCompiler() {
    }

    static Map<String, Object> expand(Map<String, Object> rawPayload) {
        return expand(rawPayload, null);
    }

    static Map<String, Object> expand(Map<String, Object> rawPayload,
                                      Object physicalAssemblies) {
        return expand(rawPayload, physicalAssemblies, null);
    }

    static Map<String, Object> expand(Map<String, Object> rawPayload,
                                      Object physicalAssemblies,
                                      java.util.function.Function<String, com.modelcloud.modules.business.model.dto.MatlabComponentVO> lookup) {
        if (rawPayload == null) {
            return null;
        }
        Object version = rawPayload.get("schemaVersion");
        if (!(version instanceof Number) || ((Number) version).intValue() < 2
                || !rawPayload.containsKey("scenes")) {
            // Version 1 is the old flat {nodes, edges} contract.  Keep it
            // byte-for-byte compatible with the existing validator.
            return rawPayload;
        }

        String rootSceneId = stringValue(rawPayload.get("rootSceneId"));
        if (rootSceneId.isBlank()) {
            throw new BusinessException("MATLAB层级图缺少rootSceneId");
        }
        Map<String, Map<String, Object>> scenes = readScenes(rawPayload.get("scenes"));
        if (!scenes.containsKey(rootSceneId)) {
            throw new BusinessException("MATLAB层级图引用不存在的根场景: " + rootSceneId);
        }

        // V3：装配成员是数据容器不产生 DAG 节点；从可见 assembly_json 数据路由识别 DP 组装节点
        java.util.Set<String> memberIds = new java.util.HashSet<>();
        java.util.Set<String> initializerIds = new java.util.HashSet<>();
        java.util.Set<String> assemblyDescriptorIds = new java.util.HashSet<>();
        if (physicalAssemblies instanceof Map<?, ?> assemblies) {
            for (Object value : assemblies.values()) {
                if (!(value instanceof Map<?, ?> assembly)) continue;
                for (Object memberId : listValue(assembly.get("memberNodeIds"))) {
                    memberIds.add(String.valueOf(memberId));
                }
                String assemblyId = stringValue(assembly.get("id"));
                if (assemblyId.isBlank()) assemblyId = stringValue(first(assembly, "assemblyId"));
                String bindingNodeId = assemblyId.isBlank() ? ""
                        : EngineAssemblyCompiler.resolveInitializerFromDataGraph(assemblyId, scenes);
                if (!bindingNodeId.isBlank()) initializerIds.add(bindingNodeId);
            }
        }
        for (Map<String, Object> scene : scenes.values()) {
            for (Object item : listValue(scene.get("nodes"))) {
                if (item instanceof Map<?, ?> node) {
                    String assemblyId = stringValue(first(node, "physicalAssemblyId"));
                    if (!assemblyId.isBlank()) {
                        assemblyDescriptorIds.add(stringValue(first(node, "id", "nodeId")));
                    }
                }
            }
        }
        ExpansionContext context = new ExpansionContext(scenes, memberIds, initializerIds, assemblyDescriptorIds);
        ExpandedScene root = context.expandScene(rootSceneId, "root", List.of(),
                new ArrayDeque<>());
        if (root.nodes.size() > MAX_NODES || root.edges.size() > MAX_EDGES) {
            throw new BusinessException("MATLAB层级图展开后规模超过限制");
        }
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("nodes", root.nodes);
        result.put("edges", root.edges);
        if (!root.publicOutputs.isEmpty()) {
            result.put("publicOutputs", root.publicOutputs);
        }
        result.put("schemaVersion", 2);
        // V3：装配数据由 EngineAssemblyCompiler 注入（不再依赖 Scene 类型）
        if (physicalAssemblies != null) {
            EngineAssemblyCompiler.applyAssemblies(root.nodes, physicalAssemblies, scenes, lookup);
        }
        return result;
    }

    private static Map<String, Map<String, Object>> readScenes(Object rawScenes) {
        Map<String, Map<String, Object>> scenes = new LinkedHashMap<>();
        if (rawScenes instanceof Map<?, ?> map) {
            for (Map.Entry<?, ?> entry : map.entrySet()) {
                if (!(entry.getValue() instanceof Map<?, ?> value)) {
                    throw new BusinessException("MATLAB层级图场景格式不正确: " + entry.getKey());
                }
                scenes.put(String.valueOf(entry.getKey()), copyMap(value));
            }
        } else if (rawScenes instanceof List<?> list) {
            for (Object item : list) {
                if (!(item instanceof Map<?, ?> value)) {
                    throw new BusinessException("MATLAB层级图场景格式不正确");
                }
                String id = stringValue(first(value, "id", "sceneId"));
                if (id.isBlank()) {
                    throw new BusinessException("MATLAB层级图场景ID不能为空");
                }
                if (scenes.put(id, copyMap(value)) != null) {
                    throw new BusinessException("MATLAB层级图场景ID重复: " + id);
                }
            }
        } else {
            throw new BusinessException("MATLAB层级图scenes必须是对象或数组");
        }
        return scenes;
    }

    private static final class ExpansionContext {
        private final Map<String, Map<String, Object>> scenes;
        private final java.util.Set<String> memberIds;
        private final java.util.Set<String> initializerIds;
        private final java.util.Set<String> assemblyDescriptorIds;
        private int nodeCount;
        private int edgeCount;

        private ExpansionContext(Map<String, Map<String, Object>> scenes,
                                 java.util.Set<String> memberIds,
                                 java.util.Set<String> initializerIds,
                                 java.util.Set<String> assemblyDescriptorIds) {
            this.scenes = scenes;
            this.memberIds = memberIds;
            this.initializerIds = initializerIds;
            this.assemblyDescriptorIds = assemblyDescriptorIds;
        }

        private ExpandedScene expandScene(
                String sceneId,
                String prefix,
                List<String> originPrefix,
                Deque<String> activeScenes) {
            if (activeScenes.size() >= MAX_SCENE_DEPTH) {
                throw new BusinessException("MATLAB层级图嵌套深度超过限制");
            }
            if (activeScenes.contains(sceneId)) {
                throw new BusinessException("MATLAB层级图存在递归场景引用: " + sceneId);
            }
            Map<String, Object> scene = scenes.get(sceneId);
            if (scene == null) {
                throw new BusinessException("MATLAB层级图引用不存在的场景: " + sceneId);
            }
            activeScenes.addLast(sceneId);
            try {
                ExpandedScene result = new ExpandedScene();
                List<?> rawNodes = listValue(scene.get("nodes"));
                for (Object item : rawNodes) {
                    if (!(item instanceof Map<?, ?> rawNode)) {
                        throw new BusinessException("MATLAB层级图节点格式不正确: " + sceneId);
                    }
                    String nodeId = stringValue(first(rawNode, "id", "nodeId"));
                    if (nodeId.isBlank()) {
                        throw new BusinessException("MATLAB层级图节点ID不能为空: " + sceneId);
                    }
                    String expandedId = prefix + "__" + safeId(nodeId);
                    String nodeKind = normalizedKind(rawNode);
                    List<String> origin = append(originPrefix, originSegment(rawNode, nodeId));
                    if (assemblyDescriptorIds.contains(nodeId)) {
                        // Descriptive assembly containers participate in the
                        // project DAG but are compiled into assembly_json and
                        // never become MATLAB execution nodes. Keep a virtual output
                        // endpoint so a generic subsystem can expose it through its
                        // ordinary BoundaryPort mapping.
                        Endpoint virtualOutput = new Endpoint(nodeId, "assembly_json");
                        result.outputEndpoints.put(nodeId + "\u0000assembly_json", virtualOutput);
                        result.directNodeEndpoints.put(nodeId, virtualOutput);
                        continue;
                    }
                    if (initializerIds.contains(nodeId)) {
                        // 装配初始化节点：DAG 节点，不递归装配容器子场景
                        Map<String, Object> node = copyMap(rawNode);
                        node.put("id", expandedId);
                        node.put("__originPath", origin);
                        node.put("__sourceNodeId", nodeId);
                        node.remove("childSceneId");
                        node.remove("subsystemKind");
                        node.remove("sceneId");
                        node.remove("subsystemRef");
                        node.remove("boundaryPorts");
                        result.addNode(node, expandedId, nodeId);
                        continue;
                    }
                    if (memberIds.contains(nodeId)) {
                        // 装配成员：纯数据容器，由 EngineAssemblyCompiler 展平
                        continue;
                    }
                    if (isWorkflowSubsystem(rawNode, nodeKind)) {
                        String childSceneId = resolveChildSceneId(rawNode);
                        ExpandedScene child = expandScene(childSceneId, expandedId,
                                origin, activeScenes);
                        result.merge(child);
                        result.addBoundaryMappings(rawNode, child, nodeId);
                        result.injectBoundaryValues(rawNode, child);
                    } else {
                        Map<String, Object> node = copyMap(rawNode);
                        node.put("id", expandedId);
                        node.put("__originPath", origin);
                        node.put("__sourceNodeId", nodeId);
                        result.addNode(node, expandedId, nodeId);
                    }
                }

                List<?> sceneEdges = scene.containsKey("dataEdges")
                        ? listValue(scene.get("dataEdges")) : listValue(scene.get("edges"));
                for (Object item : sceneEdges) {
                    if (!(item instanceof Map<?, ?> rawEdge)) {
                        throw new BusinessException("MATLAB层级图连线格式不正确: " + sceneId);
                    }
                    Map<String, Object> edge = copyMap(rawEdge);
                    String sourceNodeId = stringValue(first(rawEdge,
                            "sourceNodeId", "source"));
                    String sourcePort = stringValue(first(rawEdge,
                            "sourcePort", "sourceHandle"));
                    String targetNodeId = stringValue(first(rawEdge,
                            "targetNodeId", "target"));
                    String targetPort = stringValue(first(rawEdge,
                            "targetPort", "targetHandle"));
                    if (sourceNodeId.isBlank() || sourcePort.isBlank()
                            || targetNodeId.isBlank() || targetPort.isBlank()) {
                        throw new BusinessException("MATLAB层级图连线缺少端点: " + sceneId);
                    }
                    if (assemblyDescriptorIds.contains(sourceNodeId) || assemblyDescriptorIds.contains(targetNodeId)) {
                        // EngineAssemblyCompiler validates this compile-time
                        // dependency and injects its serialized value later.
                        continue;
                    }
                    Endpoint source = result.resolveOutputEndpoint(sourceNodeId, sourcePort);
                    List<Endpoint> targets = result.resolveInputEndpoints(targetNodeId, targetPort);
                    if (assemblyDescriptorIds.contains(source.nodeId())
                            || targets.stream().anyMatch(target -> assemblyDescriptorIds.contains(target.nodeId()))) {
                        // This dependency is validated against the original hierarchical
                        // data graph and its generated value is injected by EngineAssemblyCompiler.
                        continue;
                    }
                    for (int targetIndex = 0; targetIndex < targets.size(); targetIndex++) {
                        Endpoint target = targets.get(targetIndex);
                        Map<String, Object> expandedEdge = targetIndex == 0 ? edge : copyMap(edge);
                        expandedEdge.put("sourceNodeId", source.nodeId());
                        expandedEdge.put("sourcePort", source.port());
                        expandedEdge.put("targetNodeId", target.nodeId());
                        expandedEdge.put("targetPort", target.port());
                        expandedEdge.remove("source");
                        expandedEdge.remove("target");
                        expandedEdge.remove("sourceHandle");
                        expandedEdge.remove("targetHandle");
                        if (targetIndex > 0) expandedEdge.put("id", String.valueOf(edge.get("id")) + "__fanout_" + targetIndex);
                        result.addEdge(expandedEdge);
                    }
                }

                result.addSceneBoundaryMappings(scene, result, prefix);
                if (result.nodes.size() > MAX_NODES || result.edges.size() > MAX_EDGES) {
                    throw new BusinessException("MATLAB层级图展开后规模超过限制");
                }
                if (originPrefix.isEmpty()) {
                    result.publicOutputs.addAll(result.sceneOutputs);
                    result.addRootSubsystemOutputs(rawNodes);
                }
                return result;
            } finally {
                activeScenes.removeLast();
            }
        }

    }

    private static final class ExpandedScene {
        private final List<Map<String, Object>> nodes = new ArrayList<>();
        private final List<Map<String, Object>> edges = new ArrayList<>();
        private final Map<String, List<Endpoint>> inputEndpoints = new LinkedHashMap<>();
        private final Map<String, Endpoint> outputEndpoints = new LinkedHashMap<>();
        private final List<Map<String, Object>> sceneOutputs = new ArrayList<>();
        private final List<Map<String, Object>> publicOutputs = new ArrayList<>();
        private final Map<String, Endpoint> directNodeEndpoints = new HashMap<>();

        private void addNode(Map<String, Object> node, String id, String localId) {
            nodes.add(node);
            directNodeEndpoints.put(localId, new Endpoint(id, ""));
        }

        private void addEdge(Map<String, Object> edge) {
            edges.add(edge);
        }

        private void merge(ExpandedScene child) {
            nodes.addAll(child.nodes);
            edges.addAll(child.edges);
            inputEndpoints.putAll(child.inputEndpoints);
            outputEndpoints.putAll(child.outputEndpoints);
            directNodeEndpoints.putAll(child.directNodeEndpoints);
        }

        private Endpoint resolveOutputEndpoint(String nodeId, String port) {
            Endpoint endpoint = outputEndpoints.get(nodeId + "\u0000" + port);
            if (endpoint != null) return endpoint;
            endpoint = directNodeEndpoints.get(nodeId);
            if (endpoint != null) return new Endpoint(endpoint.nodeId(), port);
            throw new BusinessException("层级图端点引用不存在: " + nodeId + "." + port);
        }

        private List<Endpoint> resolveInputEndpoints(String nodeId, String port) {
            List<Endpoint> endpoints = inputEndpoints.get(nodeId + "\u0000" + port);
            if (endpoints != null && !endpoints.isEmpty()) return endpoints;
            Endpoint direct = directNodeEndpoints.get(nodeId);
            if (direct != null) return List.of(new Endpoint(direct.nodeId(), port));
            throw new BusinessException("层级图端点引用不存在: " + nodeId + "." + port);
        }

        private void addBoundaryMappings(Map<?, ?> wrapper, ExpandedScene child,
                                         String expandedId) {
            String wrapperId = stringValue(first(wrapper, "id", "nodeId"));
            if (boundaryPorts(wrapper).isEmpty()) {
                child.outputEndpoints.forEach((key, endpoint) -> {
                    if (!key.contains("\u0000")) {
                        outputEndpoints.put(wrapperId + "\u0000" + key, endpoint);
                    }
                });
                child.inputEndpoints.forEach((key, endpoint) -> {
                    if (!key.contains("\u0000")) {
                        inputEndpoints.put(wrapperId + "\u0000" + key, endpoint);
                    }
                });
            }
            for (Map<String, Object> boundary : boundaryPorts(wrapper)) {
                if (boundary.containsKey("kind") && !"data".equals(boundary.get("kind"))) continue;
                String outer = boundaryPortId(boundary);
                String direction = boundaryDirection(boundary);
                List<Map<String, Object>> mappings = boundaryMappings(boundary);
                if (outer.isBlank() || mappings.isEmpty()) continue;
                List<Endpoint> endpoints = new ArrayList<>();
                for (Map<String, Object> mapping : mappings) {
                    String inner = stringValue(first(mapping, "childPortId", "port", "portId", "targetPort", "sourcePort"));
                    String innerNode = stringValue(first(mapping, "childNodeId", "innerNodeId", "nodeId", "targetNodeId", "sourceNodeId"));
                    if (inner.isBlank()) continue;
                    List<Endpoint> resolved = resolveMappedEndpoints(child, direction, innerNode, inner);
                    if (resolved.isEmpty()) {
                        String alias = boundaryPortAlias(inner);
                        if (alias.equals(inner)) alias = boundaryPortAlias(outer);
                        if (!alias.equals(inner) || !alias.equals(outer)) {
                            resolved = resolveMappedEndpoints(child, direction, innerNode, alias);
                        }
                    }
                    for (Endpoint endpoint : resolved) if (!endpoints.contains(endpoint)) endpoints.add(endpoint);
                }
                if (endpoints.isEmpty()) {
                    throw new BusinessException("子系统边界端口映射不存在: " + outer);
                }
                if ("output".equals(direction)) {
                    outputEndpoints.put(wrapperId + "\u0000" + outer, endpoints.get(0));
                } else {
                    inputEndpoints.put(wrapperId + "\u0000" + outer, endpoints);
                }
            }
        }

        private Endpoint resolveMappedEndpoint(ExpandedScene child, String direction,
                                               String nodeId, String port) {
            List<Endpoint> endpoints = resolveMappedEndpoints(child, direction, nodeId, port);
            return endpoints.isEmpty() ? null : endpoints.get(0);
        }

        private List<Endpoint> resolveMappedEndpoints(ExpandedScene child, String direction,
                                                      String nodeId, String port) {
            String key = (nodeId.isBlank() ? "" : nodeId + "\u0000") + port;
            if ("output".equals(direction)) {
                Endpoint endpoint = child.outputEndpoints.get(key);
                if (endpoint == null && nodeId.isBlank()) endpoint = child.outputEndpoints.get(port);
                if (endpoint == null && !nodeId.isBlank()) {
                    Endpoint direct = child.directNodeEndpoints.get(nodeId);
                    if (direct != null) endpoint = new Endpoint(direct.nodeId(), port);
                }
                return endpoint == null ? List.of() : List.of(endpoint);
            }
            List<Endpoint> endpoints = child.inputEndpoints.get(key);
            if (endpoints == null && nodeId.isBlank()) endpoints = child.inputEndpoints.get(port);
            if (endpoints != null && !endpoints.isEmpty()) return endpoints;
            if (!nodeId.isBlank()) {
                Endpoint direct = child.directNodeEndpoints.get(nodeId);
                if (direct != null) return List.of(new Endpoint(direct.nodeId(), port));
            }
            return List.of();
        }

        private List<Map<String, Object>> boundaryMappings(Map<?, ?> boundary) {
            List<Map<String, Object>> result = new ArrayList<>();
            Object raw = boundary.get("mappings");
            if (raw instanceof List<?> list) {
                for (Object item : list) if (item instanceof Map<?, ?> map) result.add(copyMap(map));
            }
            if (result.isEmpty()) {
                Object mapping = boundary.get("mapping");
                if (mapping instanceof Map<?, ?> map) result.add(copyMap(map));
                else if (boundary.containsKey("innerNodeId") || boundary.containsKey("childNodeId")) result.add(copyMap(boundary));
            }
            return result;
        }

        private void injectBoundaryValues(Map<?, ?> wrapper, ExpandedScene child) {
            Map<?, ?> values = firstMap(wrapper, "values");
            if (values == null) values = firstMap(wrapper, "parameters");
            if (values == null) return;
            for (Map<String, Object> boundary : boundaryPorts(wrapper)) {
                if (boundary.containsKey("kind") && !"data".equals(boundary.get("kind"))) continue;
                String outer = boundaryPortId(boundary);
                String name = stringValue(boundary.get("name"));
                Object value = values.containsKey(outer) ? values.get(outer)
                        : (values.containsKey(name) ? values.get(name) : null);
                if (value == null || (outer.isBlank() && name.isBlank())) continue;
                for (Map<String, Object> mapping : boundaryMappings(boundary)) {
                    String innerNode = stringValue(first(mapping, "innerNodeId", "childNodeId", "nodeId", "targetNodeId", "sourceNodeId"));
                    String innerPort = stringValue(first(mapping, "innerPortId", "childPortId", "port", "portId", "targetPort", "sourcePort"));
                    if (innerPort.isBlank()) continue;
                    List<Endpoint> endpoints = new ArrayList<>();
                    endpoints.addAll(resolveMappedEndpoints(child, "input", innerNode, innerPort));
                    for (Endpoint endpoint : endpoints) for (Map<String, Object> node : nodes) {
                        if (!endpoint.nodeId().equals(String.valueOf(node.get("id")))) continue;
                        Map<String, Object> nodeValues = asObject(node.get("values"));
                        nodeValues.put(endpoint.port(), copyValue(value));
                        node.put("values", nodeValues);
                        break;
                    }
                }
            }
        }

        private void addSceneBoundaryMappings(Map<?, ?> scene, ExpandedScene self,
                                               String prefix) {
            for (Map<String, Object> boundary : boundaryPorts(scene)) {
                if (boundary.containsKey("kind") && !"data".equals(boundary.get("kind"))) continue;
                String outer = boundaryPortId(boundary);
                if (outer.isBlank()) continue;
                String direction = boundaryDirection(boundary);
                List<Endpoint> mappedEndpoints = new ArrayList<>();
                for (Map<String, Object> mapping : boundaryMappings(boundary)) {
                    String nodeId = stringValue(first(mapping, "innerNodeId", "childNodeId", "nodeId", "targetNodeId", "sourceNodeId"));
                    String port = stringValue(first(mapping, "innerPortId", "childPortId", "port", "portId", "targetPort", "sourcePort"));
                    if (port.isBlank()) continue;
                    for (Endpoint endpoint : resolveMappedEndpoints(self, direction, nodeId, port))
                        if (!mappedEndpoints.contains(endpoint)) mappedEndpoints.add(endpoint);
                }
                if (mappedEndpoints.isEmpty()) continue;
                Endpoint endpoint = mappedEndpoints.get(0);
                if ("output".equals(direction)) {
                    outputEndpoints.put(outer, endpoint);
                    sceneOutputs.add(new LinkedHashMap<>(Map.of(
                            "name", outer,
                            "sourceNodeId", endpoint.nodeId(),
                            "sourcePort", endpoint.port(),
                            "originPath", originFor(endpoint.nodeId()))));
                } else {
                    inputEndpoints.put(outer, mappedEndpoints);
                }
            }
        }

        private List<String> originFor(String nodeId) {
            for (Map<String, Object> node : nodes) {
                if (nodeId.equals(String.valueOf(node.get("id")))) {
                    Object origin = node.get("__originPath");
                    if (origin instanceof List<?> list) {
                        return list.stream().map(String::valueOf).toList();
                    }
                }
            }
            return List.of(nodeId);
        }

        private void addRootSubsystemOutputs(List<?> rawNodes) {
            Set<String> names = new HashSet<>();
            for (Map<String, Object> output : publicOutputs) {
                names.add(String.valueOf(output.get("name")));
            }
            for (Object item : rawNodes) {
                if (!(item instanceof Map<?, ?> wrapper)) continue;
                String kind = normalizedKind(wrapper);
                if (!isWorkflowSubsystem(wrapper, kind)) continue;
                String wrapperId = stringValue(first(wrapper, "id", "nodeId"));
                if (wrapperId.isBlank()) continue;
                boolean emitted = false;
                for (Map<String, Object> boundary : boundaryPorts(wrapper)) {
                    if (!"output".equals(boundaryDirection(boundary))) continue;
                    String port = boundaryPortId(boundary);
                    Endpoint endpoint = outputEndpoints.get(wrapperId + "\u0000" + port);
                    if (endpoint == null || port.isBlank()) continue;
                    emitted |= addRootPublicOutput(names, wrapperId, port,
                            stringValue(boundary.get("name")), endpoint);
                }
                String prefix = wrapperId + "\u0000";
                outputEndpoints.forEach((key, endpoint) -> {
                    if (!key.startsWith(prefix)) return;
                    String port = key.substring(prefix.length());
                    if (!port.isBlank()) addRootPublicOutput(names, wrapperId, port, port, endpoint);
                });
                if (!emitted && outputEndpoints.containsKey(wrapperId)) {
                    Endpoint endpoint = outputEndpoints.get(wrapperId);
                    for (String port : declaredOutputNames(wrapper)) {
                        addRootPublicOutput(names, wrapperId, port, port,
                                new Endpoint(endpoint.nodeId(), port));
                    }
                }
            }
        }

        private boolean addRootPublicOutput(Set<String> names, String wrapperId,
                                             String port, String displayName, Endpoint endpoint) {
            String name = wrapperId + "." + port;
            if (!names.add(name)) return false;
            publicOutputs.add(new LinkedHashMap<>(Map.of(
                    "name", name,
                    "displayName", displayName.isBlank() ? name : displayName,
                    "sourceNodeId", endpoint.nodeId(),
                    "sourcePort", endpoint.port(),
                    "originPath", originFor(endpoint.nodeId()))));
            return true;
        }

        private List<String> declaredOutputNames(Map<?, ?> wrapper) {
            Object raw = first(wrapper, "outputs", "outputPorts");
            List<String> names = new ArrayList<>();
            if (raw instanceof List<?> list) {
                for (Object item : list) {
                    if (item instanceof Map<?, ?> port) {
                        String name = stringValue(first(port, "name", "id", "portId"));
                        if (!name.isBlank()) names.add(name);
                    } else if (item != null) {
                        names.add(String.valueOf(item));
                    }
                }
            }
            return names;
        }
    }
}
