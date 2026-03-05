package com.modelcloud.modules.business.controller;

import com.modelcloud.common.web.domain.response.Result;
import com.modelcloud.modules.business.model.domain.BsComponent;
import com.modelcloud.modules.business.model.domain.BsModelingProject;
import com.modelcloud.modules.business.model.domain.BsSimulationTask;
import com.modelcloud.modules.business.model.request.ModelingProjectRequest;
import com.modelcloud.modules.business.model.request.SimulationRequest;
import com.modelcloud.modules.business.service.ModelDeployService;
import com.mybatisflex.core.paginate.Page;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 模型部署控制器
 * 
 * @author model-cloud
 */
@Slf4j
@RestController
@RequestMapping("/business/model-deploy")
public class ModelDeployController {
    
    private final ModelDeployService modelDeployService;
    
    public ModelDeployController(ModelDeployService modelDeployService) {
        this.modelDeployService = modelDeployService;
    }
    
    /**
     * 获取可用于建模的组件列表（公开的Modelica组件）
     */
    @GetMapping("/components")
    public Result<List<BsComponent>> getComponents(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String keyword) {
        try {
            List<BsComponent> components = modelDeployService.getComponents(category, keyword);
            return Result.success(components);
        } catch (Exception e) {
            log.error("获取组件列表失败", e);
            return Result.error("获取组件列表失败: " + e.getMessage());
        }
    }
    
    /**
     * 获取组件详情（包括参数定义、端口定义等）
     */
    @GetMapping("/components/{componentId}")
    public Result<Map<String, Object>> getComponentDetail(@PathVariable Long componentId) {
        try {
            Map<String, Object> detail = modelDeployService.getComponentDetail(componentId);
            return Result.success(detail);
        } catch (Exception e) {
            log.error("获取组件详情失败", e);
            return Result.error("获取组件详情失败: " + e.getMessage());
        }
    }
    
    /**
     * 保存建模项目
     */
    @PostMapping("/projects")
    public Result<Long> saveProject(@RequestBody ModelingProjectRequest request) {
        try {
            Long projectId = modelDeployService.saveProject(request);
            return Result.success(projectId);
        } catch (Exception e) {
            log.error("保存项目失败", e);
            return Result.error("保存项目失败: " + e.getMessage());
        }
    }
    
    /**
     * 更新建模项目
     */
    @PutMapping("/projects/{projectId}")
    public Result<?> updateProject(@PathVariable Long projectId, @RequestBody ModelingProjectRequest request) {
        try {
            modelDeployService.updateProject(projectId, request);
            return Result.success("更新成功");
        } catch (Exception e) {
            log.error("更新项目失败", e);
            return Result.error("更新项目失败: " + e.getMessage());
        }
    }
    
    /**
     * 获取建模项目
     */
    @GetMapping("/projects/{projectId}")
    public Result<BsModelingProject> getProject(@PathVariable Long projectId) {
        try {
            BsModelingProject project = modelDeployService.getProject(projectId);
            return Result.success(project);
        } catch (Exception e) {
            log.error("获取项目失败", e);
            return Result.error("获取项目失败: " + e.getMessage());
        }
    }
    
    /**
     * 删除建模项目
     */
    @DeleteMapping("/projects/{projectId}")
    public Result<?> deleteProject(@PathVariable Long projectId) {
        try {
            modelDeployService.deleteProject(projectId);
            return Result.success("删除成功");
        } catch (Exception e) {
            log.error("删除项目失败", e);
            return Result.error("删除项目失败: " + e.getMessage());
        }
    }
    
    /**
     * 获取用户的项目列表
     */
    @GetMapping("/projects")
    public Result<Page<BsModelingProject>> getUserProjects(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "10") int pageSize) {
        try {
            Page<BsModelingProject> page = modelDeployService.getUserProjects(pageNum, pageSize);
            return Result.success(page);
        } catch (Exception e) {
            log.error("获取项目列表失败", e);
            return Result.error("获取项目列表失败: " + e.getMessage());
        }
    }
    
    /**
     * 提交仿真任务
     */
    @PostMapping("/simulation/submit")
    public Result<Long> submitSimulation(@RequestBody SimulationRequest request) {
        try {
            Long taskId = modelDeployService.submitSimulation(request);
            return Result.success(taskId);
        } catch (Exception e) {
            log.error("提交仿真任务失败", e);
            return Result.error("提交仿真任务失败: " + e.getMessage());
        }
    }
    
    /**
     * 查询仿真任务状态
     */
    @GetMapping("/simulation/{taskId}/status")
    public Result<BsSimulationTask> getSimulationStatus(@PathVariable Long taskId) {
        try {
            BsSimulationTask task = modelDeployService.getSimulationTask(taskId);
            return Result.success(task);
        } catch (Exception e) {
            log.error("查询任务状态失败", e);
            return Result.error("查询任务状态失败: " + e.getMessage());
        }
    }
    
    /**
     * 获取用户的仿真任务列表
     */
    @GetMapping("/simulation/tasks")
    public Result<Page<BsSimulationTask>> getUserSimulationTasks(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "10") int pageSize) {
        try {
            Page<BsSimulationTask> page = modelDeployService.getUserSimulationTasks(pageNum, pageSize);
            return Result.success(page);
        } catch (Exception e) {
            log.error("获取任务列表失败", e);
            return Result.error("获取任务列表失败: " + e.getMessage());
        }
    }
}

