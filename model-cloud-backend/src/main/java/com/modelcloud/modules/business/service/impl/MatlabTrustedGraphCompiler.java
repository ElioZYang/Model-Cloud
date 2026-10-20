package com.modelcloud.modules.business.service.impl;

import cn.hutool.core.util.StrUtil;
import com.alibaba.fastjson2.JSON;
import com.modelcloud.common.exception.BusinessException;
import com.modelcloud.modules.business.model.dto.MatlabComponentVO;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;

/**
 * 可信图编译器：展开后的层级图在此完成受信校验与定型——
 * 组件 ID 必须来自受信目录、节点字段白名单、端口存在性与类型兼容、
 * 一个输入只能连接一个来源、必需输入检查、拓扑排序与环拒绝。
 *
 * 不校验气路守恒、轴功平衡等物理合理性（由 MATLAB 原模型在运行时自然报告）。
 * 从 {@code ModelDeployServiceImpl} 拆出，目录访问经由注入的查找函数。
 */
final class MatlabTrustedGraphCompiler {

    /** 组件目录查找（受信边界：组件定义只允许来自服务端目录）。 */
    @FunctionalInterface
    interface MatlabComponentLookup {
        MatlabComponentVO resolve(String componentId);
    }

    private final MatlabComponentLookup lookup;

    MatlabTrustedGraphCompiler(MatlabComponentLookup lookup) {
        this.lookup = lookup;
    }

