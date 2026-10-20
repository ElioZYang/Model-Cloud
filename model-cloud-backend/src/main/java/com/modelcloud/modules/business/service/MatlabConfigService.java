package com.modelcloud.modules.business.service;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONObject;
import com.modelcloud.common.exception.BusinessException;
import com.modelcloud.common.tools.SecurityUtils;
import com.modelcloud.modules.business.mapper.BsMatlabConfigMapper;
import com.modelcloud.modules.business.model.domain.BsMatlabConfig;
import com.modelcloud.modules.business.model.dto.MatlabConfigVO;
import com.modelcloud.modules.sys.mapper.SysUserMapper;
import com.modelcloud.modules.sys.model.domain.SysUser;
import com.mybatisflex.core.query.QueryWrapper;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.MessageDigest;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.HexFormat;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

/** PMSM Excel配置的上传、持久化和任务快照服务。 */
@Service
public class MatlabConfigService {
    public static final String TEMPLATE_RESOURCE =
            "static/matlab_component_source/PMSM/input/pmsm input.xlsx";
    private static final String SCHEMA_RESOURCE =
            "matlab-components/pmsm-config-schema.json";
    private static final long MAX_FILE_SIZE = 10L * 1024L * 1024L;

    private final BsMatlabConfigMapper configMapper;
    private final SysUserMapper userMapper;
    private final GiteaService giteaService;

    @Value("${model-cloud.matlab-config.simulation-task-root:./runtime/matlab_simulations}")
    private String simulationTaskRoot;

    public MatlabConfigService(
            BsMatlabConfigMapper configMapper,
            SysUserMapper userMapper,
            GiteaService giteaService) {
        this.configMapper = configMapper;
        this.userMapper = userMapper;
        this.giteaService = giteaService;
    }

    public byte[] templateBytes() {
        return templateBytes(null);
    }

    public byte[] templateBytes(String componentId) {
        String resource = independent(componentId)
                ? "static/matlab_component_source/PMSM_Independent/input/pmsm input.xlsx" : TEMPLATE_RESOURCE;
        try (InputStream input = new ClassPathResource(resource).getInputStream()) {
            return input.readAllBytes();
        } catch (Exception e) {
            throw new BusinessException("读取PMSM配置模板失败: " + e.getMessage());
        }
    }

    public JSONObject schema() {
        return schema(null);
    }

    public JSONObject schema(String componentId) {
        String resource = independent(componentId)
                ? "matlab-components/pmsm-independent-config-schema.json" : SCHEMA_RESOURCE;
        try (InputStream input = new ClassPathResource(resource).getInputStream()) {
            return JSON.parseObject(new String(input.readAllBytes(), java.nio.charset.StandardCharsets.UTF_8));
        } catch (Exception e) {
            throw new BusinessException("读取PMSM配置规范失败: " + e.getMessage());
        }
    }

    private boolean independent(String componentId) {
        return "pmsm.workflow.motor-configuration".equals(componentId);
    }

    @Transactional(rollbackFor = Exception.class)
    public MatlabConfigVO upload(MultipartFile file, String displayName, String componentId) {
        Long userId = requireUserId();
        if (file == null || file.isEmpty()) {
            throw new BusinessException("请选择PMSM配置文件");
        }
        String originalName = String.valueOf(file.getOriginalFilename());
        if (!originalName.toLowerCase().endsWith(".xlsx")) {
            throw new BusinessException("PMSM配置文件必须为.xlsx格式");
        }
        if (file.getSize() > MAX_FILE_SIZE) {
            throw new BusinessException("PMSM配置文件不能超过10MB");
        }
        try {
            byte[] bytes = file.getBytes();
            JSONObject configSchema = schema(componentId);
            WorkbookSummary summary = validateWorkbook(bytes, configSchema);
            SysUser user = userMapper.selectOneById(userId);
            if (user == null) {
                throw new BusinessException("用户不存在");
            }
            String configId = UUID.randomUUID().toString().replace("-", "");
            String repoName = "models-" + user.getUsername();
            giteaService.ensureRepository(repoName, "用户 " + user.getUsername() + " 的模型仓库");
            String repoPath = "matlab-configs/" + configId + "/pmsm-config.xlsx";
            String sha256 = sha256(bytes);
            LocalDateTime now = LocalDateTime.now();
            String name = displayName == null || displayName.isBlank()
                    ? stripExtension(originalName) : displayName.trim();

            giteaService.uploadBytes(repoName, repoPath, bytes);
            Map<String, Object> manifest = new LinkedHashMap<>();
            manifest.put("configId", configId);
            manifest.put("name", name);
            manifest.put("originalFileName", originalName);
            manifest.put("templateVersion", String.valueOf(configSchema.get("version")));
            manifest.put("sha256", sha256);
            manifest.put("createTime", now.toString());
            giteaService.uploadContent(repoName,
                    "matlab-configs/" + configId + "/config.json",
                    JSON.toJSONString(manifest));

            BsMatlabConfig entity = new BsMatlabConfig();
            entity.setConfigId(configId);
            entity.setUserId(userId);
            entity.setName(name);
            entity.setOriginalFilename(originalName);
            entity.setRepoName(repoName);
            entity.setRepoPath(repoPath);
            entity.setFileSize((long) bytes.length);
            entity.setSha256(sha256);
            entity.setTemplateVersion(String.valueOf(configSchema.get("version")));
            entity.setDesignParameterCount(summary.designParameterCount());
            entity.setOptimizationParameterCount(summary.optimizationParameterCount());
            entity.setMaterialCount(summary.materialCount());
            entity.setCreateTime(now);
            entity.setUpdateTime(now);
            entity.setIsDel(0);
            configMapper.insert(entity);
            return toVO(entity);
        } catch (BusinessException e) {
            throw e;
        } catch (Exception e) {
            throw new BusinessException("上传PMSM配置失败: " + e.getMessage());
        }
    }

