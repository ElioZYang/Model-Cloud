package com.modelcloud.modules.business.service.impl;

import com.alibaba.fastjson2.JSON;
import com.modelcloud.modules.business.model.dto.MatlabComponentVO;
import com.modelcloud.modules.business.service.MatlabConfigService;
import org.junit.jupiter.api.Test;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;

class MatlabCatalogLoadTest {
    @Test
    void independentAndHybridLibrariesKeepDistinctIdentitiesAndSources() {
        var components = new ModelDeployServiceImpl(null, null, null, null, null).getMatlabComponents();
        var independent = components.stream().filter(item -> "PMSM(独立)".equals(item.getLibrary())).toList();
        assertEquals(46, independent.size());
        assertEquals(components.size(), components.stream().map(MatlabComponentVO::getId).distinct().count());
        assertTrue(independent.stream().allMatch(item -> item.getFunctionName().startsWith("mc_pmsm_ind_")
                && item.getSourceRelativePath().startsWith("PMSM_Independent/src/")));
        assertTrue(independent.stream().anyMatch(item -> "pmsm.main-flow.design".equals(item.getId())));
        assertTrue(independent.stream().anyMatch(item -> "pmsm.main-flow.off-design".equals(item.getId())));
        assertTrue(components.stream().anyMatch(item -> "pmsm.subsystem.hpcgv".equals(item.getId())
                && "PMSM(混动发动机)".equals(item.getLibrary())));
    }

    @Test
    void configurationTemplatesValidateAgainstTheirOwnModelSchema() throws Exception {
        var service = new MatlabConfigService(null, null, null);
        String independent = "pmsm.workflow.motor-configuration";
        String hybrid = "pmsm.configuration";
        assertEquals("1.0", service.schema(independent).getString("version"));
        assertEquals("2.0", service.schema(hybrid).getString("version"));
        assertFalse(java.util.Arrays.equals(service.templateBytes(independent), service.templateBytes(hybrid)));
        var validator = MatlabConfigService.class.getDeclaredMethod("validateWorkbook", byte[].class,
                com.alibaba.fastjson2.JSONObject.class);
        validator.setAccessible(true);
        for (String componentId : List.of(independent, hybrid)) {
            assertDoesNotThrow(() -> validator.invoke(service, service.templateBytes(componentId), service.schema(componentId)));
        }
    }

    @Test
    void loadsCompleteEngineAndPmsmCatalogs() throws Exception {
        for (var entry : MatlabEngineCatalogReader.readDefinitions()) {
            try {
                JSON.parseObject(JSON.toJSONString(entry), MatlabComponentVO.class);
            } catch (Exception error) {
                throw new AssertionError("Cannot parse component " + entry.get("id"), error);
            }
        }
        ModelDeployServiceImpl service = new ModelDeployServiceImpl(null, null, null, null, null);
        var components = service.getMatlabComponents();
        assertTrue(components.stream().anyMatch(item ->
                "engine.configuration.ducted-fan".equals(item.getId())));
        assertTrue(components.stream().anyMatch(item ->
                "engine.configuration.turboshaft".equals(item.getId())));
        assertTrue(components.stream().anyMatch(item ->
                "engine.configuration.mixed-turbofan".equals(item.getId())));
        assertTrue(components.stream().anyMatch(item ->
                "engine.configuration.3-spool-mixed-turbofan".equals(item.getId())));
        assertTrue(components.stream().anyMatch(item ->
                "engine.configuration.3-spool-separated-turbofan".equals(item.getId())));
        assertEquals(List.of(
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
                        "engine.configuration.hpcgv-turboshaft"),
                components.stream().filter(item -> item.getCatalogOrder() != null)
                        .sorted(java.util.Comparator.comparing(MatlabComponentVO::getCatalogOrder))
                        .map(MatlabComponentVO::getId).toList());
        assertTrue(components.stream().anyMatch(item ->
                item.getId() != null && item.getId().startsWith("pmsm.")));
    }
}