    Map<String, Object> buildTrustedGraph(Map<String, Object> rawPayload) {
        if (rawPayload == null) {
            throw new BusinessException("MATLAB执行参数不能为空");
        }
        PmsmProgramCompiler.Prepared programs = PmsmProgramCompiler.prepare(rawPayload, lookup::resolve);
        rawPayload = programs.payload();
        rawPayload = MatlabHierarchyCompiler.expand(rawPayload, rawPayload.get("physicalAssemblies"), lookup::resolve);
        Object nodesObject = rawPayload.get("nodes");
        if (!(nodesObject instanceof List<?> rawNodes) || rawNodes.isEmpty()) {
            throw new BusinessException("MATLAB工作流至少需要一个节点");
        }
        Object edgesObject = rawPayload.getOrDefault("edges", List.of());
        if (!(edgesObject instanceof List<?> rawEdges)) {
            throw new BusinessException("MATLAB工作流edges必须是数组");
        }

        Map<String, MatlabComponentVO> nodeComponents = new LinkedHashMap<>();
        Map<String, Map<String, Object>> trustedNodesById = new LinkedHashMap<>();
        Map<String, Integer> nodeIndexes = new HashMap<>();

        for (int index = 0; index < rawNodes.size(); index++) {
            Object rawNodeObject = rawNodes.get(index);
            if (!(rawNodeObject instanceof Map<?, ?> rawNode)) {
                throw new BusinessException("MATLAB工作流节点格式不正确");
            }
            Set<String> allowedNodeFields = Set.of(
                    "id", "componentId", "values", "resources", "nodeKind", "executionKind",
                    "functionName", "parameters", "legacyName", "legacyOrder", "assemblyDefaults",
                    "busConfig", "selectorConfig", "phase", "__originPath", "__sourceNodeId");
            for (Object rawField : rawNode.keySet()) {
                if (!allowedNodeFields.contains(String.valueOf(rawField))) {
                    throw new BusinessException("MATLAB节点包含不允许的字段: " + rawField);
                }
            }
            String nodeId = rawNode.get("id") == null ? "" : String.valueOf(rawNode.get("id")).trim();
            if (nodeId.isEmpty()) {
                throw new BusinessException("MATLAB工作流节点ID不能为空");
            }
            if (trustedNodesById.containsKey(nodeId)) {
                throw new BusinessException("MATLAB工作流节点ID重复: " + nodeId);
            }

            String componentId = rawNode.get("componentId") == null
                    ? "" : String.valueOf(rawNode.get("componentId"));
            String executionKind = String.valueOf(mapValue(rawNode, "executionKind", "matlabFunction"));
            boolean builtinBus = "busCreator".equals(executionKind) || "busSelector".equals(executionKind)
                    || "builtin.bus.creator".equals(componentId) || "builtin.bus.selector".equals(componentId);
            if (builtinBus) {
                executionKind = "busSelector".equals(executionKind) || "builtin.bus.selector".equals(componentId)
                        ? "busSelector" : "busCreator";
                componentId = "busCreator".equals(executionKind)
                        ? "builtin.bus.creator" : "builtin.bus.selector";
            }
            MatlabComponentVO component = builtinBus
                    ? buildBuiltinBusComponent(nodeId, executionKind, rawNode)
                    : lookup.resolve(componentId);
            Map<String, Object> trustedValues = builtinBus ? Map.of() : validateMatlabValues(
                    rawNode.get("values"), component);
            Map<String, Object> trustedResources = builtinBus ? Map.of() : validateMatlabResources(
                    rawNode.get("resources"), component);
            Map<String, Object> trustedNode = new LinkedHashMap<>();
            trustedNode.put("id", nodeId);
            trustedNode.put("componentId", component.getId());
            trustedNode.put("executionKind", executionKind);
            trustedNode.put("nodeKind", executionKind);
            trustedNode.put("functionName", component.getFunctionName() == null ? "" : component.getFunctionName());
            trustedNode.put("sourceRelativePath", component.getSourceRelativePath());
            trustedNode.put("componentKind", component.getComponentKind());
            trustedNode.put("values", trustedValues);
            trustedNode.put("resources", trustedResources);
            trustedNode.put("inputs", buildTrustedPortDefinitions(component.getInputs()));
            trustedNode.put("outputs", buildTrustedPortDefinitions(component.getOutputs()));
            Object originPath = rawNode.get("__originPath");
            if (originPath instanceof List<?> path) {
                trustedNode.put("originPath", path.stream().map(String::valueOf).toList());
            }
            if (rawNode.get("__sourceNodeId") != null) {
                trustedNode.put("sourceNodeId", String.valueOf(rawNode.get("__sourceNodeId")));
            }
            if (rawNode.get("phase") != null) {
                trustedNode.put("phase", String.valueOf(rawNode.get("phase")));
            }
            if (!builtinBus) {
                trustedNode.put("invocation", JSON.parseObject(
                        JSON.toJSONString(component.getInvocation()), Map.class));
            }

            if (builtinBus) {
                if ("busCreator".equals(executionKind)) {
                    trustedNode.put("busConfig", sanitizeBusConfig(rawNode.get("busConfig"), nodeId));
                } else {
                    trustedNode.put("selectorConfig", sanitizeSelectorConfig(rawNode.get("selectorConfig"), nodeId));
                }
            }

            trustedNodesById.put(nodeId, trustedNode);
            nodeComponents.put(nodeId, component);
            nodeIndexes.put(nodeId, index);
        }

        Map<String, Integer> indegrees = new HashMap<>();
        Map<String, List<String>> adjacency = new HashMap<>();
        for (String nodeId : trustedNodesById.keySet()) {
            indegrees.put(nodeId, 0);
            adjacency.put(nodeId, new ArrayList<>());
        }

        List<Map<String, Object>> trustedEdges = new ArrayList<>();
        Set<String> connectedTargets = new HashSet<>();
        Set<String> edgeIdentities = new HashSet<>();
        for (int index = 0; index < rawEdges.size(); index++) {
            Object rawEdgeObject = rawEdges.get(index);
            if (!(rawEdgeObject instanceof Map<?, ?> rawEdge)) {
                throw new BusinessException("MATLAB工作流连线格式不正确");
            }
            String sourceNodeId = graphString(rawEdge, "sourceNodeId");
            String sourcePortName = graphString(rawEdge, "sourcePort");
            String targetNodeId = graphString(rawEdge, "targetNodeId");
            String targetPortName = graphString(rawEdge, "targetPort");
            if (!trustedNodesById.containsKey(sourceNodeId)) {
                throw new BusinessException("PMSM工作流连线引用不存在的源节点: " + sourceNodeId);
            }
            if (!trustedNodesById.containsKey(targetNodeId)) {
                throw new BusinessException("PMSM工作流连线引用不存在的目标节点: " + targetNodeId);
            }

            MatlabComponentVO.PortVO sourcePort = findMatlabPort(
                    nodeComponents.get(sourceNodeId).getOutputs(), sourcePortName,
                    "输出", sourceNodeId);
            MatlabComponentVO.PortVO targetPort = findMatlabPort(
                    nodeComponents.get(targetNodeId).getInputs(), targetPortName,
                    "输入", targetNodeId);
            if (!matlabPortTypesCompatible(sourcePort.getType(), targetPort.getType())) {
                throw new BusinessException("PMSM工作流端口类型不兼容: "
                        + sourceNodeId + "." + sourcePortName + "(" + sourcePort.getType() + ") -> "
                        + targetNodeId + "." + targetPortName + "(" + targetPort.getType() + ")");
            }

            // 新建匿名 Creator 的字段在连接前类型为 unknown。类型只能继承
            // 可信源端口，不接受前端伪造的类型字符串。
            if ("unknown".equals(targetPort.getType())) {
                targetPort.setType(sourcePort.getType());
                targetPort.setShape(sourcePort.getShape());
                targetPort.setUnit(sourcePort.getUnit());
                Map<String, Object> trustedTarget = trustedNodesById.get(targetNodeId);
                trustedTarget.put("inputs", buildTrustedPortDefinitions(nodeComponents.get(targetNodeId).getInputs()));
                if ("busCreator".equals(trustedTarget.get("executionKind"))
                        && trustedTarget.get("busConfig") instanceof Map<?, ?> config
                        && config.get("fields") instanceof List<?> fields) {
                    for (Object item : fields) {
                        if (item instanceof Map<?, ?> field
                                && targetPortName.equals(String.valueOf(field.get("inputPortId")))) {
                            @SuppressWarnings("unchecked")
                            Map<String, Object> mutableField = (Map<String, Object>) field;
                            mutableField.put("dataType", sourcePort.getType());
                            if (sourcePort.getShape() != null && !sourcePort.getShape().isEmpty()) {
                                mutableField.put("shape", sourcePort.getShape());
                            }
                            if (StrUtil.isNotBlank(sourcePort.getUnit())) {
                                mutableField.put("unit", sourcePort.getUnit());
                            }
                            break;
                        }
                    }
                }
            }

            String targetIdentity = targetNodeId + "\u0000" + targetPortName;
            if (!connectedTargets.add(targetIdentity)) {
                throw new BusinessException("PMSM工作流目标输入端口只能连接一次: "
                        + targetNodeId + "." + targetPortName);
            }
            String edgeIdentity = sourceNodeId + "\u0000" + sourcePortName + "\u0000"
                    + targetNodeId + "\u0000" + targetPortName;
            if (!edgeIdentities.add(edgeIdentity)) {
                throw new BusinessException("PMSM工作流存在重复连线");
            }

            Map<String, Object> trustedEdge = new LinkedHashMap<>();
            Object edgeId = rawEdge.get("id");
            trustedEdge.put("id", edgeId == null || String.valueOf(edgeId).isBlank()
                    ? "edge" + (index + 1) : String.valueOf(edgeId));
            trustedEdge.put("sourceNodeId", sourceNodeId);
            trustedEdge.put("sourcePort", sourcePortName);
            trustedEdge.put("targetNodeId", targetNodeId);
            trustedEdge.put("targetPort", targetPortName);
            trustedEdge.put("dataType", sourcePort.getType());
            trustedEdges.add(trustedEdge);

            adjacency.get(sourceNodeId).add(targetNodeId);
            indegrees.put(targetNodeId, indegrees.get(targetNodeId) + 1);
        }

        for (Map.Entry<String, MatlabComponentVO> entry : nodeComponents.entrySet()) {
            String nodeId = entry.getKey();
            List<MatlabComponentVO.PortVO> inputs = entry.getValue().getInputs();
            @SuppressWarnings("unchecked")
            Map<String, Object> nodeValues = (Map<String, Object>)
                    trustedNodesById.get(nodeId).get("values");
            if (inputs == null) {
                continue;
            }
            for (MatlabComponentVO.PortVO input : inputs) {
                Map<String, Object> trustedNode = trustedNodesById.get(nodeId);
                boolean hasBusDefault = false;
                if ("busCreator".equals(trustedNode.get("executionKind"))
                        && trustedNode.get("busConfig") instanceof Map<?, ?> busConfig
                        && busConfig.get("fields") instanceof List<?> fields) {
                    hasBusDefault = fields.stream().anyMatch(item -> item instanceof Map<?, ?> field
                            && input.getName().equals(String.valueOf(field.get("inputPortId")))
                            && field.containsKey("defaultValue") && field.get("defaultValue") != null);
                }
                if (Boolean.TRUE.equals(input.getRequired())
                        && !connectedTargets.contains(nodeId + "\u0000" + input.getName())
                        && !nodeValues.containsKey(input.getName()) && !hasBusDefault) {
                    throw new BusinessException("MATLAB工作流缺少必需输入: "
                            + nodeId + "." + input.getName());
                }
            }
        }

        java.util.PriorityQueue<String> ready = new java.util.PriorityQueue<>(
                java.util.Comparator.comparingInt(nodeIndexes::get));
        indegrees.forEach((nodeId, indegree) -> {
            if (indegree == 0) {
                ready.add(nodeId);
            }
        });
        List<String> executionOrder = new ArrayList<>();
        while (!ready.isEmpty()) {
            String nodeId = ready.remove();
            executionOrder.add(nodeId);
            for (String targetNodeId : adjacency.get(nodeId)) {
                int nextIndegree = indegrees.get(targetNodeId) - 1;
                indegrees.put(targetNodeId, nextIndegree);
                if (nextIndegree == 0) {
                    ready.add(targetNodeId);
                }
            }
        }
        if (executionOrder.size() != trustedNodesById.size()) {
            throw new BusinessException("MATLAB工作流不能包含环路");
        }

        List<Map<String, Object>> orderedNodes = executionOrder.stream()
                .map(trustedNodesById::get)
                .toList();
        Map<String, Object> trustedPayload = new LinkedHashMap<>();
        trustedPayload.put("schemaVersion", "matlab.execution.v1");
        trustedPayload.put("nodes", orderedNodes);
        trustedPayload.put("edges", trustedEdges);
        trustedPayload.put("executionOrder", executionOrder);
        if (!programs.programs().isEmpty()) trustedPayload.put("modelPrograms", programs.programs());
        if (rawPayload.get("publicOutputs") instanceof List<?> publicOutputs) {
            trustedPayload.put("publicOutputs", publicOutputs);
        }
        return trustedPayload;
    }

