package com.modelcloud.modules.business.service.impl;

import com.alibaba.fastjson2.JSON;
import com.modelcloud.common.exception.BusinessException;
import com.modelcloud.modules.business.model.dto.MatlabComponentVO;
import org.junit.jupiter.api.Test;
import java.util.List;
import java.util.Map;
import java.util.Set;
import static org.junit.jupiter.api.Assertions.*;

class EngineAssemblyCompilerTest {
    @SuppressWarnings("unchecked")
    private Map<String, Object> payload() throws Exception {
        return payload("engine.configuration.ducted-fan");
    }
    @SuppressWarnings("unchecked")
    private Map<String, Object> payload(String componentId) throws Exception {
        Map<String, Object> component = EngineGoldenFixtureTest.loadEngineCatalog().stream()
                .filter(c -> componentId.equals(c.get("id"))).findFirst().orElseThrow();
        Map<String, Object> payload = JSON.parseObject(JSON.toJSONString(component.get("templateDefinition")), Map.class);
        payload.put("schemaVersion", 3);
        return payload;
    }
    @SuppressWarnings("unchecked")
    private Map<String, Object> assembly(Map<String, Object> payload) {
        return (Map<String, Object>) ((Map<?, ?>) payload.get("physicalAssemblies")).values().iterator().next();
    }
    @SuppressWarnings("unchecked")
    private Map<String, Object> member(Map<String, Object> payload, String id) {
        return ((Map<?, ?>) payload.get("scenes")).values().stream()
                .flatMap(scene -> ((List<Map<String, Object>>) ((Map<?, ?>) scene).get("nodes")).stream())
                .filter(node -> id.equals(node.get("id"))).findFirst().orElseThrow();
    }
    private Map<String, Object> expand(Map<String, Object> payload) throws Exception {
        Map<String, MatlabComponentVO> catalog = EngineGoldenFixtureTest.componentLookup();
        return MatlabHierarchyCompiler.expand(payload, payload.get("physicalAssemblies"), catalog::get);
    }

    @Test void assemblyDescriptorCompilesIntoAssemblyJsonWithoutBecomingAnExecutionNode() throws Exception {
        Map<String, Object> payload = payload();
        ((Map<String, Object>) assembly(payload).get("initializerBinding")).put("nodeId", "stale_binding_summary");
        Map<String, Object> expanded = expand(payload);
        List<Map<String, Object>> nodes = (List<Map<String, Object>>) expanded.get("nodes");
        assertFalse(nodes.stream().anyMatch(node ->
                "project.subsystem.engine-assembly-relations".equals(node.get("componentId"))));
        Map<String, Object> initializer = nodes.stream()
                .filter(node -> "engine.stage.initialize-configuration".equals(node.get("componentId")))
                .findFirst().orElseThrow();
        Map<String, Object> values = (Map<String, Object>) initializer.get("values");
        assertTrue(values.get("assembly_json") instanceof String);
        assertFalse(((List<Map<String, Object>>) expanded.get("edges")).stream()
                .anyMatch(edge -> String.valueOf(edge.get("sourceNodeId")).contains("assembly_descriptor")));
    }

    @Test void allSixPresetConfigurationsUseTheSameDescriptorAndDAGCompilationPath() throws Exception {
        List<String> presets = List.of(
                "engine.configuration.ducted-fan", "engine.configuration.turboshaft",
                "engine.configuration.mixed-turbofan", "engine.configuration.2-spool-turboshaft",
                "engine.configuration.free-turbine-turboshaft", "engine.configuration.2-spool-mixed-turbofan");
        for (String preset : presets) {
            Map<String, Object> expanded = expand(payload(preset));
            List<Map<String, Object>> nodes = (List<Map<String, Object>>) expanded.get("nodes");
            assertFalse(nodes.stream().anyMatch(node ->
                    "project.subsystem.engine-assembly-relations".equals(node.get("componentId"))), preset);
            Map<String, Object> initializer = nodes.stream()
                    .filter(node -> "engine.stage.initialize-configuration".equals(node.get("componentId")))
                    .findFirst().orElseThrow(() -> new AssertionError("DP 组装缺失: " + preset));
            assertTrue(((Map<String, Object>) initializer.get("values")).get("assembly_json") instanceof String, preset);
            Set<String> ids = nodes.stream().map(node -> String.valueOf(node.get("id")))
                    .collect(java.util.stream.Collectors.toSet());
            for (Map<String, Object> edge : (List<Map<String, Object>>) expanded.get("edges")) {
                assertTrue(ids.contains(String.valueOf(edge.get("sourceNodeId"))), preset + " dangling source");
                assertTrue(ids.contains(String.valueOf(edge.get("targetNodeId"))), preset + " dangling target");
            }
        }
    }

