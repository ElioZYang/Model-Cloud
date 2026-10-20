package com.modelcloud.modules.business.service.impl;

import com.alibaba.fastjson2.JSON;
import org.junit.jupiter.api.Test;
import org.springframework.core.io.ClassPathResource;

import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class RecursiveExecutionGraphExpanderTest {
    private static final List<String> CONFIGURATION_LOOP_IDS = List.of(
            "engine.configuration.ducted-fan",
            "engine.configuration.turboshaft",
            "engine.configuration.mixed-turbofan");

    @Test
    @SuppressWarnings("unchecked")
    void expandsAutomaticallyInferredSubsystemInputsAndOutputs() {
        Map<String, Object> payload = JSON.parseObject("""
                {
                  "schemaVersion": 3,
                  "rootSceneId": "root",
                  "scenes": [
                    {
                      "id": "root",
                      "nodes": [
                        {"id":"source","componentId":"source","nodeKind":"matlabFunction","values":{}},
                        {"id":"sub","componentId":"sub","nodeKind":"subsystem","childSceneId":"child",
                         "values":{"boundary_data_in_1":9},
                         "boundaryPorts":[
                           {"id":"boundary_data_in_1","name":"in_1","kind":"data","direction":"input","mapping":{"childNodeId":"a","childPortId":"IN"}},
                           {"id":"boundary_data_out_1","name":"out_1","kind":"data","direction":"output","mapping":{"childNodeId":"b","childPortId":"OUT"}}
                         ]},
                        {"id":"sink","componentId":"sink","nodeKind":"matlabFunction","values":{}}
                      ],
                      "edges": [
                        {"id":"root_in","sourceNodeId":"source","sourcePort":"OUT","targetNodeId":"sub","targetPort":"boundary_data_in_1"},
                        {"id":"root_out","sourceNodeId":"sub","sourcePort":"boundary_data_out_1","targetNodeId":"sink","targetPort":"IN"}
                      ],
                      "boundaryPorts":[]
                    },
                    {
                      "id":"child","parentSceneId":"root",
                      "nodes":[
                        {"id":"a","componentId":"a","nodeKind":"matlabFunction","values":{"IN":4}},
                        {"id":"b","componentId":"b","nodeKind":"matlabFunction","values":{}}
                      ],
                      "edges":[{"id":"inner","sourceNodeId":"a","sourcePort":"OUT","targetNodeId":"b","targetPort":"IN"}],
                      "boundaryPorts":[
                        {"id":"boundary_data_in_1","name":"in_1","kind":"data","direction":"input","mapping":{"childNodeId":"a","childPortId":"IN"}},
                        {"id":"boundary_data_out_1","name":"out_1","kind":"data","direction":"output","mapping":{"childNodeId":"b","childPortId":"OUT"}}
                      ]
                    }
                  ]
                }
                """, Map.class);

        Map<String, Object> expanded = RecursiveExecutionGraphExpander.expand(payload);
        List<Map<String, Object>> edges = (List<Map<String, Object>>) expanded.get("edges");
        assertTrue(edges.stream().anyMatch(edge -> "root__source".equals(edge.get("sourceNodeId"))
                && "root__sub__a".equals(edge.get("targetNodeId"))
                && "IN".equals(edge.get("targetPort"))));
        assertTrue(edges.stream().anyMatch(edge -> "root__sub__b".equals(edge.get("sourceNodeId"))
                && "root__sink".equals(edge.get("targetNodeId"))
                && "OUT".equals(edge.get("sourcePort"))));
        Map<String, Object> childA = ((List<Map<String, Object>>) expanded.get("nodes")).stream()
                .filter(node -> "root__sub__a".equals(node.get("id"))).findFirst().orElseThrow();
        assertEquals(9, ((Map<String, Object>) childA.get("values")).get("IN"));
    }

    @Test
    @SuppressWarnings("unchecked")
    void expandsExplicitSubsystemInputToMultipleInternalTargets() {
        Map<String, Object> payload = JSON.parseObject("""
                {
                  "schemaVersion":3,"rootSceneId":"root",
                  "scenes":[
                    {"id":"root","nodes":[
                      {"id":"source","componentId":"source","nodeKind":"matlabFunction","values":{}},
                      {"id":"sub","componentId":"sub","nodeKind":"subsystem","childSceneId":"child",
                       "values":{"boundary_explicit_in":9},"boundaryPorts":[
                         {"id":"boundary_explicit_in","name":"shaft_power","kind":"data","direction":"input",
                          "mapping":{"childNodeId":"a","childPortId":"P"},
                          "mappings":[{"childNodeId":"a","childPortId":"P"},{"childNodeId":"b","childPortId":"P"}]}
                       ]}
                    ],"edges":[{"id":"root_in","sourceNodeId":"source","sourcePort":"Y","targetNodeId":"sub","targetPort":"boundary_explicit_in"}],"boundaryPorts":[]},
                    {"id":"child","parentSceneId":"root","nodes":[
                      {"id":"a","componentId":"a","nodeKind":"matlabFunction","values":{"P":1}},
                      {"id":"b","componentId":"b","nodeKind":"matlabFunction","values":{"P":2}}
                    ],"edges":[],"boundaryPorts":[]}
                  ]
                }
                """, Map.class);
        Map<String, Object> expanded = RecursiveExecutionGraphExpander.expand(payload);
        List<Map<String, Object>> edges = (List<Map<String, Object>>) expanded.get("edges");
        assertEquals(2, edges.size());
        assertTrue(edges.stream().anyMatch(edge -> "root__sub__a".equals(edge.get("targetNodeId"))));
        assertTrue(edges.stream().anyMatch(edge -> "root__sub__b".equals(edge.get("targetNodeId"))));
        List<Map<String, Object>> nodes = (List<Map<String, Object>>) expanded.get("nodes");
        for (String id : List.of("root__sub__a", "root__sub__b")) {
            Map<String, Object> node = nodes.stream().filter(item -> id.equals(item.get("id"))).findFirst().orElseThrow();
            assertEquals(9, ((Map<String, Object>) node.get("values")).get("P"));
        }
    }

    @Test
    void expandsCatalogTemplatesToPhysicalSceneV1() throws Exception {
        for (String configurationId : CONFIGURATION_LOOP_IDS) {
            Map<String, Object> component = catalogComponent(configurationId);
            Map<String, Object> payload = templatePayloadWithAssemblies(component);
            Map<String, Object> expanded = RecursiveExecutionGraphExpander
                    .expand(payload, payload.get("physicalAssemblies"));
            Map<?, ?> initializer = ((List<Map<String, Object>>) expanded.get("nodes")).stream()
                    .filter(node -> "engine.stage.initialize-configuration".equals(node.get("componentId")))
                    .findFirst().orElseThrow();
            Map<String, Object> values = (Map<String, Object>) initializer.get("values");
            Map<String, Object> assembly = JSON.parseObject(
                    String.valueOf(values.get("assembly_json")), Map.class);
            assertEquals("engine.physical-scene.v1",
                    String.valueOf(assembly.get("schemaVersion")), configurationId);
            assertTrue(assembly.containsKey("nodes"), configurationId);
            assertTrue(assembly.containsKey("edges"), configurationId);
            assertTrue(assembly.containsKey("relationGroups"), configurationId);
            assertTrue(assembly.containsKey("assemblyDefaults"), configurationId);
            for (String legacyField : List.of("F", "SHAFT", "EXT", "NS", "NW", "WA_extraction")) {
                assertTrue(!assembly.containsKey(legacyField),
                        configurationId + " 不应再由 Java 计算 " + legacyField);
            }
            // 气路成员不进入执行 DAG
            Map<String, Object> template = (Map<String, Object>) component.get("templateDefinition");
            Map<String, Object> assemblies = (Map<String, Object>) template.get("physicalAssemblies");
            for (Object asm : assemblies.values()) {
                for (Object memberId : (List<?>) ((Map<String, Object>) asm).get("memberNodeIds")) {
                    boolean inDag = ((List<Map<String, Object>>) expanded.get("nodes")).stream()
                            .anyMatch(node -> String.valueOf(node.get("__sourceNodeId")).equals(String.valueOf(memberId)));
                    assertTrue(!inDag, configurationId + " 装配成员 " + memberId + " 不应成为 DAG 节点");
                }
            }
        }
    }

    @Test
    @SuppressWarnings("unchecked")
    void relationGroupsSupportSingletonAndOverlappingMembership() throws Exception {
        Map<String, Object> component = catalogComponent("engine.configuration.ducted-fan");
        Map<String, Object> payload = templatePayloadWithAssemblies(component);
        Map<String, Object> assemblies = (Map<String, Object>) payload.get("physicalAssemblies");
        Map<String, Object> assembly = (Map<String, Object>) assemblies.values().iterator().next();
        List<Map<String, Object>> shaftGroups = (List<Map<String, Object>>) assembly.get("shaftGroups");
        shaftGroups.add(new java.util.LinkedHashMap<>(Map.of(
                "id", "shaft_2", "kind", "shaft", "name", "第二轴", "order", 101,
                "memberNodeIds", List.of("inlet_1"),
                "parameters", Map.of("E_mech", 0.98))));
        List<Map<String, Object>> bleedGroups = (List<Map<String, Object>>) assembly.get("bleedGroups");
        bleedGroups.add(new java.util.LinkedHashMap<>(Map.of(
                "id", "bleed_1", "kind", "bleed", "name", "引气组", "order", 1,
                "memberNodeIds", List.of("lpc_1"))));

        Map<String, Object> expanded = RecursiveExecutionGraphExpander
                .expand(payload, payload.get("physicalAssemblies"));
        Map<?, ?> initializer = ((List<Map<String, Object>>) expanded.get("nodes")).stream()
                .filter(node -> "engine.stage.initialize-configuration".equals(node.get("componentId")))
                .findFirst().orElseThrow();
        Map<String, Object> assemblyJson = JSON.parseObject(
                String.valueOf(((Map<String, Object>) initializer.get("values")).get("assembly_json")), Map.class);
        List<Map<String, Object>> groups = (List<Map<String, Object>>) assemblyJson.get("relationGroups");
        long shaftCount = groups.stream().filter(g -> "shaft".equals(g.get("relation"))).count();
        long bleedCount = groups.stream().filter(g -> "bleed".equals(g.get("relation"))).count();
        assertEquals(2, shaftCount);
        assertEquals(1, bleedCount);
        // 单部件轴组：memberNodeIds 只含锚点也成立
        assertTrue(groups.stream().anyMatch(g -> "shaft_2".equals(g.get("id"))
                && ((List<?>) g.get("memberNodeIds")).size() == 1));
    }

    @Test
    @SuppressWarnings("unchecked")
    void mixedFanTemplateKeepsBypassAndCoreTopologyOrder() throws Exception {
        Map<String, Object> component = catalogComponent("engine.configuration.mixed-turbofan");
        Map<String, Object> payload = templatePayloadWithAssemblies(component);
        Map<String, Object> assemblies = (Map<String, Object>) payload.get("physicalAssemblies");
        Map<String, Object> assembly = (Map<String, Object>) assemblies.values().iterator().next();
        List<Map<String, Object>> flows = (List<Map<String, Object>>) assembly.get("flowRelations");
        Map<String, Object> bypass = flows.stream().filter(r -> "flow_bypass_1".equals(r.get("id"))).findFirst().orElseThrow();
        Map<String, Object> core = flows.stream().filter(r -> "flow_core_1".equals(r.get("id"))).findFirst().orElseThrow();
        assertEquals("bypass", bypass.get("streamRole"));
        assertEquals("core", core.get("streamRole"));
        assertEquals("BYPASS", bypass.get("sourcePortId"));
        assertEquals("CORE", core.get("sourcePortId"));
    }

    /** 模板 payload：V3 + physicalAssemblies 透传。 */
    private static Map<String, Object> templatePayloadWithAssemblies(Map<String, Object> component) {
        Map<String, Object> payload = new java.util.LinkedHashMap<>();
        Map<String, Object> template = (Map<String, Object>) component.get("templateDefinition");
        payload.putAll(template);
        payload.put("schemaVersion", 3);
        payload.put("physicalAssemblies", template.get("physicalAssemblies"));
        return payload;
    }

    private static Map<String, Object> catalogComponent(String configurationId) throws Exception {
        return EngineGoldenFixtureTest.loadEngineCatalog().stream()
                .filter(item -> configurationId.equals(item.get("id")))
                .findFirst()
                .orElseThrow(() -> new IllegalStateException("Missing catalog template: " + configurationId));
    }

}