    private static Object mapValue(Map<?, ?> map, String key, Object fallback) {
        return map.containsKey(key) ? map.get(key) : fallback;
    }

    private static String graphString(Map<?, ?> value, String fieldName) {
        Object rawValue = value.get(fieldName);
        String result = rawValue == null ? "" : String.valueOf(rawValue).trim();
        if (result.isEmpty()) {
            throw new BusinessException("MATLAB工作流连线缺少字段: " + fieldName);
        }
        return result;
    }

    private static boolean matlabIdentifier(String value) {
        return value != null && value.matches("^[A-Za-z][A-Za-z0-9_]*$");
    }

    private static boolean matlabFieldPath(String value) {
        return value != null && value.matches("^[A-Za-z][A-Za-z0-9_]*(\\.[A-Za-z][A-Za-z0-9_]*)*$");
    }

    private static boolean matlabBusType(String value) {
        return "unknown".equals(value) || matlabIdentifier(value) || "number".equals(value) || "string".equals(value)
                || "boolean".equals(value) || "array".equals(value) || "struct".equals(value)
                || "bus".equals(value) || isNamedMatlabBusType(value);
    }

    /** Named buses use a dotted namespace (for example engine.dp or
     * pmsm.design_result).  Keep the generic bus contract backwards
     * compatible while allowing independent component libraries to register
     * their own schemas. */
    private static boolean isNamedMatlabBusType(String value) {
        return value != null && value.matches("^[A-Za-z][A-Za-z0-9_]*(\\.[A-Za-z][A-Za-z0-9_]*)+$");
    }

