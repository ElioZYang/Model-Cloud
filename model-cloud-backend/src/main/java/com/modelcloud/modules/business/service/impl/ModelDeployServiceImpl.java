package com.modelcloud.modules.business.service.impl;

import cn.hutool.core.util.StrUtil;
import com.alibaba.fastjson2.JSON;
import com.modelcloud.common.exception.BusinessException;
import com.modelcloud.common.tools.SecurityUtils;
import com.modelcloud.modules.business.mapper.BsModelingProjectMapper;
import com.modelcloud.modules.business.mapper.BsSimulationTaskMapper;
import com.modelcloud.modules.business.model.domain.BsComponentParseMeta;
import com.modelcloud.modules.business.model.domain.BsComponentParseMetaOmc;
import com.modelcloud.modules.business.model.dto.ComponentVO;
import com.modelcloud.modules.business.model.dto.MatlabComponentVO;
import com.modelcloud.modules.business.model.domain.BsModelingProject;
import com.modelcloud.modules.business.model.domain.BsSimulationTask;
import com.modelcloud.modules.business.model.request.ModelingProjectRequest;
import com.modelcloud.modules.business.model.request.SimulationRequest;
import com.modelcloud.modules.business.repository.BsComponentParseMetaOmcRepository;
import com.modelcloud.modules.business.repository.BsComponentParseMetaRepository;
import com.modelcloud.modules.business.service.ModelDeployService;
import com.modelcloud.modules.business.service.MatlabConfigService;
import com.mybatisflex.core.paginate.Page;
import com.mybatisflex.core.query.QueryWrapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.net.URLEncoder;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.PriorityQueue;
import java.util.Set;
import java.util.UUID;
import java.util.regex.Pattern;
import java.util.stream.Stream;

import static com.modelcloud.modules.business.model.domain.table.BsModelingProjectTableDef.BS_MODELING_PROJECT;

/**
 * 模型部署服务实现类
 * 
 * @author model-cloud
 */
@Slf4j
@Service
public class ModelDeployServiceImpl implements ModelDeployService {
    private static final Pattern ARTIFACT_ID = Pattern.compile("^[A-Za-z0-9_-]{1,128}$");
    private static final Set<String> SUPPORTED_MODULES = Set.of("Electrical", "Mechanics", "Blocks", "Math");
    /** PMSM remains an array catalog; engine definitions are discovered by directory. */
    private static final List<MatlabComponentCatalog> MATLAB_COMPONENT_CATALOGS = List.of(
            new MatlabComponentCatalog("matlab-components/pmsm-components.json", "PMSM(混动发动机)", "PMSM/src"),
            new MatlabComponentCatalog("matlab-components/pmsm-independent-components.json", "PMSM(独立)", "PMSM_Independent/src"));

    private record MatlabComponentCatalog(String resourcePath, String library, String sourcePrefix) {}
    