    @Test void newMultiShaftTemplatesCompilePerShaftGroupsAndKeepEmptyBleedRows() throws Exception {
        Map<String, String> types = Map.of(
                "engine.configuration.2-spool-turboshaft", "2 spool turboshaft",
                "engine.configuration.free-turbine-turboshaft", "turboshaft with free turbine",
                "engine.configuration.2-spool-mixed-turbofan", "2 spool mixed turbofan");
        for (Map.Entry<String, String> entry : types.entrySet()) {
            Map<String, Object> payload = payload(entry.getKey());
            Map<String, Object> expanded = expand(payload);
            List<Map<String, Object>> nodes = (List<Map<String, Object>>) expanded.get("nodes");
            Map<String, Object> initializer = nodes.stream()
                    .filter(node -> "engine.stage.initialize-configuration".equals(node.get("componentId")))
                    .findFirst().orElseThrow();
            Map<String, Object> values = (Map<String, Object>) initializer.get("values");
            Map<String, Object> assemblyJson = JSON.parseObject(String.valueOf(values.get("assembly_json")), Map.class);
            assertEquals(entry.getValue(), ((Map<String, Object>) assemblyJson.get("assemblyDefaults")).get("type"));
            List<Map<String, Object>> groups = (List<Map<String, Object>>) assemblyJson.get("relationGroups");
            assertEquals(2L, groups.stream().filter(g -> "shaft".equals(g.get("relation"))).count());
            int expectedBleedRows = "2 spool turboshaft".equals(entry.getValue()) ? 2 : 1;
            assertEquals((long) expectedBleedRows, groups.stream().filter(g -> "bleed".equals(g.get("relation"))).count());
            if ("2 spool turboshaft".equals(entry.getValue())) {
                assertTrue(groups.stream().anyMatch(g -> "bleed".equals(g.get("relation"))
                        && ((List<?>) g.get("memberNodeIds")).isEmpty()));
            }
            if ("turboshaft with free turbine".equals(entry.getValue())) {
                assertTrue(((List<Map<String, Object>>) assemblyJson.get("nodes")).stream()
                        .anyMatch(n -> "pmsm 0d".equals(n.get("legacyName"))));
            }
        }
    }