    private static boolean matlabPortTypesCompatible(String sourceType, String targetType) {
        if (StrUtil.isBlank(sourceType) || StrUtil.isBlank(targetType)) return false;
        if ("unknown".equals(targetType)) return true;
        if (sourceType.equals(targetType)) return true;
        // MATLAB accepts a scalar where a numeric vector input is declared;
        // this keeps pre-vector saved workspaces and one-shaft templates valid.
        if ("array".equals(targetType) && "number".equals(sourceType)) return true;
        // A generic bus input accepts a named/anonymous bus; ordinary scalar and
        // structure ports still require an exact contract match.
        return "bus".equals(targetType) && ("bus".equals(sourceType) || isNamedMatlabBusType(sourceType));
    }

    private static Map<String, Object> sanitizeBusConfig(Object rawConfig, String nodeId) {
        if (!(rawConfig instanceof Map<?, ?> raw)) {
            throw new BusinessException("Bus Creator缺少配置: " + nodeId);
        }
        String schemaMode = String.valueOf(mapValue(raw, "schemaMode", "anonymous"));
        if (!"anonymous".equals(schemaMode) && !"named".equals(schemaMode)) {
            throw new BusinessException("Bus Creator结构模式不合法: " + nodeId);
        }
        String schemaRef = raw.get("schemaRef") == null ? "" : String.valueOf(raw.get("schemaRef")).trim();
        if ("named".equals(schemaMode) && !matlabFieldPath(schemaRef)) {
            throw new BusinessException("Bus Creator命名结构标识不合法: " + nodeId);
        }
        Object fieldsObject = raw.get("fields");
        if (!(fieldsObject instanceof List<?> fields) || fields.isEmpty()) {
            throw new BusinessException("Bus Creator至少需要一个字段: " + nodeId);
        }
        List<Map<String, Object>> sanitizedFields = new ArrayList<>();
        Set<String> ids = new HashSet<>();
        Set<String> paths = new HashSet<>();
        Set<String> ports = new HashSet<>();
        for (Object item : fields) {
            if (!(item instanceof Map<?, ?> field)) {
                throw new BusinessException("Bus Creator字段格式不合法: " + nodeId);
            }
            String id = String.valueOf(mapValue(field, "id", "")).trim();
            String path = String.valueOf(mapValue(field, "path", "")).trim();
            String type = String.valueOf(mapValue(field, "dataType", "")).trim();
            String inputPortId = String.valueOf(mapValue(field, "inputPortId", id)).trim();
            if (!matlabIdentifier(id) || !matlabFieldPath(path) || !matlabBusType(type)
                    || !matlabIdentifier(inputPortId) || !ids.add(id) || !paths.add(path)
                    || !ports.add(inputPortId)) {
                throw new BusinessException("Bus Creator字段定义不合法: " + nodeId + "." + path);
            }
            Map<String, Object> value = new LinkedHashMap<>();
            value.put("id", id);
            value.put("path", path);
            value.put("label", field.get("label") == null ? path : String.valueOf(field.get("label")));
            value.put("dataType", type);
            if (field.get("shape") instanceof List<?> shape) value.put("shape", new ArrayList<>(shape));
            if (field.get("unit") != null) value.put("unit", String.valueOf(field.get("unit")));
            value.put("required", !Boolean.FALSE.equals(field.get("required")));
            if (field.containsKey("defaultValue") && field.get("defaultValue") != null) {
                value.put("defaultValue", field.get("defaultValue"));
            }
            value.put("inputPortId", inputPortId);
            sanitizedFields.add(value);
        }
        for (int i = 0; i < sanitizedFields.size(); i++) {
            String left = String.valueOf(sanitizedFields.get(i).get("path"));
            for (int j = i + 1; j < sanitizedFields.size(); j++) {
                String right = String.valueOf(sanitizedFields.get(j).get("path"));
                if (left.equals(right) || left.startsWith(right + ".") || right.startsWith(left + ".")) {
                    throw new BusinessException("Bus Creator字段存在覆盖关系: " + nodeId);
                }
            }
        }
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("schemaMode", schemaMode);
        if (!schemaRef.isBlank()) result.put("schemaRef", schemaRef);
        if (raw.get("name") != null) result.put("name", String.valueOf(raw.get("name")));
        result.put("fields", sanitizedFields);
        return result;
    }

