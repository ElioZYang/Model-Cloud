package com.modelcloud.modules.business.service.impl;

import com.alibaba.fastjson2.JSON;
import org.junit.jupiter.api.Test;
import java.util.List;
import java.util.Map;

class V3DiagTest {
    @Test
    @SuppressWarnings("unchecked")
    void diagnoseTrustedExpansion() throws Exception {
        Map<String, Object> component = EngineGoldenFixtureTest.loadEngineCatalog().stream()
                .filter(item -> "engine.configuration.ducted-fan".equals(item.get("id")))
                .findFirst().orElseThrow();
        Map<String, Object> template = (Map<String, Object>) component.get("templateDefinition");
        Map<String, Object> payload = new java.util.LinkedHashMap<>(template);
        payload.put("schemaVersion", 3);
        payload.put("physicalAssemblies", template.get("physicalAssemblies"));
        // 直接复现 fixture 测试的 productionShaped 路径
        try {
            Map<String, com.modelcloud.modules.business.model.dto.MatlabComponentVO> catalogLookup =
                    EngineGoldenFixtureTest.componentLookup();
            Map<String, Object> trusted = new MatlabTrustedGraphCompiler(catalogLookup::get)
                    .buildTrustedGraph(EngineGoldenFixtureTest.productionShapedPayload(payload));
            System.out.println("[DIAG] trusted nodes: "
                    + ((List<?>) trusted.get("nodes")).size());
        } catch (Exception failure) {
            org.junit.jupiter.api.Assertions.fail("可信构型展开失败", failure);
            System.out.println("[DIAG] FAILED: " + failure.getMessage());
            // 再跑一次 expand-only 看节点列表
            Map<String, Object> expanded = MatlabHierarchyCompiler.expand(payload, payload.get("physicalAssemblies"));
            System.out.println("[DIAG] expand-only nodes: " + ((List<?>) expanded.get("nodes")).stream()
                    .map(n -> String.valueOf(((Map<?, ?>) n).get("id"))).toList());
            System.out.println("[DIAG] expand-only edges: " + JSON.toJSONString(
                    ((List<?>) expanded.get("edges")).stream().map(e -> {
                        Map<?, ?> m = (Map<?, ?>) e;
                        return m.get("sourceNodeId") + "->" + m.get("targetNodeId");
                    }).toList()));
        }
    }
}