    @Test void freeTurbineTemplateHasOneCompleteConnectedFlowPathIncludingMotor() throws Exception {
        Map<String, Object> payload = payload("engine.configuration.free-turbine-turboshaft");
        Map<String, Object> assembly = assembly(payload);
        List<String> expectedMembers = List.of("inlet_1", "pmsm_0d_1", "duct_1", "hpc_1", "burn_1",
                "hpt_1", "duct_2", "lpt_1", "afterburn_1", "nozzle_1");
        assertEquals(expectedMembers, assembly.get("memberNodeIds"));

        List<Map<String, Object>> flowRelations = (List<Map<String, Object>>) assembly.get("flowRelations");
        assertEquals(9, flowRelations.size());
        List<List<String>> expectedPath = List.of(
                List.of("inlet_1", "pmsm_0d_1"), List.of("pmsm_0d_1", "duct_1"),
                List.of("duct_1", "hpc_1"), List.of("hpc_1", "burn_1"),
                List.of("burn_1", "hpt_1"), List.of("hpt_1", "duct_2"),
                List.of("duct_2", "lpt_1"), List.of("lpt_1", "afterburn_1"),
                List.of("afterburn_1", "nozzle_1"));
        Set<String> relationIds = new java.util.HashSet<>();
        Map<String, String> nextByNode = new java.util.LinkedHashMap<>();
        for (Map<String, Object> relation : flowRelations) {
            assertTrue(relationIds.add(String.valueOf(relation.get("id"))), "duplicate flow relation id");
            String source = String.valueOf(relation.get("sourceNodeId"));
            String target = String.valueOf(relation.get("targetNodeId"));
            assertTrue(expectedMembers.contains(source), "unknown flow source " + source);
            assertTrue(expectedMembers.contains(target), "unknown flow target " + target);
            assertNull(nextByNode.put(source, target), "multiple outgoing flow edges from " + source);
        }
        List<List<String>> actualPath = new java.util.ArrayList<>();
        Set<String> visited = new java.util.HashSet<>();
        String current = "inlet_1";
        while (nextByNode.containsKey(current)) {
            assertTrue(visited.add(current), "flow cycle at " + current);
            String next = nextByNode.get(current);
            actualPath.add(List.of(current, next));
            current = next;
        }
        assertEquals("nozzle_1", current);
        assertEquals(expectedPath, actualPath);
        assertEquals(expectedMembers.size(), visited.size() + 1, "all members must be reachable from inlet");

        for (int index = 0; index < expectedMembers.size(); index++) {
            Map<String, Object> node = member(payload, expectedMembers.get(index));
            assertEquals(index * 270 + 40, ((Number) ((Map<?, ?>) node.get("position")).get("x")).intValue());
            assertEquals(40, ((Number) ((Map<?, ?>) node.get("position")).get("y")).intValue());
        }

        Map<String, Object> expanded = expand(payload);
        List<Map<String, Object>> executionNodes = (List<Map<String, Object>>) expanded.get("nodes");
        Map<String, Object> initializer = executionNodes.stream()
                .filter(node -> "engine.stage.initialize-configuration".equals(node.get("componentId")))
                .findFirst().orElseThrow();
        Map<String, Object> assemblyJson = JSON.parseObject(
                String.valueOf(((Map<String, Object>) initializer.get("values")).get("assembly_json")), Map.class);
        List<Map<String, Object>> compiledFlows = ((List<Map<String, Object>>) assemblyJson.get("edges"))
                .stream().filter(edge -> "flow".equals(edge.get("relation"))).toList();
        assertEquals(9, compiledFlows.size());
        assertTrue(compiledFlows.stream().anyMatch(edge ->
                "pmsm_0d_1".equals(edge.get("sourceNodeId")) && "duct_1".equals(edge.get("targetNodeId"))));
    }

    @Test void rejectsAssemblyDescriptorWhenItsVisibleDagEdgeIsMissing() throws Exception {
        Map<String, Object> payload = payload();
        Map<String, Object> scenes = (Map<String, Object>) payload.get("scenes");
        Map<String, Object> assemblyScene = (Map<String, Object>) scenes.get("physical");
        List<Map<String, Object>> edges = (List<Map<String, Object>>) assemblyScene.get("dataEdges");
        edges.removeIf(edge -> String.valueOf(edge.get("sourceNodeId")).contains("assembly_descriptor"));
        assertThrows(BusinessException.class, () -> expand(payload));
    }

    @Test void rejectsOrdinaryComponentDespiteForgedPhysicalCapability() throws Exception {
        Map<String, Object> payload = payload();
        String id = String.valueOf(((List<?>) assembly(payload).get("memberNodeIds")).get(0));
        Map<String, Object> node = member(payload, id);
        node.put("componentId", "engine.stage.solve-design-point");
        node.put("physicalCapabilities", Map.of("flow", Map.of()));
        assertThrows(BusinessException.class, () -> expand(payload));
    }