    private static Map<String, Object> sanitizeSelectorConfig(Object rawConfig, String nodeId) {
        if (!(rawConfig instanceof Map<?, ?> raw)) {
            throw new BusinessException("Bus Selector缺少配置: " + nodeId);
        }
        List<Map<String, Object>> selected = new ArrayList<>();
        Object fieldsObject = raw.get("selectedFields");
        if (fieldsObject instanceof List<?> fields) {
            Set<String> ids = new HashSet<>();
            Set<String> paths = new HashSet<>();
            Set<String> ports = new HashSet<>();
            for (Object item : fields) {
                if (!(item instanceof Map<?, ?> field)) {
                    throw new BusinessException("Bus Selector字段格式不合法: " + nodeId);
                }
                String id = String.valueOf(mapValue(field, "id", "")).trim();
                String path = String.valueOf(mapValue(field, "path", "")).trim();
                String type = String.valueOf(mapValue(field, "dataType", "")).trim();
                String outputPortId = String.valueOf(mapValue(field, "outputPortId", "bus_out_" + id)).trim();
                if (!matlabIdentifier(id) || !matlabFieldPath(path) || !matlabBusType(type)
                        || !matlabIdentifier(outputPortId) || !ids.add(id) || !paths.add(path)
                        || !ports.add(outputPortId)) {
                    throw new BusinessException("Bus Selector字段定义不合法: " + nodeId + "." + path);
                }
                Map<String, Object> value = new LinkedHashMap<>();
                value.put("id", id);
                value.put("path", path);
                value.put("label", field.get("label") == null ? path : String.valueOf(field.get("label")));
                value.put("dataType", type);
                value.put("outputPortId", outputPortId);
                if (field.get("shape") instanceof List<?> shape) value.put("shape", new ArrayList<>(shape));
                if (field.get("unit") != null) value.put("unit", String.valueOf(field.get("unit")));
                selected.add(value);
            }
        } else if (fieldsObject != null) {
            throw new BusinessException("Bus Selector字段列表格式不合法: " + nodeId);
        }
        for (int i = 0; i < selected.size(); i++) {
            String left = String.valueOf(selected.get(i).get("path"));
            for (int j = i + 1; j < selected.size(); j++) {
                String right = String.valueOf(selected.get(j).get("path"));
                if (left.equals(right) || left.startsWith(right + ".") || right.startsWith(left + ".")) {
                    throw new BusinessException("Bus Selector字段存在覆盖关系: " + nodeId);
                }
            }
        }
        Map<String, Object> result = new LinkedHashMap<>();
        if (raw.get("sourceSchemaRef") != null) result.put("sourceSchemaRef", String.valueOf(raw.get("sourceSchemaRef")));
        result.put("selectedFields", selected);
        return result;
    }