    public List<MatlabConfigVO> listMine() {
        Long userId = requireUserId();
        QueryWrapper query = QueryWrapper.create()
                .where("user_id = ?", userId)
                .and("is_del = ?", 0)
                .orderBy("create_time", false);
        return configMapper.selectListByQuery(query).stream().map(this::toVO).toList();
    }

    public MatlabConfigVO getMine(String configId) {
        return toVO(requireOwned(configId, requireUserId()));
    }

    public void softDelete(String configId) {
        BsMatlabConfig config = requireOwned(configId, requireUserId());
        config.setIsDel(1);
        config.setUpdateTime(LocalDateTime.now());
        configMapper.update(config);
    }

    /** 将Gitea原件复制为本次任务的不可变快照，返回可信资源元数据。 */
    public Map<String, Object> materializeTaskSnapshot(
            Long userId, String configId, String taskId) {
        BsMatlabConfig config = requireOwned(configId, userId);
        byte[] bytes = giteaService.getFileBytes(config.getRepoName(), config.getRepoPath());
        String actualSha = sha256(bytes);
        if (!actualSha.equalsIgnoreCase(config.getSha256())) {
            throw new BusinessException("PMSM配置文件摘要不一致: " + configId);
        }
        try {
            Path root = Path.of(simulationTaskRoot).toAbsolutePath().normalize();
            Path taskDir = root.resolve(taskId).normalize();
            if (!taskDir.startsWith(root)) {
                throw new BusinessException("非法MATLAB任务目录");
            }
            Path inputDir = taskDir.resolve("inputs");
            Files.createDirectories(inputDir);
            Path snapshot = inputDir.resolve("pmsm-config.xlsx");
            Files.write(snapshot, bytes);
            Map<String, Object> resource = new LinkedHashMap<>();
            resource.put("configId", config.getConfigId());
            resource.put("taskRelativePath", "inputs/pmsm-config.xlsx");
            resource.put("originalFileName", config.getOriginalFilename());
            resource.put("sha256", config.getSha256());
            resource.put("templateVersion", config.getTemplateVersion());
            return resource;
        } catch (BusinessException e) {
            throw e;
        } catch (Exception e) {
            throw new BusinessException("创建PMSM配置任务快照失败: " + e.getMessage());
        }
    }

    private WorkbookSummary validateWorkbook(byte[] bytes, JSONObject configSchema) {
        String designSheetName = configSchema.getString("designSheet");
        String materialSheetName = configSchema.getString("materialSheet");
        List<String> requiredColumns = configSchema.getList("designColumns", String.class);
        List<String> requiredMaterialColumns = configSchema.getList("materialColumns", String.class);
        Set<String> requiredVariables = new HashSet<>(
                configSchema.getList("requiredVariables", String.class));
        try (Workbook workbook = WorkbookFactory.create(new ByteArrayInputStream(bytes))) {
            Sheet design = workbook.getSheet(designSheetName);
            Sheet material = workbook.getSheet(materialSheetName);
            if (design == null) {
                throw new BusinessException("配置文件缺少工作表: " + designSheetName);
            }
            if (material == null) {
                throw new BusinessException("配置文件缺少工作表: " + materialSheetName);
            }
            Row header = design.getRow(design.getFirstRowNum());
            Map<String, Integer> columns = headerIndexes(header);
            for (String column : requiredColumns) {
                if (!columns.containsKey(column)) {
                    throw new BusinessException("工作表" + designSheetName + "缺少列: " + column);
                }
            }
            DataFormatter formatter = new DataFormatter();
            Set<String> variables = new HashSet<>();
            int parameters = 0;
            int optimizations = 0;
            for (int rowIndex = design.getFirstRowNum() + 1;
                    rowIndex <= design.getLastRowNum(); rowIndex++) {
                Row row = design.getRow(rowIndex);
                if (row == null) continue;
                String variable = formatter.formatCellValue(
                        row.getCell(columns.get("variables"))).trim();
                if (variable.isEmpty()) continue;
                if (!variables.add(variable)) {
                    throw new BusinessException("配置变量重复: " + variable);
                }
                requireFiniteNumeric(row.getCell(columns.get("value")), variable + ".value");
                double opt = requireFiniteNumeric(row.getCell(columns.get("opt")), variable + ".opt");
                if (opt != 0.0 && opt != 1.0) {
                    throw new BusinessException(variable + ".opt只能为0或1");
                }
                if (opt == 1.0) optimizations++;
                Double min = optionalNumeric(row.getCell(columns.get("min")), variable + ".min");
                Double max = optionalNumeric(row.getCell(columns.get("max")), variable + ".max");
                if (opt == 1.0 && (min == null || max == null)) {
                    throw new BusinessException(variable + "的优化范围不能为空");
                }
                if (min != null && max != null && min > max) {
                    throw new BusinessException(variable + "的min不能大于max");
                }
                parameters++;
            }
            Set<String> missing = new HashSet<>(requiredVariables);
            missing.removeAll(variables);
            if (!missing.isEmpty()) {
                throw new BusinessException("配置文件缺少必要变量: " + String.join(", ", missing));
            }
            Map<String, Integer> materialColumns = headerIndexes(
                    material.getRow(material.getFirstRowNum()));
            for (String column : requiredMaterialColumns) {
                if (!materialColumns.containsKey(column)) {
                    throw new BusinessException("工作表" + materialSheetName + "缺少列: " + column);
                }
            }
            int materials = 0;
            DataFormatter materialFormatter = new DataFormatter();
            for (int i = material.getFirstRowNum() + 1; i <= material.getLastRowNum(); i++) {
                Row row = material.getRow(i);
                if (row != null && !materialFormatter.formatCellValue(row.getCell(0)).trim().isEmpty()) {
                    materials++;
                }
            }
            return new WorkbookSummary(parameters, optimizations, materials);
        } catch (BusinessException e) {
            throw e;
        } catch (Exception e) {
            throw new BusinessException("无法解析PMSM Excel配置: " + e.getMessage());
        }
    }