    @Test void rejectsRelationsOutsideTheirAssembly() throws Exception {
        Map<String, Object> payload = payload();
        Map<String, Object> relation = (Map<String, Object>) ((List<?>) assembly(payload).get("flowRelations")).get(0);
        relation.put("targetNodeId", ((Map<?, ?>) assembly(payload).get("initializerBinding")).get("nodeId"));
        assertThrows(BusinessException.class, () -> expand(payload));
    }

    @Test void rejectsUndeclaredPhysicalPort() throws Exception {
        Map<String, Object> payload = payload();
        Map<String, Object> relation = (Map<String, Object>) ((List<?>) assembly(payload).get("flowRelations")).get(0);
        relation.put("sourcePortId", "NONEXISTENT");
        assertThrows(BusinessException.class, () -> expand(payload));
    }

    @Test void rejectsGroupMemberWithoutJoinableCapability() throws Exception {
        Map<String, Object> payload = payload();
        Map<String, Object> group = (Map<String, Object>) ((List<?>) assembly(payload).get("shaftGroups")).get(0);
        group.put("memberNodeIds", List.of("inlet_1"));
        assertThrows(BusinessException.class, () -> expand(payload));
    }

    @Test void visibleDataEdgeMustTargetAssemblyJsonPort() throws Exception {
        Map<String, Object> payload = payload();
        Map<String, Object> scenes = (Map<String, Object>) payload.get("scenes");
        for (Object rawScene : scenes.values()) {
            Map<String, Object> scene = (Map<String, Object>) rawScene;
            for (Object rawEdge : (List<?>) scene.getOrDefault("dataEdges", List.of())) {
                Map<String, Object> edge = (Map<String, Object>) rawEdge;
                if ("assembly_json".equals(edge.get("sourcePort"))) edge.put("targetPort", "DP");
            }
        }
        assertThrows(BusinessException.class, () -> expand(payload));
    }