    private static MatlabComponentVO buildBuiltinBusComponent(String nodeId, String executionKind,
                                                        Map<?, ?> rawNode) {
        MatlabComponentVO component = new MatlabComponentVO();
        boolean creator = "busCreator".equals(executionKind);
        component.setId(creator ? "builtin.bus.creator" : "builtin.bus.selector");
        component.setName(creator ? "Bus Creator" : "Bus Selector");
        component.setEngineType("matlab");
        component.setExecutorType("julia-matlab-graph");
        component.setComponentKind("workflow");
        component.setFunctionName("");
        component.setCategory("workflow-tools");
        component.setResources(List.of());
        List<MatlabComponentVO.PortVO> inputs = new ArrayList<>();
        List<MatlabComponentVO.PortVO> outputs = new ArrayList<>();
        if (creator) {
            Map<String, Object> config = sanitizeBusConfig(rawNode.get("busConfig"), nodeId);
            for (Object item : (List<?>) config.get("fields")) {
                Map<?, ?> field = (Map<?, ?>) item;
                MatlabComponentVO.PortVO port = new MatlabComponentVO.PortVO();
                port.setName(String.valueOf(field.get("inputPortId")));
                port.setType(String.valueOf(field.get("dataType")));
                port.setUnit(field.get("unit") == null ? null : String.valueOf(field.get("unit")));
                if (field.get("shape") instanceof List<?> shape) {
                    List<Integer> dimensions = new ArrayList<>();
                    for (Object dimension : shape) {
                        if (dimension instanceof Number number) dimensions.add(number.intValue());
                    }
                    port.setShape(dimensions);
                }
                port.setRequired(!Boolean.FALSE.equals(field.get("required")));
                inputs.add(port);
            }
            MatlabComponentVO.PortVO bus = new MatlabComponentVO.PortVO();
            bus.setName("bus");
            String type = config.get("schemaRef") == null ? "bus" : String.valueOf(config.get("schemaRef"));
            bus.setType(type);
            bus.setRequired(true);
            outputs.add(bus);
        } else {
            MatlabComponentVO.PortVO bus = new MatlabComponentVO.PortVO();
            bus.setName("bus");
            bus.setType("bus");
            bus.setRequired(true);
            inputs.add(bus);
            Map<String, Object> config = sanitizeSelectorConfig(rawNode.get("selectorConfig"), nodeId);
            for (Object item : (List<?>) config.get("selectedFields")) {
                Map<?, ?> field = (Map<?, ?>) item;
                MatlabComponentVO.PortVO port = new MatlabComponentVO.PortVO();
                port.setName(String.valueOf(field.get("outputPortId")));
                port.setType(String.valueOf(field.get("dataType")));
                port.setUnit(field.get("unit") == null ? null : String.valueOf(field.get("unit")));
                if (field.get("shape") instanceof List<?> shape) {
                    List<Integer> dimensions = new ArrayList<>();
                    for (Object dimension : shape) {
                        if (dimension instanceof Number number) dimensions.add(number.intValue());
                    }
                    port.setShape(dimensions);
                }
                port.setRequired(false);
                outputs.add(port);
            }
        }
        component.setInputs(inputs);
        component.setOutputs(outputs);
        component.setInvocation(null);
        return component;
    }

