package com.modelcloud.modules.business.service.impl;

import com.modelcloud.common.exception.BusinessException;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 层级图编译器族共享的低层数据访问辅助。只做无副作用的读取、拷贝与
 * 字段别名归一，供工作流编译器与物理场景展开器共同使用。
 */
final class MatlabGraphSupport {
    static final int MAX_SCENE_DEPTH = 32;
    static final int MAX_NODES = 2000;
    static final int MAX_EDGES = 5000;

    private MatlabGraphSupport() {
    }

    record Endpoint(String nodeId, String port) {
    }

    static String normalizedKind(Map<?, ?> node) {
        return stringValue(first(node, "subsystemKind", "componentKind", "nodeKind",
                        "executionKind", "kind", "type", "subsystemType"))
                .replace("_", "").replace("-", "").replace(" ", "").toLowerCase();
    }

    static String resolveChildSceneId(Map<?, ?> node) {
        Object ref = first(node, "subsystemRef", "sceneRef", "scene");
        String child = stringValue(first(node, "sceneId", "childSceneId", "subsystemSceneId",
                "subsystemId", "definitionId"));
        if (ref instanceof Map<?, ?> map) {
            child = stringValue(first(map, "sceneId", "id", "ref"));
        } else if (!stringValue(ref).isBlank()) {
            child = stringValue(ref);
        }
        if (child.isBlank()) throw new BusinessException("子系统节点缺少sceneId");
        return child;
    }

    static boolean isWorkflowSubsystem(Map<?, ?> node, String kind) {
        // V3：统一通用子系统；workflowSubsystem 为 V2 导入别名
        return "subsystem".equals(kind) || "workflowsubsystem".equals(kind) || "workflow".equals(kind)
                || Boolean.TRUE.equals(node.get("workflowSubsystem"));
    }

    static String originSegment(Map<?, ?> node, String fallback) {
        String segment = stringValue(first(node, "instanceName", "name", "label", "legacyName"));
        return segment.isBlank() ? fallback : segment;
    }

    static Map<?, ?> firstMap(Map<?, ?> node, String key) {
        Object value = node.get(key);
        return value instanceof Map<?, ?> map ? map : null;
    }

    static void mergeMap(Map<String, Object> target, Map<?, ?> source) {
        if (source == null) return;
        for (Map.Entry<?, ?> entry : source.entrySet()) {
            target.put(String.valueOf(entry.getKey()), copyValue(entry.getValue()));
        }
    }

    static List<Map<String, Object>> boundaryPorts(Map<?, ?> object) {
        List<Map<String, Object>> result = new ArrayList<>();
        Object raw = object.get("boundaryPorts");
        if (raw instanceof List<?> list) {
            for (Object item : list) {
                if (item instanceof Map<?, ?> map) result.add(normalizeBoundary(map));
            }
        } else if (raw instanceof Map<?, ?> map) {
            for (Map.Entry<?, ?> entry : map.entrySet()) {
                if (entry.getValue() instanceof Map<?, ?> value) {
                    Map<String, Object> copy = normalizeBoundary(value);
                    copy.putIfAbsent("outerPortId", String.valueOf(entry.getKey()));
                    result.add(copy);
                }
            }
        }
        return result;
    }

    private static Map<String, Object> normalizeBoundary(Map<?, ?> value) {
        Map<String, Object> copy = copyMap(value);
        Object inner = first(value, "inner", "internal", "child", "mapping");
        if (inner instanceof Map<?, ?> innerMap) {
            copy.putIfAbsent("innerNodeId", first(innerMap,
                    "childNodeId", "nodeId", "id"));
            copy.putIfAbsent("innerPortId", first(innerMap,
                    "childPortId", "childHandle", "port", "portId", "name", "handle"));
        }
        return copy;
    }

    static String boundaryPortId(Map<?, ?> boundary) {
        return stringValue(first(boundary, "outerPortId", "externalPortId", "parentPortId",
                "outer", "portId", "id", "name"));
    }

    static String boundaryDirection(Map<?, ?> boundary) {
        String direction = stringValue(first(boundary, "direction", "side")).toLowerCase();
        if (direction.contains("out")) return "output";
        return "input";
    }

    static String boundaryPortAlias(String port) {
        return switch (port) {
            case "flight_speed_mps" -> "V";
            case "mach" -> "M";
            case "altitude_m" -> "H";
            default -> port;
        };
    }

    static List<?> listValue(Object value) {
        return value instanceof List<?> list ? list : List.of();
    }

    static Object first(Map<?, ?> map, String... keys) {
        for (String key : keys) if (map.containsKey(key)) return map.get(key);
        return null;
    }

    static String stringValue(Object value) {
        return value == null ? "" : String.valueOf(value).trim();
    }

    static String safeId(String value) {
        String result = value.replaceAll("[^A-Za-z0-9_]+", "_");
        return result.isBlank() ? "node" : result;
    }

    static List<String> append(List<String> prefix, String value) {
        List<String> result = new ArrayList<>(prefix);
        result.add(value);
        return result;
    }

    @SuppressWarnings("unchecked")
    static Map<String, Object> asObject(Object value) {
        if (value instanceof Map<?, ?> map) return copyMap(map);
        return new LinkedHashMap<>();
    }

    @SuppressWarnings("unchecked")
    static Map<String, Object> copyMap(Map<?, ?> value) {
        Map<String, Object> result = new LinkedHashMap<>();
        for (Map.Entry<?, ?> entry : value.entrySet()) {
            result.put(String.valueOf(entry.getKey()), copyValue(entry.getValue()));
        }
        return result;
    }

    static Object copyValue(Object value) {
        if (value instanceof Map<?, ?> map) return copyMap(map);
        if (value instanceof List<?> list) {
            List<Object> result = new ArrayList<>();
            for (Object item : list) result.add(copyValue(item));
            return result;
        }
        return value;
    }
}
