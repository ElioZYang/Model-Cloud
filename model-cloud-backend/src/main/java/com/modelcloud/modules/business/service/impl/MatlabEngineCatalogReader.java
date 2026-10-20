package com.modelcloud.modules.business.service.impl;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.TypeReference;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;

/** Reads the engine component catalog from one JSON definition per resource. */
final class MatlabEngineCatalogReader {
    private static final List<String> DIRECTORY_ORDER = List.of(
            "physical", "stages", "workflows", "configurations");
    private static final String RESOURCE_ROOT = "classpath*:matlab-components/engine/";

    private MatlabEngineCatalogReader() {}

    static List<Map<String, Object>> readDefinitions() throws IOException {
        PathMatchingResourcePatternResolver resolver =
                new PathMatchingResourcePatternResolver();
        List<Map<String, Object>> definitions = new ArrayList<>();
        for (String directory : DIRECTORY_ORDER) {
            String pattern = RESOURCE_ROOT + directory + "/*.json";
            Resource[] resources;
            try {
                resources = resolver.getResources(pattern);
            } catch (IOException error) {
                throw new IOException("读取发动机组件目录失败: " + pattern, error);
            }
            java.util.Arrays.sort(resources, Comparator.comparing(
                    Resource::getFilename, Comparator.nullsLast(String::compareTo)));
            for (Resource resource : resources) {
                String resourcePath = resource.getDescription();
                try (InputStream input = resource.getInputStream()) {
                    String content = new String(input.readAllBytes(), StandardCharsets.UTF_8);
                    Map<String, Object> definition = JSON.parseObject(
                            content, new TypeReference<Map<String, Object>>() {});
                    if (definition == null) {
                        throw new IllegalArgumentException("JSON 内容不是对象");
                    }
                    definitions.add(definition);
                } catch (Exception error) {
                    throw new IOException("读取发动机组件文件失败: " + resourcePath, error);
                }
            }
        }
        return List.copyOf(definitions);
    }
}
