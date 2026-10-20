package com.modelcloud.modules.business.service.impl;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONWriter;
import com.modelcloud.modules.business.model.dto.MatlabComponentVO;
import org.junit.jupiter.api.Test;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Golden fixtures for the engine configuration templates.
 *
 * <p>Run {@code mvn test -Dgolden.update=true} to regenerate the committed
 * fixtures under {@code contracts/matlab/fixtures/engine/}. Every regular test
 * run re-expands the catalog templates and compares the result byte-for-byte
 * with the committed fixtures, so any drift in the recursive expansion or the
 * physical assembly pipeline fails loudly here instead of silently changing
 * what MATLAB receives.
 */
class EngineGoldenFixtureTest {

    private static final List<String> CONFIGURATION_IDS = List.of(
            "engine.configuration.ducted-fan",
            "engine.configuration.turboshaft",
            "engine.configuration.2-spool-turboshaft",
            "engine.configuration.free-turbine-turboshaft",
            "engine.configuration.mixed-turbofan",
            "engine.configuration.separated-turbofan",
            "engine.configuration.2-spool-mixed-turbofan",
            "engine.configuration.2-spool-separated-turbofan",
            "engine.configuration.cfm56",
            "engine.configuration.3-spool-mixed-turbofan",
            "engine.configuration.3-spool-separated-turbofan",
            "engine.configuration.hpcgv-turboshaft");

    private static final Path FIXTURE_DIRECTORY = Paths.get(
            "..", "contracts", "matlab", "fixtures", "engine");

    @Test
    void engineConfigurationsFollowOriginalCatalogOrder() throws Exception {
        List<String> actual = loadEngineCatalog().stream()
                .filter(item -> item.get("catalogOrder") instanceof Number)
                .sorted(java.util.Comparator.comparingInt(item ->
                        ((Number) item.get("catalogOrder")).intValue()))
                .map(item -> String.valueOf(item.get("id")))
                .toList();
        assertEquals(CONFIGURATION_IDS, actual, "发动机构型目录顺序");
    }

    @Test
    void expansionMatchesGoldenFixtures() throws Exception {
        boolean update = Boolean.getBoolean("golden.update");
        if (update) {
            Files.createDirectories(FIXTURE_DIRECTORY);
        } else if (!Files.isDirectory(FIXTURE_DIRECTORY)) {
            throw new IllegalStateException(
                    "Golden fixtures missing under contracts/matlab/fixtures/engine; "
                            + "run `mvn test -Dgolden.update=true` once to generate them.");
        }
        Map<String, MatlabComponentVO> catalogLookup = componentLookup();
        List<String> fixtureIds = CONFIGURATION_IDS;
        String requestedUpdateIds = System.getProperty("golden.update.ids");
        if (update && requestedUpdateIds != null && !requestedUpdateIds.isBlank()) {
            fixtureIds = java.util.Arrays.stream(requestedUpdateIds.split(","))
                    .map(String::trim)
                    .filter(CONFIGURATION_IDS::contains)
                    .toList();
        }
        for (String configurationId : fixtureIds) {
            Map<String, Object> component = catalogComponent(configurationId);
            String projectJson = canonical(projectDocument(component));
            Map<String, Object> payload = new java.util.LinkedHashMap<>(templatePayload(component));
            Map<String, Object> expanded = RecursiveExecutionGraphExpander.expand(payload, payload.get("physicalAssemblies"));
            String expandedJson = canonical(expanded);
            // trusted-graph：与 submitSimulation 实际提交给仿真服务的负载同源。
            // 前端编译器只发送契约字段（不含 instanceName/position 等画布字段），
            // 此处先做同样的字段过滤再交给同一编译器。
            Map<String, Object> trusted = new MatlabTrustedGraphCompiler(catalogLookup::get)
                    .buildTrustedGraph(frontendSubmissionPayload(payload));
            String trustedJson = canonical(trusted);

            if (update) {
                Files.writeString(FIXTURE_DIRECTORY.resolve(configurationId + ".project-v2.json"),
                        projectJson, StandardCharsets.UTF_8);
                Files.writeString(FIXTURE_DIRECTORY.resolve(configurationId + ".expanded-graph.json"),
                        expandedJson, StandardCharsets.UTF_8);
                Files.writeString(FIXTURE_DIRECTORY.resolve(configurationId + ".trusted-graph.json"),
                        trustedJson, StandardCharsets.UTF_8);
                continue;
            }
            assertEquals(Files.readString(FIXTURE_DIRECTORY
                            .resolve(configurationId + ".project-v2.json"), StandardCharsets.UTF_8),
                    projectJson, "project template drifted for " + configurationId);
            assertEquals(Files.readString(FIXTURE_DIRECTORY
                            .resolve(configurationId + ".expanded-graph.json"), StandardCharsets.UTF_8),
                    expandedJson, "expanded execution graph drifted for " + configurationId);
            assertEquals(Files.readString(FIXTURE_DIRECTORY
                            .resolve(configurationId + ".trusted-graph.json"), StandardCharsets.UTF_8),
                    trustedJson, "trusted execution graph drifted for " + configurationId);
        }
        if (update && (requestedUpdateIds == null || requestedUpdateIds.isBlank())) {
            Files.writeString(FIXTURE_DIRECTORY.resolve("README.md"), fixtureReadme(),
                    StandardCharsets.UTF_8);
        }
    }

