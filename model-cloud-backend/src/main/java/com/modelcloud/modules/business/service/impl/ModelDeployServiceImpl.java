package com.modelcloud.modules.business.service.impl;

import cn.hutool.core.util.StrUtil;
import com.alibaba.fastjson2.JSON;
import com.modelcloud.common.exception.BusinessException;
import com.modelcloud.common.tools.SecurityUtils;
import com.modelcloud.modules.business.mapper.BsModelMapper;
import com.modelcloud.modules.business.mapper.BsModelingProjectMapper;
import com.modelcloud.modules.business.mapper.BsSimulationTaskMapper;
import com.modelcloud.modules.business.model.domain.BsModel;
import com.modelcloud.modules.business.model.domain.BsModelingProject;
import com.modelcloud.modules.business.model.domain.BsSimulationTask;
import com.modelcloud.modules.business.model.request.ModelingProjectRequest;
import com.modelcloud.modules.business.model.request.SimulationRequest;
import com.modelcloud.modules.business.service.BsModelService;
import com.modelcloud.modules.business.service.GiteaService;
import com.modelcloud.modules.business.service.ModelDeployService;
import com.mybatisflex.core.paginate.Page;
import com.mybatisflex.core.query.QueryWrapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import static com.modelcloud.modules.business.model.domain.table.BsModelTableDef.BS_MODEL;
// TableDef会在编译时自动生成，如果编译报错，请先编译一次项目
// import static com.modelcloud.modules.business.model.domain.table.BsModelingProjectTableDef.BS_MODELING_PROJECT;
// import static com.modelcloud.modules.business.model.domain.table.BsSimulationTaskTableDef.BS_SIMULATION_TASK;

/**
 * 模型部署服务实现类
 * 
 * @author model-cloud
 */
@Slf4j
@Service
public class ModelDeployServiceImpl implements ModelDeployService {
    