    @Test void resolvesAssemblyJsonBindingAcrossNestedSubsystemBoundaries() throws Exception {
        Map<String, Object> payload = payload();
        Map<String, Object> scenes = (Map<String, Object>) payload.get("scenes");
        Map<String, Object> parent = (Map<String, Object>) scenes.get("physical");
        List<Map<String, Object>> parentNodes = (List<Map<String, Object>>) parent.get("nodes");
        Map<String, Object> descriptor = parentNodes.stream()
                .filter(node -> "project.subsystem.engine-assembly-relations".equals(node.get("componentId")))
                .findFirst().orElseThrow();
        Map<String, Object> initializer = parentNodes.stream()
                .filter(node -> "engine.stage.initialize-configuration".equals(node.get("componentId")))
                .findFirst().orElseThrow();
        parentNodes.remove(descriptor);
        parentNodes.remove(initializer);

        Map<String, Object> descriptorLeaf = Map.of("id", "descriptor_leaf", "nodes", List.of(descriptor), "dataEdges", List.of());
        Map<String, Object> descriptorInner = Map.of("id", "descriptor_inner", "nodes", List.of(Map.of(
                "id", "descriptor_inner_wrapper", "nodeKind", "subsystem", "childSceneId", "descriptor_leaf",
                "boundaryPorts", List.of(Map.of("id", "inner_out", "kind", "data", "direction", "output",
                        "mapping", Map.of("childNodeId", descriptor.get("id"), "childPortId", "assembly_json"))))), "dataEdges", List.of());
        Map<String, Object> initializerLeaf = Map.of("id", "initializer_leaf", "nodes", List.of(initializer), "dataEdges", List.of());
        Map<String, Object> initializerInner = Map.of("id", "initializer_inner", "nodes", List.of(Map.of(
                "id", "initializer_inner_wrapper", "nodeKind", "subsystem", "childSceneId", "initializer_leaf",
                "boundaryPorts", List.of(Map.of("id", "inner_in", "kind", "data", "direction", "input",
                        "mapping", Map.of("childNodeId", initializer.get("id"), "childPortId", "assembly_json"))))), "dataEdges", List.of());
        scenes.put("descriptor_leaf", descriptorLeaf);
        scenes.put("descriptor_inner", descriptorInner);
        scenes.put("initializer_leaf", initializerLeaf);
        scenes.put("initializer_inner", initializerInner);

        Map<String, Object> left = Map.of("id", "descriptor_outer", "nodeKind", "subsystem", "childSceneId", "descriptor_inner",
                "boundaryPorts", List.of(Map.of("id", "outer_out", "kind", "data", "direction", "output",
                        "mapping", Map.of("childNodeId", "descriptor_inner_wrapper", "childPortId", "inner_out"))));
        Map<String, Object> right = Map.of("id", "initializer_outer", "nodeKind", "subsystem", "childSceneId", "initializer_inner",
                "boundaryPorts", List.of(Map.of("id", "outer_in", "kind", "data", "direction", "input",
                        "mapping", Map.of("childNodeId", "initializer_inner_wrapper", "childPortId", "inner_in"))));
        parentNodes.add(left);
        parentNodes.add(right);
        List<Map<String, Object>> edges = (List<Map<String, Object>>) parent.get("dataEdges");
        edges.removeIf(edge -> String.valueOf(edge.get("sourcePort")).equals("assembly_json"));
        edges.add(Map.of("id", "outer_binding", "sourceNodeId", "descriptor_outer", "sourcePort", "outer_out",
                "targetNodeId", "initializer_outer", "targetPort", "outer_in"));

        Map<String, Object> expanded = expand(payload);
        List<Map<String, Object>> executionNodes = (List<Map<String, Object>>) expanded.get("nodes");
        assertTrue(executionNodes.stream().anyMatch(node -> initializer.get("id").equals(node.get("__sourceNodeId"))));
        Map<String, Object> compiledInitializer = executionNodes.stream()
                .filter(node -> initializer.get("id").equals(node.get("__sourceNodeId"))).findFirst().orElseThrow();
        assertTrue(((Map<String, Object>) compiledInitializer.get("values")).get("assembly_json") instanceof String);
        Set<String> compiledIds = executionNodes.stream().map(node -> String.valueOf(node.get("id")))
                .collect(java.util.stream.Collectors.toSet());
        for (Map<String, Object> edge : (List<Map<String, Object>>) expanded.get("edges")) {
            assertTrue(compiledIds.contains(String.valueOf(edge.get("sourceNodeId"))), "dangling source " + edge);
            assertTrue(compiledIds.contains(String.valueOf(edge.get("targetNodeId"))), "dangling target " + edge);
        }
    }

    @Test void recursivePhysicalBoundaryIsNotAnExecutionEdge() throws Exception {
        Map<String, Object> payload = payload();
        Map<String, Object> part = member(payload, "lpc_1");
        Map<String, Object> scenes = (Map<String, Object>) payload.get("scenes");
        Map<String, Object> container = scenes.values().stream().map(s -> (Map<String, Object>) s)
                .filter(s -> ((List<?>) s.get("nodes")).contains(part)).findFirst().orElseThrow();
        ((List<?>) container.get("nodes")).remove(part);
        Map<String, Object> boundary = Map.of("id", "physical_in", "kind", "flow", "direction", "input", "name", "气路",
                "mapping", Map.of("childNodeId", "lpc_1", "childPortId", "INPUT"));
        scenes.put("nested", Map.of("id", "nested", "nodes", List.of(part), "dataEdges", List.of(), "boundaryPorts", List.of(boundary)));
        ((List<Object>) container.get("nodes")).add(Map.of("id", "nested_subsystem", "nodeKind", "subsystem",
                "childSceneId", "nested", "values", Map.of(), "boundaryPorts", List.of(boundary)));
        Map<String, Object> expanded = expand(payload);
        assertFalse(((List<Map<String, Object>>) expanded.get("nodes")).stream()
                .anyMatch(node -> "lpc_1".equals(node.get("__sourceNodeId"))));
        assertTrue(((List<Map<String, Object>>) expanded.get("nodes")).stream()
                .anyMatch(node -> node.get("__originPath") instanceof List<?>));
    }
}
