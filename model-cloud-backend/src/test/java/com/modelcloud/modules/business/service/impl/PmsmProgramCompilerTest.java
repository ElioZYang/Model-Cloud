package com.modelcloud.modules.business.service.impl;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.TypeReference;
import com.modelcloud.modules.business.model.dto.MatlabComponentVO;
import java.nio.file.*;
import java.util.*;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class PmsmProgramCompilerTest {
    private Map<String,MatlabComponentVO> catalog() throws Exception {
        return EngineGoldenFixtureTest.componentLookup();
    }
    private Map<String,Object> project() throws Exception {
        Map<String,Object> project=JSON.parseObject(Files.readString(Path.of("../contracts/matlab/fixtures/pmsm/standalone.project-v3.json")),
            new TypeReference<Map<String,Object>>(){});
        // Match the frontend execution payload: presentation stays in projectData.
        for(Object scene:((Map<?,?>)project.get("scenes")).values())
            for(Object item:(List<?>)((Map<?,?>)scene).get("nodes")) {
                ((Map<?,?>)item).remove("position"); ((Map<?,?>)item).remove("instanceName");
            }
        return project;
    }
    @Test void compilesEditableEntrypointsAndKeepsThemOutOfOuterDag() throws Exception {
        var graph=new MatlabTrustedGraphCompiler(catalog()::get).buildTrustedGraph(project());
        assertEquals(3,((List<?>)graph.get("modelPrograms")).size());
        var nodes=(List<Map<String,Object>>)graph.get("nodes");
        assertTrue(nodes.stream().anyMatch(n->"pmsm.program.execute".equals(n.get("componentId"))));
        assertFalse(nodes.stream().anyMatch(n->"pmsm.stage.main_dimensions".equals(n.get("componentId"))));
        for (var program:(List<Map<String,Object>>)graph.get("modelPrograms")) {
            var entries=(Map<String,Map<String,Object>>)program.get("entries");
            for (String mode:List.of("design","offdesign","thermal")) {
                var entry=entries.get(mode);
                assertEquals(mode,entry.get("analysisMode"));
                var ids=((List<Map<String,Object>>)entry.get("nodes")).stream().map(n->n.get("componentId").toString()).toList();
                assertFalse(ids.contains("pmsm.c.merge"));
                assertEquals(mode.equals("design"),ids.contains("pmsm.c.prepare-design"));
                assertEquals(mode.equals("offdesign"),ids.contains("pmsm.c.off-operating"));
                assertEquals(mode.equals("thermal"),ids.contains("pmsm.c.existing-model"));
            }
        }
        Files.createDirectories(Path.of("target/pmsm"));
        Files.writeString(Path.of("target/pmsm/standalone.trusted-graph.json"),JSON.toJSONString(graph));
    }
    @Test void rejectsBrokenEntrypointWiring() throws Exception {
        var project=project();
        var scenes=(Map<String,Object>)project.get("scenes");
        var design=(Map<String,Object>)scenes.get("design_instance_design");
        ((List<?>)design.get("dataEdges")).remove(0);
        assertThrows(RuntimeException.class,()->new MatlabTrustedGraphCompiler(catalog()::get).buildTrustedGraph(project));
    }
    @Test void sceneArraysFromTheProductionFrontendCompile() throws Exception {
        var project=EngineGoldenFixtureTest.frontendSubmissionPayload(project());
        assertEquals(3,((List<?>)new MatlabTrustedGraphCompiler(catalog()::get)
            .buildTrustedGraph(project).get("modelPrograms")).size());
    }
    @Test void hpcgvCanvasEdgesCompileToTheSameGraphWithoutMutatingTheRequest() throws Exception {
        var project=JSON.parseObject(Files.readString(Path.of("../contracts/matlab/fixtures/pmsm/hpcgv.project-v3.json")),
            new TypeReference<Map<String,Object>>(){});
        var compiler=new MatlabTrustedGraphCompiler(catalog()::get);
        var expected=compiler.buildTrustedGraph(EngineGoldenFixtureTest.productionShapedPayload(project));
        var canvas=EngineGoldenFixtureTest.frontendSubmissionPayload(project);
        String before=JSON.toJSONString(canvas);
        assertEquals(expected,compiler.buildTrustedGraph(canvas));
        assertEquals(before,JSON.toJSONString(canvas));
    }
    @Test void rewiredEngineUsesTheSelectedInternalCoolingComponent() throws Exception {
        var project=JSON.parseObject(Files.readString(Path.of("../contracts/matlab/fixtures/pmsm/hpcgv.project-v3.json")),
            new TypeReference<Map<String,Object>>(){});
        var scenes=(Map<String,Object>)project.get("scenes");
        var design=(Map<String,Object>)scenes.get("hpcgv_thermal");
        String previous="hpcgv_cooling_network";
        for(var node:(List<Map<String,Object>>)design.get("nodes")) if(previous.equals(node.get("id"))) {
            node.put("componentId","pmsm.c.network-air");
        }
        var graph=new MatlabTrustedGraphCompiler(catalog()::get)
            .buildTrustedGraph(EngineGoldenFixtureTest.productionShapedPayload(project));
        Files.createDirectories(Path.of("target/pmsm"));
        Files.writeString(Path.of("target/pmsm/hpcgv-rewired.trusted-graph.json"),JSON.toJSONString(graph));
        assertEquals(1,((List<?>)graph.get("modelPrograms")).size());
    }
}