    private final BsModelMapper bsModelMapper;
    private final BsModelingProjectMapper projectMapper;
    private final BsSimulationTaskMapper taskMapper;
    private final BsModelService bsModelService;
    private final com.modelcloud.modules.sys.mapper.SysUserMapper sysUserMapper;
    private final GiteaService giteaService;
    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${model-cloud.simulation.base-url:http://localhost:8000/api/v1/simulation}")
    private String simulationBaseUrl;
    
    public ModelDeployServiceImpl(
            BsModelMapper bsModelMapper,
            BsModelingProjectMapper projectMapper,
            BsSimulationTaskMapper taskMapper,
            BsModelService bsModelService,
            com.modelcloud.modules.sys.mapper.SysUserMapper sysUserMapper,
            GiteaService giteaService) {
        this.bsModelMapper = bsModelMapper;
        this.projectMapper = projectMapper;
        this.taskMapper = taskMapper;
        this.bsModelService = bsModelService;
        this.sysUserMapper = sysUserMapper;
        this.giteaService = giteaService;
    }
    
    @Override
    public List<BsModel> getComponents(String category, String keyword) {
        // 查询所有基础组件（component），由超级管理员维护后在部署页使用
        QueryWrapper queryWrapper = QueryWrapper.create()
                .where(BS_MODEL.IS_DEL.eq(0))
                .and(BS_MODEL.STATUS.eq(20))
                .and(BS_MODEL.ATTR_TYPE.eq("component"))
                .and(BS_MODEL.NAME.like(keyword).or(BS_MODEL.DESCRIPTION.like(keyword)).when(StrUtil.isNotBlank(keyword)))
                .orderBy(BS_MODEL.CREATE_TIME.desc());
        
        List<BsModel> models = bsModelMapper.selectListByQuery(queryWrapper);
        
        // 填充作者名称和默认封面
        for (BsModel model : models) {
            fillAuthorName(model);
            fillDefaultCoverImage(model);
        }
        
        return models;
    }
    
    /**
     * 填充作者名称
     */
    private void fillAuthorName(BsModel model) {
        if (model.getUserId() != null) {
            com.modelcloud.modules.sys.model.domain.SysUser user = sysUserMapper.selectOneById(model.getUserId());
            if (user != null) {
                model.setAuthorName(user.getNickname() != null ? user.getNickname() : user.getUsername());
            }
        }
    }
    
    /**
     * 填充默认封面图片
     */
    private void fillDefaultCoverImage(BsModel model) {
        if (model != null && StrUtil.isBlank(model.getCoverImage())) {
            String defaultCoverUrl = giteaService.getDefaultCoverImageUrl();
            model.setCoverImage(defaultCoverUrl);
        }
    }
    
    @Override
    public Map<String, Object> getComponentDetail(Long componentId) {
        BsModel model = bsModelMapper.selectOneById(componentId);
        if (model == null || model.getIsDel() == 1) {
            throw new BusinessException("组件不存在");
        }
        
        // 获取模型源码
        Map<String, String> sourceCode = null;
        try {
            sourceCode = bsModelService.getModelSourceCode(componentId);
        } catch (Exception e) {
            log.warn("获取组件源码失败: {}", e.getMessage());
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("id", model.getId());
        result.put("name", model.getName());
        result.put("description", model.getDescription());
        result.put("sourceCode", sourceCode != null ? sourceCode.get("content") : null);
        result.put("fileName", sourceCode != null ? sourceCode.get("fileName") : null);
        result.put("coverImage", model.getCoverImage());
        result.put("className", model.getName());
        
        // 解析.mo文件，提取参数和接口信息
        Map<String, Object> parameters = new HashMap<>();
        Map<String, Object> connectors = new HashMap<>();
        
        if (sourceCode != null && sourceCode.get("content") != null) {
            try {
                com.modelcloud.modules.business.utils.ModelicaParser.ModelicaComponentInfo info = 
                    com.modelcloud.modules.business.utils.ModelicaParser.parseModel(sourceCode.get("content"));
                if (StrUtil.isNotBlank(info.getClassName())) {
                    result.put("className", info.getClassName());
                }
                
                // 转换参数
                for (com.modelcloud.modules.business.utils.ModelicaParser.ParameterInfo param : info.getParameters()) {
                    String defaultValue = param.getDefaultValue();
                    if (StrUtil.isBlank(defaultValue)) {
                        defaultValue = "0";
                    }
                    parameters.put(param.getName(), defaultValue);
                }
                
                // 转换接口
                List<Map<String, String>> connectorList = new ArrayList<>();
                for (com.modelcloud.modules.business.utils.ModelicaParser.ConnectorInfo connector : info.getConnectors()) {
                    Map<String, String> connectorMap = new HashMap<>();
                    connectorMap.put("name", connector.getName());
                    connectorMap.put("type", connector.getType());
                    connectorList.add(connectorMap);
                }
                connectors.put("list", connectorList);
                connectors.put("input", new ArrayList<>()); // 简化处理，后续可细化
                connectors.put("output", new ArrayList<>()); // 简化处理，后续可细化
                
            } catch (Exception e) {
                log.warn("解析Modelica代码失败: {}", e.getMessage());
                // 如果解析失败，使用默认接口
                connectors.put("list", createDefaultConnectors());
            }
        } else {
            // 如果没有源码，使用默认接口
            connectors.put("list", createDefaultConnectors());
        }
        
        result.put("parameters", parameters);
        result.put("ports", connectors);
        result.put("connectors", connectors); // 兼容前端可能使用的字段名
        
        return result;
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
        
        BsModelingProject project = new BsModelingProject();
        project.setUserId(userId);
        project.setName(request.getName());
        project.setDescription(request.getDescription());
        project.setProjectData(request.getProjectData());
        project.setModelicaCode(request.getModelicaCode());
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
        
        projectMapper.update(project);
    }
    
    @Override
    public BsModelingProject getProject(Long projectId) {
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
    public Page<BsModelingProject> getUserProjects(int pageNum, int pageSize) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new BusinessException("用户未登录");
        }
        
        QueryWrapper queryWrapper = QueryWrapper.create()
                .where("user_id = ?", userId)
                .and("is_del = ?", 0)
                .orderBy("create_time", false);
        
        return projectMapper.paginate(pageNum, pageSize, queryWrapper);
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long submitSimulation(SimulationRequest request) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new BusinessException("用户未登录");
        }
        
        // 验证请求
        if (request.getProjectId() == null && StrUtil.isBlank(request.getModelCode())) {
            throw new BusinessException("项目ID或模型代码必须提供其一");
        }
        
        String modelCode = request.getModelCode();
        
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
        
        // 创建仿真任务记录
        BsSimulationTask task = new BsSimulationTask();
        task.setUserId(userId);
        task.setProjectId(request.getProjectId());
        task.setTaskId(UUID.randomUUID().toString().replace("-", ""));
        task.setModelCode(modelCode);
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
        payload.put("modelCode", task.getModelCode());
        payload.put("simulationParams", JSON.parseObject(task.getSimulationParams()));

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