    private final BsComponentParseMetaOmcRepository bsComponentParseMetaOmcRepository;
    private final BsComponentParseMetaRepository bsComponentParseMetaRepository;
    private final BsModelingProjectMapper projectMapper;
    private final BsSimulationTaskMapper taskMapper;
    private final MatlabConfigService matlabConfigService;
    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${model-cloud.simulation.base-url:http://localhost:8000/api/v1/simulation}")
    private String simulationBaseUrl;
    @Value("${model-cloud.component.icon-dir:./src/main/resources/static/component_icon}")
    private String componentIconDir;
    @Value("${model-cloud.component.source-dir:./src/main/resources/static/component_source}")
    private String componentSourceDir;
    @Value("${model-cloud.component.icon-url-prefix:/api/component_icon}")
    private String componentIconUrlPrefix;
    @Value("${model-cloud.matlab-component.icon-url-prefix:/api/matlab_component_icon}")
    private String matlabComponentIconUrlPrefix;

    private volatile Map<String, Set<String>> moduleIconFileNames = null;
    private volatile List<MatlabComponentVO> matlabComponents = null;
    
    public ModelDeployServiceImpl(
            BsComponentParseMetaOmcRepository bsComponentParseMetaOmcRepository,
            BsComponentParseMetaRepository bsComponentParseMetaRepository,
            BsModelingProjectMapper projectMapper,
            BsSimulationTaskMapper taskMapper,
            MatlabConfigService matlabConfigService) {
        this.bsComponentParseMetaOmcRepository = bsComponentParseMetaOmcRepository;
        this.bsComponentParseMetaRepository = bsComponentParseMetaRepository;
        this.projectMapper = projectMapper;
        this.taskMapper = taskMapper;
        this.matlabConfigService = matlabConfigService;
    }
    
    private static final Set<String> EXCLUDE_PATH_PARTS = Set.of(
            "Interfaces", "BaseClasses", "Internal", "Types", "Icons", "Examples", "UsersGuide");

    @Override
    public List<ComponentVO> getComponents(String category, String keyword) {
        List<ComponentVO> list = loadComponentsFromMongo(category, keyword);
        if (!list.isEmpty()) {
            list.sort((a, b) -> String.CASE_INSENSITIVE_ORDER.compare(
                    StrUtil.blankToDefault(a.getClassName(), ""),
                    StrUtil.blankToDefault(b.getClassName(), "")));
            return list;
        }

        List<ComponentVO> scannedList = new ArrayList<>();
        Path sourceRoot = Path.of(componentSourceDir).normalize();
        for (String module : SUPPORTED_MODULES) {
            Path moduleDir = sourceRoot.resolve(module);
            if (!Files.exists(moduleDir) || !Files.isDirectory(moduleDir)) {
                continue;
            }
            try (Stream<Path> stream = Files.walk(moduleDir)) {
                stream.filter(Files::isRegularFile)
                        .filter(p -> p.getFileName().toString().toLowerCase().endsWith(".mo"))
                        .filter(p -> !"package.mo".equalsIgnoreCase(p.getFileName().toString()))
                        .filter(p -> {
                            String rel = sourceRoot.relativize(p).toString().replace("\\", "/");
                            for (String exc : EXCLUDE_PATH_PARTS) {
                                if (rel.contains("/" + exc + "/") || rel.startsWith(exc + "/")) {
                                    return false;
                                }
                            }
                            return true;
                        })
                        .forEach(moPath -> {
                            try {
                                ComponentVO vo = buildComponentVO(moPath, sourceRoot);
                                if (vo != null && matchesFilter(vo, category, keyword)) {
                                    scannedList.add(vo);
                                }
                            } catch (Exception e) {
                                log.debug("跳过组件 {}: {}", moPath, e.getMessage());
                            }
                        });
            } catch (Exception e) {
                log.error("扫描组件目录失败 module={}", module, e);
                throw new BusinessException("扫描组件目录失败: " + e.getMessage());
            }
        }
        scannedList.sort((a, b) -> String.CASE_INSENSITIVE_ORDER.compare(
                StrUtil.blankToDefault(a.getClassName(), ""),
                StrUtil.blankToDefault(b.getClassName(), "")));
        return scannedList;
    }

    @Override
    public List<MatlabComponentVO> getMatlabComponents() {
        List<MatlabComponentVO> cached = matlabComponents;
        if (cached != null) {
            return cached;
        }
        synchronized (this) {
            if (matlabComponents != null) {
                return matlabComponents;
            }
            List<MatlabComponentVO> loaded = new ArrayList<>();
            try {
                for (MatlabComponentCatalog catalog : MATLAB_COMPONENT_CATALOGS) {
                    ClassPathResource resource = new ClassPathResource(catalog.resourcePath());
                    try (InputStream inputStream = resource.getInputStream()) {
                        String content = new String(inputStream.readAllBytes(), StandardCharsets.UTF_8);
                        List<MatlabComponentVO> catalogComponents = JSON.parseArray(
                                content, MatlabComponentVO.class);
                        for (MatlabComponentVO component : catalogComponents) {
                            component.setLibrary(catalog.library());
                            component.setSourceRelativePath(normalizeMatlabSourcePath(
                                    component.getSourceRelativePath(), catalog.sourcePrefix()));
                            loaded.add(component);
                        }
                    }
                }
                for (Map<String, Object> definition : MatlabEngineCatalogReader.readDefinitions()) {
                    MatlabComponentVO component = JSON.parseObject(
                            JSON.toJSONString(definition), MatlabComponentVO.class);
                    component.setLibrary("航空发动机");
                    component.setSourceRelativePath(normalizeMatlabSourcePath(
                            component.getSourceRelativePath(), "engine/src"));
                    loaded.add(component);
                }
                String prefix = StrUtil.blankToDefault(
                        matlabComponentIconUrlPrefix, "/api/matlab_component_icon")
                        .replaceAll("/+$", "");
                Set<String> componentIds = new HashSet<>();
                for (MatlabComponentVO component : loaded) {
                    validateMatlabComponentDefinition(component, componentIds);
                    component.setCoverImage(prefix + "/" + component.getIconRelativePath());
                    component.setFallbackIcon(prefix + "/" + component.getFallbackIconRelativePath());
                }
                matlabComponents = List.copyOf(loaded);
                return matlabComponents;
            } catch (Exception e) {
                log.error("加载MATLAB组件元数据失败", e);
                throw new BusinessException("加载MATLAB组件元数据失败: " + e.getMessage());
            }
        }
    }

    private String normalizeMatlabSourcePath(String sourcePath, String sourcePrefix) {
        if (StrUtil.isBlank(sourcePath)) return sourcePath;
        String normalized = sourcePath.replace('\\', '/');
        return sourcePrefix.replaceAll("/+$", "") + "/" + normalized;
    }

    private MatlabComponentVO getMatlabComponent(String componentId) {
        return getMatlabComponents().stream()
                .filter(component -> component.getId().equals(componentId))
                .findFirst()
                .orElseThrow(() -> new BusinessException("未知MATLAB组件: " + componentId));
    }

    private void validateMatlabComponentDefinition(
            MatlabComponentVO component, Set<String> componentIds) {
        if (component == null || StrUtil.isBlank(component.getId())
                || !componentIds.add(component.getId())) {
            throw new BusinessException("MATLAB组件ID为空或重复: "
                    + (component == null ? "null" : component.getId()));
        }
        if (StrUtil.isBlank(component.getLibrary()) || StrUtil.isBlank(component.getCategory())) {
            throw new BusinessException("MATLAB组件库或类别为空: " + component.getId());
        }
        boolean catalogOnly = "subsystem".equals(component.getComponentKind())
                || "workflowSubsystem".equals(component.getComponentKind())
                || "physicalComponent".equals(component.getComponentKind())
                ;
        if (component.getInputs() == null) component.setInputs(List.of());
        if (component.getOutputs() == null) component.setOutputs(List.of());
        if (catalogOnly) {
            validatePortDefinitions(component.getInputs(), "输入", component.getId());
            validatePortDefinitions(component.getOutputs(), "输出", component.getId());
            if (component.getResources() == null) component.setResources(List.of());
            return;
        }
        if (!matlabIdentifier(component.getFunctionName())) {
            throw new BusinessException("MATLAB函数名不合法: " + component.getId());
        }
        String sourcePath = component.getSourceRelativePath();
        if (StrUtil.isBlank(sourcePath) || sourcePath.startsWith("/")
                || sourcePath.startsWith("\\") || sourcePath.contains("..")
                || !sourcePath.replace('\\', '/').endsWith("/" + component.getFunctionName() + ".m")) {
            throw new BusinessException("MATLAB组件源码路径不合法: " + component.getId());
        }
        if (!new ClassPathResource(
                "static/matlab_component_source/" + sourcePath.replace('\\', '/')).exists()) {
            throw new BusinessException("MATLAB组件源码不存在: " + sourcePath);
        }
        if (component.getOutputs().isEmpty()) {
            throw new BusinessException("MATLAB组件输出不能为空: " + component.getId());
        }
        if (component.getResources() == null) component.setResources(List.of());

        Set<String> inputNames = validatePortDefinitions(component.getInputs(), "输入", component.getId());
        Set<String> outputNames = validatePortDefinitions(component.getOutputs(), "输出", component.getId());
        Set<String> resourceNames = new HashSet<>();
        for (MatlabComponentVO.ResourceVO resource : component.getResources()) {
            if (resource == null || !matlabIdentifier(resource.getName())
                    || !resourceNames.add(resource.getName())) {
                throw new BusinessException("MATLAB组件资源定义不正确: " + component.getId());
            }
        }

        MatlabComponentVO.InvocationVO invocation = component.getInvocation();
        if (invocation == null || !component.getFunctionName().equals(invocation.getFunction())
                || invocation.getArguments() == null || invocation.getReturns() == null
                || invocation.getReturns().isEmpty()) {
            throw new BusinessException("MATLAB组件invocation定义不正确: " + component.getId());
        }
        for (MatlabComponentVO.ArgumentVO argument : invocation.getArguments()) {
            if ("input".equals(argument.getSource())) {
                if (!inputNames.contains(argument.getName())) {
                    throw new BusinessException("invocation引用不存在的输入: " + argument.getName());
                }
            } else if ("object".equals(argument.getSource())) {
                for (MatlabComponentVO.BindingVO binding :
                        argument.getBindings() == null ? List.<MatlabComponentVO.BindingVO>of() : argument.getBindings()) {
                    validateInvocationBinding(binding, inputNames, resourceNames, component.getId());
                }
            } else {
                throw new BusinessException("invocation参数source不受支持: " + component.getId());
            }
        }
        Set<String> mappedOutputs = new HashSet<>();
        Set<Integer> returnIndexes = new HashSet<>();
        for (MatlabComponentVO.ReturnVO result : invocation.getReturns()) {
            if (result.getReturnIndex() == null || result.getReturnIndex() < 0
                    || !outputNames.contains(result.getOutput())
                    || !mappedOutputs.add(result.getOutput())) {
                throw new BusinessException("invocation返回值定义不正确: " + component.getId());
            }
            if (StrUtil.isNotBlank(result.getPath()) && !matlabFieldPath(result.getPath())) {
                throw new BusinessException("invocation返回路径不合法: " + result.getPath());
            }
            // Physical fan ports may expose core and bypass handles that
            // reference the same MATLAB return value as the regular output.
            // Output names remain unique and every declared output is mapped.
            returnIndexes.add(result.getReturnIndex());
        }
        if (!mappedOutputs.equals(outputNames)) {
            throw new BusinessException("invocation未完整映射组件输出: " + component.getId());
        }
        int maxReturnIndex = returnIndexes.stream().max(Integer::compareTo).orElse(-1);
        for (int index = 0; index <= maxReturnIndex; index++) {
            if (!returnIndexes.contains(index)) {
                throw new BusinessException("invocation returnIndex必须从0连续编号: " + component.getId());
            }
        }
    }

    private Set<String> validatePortDefinitions(
            List<MatlabComponentVO.PortVO> ports, String direction, String componentId) {
        Set<String> names = new HashSet<>();
        for (MatlabComponentVO.PortVO port : ports) {
            if (port == null || !matlabIdentifier(port.getName()) || StrUtil.isBlank(port.getType())
                    || !names.add(port.getName())) {
                throw new BusinessException("MATLAB组件" + direction + "端口定义不正确: " + componentId);
            }
        }
        return names;
    }

    private void validateInvocationBinding(
            MatlabComponentVO.BindingVO binding, Set<String> inputNames,
            Set<String> resourceNames, String componentId) {
        if (binding == null || !matlabFieldPath(binding.getTarget())) {
            throw new BusinessException("invocation对象绑定target不合法: " + componentId);
        }
        if ("input".equals(binding.getSource())) {
            if (!inputNames.contains(binding.getName())) {
                throw new BusinessException("invocation对象绑定引用不存在的输入: " + binding.getName());
            }
        } else if ("resource".equals(binding.getSource())) {
            if (!resourceNames.contains(binding.getName()) || !matlabIdentifier(binding.getProperty())) {
                throw new BusinessException("invocation对象绑定引用不存在的资源: " + binding.getName());
            }
        } else {
            throw new BusinessException("invocation对象绑定source不受支持: " + componentId);
        }
    }

    private boolean matlabIdentifier(String value) {
        return value != null && value.matches("^[A-Za-z][A-Za-z0-9_]*$");
    }

    private boolean matlabFieldPath(String value) {
        return value != null && value.matches("^[A-Za-z][A-Za-z0-9_]*(\\.[A-Za-z][A-Za-z0-9_]*)*$");
    }

    private Map<String, Object> buildTrustedMatlabGraph(Map<String, Object> rawPayload) {
        return new MatlabTrustedGraphCompiler(this::getMatlabComponent).buildTrustedGraph(rawPayload);
    }

    @SuppressWarnings("unchecked")
    private void materializeMatlabResources(
            Map<String, Object> payload, Long userId, String taskId) {
        Object rawNodes = payload.get("nodes");
        if (!(rawNodes instanceof List<?> nodes)) return;
        for (Object rawNode : nodes) {
            if (!(rawNode instanceof Map<?, ?> map)) continue;
            Map<String, Object> node = (Map<String, Object>) map;
            Object rawResources = node.get("resources");
            if (!(rawResources instanceof Map<?, ?> resources)) continue;
            Map<String, Object> resolved = new LinkedHashMap<>();
            for (Map.Entry<?, ?> entry : resources.entrySet()) {
                if (!(entry.getValue() instanceof Map<?, ?> metadata)) continue;
                Object configId = metadata.get("configId");
                if (configId == null || String.valueOf(configId).isBlank()) continue;
                resolved.put(String.valueOf(entry.getKey()),
                        matlabConfigService.materializeTaskSnapshot(
                                userId, String.valueOf(configId), taskId));
            }
            node.put("resources", resolved);
        }
    }

    @Override
    public Map<String, Object> getComponentsPaged(String category, String keyword, String module, int pageNum, int pageSize) {
        int safePageNum = Math.max(pageNum, 1);
        int safePageSize = Math.max(Math.min(pageSize, 500), 1);
        List<ComponentVO> all = getComponents(category, keyword);
        List<ComponentVO> filtered = all;
        if (StrUtil.isNotBlank(module)) {
            String modulePrefix = "Modelica." + module.trim() + ".";
            filtered = all.stream()
                    .filter(c -> StrUtil.blankToDefault(c.getClassName(), "").startsWith(modulePrefix))
                    .toList();
        }
        int total = filtered.size();
        int from = Math.min((safePageNum - 1) * safePageSize, total);
        int to = Math.min(from + safePageSize, total);
        List<ComponentVO> records = filtered.subList(from, to);

        Map<String, Object> result = new HashMap<>();
        result.put("records", records);
        result.put("total", total);
        result.put("pageNum", safePageNum);
        result.put("pageSize", safePageSize);
        result.put("modules", SUPPORTED_MODULES);
        return result;
    }

    private List<ComponentVO> loadComponentsFromMongo(String category, String keyword) {
        Map<String, ComponentVO> map = new HashMap<>();
        try {
            for (BsComponentParseMetaOmc doc : bsComponentParseMetaOmcRepository.findAll()) {
                if (doc == null || StrUtil.isBlank(doc.getId())) {
                    continue;
                }
                if (!isSupportedClassName(doc.getId())) {
                    continue;
                }
                ComponentVO vo = toComponentVOFromMeta(
                        doc.getId(), doc.getName(), doc.getDescription(), doc.getSourcePath(), doc.getIndexPath(), doc.getIconPath(),
                        doc.getRestriction(), doc.getNodeType(), doc.getPartial(), doc.getLeaf(), doc.getDraggable(),
                        doc.getConnectable(), doc.getParentClassName(), doc.getChildrenCount());
                if (vo != null && matchesFilter(vo, category, keyword)) {
                    map.put(vo.getId(), vo);
                }
            }
            if (map.isEmpty()) {
                for (BsComponentParseMeta doc : bsComponentParseMetaRepository.findAll()) {
                    if (doc == null || StrUtil.isBlank(doc.getId())) {
                        continue;
                    }
                    if (!isSupportedClassName(doc.getId())) {
                        continue;
                    }
                    ComponentVO vo = toComponentVOFromMeta(
                            doc.getId(), doc.getName(), doc.getDescription(), doc.getSourcePath(), doc.getIndexPath(), doc.getIconPath(),
                            doc.getRestriction(), doc.getNodeType(), doc.getPartial(), doc.getLeaf(), doc.getDraggable(),
                            doc.getConnectable(), doc.getParentClassName(), doc.getChildrenCount());
                    if (vo != null && matchesFilter(vo, category, keyword)) {
                        map.put(vo.getId(), vo);
                    }
                }
            }
        } catch (Exception e) {
            log.warn("从Mongo加载组件列表失败，回退文件扫描: {}", e.getMessage());
            return List.of();
        }
        return new ArrayList<>(map.values());
    }

    private boolean isSupportedClassName(String className) {
        if (StrUtil.isBlank(className) || !className.startsWith("Modelica.")) {
            return false;
        }
        String[] parts = className.split("\\.");
        return parts.length >= 2 && SUPPORTED_MODULES.contains(parts[1]);
    }

    private ComponentVO toComponentVOFromMeta(
            String id, String name, String description, String sourcePath, String indexPath, String iconPath,
            String restriction, String nodeType, Boolean partial, Boolean leaf, Boolean draggable,
            Boolean connectable, String parentClassName, Integer childrenCount) {
        if (StrUtil.isBlank(id)) {
            return null;
        }
        String resolvedName = StrUtil.blankToDefault(name, id.substring(id.lastIndexOf('.') + 1));
        String resolvedIndexPath = StrUtil.blankToDefault(indexPath, "Modelica/" + id.replace("Modelica.", "").replace(".", "/"));
        String iconUrl = null;
        if (StrUtil.isNotBlank(iconPath)) {
            iconUrl = buildStaticIconUrl(iconPath);
        } else {
            iconUrl = resolveComponentIconUrl(id, resolvedName, StrUtil.blankToDefault(sourcePath, ""));
        }
        ComponentVO vo = new ComponentVO();
        vo.setId(id);
        vo.setName(resolvedName);
        vo.setClassName(id);
        vo.setDescription(StrUtil.blankToDefault(description, ""));
        vo.setSourcePath(StrUtil.blankToDefault(sourcePath, ""));
        vo.setIndexPath(resolvedIndexPath);
        vo.setCoverImage(StrUtil.blankToDefault(iconUrl, ""));
        vo.setRestriction(StrUtil.blankToDefault(restriction, ""));
        vo.setNodeType(StrUtil.blankToDefault(nodeType, "component"));
        vo.setPartial(Boolean.TRUE.equals(partial));
        vo.setLeaf(leaf == null || Boolean.TRUE.equals(leaf));
        vo.setDraggable(draggable == null || Boolean.TRUE.equals(draggable));
        vo.setConnectable(connectable == null || Boolean.TRUE.equals(connectable));
        vo.setParentClassName(StrUtil.blankToDefault(parentClassName, ""));
        vo.setChildrenCount(childrenCount == null ? 0 : childrenCount);
        return vo;
    }

    private ComponentVO buildComponentVO(Path moPath, Path sourceRoot) throws Exception {
        String rel = sourceRoot.relativize(moPath).toString().replace("\\", "/");
        String className = "Modelica." + rel.replace("/", ".").replace(".mo", "");
        String name = moPath.getFileName().toString().replace(".mo", "");
        String indexPath = "Modelica/" + rel.substring(0, rel.lastIndexOf('/')).replace(".", "/");

        ComponentVO vo = new ComponentVO();
        vo.setId(className);
        vo.setName(name);
        vo.setClassName(className);
        vo.setSourcePath(rel);
        vo.setIndexPath(indexPath);
        vo.setRestriction("model");
        vo.setNodeType("component");
        vo.setPartial(false);
        vo.setLeaf(true);
        vo.setDraggable(true);
        vo.setConnectable(true);
        vo.setParentClassName(className.contains(".") ? className.substring(0, className.lastIndexOf('.')) : "");
        vo.setChildrenCount(0);

        String desc = extractDescriptionFromMo(moPath);
        vo.setDescription(StrUtil.blankToDefault(desc, ""));

        String iconUrl = resolveComponentIconUrl(className, name, rel);
        vo.setCoverImage(StrUtil.blankToDefault(iconUrl, ""));
        return vo;
    }

    private String extractDescriptionFromMo(Path moPath) {
        try {
            String content = Files.readString(moPath);
            java.util.regex.Pattern p = java.util.regex.Pattern.compile(
                    "(?:model|block|class)\\s+\\w+\\s+\"([^\"]+)\"", java.util.regex.Pattern.CASE_INSENSITIVE);
            java.util.regex.Matcher m = p.matcher(content);
            return m.find() ? m.group(1).trim() : "";
        } catch (Exception e) {
            return "";
        }
    }

    private boolean matchesFilter(ComponentVO vo, String category, String keyword) {
        if (StrUtil.isNotBlank(category) && !StrUtil.blankToDefault(vo.getIndexPath(), "").contains(category)) {
            return false;
        }
        if (StrUtil.isNotBlank(keyword)) {
            String kw = keyword.toLowerCase();
            return StrUtil.blankToDefault(vo.getName(), "").toLowerCase().contains(kw)
                    || StrUtil.blankToDefault(vo.getClassName(), "").toLowerCase().contains(kw)
                    || StrUtil.blankToDefault(vo.getDescription(), "").toLowerCase().contains(kw);
        }
        return true;
    }

    private String resolveComponentIconUrl(String className, String name, String sourcePath) {
        String module = extractModuleFromClassName(className);
        Set<String> fileNames = getModuleIconFileNames(module);
        if (fileNames.isEmpty()) return null;
        List<String> candidates = List.of(name + ".svg", className + ".svg",
                (className.contains(".") ? className.substring(className.lastIndexOf('.') + 1) : "") + ".svg");
        for (String c : candidates) {
            if (StrUtil.isNotBlank(c) && fileNames.contains(c)) {
                return buildStaticIconUrl(module + "/" + c);
            }
        }
        return null;
    }

    @Override
    public Map<String, Object> getComponentDetailByClassName(String className) {
        if (StrUtil.isBlank(className)) {
            throw new BusinessException("className 不能为空");
        }
        BsComponentParseMetaOmc omcMeta = omcMetaByClassName(className);
        BsComponentParseMeta parseMeta = null;
        Path sourceRoot = Path.of(componentSourceDir).normalize();
        String rel = className.replace("Modelica.", "").replace(".", "/") + ".mo";
        Path sourceFile = sourceRoot.resolve(rel).normalize();
        String content = null;
        if (!Files.exists(sourceFile)) {
            String sourcePathFromMeta = null;
            if (omcMeta == null) {
                try {
                    omcMeta = bsComponentParseMetaOmcRepository.findById(className).orElse(null);
                } catch (Exception ignored) {
                    // ignore
                }
            }
            if (parseMeta == null) {
                try {
                    parseMeta = bsComponentParseMetaRepository.findById(className).orElse(null);
                } catch (Exception ignored) {
                    // ignore
                }
            }
            if (omcMeta != null && StrUtil.isNotBlank(omcMeta.getSourcePath())) {
                sourcePathFromMeta = omcMeta.getSourcePath();
            } else if (parseMeta != null && StrUtil.isNotBlank(parseMeta.getSourcePath())) {
                sourcePathFromMeta = parseMeta.getSourcePath();
            }
            if (StrUtil.isNotBlank(sourcePathFromMeta)) {
                sourceFile = sourceRoot.resolve(normalizeRelativePath(sourcePathFromMeta)).normalize();
            }
        }
        if (!Files.exists(sourceFile)) {
            throw new BusinessException("组件不存在: " + className);
        }

        try {
            content = Files.readString(sourceFile);
        } catch (Exception e) {
            throw new BusinessException("读取组件源码失败: " + e.getMessage());
        }

        String name = sourceFile.getFileName().toString().replace(".mo", "");
        String iconUrl = resolveComponentIconUrl(className, name, rel);

        Map<String, Object> result = new HashMap<>();
        result.put("id", className);
        result.put("name", name);
        result.put("className", className);
        result.put("sourceCode", content);
        result.put("fileName", sourceFile.getFileName().toString());
        result.put("coverImage", StrUtil.blankToDefault(iconUrl, ""));

        String desc = extractDescriptionFromMo(sourceFile);
        result.put("description", StrUtil.blankToDefault(desc, ""));
        try {
            if (omcMeta == null) {
                parseMeta = bsComponentParseMetaRepository.findById(className).orElse(null);
            }
        } catch (Exception e) {
            log.warn("读取Mongo组件解析元数据失败 className={}, reason={}", className, e.getMessage());
        }

        Map<String, Object> parameters = new HashMap<>();
        List<Map<String, Object>> parameterDetails = new ArrayList<>();
        Map<String, Object> connectors = new HashMap<>();
        String metaSource = "source_parse";

        if (omcMeta != null && omcMeta.getParameters() != null) {
            metaSource = "omc_mongo";
            for (BsComponentParseMetaOmc.ParamMeta p : omcMeta.getParameters()) {
                String defaultValue = StrUtil.blankToDefault(p.getDefaultValue(), "0");
                parameters.put(p.getName(), defaultValue);
                Map<String, Object> pd = new HashMap<>();
                pd.put("name", p.getName());
                pd.put("type", p.getType());
                pd.put("defaultValue", defaultValue);
                pd.put("unit", p.getUnit());
                pd.put("description", StrUtil.blankToDefault(p.getDescription(), ""));
                parameterDetails.add(pd);
            }
            List<Map<String, String>> connectorList = new ArrayList<>();
            for (BsComponentParseMetaOmc.ConnectorMeta c : omcMeta.getInputConnectors()) {
                Map<String, String> connectorMap = new HashMap<>();
                connectorMap.put("name", c.getName());
                connectorMap.put("type", c.getType());
                connectorList.add(connectorMap);
            }
            for (BsComponentParseMetaOmc.ConnectorMeta c : omcMeta.getOutputConnectors()) {
                Map<String, String> connectorMap = new HashMap<>();
                connectorMap.put("name", c.getName());
                connectorMap.put("type", c.getType());
                connectorList.add(connectorMap);
            }
            for (BsComponentParseMetaOmc.ConnectorMeta c : omcMeta.getConnectors()) {
                Map<String, String> connectorMap = new HashMap<>();
                connectorMap.put("name", c.getName());
                connectorMap.put("type", c.getType());
                connectorList.add(connectorMap);
            }
            connectors.put("list", connectorList);
            connectors.put("input", omcMeta.getInputConnectors().stream().map(BsComponentParseMetaOmc.ConnectorMeta::getName).toList());
            connectors.put("output", omcMeta.getOutputConnectors().stream().map(BsComponentParseMetaOmc.ConnectorMeta::getName).toList());
        } else if (parseMeta != null && parseMeta.getParameters() != null) {
            metaSource = "legacy_mongo";
            for (BsComponentParseMeta.ParamMeta p : parseMeta.getParameters()) {
                String defaultValue = StrUtil.blankToDefault(p.getDefaultValue(), "0");
                parameters.put(p.getName(), defaultValue);
                Map<String, Object> pd = new HashMap<>();
                pd.put("name", p.getName());
                pd.put("type", p.getType());
                pd.put("defaultValue", defaultValue);
                pd.put("unit", p.getUnit());
                pd.put("description", StrUtil.blankToDefault(p.getDescription(), ""));
                parameterDetails.add(pd);
            }
            List<Map<String, String>> connectorList = new ArrayList<>();
            for (BsComponentParseMeta.ConnectorMeta c : parseMeta.getInputConnectors()) {
                Map<String, String> connectorMap = new HashMap<>();
                connectorMap.put("name", c.getName());
                connectorMap.put("type", c.getType());
                connectorList.add(connectorMap);
            }
            for (BsComponentParseMeta.ConnectorMeta c : parseMeta.getOutputConnectors()) {
                Map<String, String> connectorMap = new HashMap<>();
                connectorMap.put("name", c.getName());
                connectorMap.put("type", c.getType());
                connectorList.add(connectorMap);
            }
            for (BsComponentParseMeta.ConnectorMeta c : parseMeta.getConnectors()) {
                Map<String, String> connectorMap = new HashMap<>();
                connectorMap.put("name", c.getName());
                connectorMap.put("type", c.getType());
                connectorList.add(connectorMap);
            }
            connectors.put("list", connectorList);
            connectors.put("input", parseMeta.getInputConnectors().stream().map(BsComponentParseMeta.ConnectorMeta::getName).toList());
            connectors.put("output", parseMeta.getOutputConnectors().stream().map(BsComponentParseMeta.ConnectorMeta::getName).toList());
        } else if (StrUtil.isNotBlank(content)) {
            try {
                var info = com.modelcloud.modules.business.utils.ModelicaParser.parseModel(content);
                
                for (var param : info.getParameters()) {
                    String defaultValue = StrUtil.blankToDefault(param.getDefaultValue(), "0");
                    parameters.put(param.getName(), defaultValue);
                    Map<String, Object> pd = new HashMap<>();
                    pd.put("name", param.getName());
                    pd.put("type", param.getType());
                    pd.put("defaultValue", defaultValue);
                    pd.put("unit", "");
                    pd.put("description", "");
                    parameterDetails.add(pd);
                }
                List<Map<String, String>> connectorList = new ArrayList<>();
                for (var connector : info.getConnectors()) {
                    Map<String, String> connectorMap = new HashMap<>();
                    connectorMap.put("name", connector.getName());
                    connectorMap.put("type", connector.getType());
                    connectorList.add(connectorMap);
                }
                connectors.put("list", connectorList);
                connectors.put("input", new ArrayList<>());
                connectors.put("output", new ArrayList<>());
            } catch (Exception e) {
                log.warn("解析Modelica代码失败: {}", e.getMessage());
                connectors.put("list", createDefaultConnectors());
            }
        } else {
            connectors.put("list", createDefaultConnectors());
        }
        
        result.put("parameters", parameters);
        result.put("parameterDetails", parameterDetails);
        result.put("ports", connectors);
        result.put("connectors", connectors); // 兼容前端可能使用的字段名
        result.put("_metaSource", metaSource);
        Object connectorListObj = connectors.get("list");
        if (connectorListObj instanceof List<?> list) {
            List<String> names = new ArrayList<>();
            for (Object obj : list) {
                if (obj instanceof Map<?, ?> m) {
                    Object n = m.get("name");
                    if (n != null) names.add(String.valueOf(n));
                }
            }
            result.put("_connectorNames", names);
        }
        
        return result;
    }

    private BsComponentParseMetaOmc omcMetaByClassName(String className) {
        try {
            return bsComponentParseMetaOmcRepository.findById(className).orElse(null);
        } catch (Exception e) {
            return null;
        }
    }

    @Override
    public Map<String, Object> getComponentMetaDebugByClassName(String className) {
        Map<String, Object> debug = new HashMap<>();
        debug.put("className", className);
        BsComponentParseMetaOmc omc = null;
        BsComponentParseMeta legacy = null;
        try {
            omc = bsComponentParseMetaOmcRepository.findById(className).orElse(null);
            legacy = bsComponentParseMetaRepository.findById(className).orElse(null);
            debug.put("existsInOmcCollection", omc != null);
            debug.put("existsInLegacyCollection", legacy != null);
            if (omc != null) {
                List<BsComponentParseMetaOmc.ConnectorMeta> omcConnectors =
                        omc.getConnectors() == null ? List.of() : omc.getConnectors();
                List<BsComponentParseMetaOmc.ParamMeta> omcParams =
                        omc.getParameters() == null ? List.of() : omc.getParameters();
                debug.put("omcConnectorNames", omcConnectors.stream().map(BsComponentParseMetaOmc.ConnectorMeta::getName).toList());
                debug.put("omcParameterCount", omcParams.size());
            }
            if (legacy != null) {
                List<BsComponentParseMeta.ConnectorMeta> legacyConnectors =
                        legacy.getConnectors() == null ? List.of() : legacy.getConnectors();
                List<BsComponentParseMeta.ParamMeta> legacyParams =
                        legacy.getParameters() == null ? List.of() : legacy.getParameters();
                debug.put("legacyConnectorNames", legacyConnectors.stream().map(BsComponentParseMeta.ConnectorMeta::getName).toList());
                debug.put("legacyParameterCount", legacyParams.size());
            }
        } catch (Exception e) {
            debug.put("mongoError", e.getMessage());
            debug.put("existsInOmcCollection", false);
            debug.put("existsInLegacyCollection", false);
        }
        Map<String, Object> detail = getComponentDetailByClassName(className);
        debug.put("detailMetaSource", detail.get("_metaSource"));
        debug.put("detailConnectorNames", detail.get("_connectorNames"));
        debug.put("detailParameters", detail.get("parameters"));
        return debug;
    }
    
    /**
     * 创建默认接口（用于没有解析到接口的情况）
     */
    private List<Map<String, String>> createDefaultConnectors() {
        List<Map<String, String>> connectors = new ArrayList<>();
        Map<String, String> p = new HashMap<>();
        p.put("name", "p");
        p.put("type", "Modelica.Electrical.Analog.Interfaces.PositivePin");
        connectors.add(p);
        Map<String, String> n = new HashMap<>();
        n.put("name", "n");
        n.put("type", "Modelica.Electrical.Analog.Interfaces.NegativePin");
        connectors.add(n);
        return connectors;
    }

    private String extractModuleFromClassName(String className) {
        if (StrUtil.isBlank(className)) {
            return "Electrical";
        }
        String[] parts = className.split("\\.");
        if (parts.length >= 2 && "Modelica".equals(parts[0]) && SUPPORTED_MODULES.contains(parts[1])) {
            return parts[1];
        }
        return "Electrical";
    }

    private Set<String> getModuleIconFileNames(String moduleName) {
        Map<String, Set<String>> cache = moduleIconFileNames;
        if (cache == null) {
            cache = loadModuleIconFileNames();
            moduleIconFileNames = cache;
        }
        return cache.getOrDefault(StrUtil.blankToDefault(moduleName, "Electrical"), Set.of());
    }

    private Map<String, Set<String>> loadModuleIconFileNames() {
        synchronized (this) {
            if (moduleIconFileNames != null) {
                return moduleIconFileNames;
            }
            Map<String, Set<String>> loadedByModule = new HashMap<>();
            for (String module : SUPPORTED_MODULES) {
                Set<String> loaded = new HashSet<>();
                Path moduleDir = Path.of(componentIconDir).resolve(module).normalize();
                try {
                    if (Files.exists(moduleDir) && Files.isDirectory(moduleDir)) {
                        try (var stream = Files.list(moduleDir)) {
                            stream.filter(Files::isRegularFile).forEach(path -> {
                                String fileName = path.getFileName().toString();
                                if (fileName.toLowerCase().endsWith(".svg")) {
                                    loaded.add(fileName);
                                }
                            });
                        }
                    }
                } catch (Exception e) {
                    log.warn("加载组件图标目录索引失败 module={}, reason={}", module, e.getMessage());
                }
                loadedByModule.put(module, loaded);
            }
            moduleIconFileNames = loadedByModule;
            return loadedByModule;
        }
    }

    private String normalizeRelativePath(String value) {
        return String.valueOf(value).replace("\\", "/").replaceAll("^/+", "");
    }

    private String buildStaticIconUrl(String relativePath) {
        String prefix = StrUtil.blankToDefault(componentIconUrlPrefix, "/api/component_icon").replaceAll("/+$", "");
        String normalized = normalizeRelativePath(relativePath);
        String encodedPath = encodePath(normalized);
        return prefix + "/" + encodedPath;
    }

    private String encodePath(String path) {
        String[] segments = String.valueOf(path).split("/");
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < segments.length; i++) {
            if (i > 0) {
                sb.append('/');
            }
            sb.append(URLEncoder.encode(segments[i], StandardCharsets.UTF_8));
        }
        return sb.toString();
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long saveProject(ModelingProjectRequest request) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new BusinessException("用户未登录");
        }
        