    private static Map<String, Object> validateMatlabResources(
            Object rawResourcesObject, MatlabComponentVO component) {
        Map<?, ?> rawResources;
        if (rawResourcesObject == null) {
            rawResources = Map.of();
        } else if (rawResourcesObject instanceof Map<?, ?> map) {
            rawResources = map;
        } else {
            throw new BusinessException("MATLAB工作流节点resources必须是对象: " + component.getId());
        }
        Map<String, Object> result = new LinkedHashMap<>();
        Set<String> allowedFields = new HashSet<>();
        for (MatlabComponentVO.ResourceVO definition : component.getResources()) {
            String idField = definition.getName() + "Id";
            allowedFields.add(idField);
            Object rawId = rawResources.get(idField);
            if (rawId != null && !String.valueOf(rawId).isBlank()) {
                result.put(definition.getName(), new LinkedHashMap<>(Map.of(
                        "configId", String.valueOf(rawId).trim())));
            } else if (Boolean.TRUE.equals(definition.getRequired())) {
                throw new BusinessException("MATLAB节点缺少必需资源: "
                        + component.getId() + "." + definition.getName());
            }
        }
        for (Object rawField : rawResources.keySet()) {
            if (!allowedFields.contains(String.valueOf(rawField))) {
                throw new BusinessException("MATLAB节点包含未声明资源: " + rawField);
            }
        }
        return result;
    }