    private Map<String, Integer> headerIndexes(Row header) {
        if (header == null) throw new BusinessException("PMSM配置表头为空");
        Map<String, Integer> result = new HashMap<>();
        DataFormatter formatter = new DataFormatter();
        for (Cell cell : header) {
            result.put(formatter.formatCellValue(cell).trim(), cell.getColumnIndex());
        }
        return result;
    }

    private double requireFiniteNumeric(Cell cell, String name) {
        Double value = optionalNumeric(cell, name);
        if (value == null) throw new BusinessException(name + "不能为空");
        return value;
    }

    private Double optionalNumeric(Cell cell, String name) {
        if (cell == null || cell.getCellType() == org.apache.poi.ss.usermodel.CellType.BLANK) {
            return null;
        }
        try {
            String formatted = new DataFormatter().formatCellValue(cell).trim();
            if (formatted.isEmpty() || "-".equals(formatted)) return null;
            boolean numericCell = cell.getCellType()
                    == org.apache.poi.ss.usermodel.CellType.NUMERIC;
            boolean numericFormula = cell.getCellType()
                    == org.apache.poi.ss.usermodel.CellType.FORMULA
                    && cell.getCachedFormulaResultType()
                    == org.apache.poi.ss.usermodel.CellType.NUMERIC;
            double value = numericCell || numericFormula
                    ? cell.getNumericCellValue() : Double.parseDouble(formatted);
            if (!Double.isFinite(value)) throw new NumberFormatException();
            return value;
        } catch (Exception e) {
            throw new BusinessException(name + "必须是有限数值");
        }
    }

    private BsMatlabConfig requireOwned(String configId, Long userId) {
        if (configId == null || configId.isBlank()) {
            throw new BusinessException("PMSM配置ID不能为空");
        }
        QueryWrapper query = QueryWrapper.create()
                .where("config_id = ?", configId)
                .and("user_id = ?", userId)
                .and("is_del = ?", 0);
        BsMatlabConfig config = configMapper.selectOneByQuery(query);
        if (config == null) throw new BusinessException("PMSM配置不存在或无权访问");
        return config;
    }

    private Long requireUserId() {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) throw new BusinessException("用户未登录");
        return userId;
    }

    private MatlabConfigVO toVO(BsMatlabConfig entity) {
        MatlabConfigVO value = new MatlabConfigVO();
        value.setConfigId(entity.getConfigId());
        value.setName(entity.getName());
        value.setFileName(entity.getOriginalFilename());
        value.setFileSize(entity.getFileSize());
        value.setSha256(entity.getSha256());
        value.setTemplateVersion(entity.getTemplateVersion());
        value.setStatus("validated");
        value.setCreateTime(entity.getCreateTime());
        value.getSummary().put("designParameterCount", entity.getDesignParameterCount());
        value.getSummary().put("optimizationParameterCount", entity.getOptimizationParameterCount());
        value.getSummary().put("materialCount", entity.getMaterialCount());
        return value;
    }

    private String stripExtension(String fileName) {
        int dot = fileName.lastIndexOf('.');
        return dot > 0 ? fileName.substring(0, dot) : fileName;
    }

    private String sha256(byte[] bytes) {
        try {
            return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(bytes));
        } catch (Exception e) {
            throw new BusinessException("计算文件摘要失败: " + e.getMessage());
        }
    }

    private record WorkbookSummary(
            int designParameterCount,
            int optimizationParameterCount,
            int materialCount) {
    }
}