        if (StrUtil.isBlank(request.getName())) {
            throw new BusinessException("项目名称不能为空");
        }
        
        if (StrUtil.isBlank(request.getProjectData())) {
            throw new BusinessException("项目数据不能为空");
        }
        
        String projectType = normalizeProjectType(request.getProjectType());
        BsModelingProject project = new BsModelingProject();
        project.setUserId(userId);
        project.setName(request.getName());
        project.setDescription(request.getDescription());
        project.setProjectData(request.getProjectData());
        project.setModelicaCode(request.getModelicaCode());
        project.setProjectType(projectType);
        project.setIsDel(0);
        
        projectMapper.insert(project);
        return project.getId();
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateProject(Long projectId, ModelingProjectRequest request) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new BusinessException("用户未登录");
        }
        
        BsModelingProject project = projectMapper.selectOneById(projectId);
        if (project == null || project.getIsDel() == 1) {
            throw new BusinessException("项目不存在");
        }
        
        if (!project.getUserId().equals(userId)) {
            throw new BusinessException("无权修改此项目");
        }
        
        if (StrUtil.isNotBlank(request.getName())) {
            project.setName(request.getName());
        }
        if (request.getDescription() != null) {
            project.setDescription(request.getDescription());
        }
        if (StrUtil.isNotBlank(request.getProjectData())) {
            project.setProjectData(request.getProjectData());
        }
        if (request.getModelicaCode() != null) {
            project.setModelicaCode(request.getModelicaCode());
        }
        if (StrUtil.isNotBlank(request.getProjectType())) {
            project.setProjectType(normalizeProjectType(request.getProjectType()));
        }
        
        projectMapper.update(project);
    }
    
    @Override
    public BsModelingProject getProject(Long projectId, String projectType) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new BusinessException("用户未登录");
        }
        
        BsModelingProject project = projectMapper.selectOneById(projectId);
        if (project == null || project.getIsDel() == 1) {
            throw new BusinessException("项目不存在");
        }
        
        if (!project.getUserId().equals(userId)) {
            throw new BusinessException("无权访问此项目");
        }

        if (StrUtil.isNotBlank(projectType)
                && !normalizeProjectType(projectType).equalsIgnoreCase(
                StrUtil.blankToDefault(project.getProjectType(), "MODELICA"))) {
            throw new BusinessException("项目类型与当前页面不匹配");
        }

        return project;
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteProject(Long projectId) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new BusinessException("用户未登录");
        }
        
        BsModelingProject project = projectMapper.selectOneById(projectId);
        if (project == null || project.getIsDel() == 1) {
            throw new BusinessException("项目不存在");
        }
        
        if (!project.getUserId().equals(userId)) {
            throw new BusinessException("无权删除此项目");
        }
        
        project.setIsDel(1);
        projectMapper.update(project);
    }
    
    @Override
    public Page<BsModelingProject> getUserProjects(int pageNum, int pageSize, String projectType) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new BusinessException("用户未登录");
        }
        
        String normalizedProjectType = StrUtil.isBlank(projectType)
                ? null
                : normalizeProjectType(projectType);
        QueryWrapper queryWrapper = QueryWrapper.create()
                .where("user_id = ?", userId)
                .and("is_del = ?", 0);

        if (normalizedProjectType != null) {
            queryWrapper.and("project_type = ?", normalizedProjectType);
        }

        if ("JULIA_MATLAB".equals(normalizedProjectType)) {
            queryWrapper.select(
                    BS_MODELING_PROJECT.ID,
                    BS_MODELING_PROJECT.NAME,
                    BS_MODELING_PROJECT.DESCRIPTION,
                    BS_MODELING_PROJECT.PROJECT_TYPE,
                    BS_MODELING_PROJECT.CREATE_TIME,
                    BS_MODELING_PROJECT.UPDATE_TIME
            );
        }

        queryWrapper.orderBy("create_time", false);
        
        return projectMapper.paginate(pageNum, pageSize, queryWrapper);
    }

    private String normalizeProjectType(String projectType) {
        String normalized = StrUtil.blankToDefault(projectType, "MODELICA").trim().toUpperCase();
        if (!"MODELICA".equals(normalized) && !"JULIA_MATLAB".equals(normalized)) {
            throw new BusinessException("不支持的项目类型：" + projectType);
        }
        return normalized;
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long submitSimulation(SimulationRequest request) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new BusinessException("用户未登录");
        }

        String engineType = StrUtil.blankToDefault(request.getEngineType(), "modelica").toLowerCase();
        String modelCode = request.getModelCode();
        Map<String, Object> trustedExecutionPayload = null;

        if ("matlab".equals(engineType)) {
            trustedExecutionPayload = buildTrustedMatlabGraph(request.getExecutionPayload());
            modelCode = null;
        } else if ("modelica".equals(engineType)) {
            if (request.getProjectId() == null && StrUtil.isBlank(modelCode)) {
                throw new BusinessException("项目ID或模型代码必须提供其一");
            }
            // 如果提供了项目ID，从项目获取模型代码
            if (request.getProjectId() != null) {
                BsModelingProject project = projectMapper.selectOneById(request.getProjectId());
                if (project == null || project.getIsDel() == 1) {
                    throw new BusinessException("项目不存在");
                }
                if (!project.getUserId().equals(userId)) {
                    throw new BusinessException("无权使用此项目");
                }
                modelCode = project.getModelicaCode();
                if (StrUtil.isBlank(modelCode)) {
                    throw new BusinessException("项目未生成Modelica代码");
                }
            }
        } else {
            throw new BusinessException("不支持的执行引擎: " + engineType);
        }
        
        // 创建仿真任务记录
        BsSimulationTask task = new BsSimulationTask();
        task.setUserId(userId);
        task.setProjectId(request.getProjectId());
        task.setTaskId(UUID.randomUUID().toString().replace("-", ""));
        if (trustedExecutionPayload != null && "matlab".equals(engineType)) {
            materializeMatlabResources(trustedExecutionPayload, userId, task.getTaskId());
        }
        task.setEngineType(engineType);
        task.setModelCode(modelCode);
        task.setExecutionPayload(trustedExecutionPayload == null
                ? null
                : JSON.toJSONString(trustedExecutionPayload));
        task.setSimulationParams(JSON.toJSONString(request.getSimulationParams()));
        task.setStatus("pending");
        task.setProgress(0);
        task.setStartTime(LocalDateTime.now());
        
        taskMapper.insert(task);
        submitToSimulationService(task);
        
        log.info("创建仿真任务: taskId={}, userId={}", task.getTaskId(), userId);
        
        return task.getId();
    }
    
    @Override
    public BsSimulationTask getSimulationTask(Long taskId) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new BusinessException("用户未登录");
        }
        
        BsSimulationTask task = taskMapper.selectOneById(taskId);
        if (task == null) {
            throw new BusinessException("任务不存在");
        }
        
        if (!task.getUserId().equals(userId)) {
            throw new BusinessException("无权访问此任务");
        }
        syncTaskStatusFromSimulation(task);
        return task;
    }

    @Override
    public ResponseEntity<byte[]> getSimulationArtifact(Long taskId, String artifactId) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new BusinessException("用户未登录");
        }
        if (StrUtil.isBlank(artifactId) || !ARTIFACT_ID.matcher(artifactId).matches()) {
            throw new BusinessException("图片产物标识不合法");
        }
        BsSimulationTask task = taskMapper.selectOneById(taskId);
        if (task == null) {
            throw new BusinessException("任务不存在");
        }
        if (!userId.equals(task.getUserId())) {
            throw new BusinessException("无权访问此任务");
        }
        String artifactUrl = simulationBaseUrl + "/tasks/"
                + URLEncoder.encode(task.getTaskId(), StandardCharsets.UTF_8)
                + "/artifacts/" + URLEncoder.encode(artifactId, StandardCharsets.UTF_8);
        try {
            ResponseEntity<byte[]> response = restTemplate.exchange(
                    artifactUrl, HttpMethod.GET, HttpEntity.EMPTY, byte[].class);
            if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
                throw new BusinessException("图片产物不存在");
            }
            HttpHeaders headers = new HttpHeaders();
            MediaType contentType = response.getHeaders().getContentType();
            headers.setContentType(contentType == null ? MediaType.IMAGE_PNG : contentType);
            headers.setContentLength(response.getBody().length);
            headers.setCacheControl("private, max-age=3600");
            return new ResponseEntity<>(response.getBody(), headers, response.getStatusCode());
        } catch (RestClientException e) {
            log.warn("获取仿真图片失败 taskId={}, artifactId={}, reason={}",
                    task.getTaskId(), artifactId, e.getMessage());
            throw new BusinessException("图片产物不存在");
        }
    }
    
    @Override
    public Page<BsSimulationTask> getUserSimulationTasks(int pageNum, int pageSize) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new BusinessException("用户未登录");
        }
        
        QueryWrapper queryWrapper = QueryWrapper.create()
                .where("user_id = ?", userId)
                .orderBy("create_time", false);
        
        return taskMapper.paginate(pageNum, pageSize, queryWrapper);
    }

    private void submitToSimulationService(BsSimulationTask task) {
        String submitUrl = simulationBaseUrl + "/submit";
        Map<String, Object> payload = new HashMap<>();
        payload.put("taskId", task.getTaskId());
        payload.put("engineType", StrUtil.blankToDefault(task.getEngineType(), "modelica"));
        if ("matlab".equals(task.getEngineType())) {
            payload.put("executionPayload", JSON.parseObject(task.getExecutionPayload()));
        } else {
            payload.put("modelCode", task.getModelCode());
            payload.put("simulationParams", JSON.parseObject(task.getSimulationParams()));
        }

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, headers);

        try {
            ResponseEntity<String> response = restTemplate.postForEntity(submitUrl, entity, String.class);
            if (!response.getStatusCode().is2xxSuccessful()) {
                throw new BusinessException("仿真服务提交失败，HTTP状态: " + response.getStatusCode().value());
            }
            task.setStatus("running");
            task.setProgress(5);
            taskMapper.update(task);
        } catch (RestClientException e) {
            task.setStatus("failed");
            task.setErrorMessage("调用仿真服务失败: " + e.getMessage());
            task.setEndTime(LocalDateTime.now());
            taskMapper.update(task);
            throw new BusinessException("调用仿真服务失败: " + e.getMessage());
        }
    }

    private void syncTaskStatusFromSimulation(BsSimulationTask task) {
        if (task == null || StrUtil.isBlank(task.getTaskId())) {
            return;
        }
        if ("completed".equals(task.getStatus()) || "failed".equals(task.getStatus()) || "cancelled".equals(task.getStatus())) {
            return;
        }

        String statusUrl = simulationBaseUrl + "/tasks/" + task.getTaskId();
        try {
            ResponseEntity<String> response = restTemplate.getForEntity(statusUrl, String.class);
            if (!response.getStatusCode().is2xxSuccessful() || StrUtil.isBlank(response.getBody())) {
                return;
            }
            com.alibaba.fastjson2.JSONObject json = JSON.parseObject(response.getBody());
            String status = json.getString("status");
            Integer progress = json.getInteger("progress");
            String errorMessage = json.getString("errorMessage");
            String resultFileUrl = json.getString("resultFileUrl");
            Object resultData = json.get("resultData");
            Object errorDetail = json.get("errorDetail");

            if (StrUtil.isNotBlank(status)) {
                task.setStatus(status);
            }
            if (progress != null) {
                task.setProgress(progress);
            }
            if (StrUtil.isNotBlank(errorMessage)) {
                task.setErrorMessage(errorMessage);
            }
            if (StrUtil.isNotBlank(resultFileUrl)) {
                task.setResultFileUrl(resultFileUrl);
            }
            if (resultData != null) {
                task.setResultData(JSON.toJSONString(resultData));
            } else if (errorDetail != null) {
                task.setResultData(JSON.toJSONString(Map.of("errorDetail", errorDetail)));
            }
            if ("completed".equals(status) || "failed".equals(status) || "cancelled".equals(status)) {
                task.setEndTime(LocalDateTime.now());
            }
            taskMapper.update(task);
        } catch (Exception e) {
            log.warn("同步仿真任务状态失败 taskId={}, reason={}", task.getTaskId(), e.getMessage());
        }
    }
}