    private static Map<String, Object> validateMatlabValues(
            Object rawValuesObject, MatlabComponentVO component) {
        Map<?, ?> rawValues;
        if (rawValuesObject == null) {
            rawValues = Map.of();
        } else if (rawValuesObject instanceof Map<?, ?> map) {
            rawValues = map;
        } else {
            throw new BusinessException("MATLAB节点values必须是对象: " + component.getId());
        }
        Set<String> declaredNames = component.getInputs().stream()
                .map(MatlabComponentVO.PortVO::getName).collect(java.util.stream.Collectors.toSet());
        for (Object rawName : rawValues.keySet()) {
            if (!declaredNames.contains(String.valueOf(rawName))) {
                throw new BusinessException("MATLAB节点包含未声明输入值: " + rawName);
            }
        }
        Map<String, Object> trustedValues = new LinkedHashMap<>();
        for (MatlabComponentVO.PortVO definition : component.getInputs()) {
            Object value = rawValues.get(definition.getName());
            if (value == null) {
                value = definition.getDefaultValue();
            }
            if (value == null) {
                continue;
            }
            if ("number".equals(definition.getType())) {
                if (!(value instanceof Number number)) {
                    throw new BusinessException("MATLAB输入必须是数字: " + definition.getName());
                }
                double doubleValue = number.doubleValue();
                if (!Double.isFinite(doubleValue)) {
                    throw new BusinessException("MATLAB输入必须是有限数字: " + definition.getName());
                }
                if (definition.getMin() != null && doubleValue < definition.getMin()) {
                    throw new BusinessException("MATLAB输入低于下限: " + definition.getName());
                }
                if (definition.getMax() != null && doubleValue > definition.getMax()) {
                    throw new BusinessException("MATLAB输入高于上限: " + definition.getName());
                }
                trustedValues.put(definition.getName(), doubleValue);
            } else if ("array".equals(definition.getType())) {
                trustedValues.put(definition.getName(), validateNumericArray(value, definition.getName()));
            } else if (value instanceof Boolean || value instanceof String) {
                trustedValues.put(definition.getName(), value);
            } else {
                throw new BusinessException("MATLAB结构化输入必须由连线提供: " + definition.getName());
            }
        }
        return trustedValues;
    }

    /** Numeric MATLAB arrays may be a legacy scalar, a vector, or a rectangular matrix. */
    private static Object validateNumericArray(Object value, String name) {
        if (value instanceof Number number) {
            double scalar = number.doubleValue();
            if (!Double.isFinite(scalar)) throw new BusinessException("MATLAB数组必须是有限数值: " + name);
            return scalar;
        }
        if (!(value instanceof List<?> list)) {
            throw new BusinessException("MATLAB数组输入必须是数值向量或矩阵: " + name);
        }
        boolean matrix = !list.isEmpty() && list.get(0) instanceof List<?>;
        List<Object> normalized = new ArrayList<>(list.size());
        int columns = matrix ? ((List<?>) list.get(0)).size() : -1;
        for (Object item : list) {
            if (matrix) {
                if (!(item instanceof List<?> row) || row.size() != columns) {
                    throw new BusinessException("MATLAB数值矩阵各行长度必须一致: " + name);
                }
                normalized.add(validateNumericRow(row, name));
            } else {
                if (item instanceof List<?>) throw new BusinessException("MATLAB数组最多支持二维: " + name);
                normalized.add(finiteArrayNumber(item, name));
            }
        }
        return normalized;
    }

    private static List<Double> validateNumericRow(List<?> row, String name) {
        List<Double> normalized = new ArrayList<>(row.size());
        for (Object item : row) normalized.add(finiteArrayNumber(item, name));
        return normalized;
    }

    private static Double finiteArrayNumber(Object value, String name) {
        if (!(value instanceof Number number) || !Double.isFinite(number.doubleValue())) {
            throw new BusinessException("MATLAB数组必须由有限数值组成: " + name);
        }
        return number.doubleValue();
    }

    private static List<Map<String, Object>> buildTrustedPortDefinitions(
            List<MatlabComponentVO.PortVO> ports) {
        if (ports == null) {
            return List.of();
        }
        List<Map<String, Object>> trustedPorts = new ArrayList<>();
        for (MatlabComponentVO.PortVO port : ports) {
            Map<String, Object> trustedPort = new LinkedHashMap<>();
            trustedPort.put("name", port.getName());
            trustedPort.put("type", port.getType());
            trustedPort.put("required", Boolean.TRUE.equals(port.getRequired()));
            if (StrUtil.isNotBlank(port.getUnit())) {
                trustedPort.put("unit", port.getUnit());
            }
            if (port.getShape() != null && !port.getShape().isEmpty()) {
                trustedPort.put("shape", port.getShape());
            }
            trustedPorts.add(trustedPort);
        }
        return trustedPorts;
    }

    private static MatlabComponentVO.PortVO findMatlabPort(
            List<MatlabComponentVO.PortVO> ports, String portName,
            String direction, String nodeId) {
        if (ports != null) {
            for (MatlabComponentVO.PortVO port : ports) {
                if (port.getName().equals(portName)) {
                    return port;
                }
            }
        }
        throw new BusinessException("MATLAB工作流节点不存在" + direction + "端口: "
                + nodeId + "." + portName);
    }
}