    @Test
    @SuppressWarnings("unchecked")
    void expandedGraphsKeepEngineAssemblyContract() throws Exception {
        Map<String, Integer> expectedFlows = Map.ofEntries(
                Map.entry("engine.configuration.ducted-fan", 2),
                Map.entry("engine.configuration.turboshaft", 5),
                Map.entry("engine.configuration.2-spool-turboshaft", 10),
                Map.entry("engine.configuration.free-turbine-turboshaft", 9),
                Map.entry("engine.configuration.mixed-turbofan", 10),
                Map.entry("engine.configuration.separated-turbofan", 8),
                Map.entry("engine.configuration.2-spool-mixed-turbofan", 12),
                Map.entry("engine.configuration.2-spool-separated-turbofan", 11),
                Map.entry("engine.configuration.cfm56", 12),
                Map.entry("engine.configuration.3-spool-mixed-turbofan", 16),
                Map.entry("engine.configuration.3-spool-separated-turbofan", 15),
                Map.entry("engine.configuration.hpcgv-turboshaft", 6));
        Map<String, Integer> expectedParts = Map.ofEntries(
                Map.entry("engine.configuration.ducted-fan", 3),
                Map.entry("engine.configuration.turboshaft", 6),
                Map.entry("engine.configuration.2-spool-turboshaft", 11),
                Map.entry("engine.configuration.free-turbine-turboshaft", 10),
                Map.entry("engine.configuration.mixed-turbofan", 10),
                Map.entry("engine.configuration.separated-turbofan", 9),
                Map.entry("engine.configuration.2-spool-mixed-turbofan", 12),
                Map.entry("engine.configuration.2-spool-separated-turbofan", 12),
                Map.entry("engine.configuration.cfm56", 13),
                Map.entry("engine.configuration.3-spool-mixed-turbofan", 16),
                Map.entry("engine.configuration.3-spool-separated-turbofan", 16),
                Map.entry("engine.configuration.hpcgv-turboshaft", 7));
        Map<String, Integer> expectedShaftGroups = Map.ofEntries(
                Map.entry("engine.configuration.ducted-fan", 1),
                Map.entry("engine.configuration.turboshaft", 1),
                Map.entry("engine.configuration.2-spool-turboshaft", 2),
                Map.entry("engine.configuration.free-turbine-turboshaft", 2),
                Map.entry("engine.configuration.mixed-turbofan", 1),
                Map.entry("engine.configuration.separated-turbofan", 1),
                Map.entry("engine.configuration.2-spool-mixed-turbofan", 2),
                Map.entry("engine.configuration.2-spool-separated-turbofan", 2),
                Map.entry("engine.configuration.cfm56", 2),
                Map.entry("engine.configuration.3-spool-mixed-turbofan", 3),
                Map.entry("engine.configuration.3-spool-separated-turbofan", 3),
                Map.entry("engine.configuration.hpcgv-turboshaft", 1));
        Map<String, Integer> expectedBleedGroups = Map.ofEntries(
                Map.entry("engine.configuration.ducted-fan", 0),
                Map.entry("engine.configuration.turboshaft", 1),
                Map.entry("engine.configuration.2-spool-turboshaft", 2),
                Map.entry("engine.configuration.free-turbine-turboshaft", 1),
                Map.entry("engine.configuration.mixed-turbofan", 1),
                Map.entry("engine.configuration.separated-turbofan", 1),
                Map.entry("engine.configuration.2-spool-mixed-turbofan", 1),
                Map.entry("engine.configuration.2-spool-separated-turbofan", 1),
                Map.entry("engine.configuration.cfm56", 2),
                Map.entry("engine.configuration.3-spool-mixed-turbofan", 1),
                Map.entry("engine.configuration.3-spool-separated-turbofan", 1),
                Map.entry("engine.configuration.hpcgv-turboshaft", 1));
        for (String configurationId : CONFIGURATION_IDS) {
            Map<String, Object> payload = templatePayload(catalogComponent(configurationId));
            Map<String, Object> scenes = (Map<String, Object>) payload.get("scenes");
            assertEquals(4, ((List<?>) ((Map<?, ?>) scenes.get("workflow")).get("dataEdges")).size(),
                    configurationId + " 第一层 DAG 边数");
            assertEquals(2, ((List<?>) ((Map<?, ?>) scenes.get("design_point")).get("dataEdges")).size(),
                    configurationId + " 设计点层 DAG 边数");
            Map<String, Object> assemblyScene = (Map<String, Object>) scenes.get("physical");
            assertEquals(1, ((List<?>) assemblyScene.get("dataEdges")).size(),
                    configurationId + " 发动机组装 DAG 边数");
            assertEquals(2, ((List<?>) assemblyScene.get("nodes")).size(),
                    configurationId + " 发动机组装仅保留装配关系与 DP 组装");
            assertTrue(((List<Map<String, Object>>) assemblyScene.get("nodes")).stream()
                    .noneMatch(node -> "engine.stage.set-operating-conditions".equals(node.get("componentId"))),
                    configurationId + " 不应保留透传工况节点");
            Map<String, Object> physicalAssemblies = (Map<String, Object>) payload.get("physicalAssemblies");
            Map<String, Object> physicalAssembly = (Map<String, Object>) physicalAssemblies.values().iterator().next();
            assertEquals(expectedFlows.get(configurationId),
                    ((List<?>) physicalAssembly.get("flowRelations")).size(),
                    configurationId + " 物理气路关系数");
            assertEquals(expectedParts.get(configurationId),
                    ((List<?>) physicalAssembly.get("memberNodeIds")).size(),
                    configurationId + " 装配部件数");
            assertEquals(expectedShaftGroups.get(configurationId),
                    ((List<?>) physicalAssembly.get("shaftGroups")).size(),
                    configurationId + " 轴组数");
            assertEquals(expectedBleedGroups.get(configurationId),
                    ((List<?>) physicalAssembly.get("bleedGroups")).size(),
                    configurationId + " 引气组数");
            if (configurationId.endsWith("separated-turbofan")
                    || configurationId.equals("engine.configuration.3-spool-mixed-turbofan")
                    || configurationId.endsWith(".cfm56")) {
                assertPhysicalFlowSequence(configurationId, physicalAssembly, scenes);
                assertPhysicalGroupMembers(configurationId, physicalAssembly, scenes);
                Map<String, Object> designPointScene = (Map<String, Object>) scenes.get("design_point");
                Map<String, Object> designConditions = ((List<Map<String, Object>>) designPointScene
                        .get("nodes")).stream()
                        .filter(node -> "engine.stage.apply-design-conditions".equals(node.get("componentId")))
                        .findFirst().orElseThrow();
                Object expectedPower = configurationId.equals("engine.configuration.separated-turbofan")
                        ? 1000 : (configurationId.startsWith("engine.configuration.3-spool-")
                                ? List.of(0, 0, 0) : List.of(0, 0));
                assertEquals(expectedPower,
                        ((Map<String, Object>) designConditions.get("values")).get("generator_power_kw"),
                        configurationId + " 设计功率默认值");
            }
            Map<String, Object> descriptor = ((List<Map<String, Object>>) assemblyScene.get("nodes")).stream()
                    .filter(node -> node.get("physicalAssemblyId") != null).findFirst().orElseThrow();
            Map<String, Object> relationScene = (Map<String, Object>) scenes.get(descriptor.get("childSceneId"));
            assertEquals(((List<?>) physicalAssembly.get("memberNodeIds")).size(),
                    ((List<?>) relationScene.get("nodes")).size(), configurationId + " 装配部件数");
            Map<String, Object> expanded = RecursiveExecutionGraphExpander
                    .expand(payload, payload.get("physicalAssemblies"));
            // 装配初始化节点存在于 DAG 且携带 V1 装配；气路成员不是 DAG 节点
            Map<?, ?> initializer = ((List<Map<String, Object>>) expanded.get("nodes")).stream()
                    .filter(node -> "engine.stage.initialize-configuration".equals(node.get("componentId")))
                    .findFirst().orElseThrow();
            Map<String, Object> values = (Map<String, Object>) initializer.get("values");
            assertEquals(60, ((Number) values.get("V")).intValue(), configurationId + " 速度直接进入 DP 组装");
            assertEquals(0, ((Number) values.get("M")).intValue(), configurationId + " 马赫数直接进入 DP 组装");
            assertEquals(3000, ((Number) values.get("H")).intValue(), configurationId + " 高度直接进入 DP 组装");
            assertTrue(((List<Map<String, Object>>) expanded.get("nodes")).stream()
                    .noneMatch(node -> "engine.stage.set-operating-conditions".equals(node.get("componentId"))),
                    configurationId + " 透传节点不得进入 MATLAB DAG");
            Map<String, Object> assembly = JSON.parseObject(
                    String.valueOf(values.get("assembly_json")), Map.class);
            assertEquals("engine.physical-scene.v1",
                    String.valueOf(assembly.get("schemaVersion")), configurationId);
            assertTrue(assembly.containsKey("nodes"), configurationId);
            assertTrue(assembly.containsKey("edges"), configurationId);
            assertTrue(assembly.containsKey("relationGroups"), configurationId);
            assertTrue(assembly.containsKey("assemblyDefaults"), configurationId);
            if (configurationId.endsWith("separated-turbofan")
                    || configurationId.endsWith(".cfm56")) {
                Map<String, Object> assemblyDefaults = (Map<String, Object>) assembly.get("assemblyDefaults");
                assertEquals("separated", assemblyDefaults.get("flow"),
                        configurationId + " 分排模式必须进入 assembly_json");
            }
            if (configurationId.endsWith(".cfm56")) {
                Map<String, Object> hpc = ((List<Map<String, Object>>) assembly.get("nodes")).stream()
                        .filter(node -> "hpc".equals(node.get("legacyName")))
                        .findFirst().orElseThrow();
                assertEquals(0.1, ((Number) ((Map<String, Object>) hpc.get("assemblyDefaults"))
                                .get("WA_extraction")).doubleValue(), 1e-12,
                        "CFM56 高压压气机引气量");
            }
            assertTrue(((List<Map<String, Object>>) expanded.get("nodes")).stream()
                    .noneMatch(node -> "project.subsystem.engine-assembly-relations".equals(node.get("componentId"))),
                    configurationId + " 编译期装配节点不得进入 MATLAB DAG");
            for (String legacyField : List.of("F", "SHAFT", "EXT", "NS", "NW", "WA_extraction")) {
                assertTrue(!assembly.containsKey(legacyField),
                        configurationId + " 不应再由 Java 计算 " + legacyField);
            }
            // 气路成员不进入执行 DAG
            Map<String, Object> component = catalogComponent(configurationId);
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

    static List<Map<String, Object>> loadEngineCatalog() throws Exception {
        return MatlabEngineCatalogReader.readDefinitions();
    }

    // List 而非 Set：Set.of 的迭代顺序逐 JVM 加盐，会让 assembly_json 键序漂移。
    private static final java.util.List<String> TRUSTED_NODE_FIELDS = java.util.List.of(
            "id", "componentId", "values", "resources", "nodeKind", "executionKind",
            "functionName", "parameters", "legacyName", "legacyOrder", "assemblyDefaults",
            "childSceneId", "modelEntrypoints", "activeModes", "physicalAssemblyId", "busConfig", "selectorConfig", "phase");

    /**
     * 把目录模板节点过滤为前端编译器实际提交的字段集合，
     * 保证 trusted 夹具与生产请求经过完全相同的编译管线。
     */
    static Map<String, Object> productionShapedPayload(Map<String, Object> payload) {
        Map<String, Object> shaped = new java.util.LinkedHashMap<>(payload);
        Map<String, Object> scenes = (Map<String, Object>) payload.get("scenes");
        Map<String, Object> shapedScenes = new java.util.LinkedHashMap<>();
        for (Map.Entry<String, Object> entry : scenes.entrySet()) {
            Map<String, Object> scene = (Map<String, Object>) entry.getValue();
            Map<String, Object> shapedScene = new java.util.LinkedHashMap<>(scene);
            List<?> nodes = (List<?>) scene.get("nodes");
            List<Object> shapedNodes = new java.util.ArrayList<>();
            for (Object node : nodes) {
                Map<?, ?> raw = (Map<?, ?>) node;
                Map<String, Object> shapedNode = new java.util.LinkedHashMap<>();
                for (String field : TRUSTED_NODE_FIELDS) {
                    if (raw.containsKey(field)) shapedNode.put(field, raw.get(field));
                }
                shapedNodes.add(shapedNode);
            }
            shapedScene.put("nodes", shapedNodes);
            shapedScenes.put(entry.getKey(), shapedScene);
        }
        shaped.put("scenes", shapedScenes);
        return shaped;
    }

    /** Match compileExecutionPayload: scene array, edges (not saved dataEdges), schema 2. */
    static Map<String, Object> frontendSubmissionPayload(Map<String, Object> payload) {
        Map<String, Object> shaped = productionShapedPayload(payload);
        List<Map<String, Object>> scenes = new java.util.ArrayList<>();
        for (Object item : ((Map<?, ?>) shaped.get("scenes")).values()) {
            Map<String, Object> scene = new java.util.LinkedHashMap<>((Map<String, Object>) item);
            scene.put("edges", scene.remove("dataEdges"));
            scenes.add(scene);
        }
        Map<String, Object> root = scenes.stream()
                .filter(scene -> java.util.Objects.equals(shaped.get("rootSceneId"), scene.get("id")))
                .findFirst().orElseThrow();
        shaped.put("schemaVersion", 2);
        shaped.put("scenes", scenes);
        shaped.put("nodes", root.get("nodes"));
        shaped.put("edges", root.get("edges"));
        return shaped;
    }

    /** 与 ModelDeployServiceImpl 相同的目录 VO 化（含 sourceRelativePath 前缀归一）。 */
    static Map<String, MatlabComponentVO> componentLookup() throws Exception {
        Map<String, MatlabComponentVO> lookup = new java.util.LinkedHashMap<>();
        for (MatlabComponentVO component : new ModelDeployServiceImpl(null,null,null,null,null).getMatlabComponents())
            if (component.getId().startsWith("pmsm.")) lookup.put(component.getId(),component);
        for (Map<String, Object> raw : loadEngineCatalog()) {
            MatlabComponentVO vo = JSON.parseObject(JSON.toJSONString(raw), MatlabComponentVO.class);
            String relativePath = vo.getSourceRelativePath();
            if (relativePath != null && !relativePath.isBlank()) {
                vo.setSourceRelativePath("engine/src/" + relativePath.replace('\\', '/'));
            }
            lookup.put(vo.getId(), vo);
        }
        return lookup;
    }

    private static Map<String, Object> catalogComponent(String configurationId) throws Exception {
        List<Map<String, Object>> catalog = loadEngineCatalog();
        return catalog.stream()
                .filter(item -> configurationId.equals(item.get("id")))
                .findFirst()
                .orElseThrow(() -> new IllegalStateException("Missing catalog template: " + configurationId));
    }

    private static Map<String, Object> templatePayload(Map<String, Object> component) {
        Map<String, Object> payload = new java.util.LinkedHashMap<>();
        Map<String, Object> template = (Map<String, Object>) component.get("templateDefinition");
        payload.putAll(template);
        payload.put("schemaVersion", 3);
        return payload;
    }

    /**
     * 把目录模板包装为前端保存时会产生的完整 V3 工程文档。
     */
    @SuppressWarnings("unchecked")
    private static Map<String, Object> projectDocument(Map<String, Object> component) {
        Map<String, Object> template = (Map<String, Object>) component.get("templateDefinition");
        Map<String, Object> scenes = (Map<String, Object>) template.get("scenes");
        String rootSceneId = String.valueOf(template.get("rootSceneId"));
        Map<String, Object> document = new java.util.LinkedHashMap<>();
        document.put("schemaVersion", 3);
        document.put("engineType", "matlab");
        document.put("rootSceneId", rootSceneId);
        document.put("scenes", scenes);
        document.put("physicalAssemblies", template.get("physicalAssemblies"));
        return document;
    }

    private static String canonical(Object value) {
        // The expander builds edge/publicOutput maps with Map.of, whose
        // iteration order is salted per JVM. Canonicalize structurally so the
        // fixtures only change when the expansion result itself changes.
        return JSON.toJSONString(canonicalize(value), JSONWriter.Feature.PrettyFormat)
                .replaceAll("(?m)[ \\t]+$", "") + "\n";
    }

    private static Object canonicalize(Object value) {
        if (value instanceof Map<?, ?> map) {
            Map<String, Object> sorted = new java.util.TreeMap<>();
            map.forEach((key, item) -> sorted.put(String.valueOf(key), canonicalize(item)));
            return sorted;
        }
        if (value instanceof List<?> list) {
            List<Object> items = new java.util.ArrayList<>(list.size());
            list.forEach(item -> items.add(canonicalize(item)));
            return items;
        }
        return value;
    }

    private static String fixtureReadme() {
        return """
                # 发动机 V3 工程与执行图夹具

                由 `EngineGoldenFixtureTest` 在 `-Dgolden.update=true` 时生成：
                每个文件是 `matlab-components/engine/` 分片目录中对应构型
                templateDefinition 的规范化 JSON 或其递归展开结果。

                - `<构型>.project-v2.json`：V3 工程文档（schemaVersion=3，通用 Scene
                  与 project-level physicalAssemblies）。文件名保留历史名称以保持测试入口路径稳定。
                - `<构型>.expanded-graph.json`：`RecursiveExecutionGraphExpander.expand`
                  的输出（展开后节点/边/publicOutputs），即可信校验与提交仿真前的
                  执行图样本。
                - `<构型>.trusted-graph.json`：生产请求字段过滤后，经可信目录校验的执行图。

                MATLAB 数值基线不在本目录生成：初始化、设计点与工况扫描回归
                由 `engine/src/tests/component_engine_backend_scene_tests.m`、
                `component_engine_entry_tests.m` 与 `engine_legacy_baseline.m`
                在 MATLAB 环境中单独运行对比。本目录只验证工程模板和执行图，
                不代表数值求解已经收敛。

                常规测试运行会重新展开并逐字节对比这些文件；若测试失败，说明展开
                或物理装配管线发生了漂移，需要明确决策后运行 `-Dgolden.update=true`
                重新生成。
                """;
    }

    @SuppressWarnings("unchecked")
    private static void assertPhysicalFlowSequence(
            String configurationId,
            Map<String, Object> physicalAssembly,
            Map<String, Object> scenes) {
        Map<String, Object> relationScene = (Map<String, Object>) scenes.get("assembly_relations");
        Map<String, Map<String, Object>> nodesById = ((List<Map<String, Object>>) relationScene.get("nodes"))
                .stream().collect(java.util.stream.Collectors.toMap(
                        node -> String.valueOf(node.get("id")), node -> node));
        List<Map<String, Object>> flowRelations = (List<Map<String, Object>>) physicalAssembly.get("flowRelations");
        List<String> actual = flowRelations.stream().map(edge -> {
            String source = String.valueOf(nodesById.get(String.valueOf(edge.get("sourceNodeId"))).get("legacyName"));
            String target = String.valueOf(nodesById.get(String.valueOf(edge.get("targetNodeId"))).get("legacyName"));
            String role = String.valueOf(edge.getOrDefault("streamRole", ""));
            return source + "->" + target + ":" + role;
        }).toList();
        List<String> expected;
        if (configurationId.equals("engine.configuration.3-spool-mixed-turbofan")) {
            expected = List.of(
                    "inlet->duct:", "duct->fan:", "fan->outer duct:bypass", "outer duct->mixer:bypass",
                    "fan->lpc:core", "lpc->duct:core", "duct->hpc:core", "hpc->burn:core",
                    "burn->hpt:core", "hpt->duct:core", "duct->ipt:core", "ipt->duct:core",
                    "duct->lpt:core", "lpt->mixer:core", "mixer->afterburn:", "afterburn->nozzle:");
        } else if (configurationId.equals("engine.configuration.3-spool-separated-turbofan")) {
            expected = List.of(
                    "inlet->duct:", "duct->fan:", "fan->duct:", "duct->lpc:", "lpc->duct:",
                    "duct->hpc:", "hpc->burn:", "burn->hpt:", "hpt->duct:", "duct->ipt:",
                    "ipt->duct:", "duct->lpt:", "lpt->duct:", "duct->afterburn:", "afterburn->nozzle:");
        } else if (configurationId.equals("engine.configuration.separated-turbofan")) {
            expected = List.of(
                    "inlet->duct:", "duct->fan:", "fan->outer duct:bypass", "fan->hpc:core",
                    "hpc->burn:core", "burn->hpt:core", "hpt->duct:core", "duct->nozzle:core");
        } else if (configurationId.equals("engine.configuration.2-spool-separated-turbofan")) {
            expected = List.of(
                    "inlet->duct:", "duct->fan:", "fan->duct:", "duct->hpc:", "hpc->burn:",
                    "burn->hpt:", "hpt->duct:", "duct->lpt:", "lpt->duct:", "duct->afterburn:",
                    "afterburn->nozzle:");
        } else {
            expected = List.of(
                    "inlet->duct:", "duct->fan:", "fan->duct:", "duct->lpc:", "lpc->duct:",
                    "duct->hpc:", "hpc->burn:", "burn->hpt:", "hpt->duct:", "duct->lpt:",
                    "lpt->duct:", "duct->nozzle:");
        }
        assertEquals(expected, actual, configurationId + " 气路端点及顺序");
        assertEquals(flowRelations.size(), new java.util.HashSet<>(flowRelations.stream()
                .map(edge -> edge.get("id")).toList()).size(), configurationId + " 气路边 ID 必须唯一");
        assertTrue(flowRelations.stream().allMatch(edge -> nodesById.containsKey(String.valueOf(edge.get("sourceNodeId")))
                        && nodesById.containsKey(String.valueOf(edge.get("targetNodeId")))),
                configurationId + " 气路关系端点必须指向本构型部件");
    }

    @SuppressWarnings("unchecked")
    private static void assertPhysicalGroupMembers(
            String configurationId,
            Map<String, Object> physicalAssembly,
            Map<String, Object> scenes) {
        Map<String, Object> relationScene = (Map<String, Object>) scenes.get("assembly_relations");
        Map<String, Map<String, Object>> nodesById = ((List<Map<String, Object>>) relationScene.get("nodes"))
                .stream().collect(java.util.stream.Collectors.toMap(
                        node -> String.valueOf(node.get("id")), node -> node));
        List<List<String>> expectedShafts;
        List<List<String>> expectedBleeds;
        if (configurationId.equals("engine.configuration.3-spool-mixed-turbofan")
                || configurationId.equals("engine.configuration.3-spool-separated-turbofan")) {
            expectedShafts = List.of(List.of("fan", "lpt"), List.of("lpc", "ipt"), List.of("hpc", "hpt"));
            expectedBleeds = List.of(List.of("hpc", "hpt", "lpt"));
        } else if (configurationId.equals("engine.configuration.separated-turbofan")) {
            expectedShafts = List.of(List.of("fan", "hpc", "hpt"));
            expectedBleeds = List.of(List.of("hpc", "hpt"));
        } else if (configurationId.equals("engine.configuration.2-spool-separated-turbofan")) {
            expectedShafts = List.of(List.of("fan", "lpt"), List.of("hpc", "hpt"));
            expectedBleeds = List.of(List.of("hpc", "hpt", "lpt"));
        } else {
            expectedShafts = List.of(List.of("fan", "lpc", "lpt"), List.of("hpc", "hpt"));
            expectedBleeds = List.of(List.of("fan", "hpt", "lpt"), List.of("hpc", "hpt"));
        }
        assertEquals(expectedShafts, groupLegacyMembers(physicalAssembly.get("shaftGroups"), nodesById),
                configurationId + " 轴组成员和顺序");
        assertEquals(expectedBleeds, groupLegacyMembers(physicalAssembly.get("bleedGroups"), nodesById),
                configurationId + " 引气组成员和顺序");
    }

    @SuppressWarnings("unchecked")
    private static List<List<String>> groupLegacyMembers(
            Object groupsValue, Map<String, Map<String, Object>> nodesById) {
        return ((List<Map<String, Object>>) groupsValue).stream()
                .map(group -> ((List<String>) group.get("memberNodeIds")).stream()
                        .map(nodeId -> String.valueOf(nodesById.get(nodeId).get("legacyName")))
                        .toList())
                .toList();
    }
}
