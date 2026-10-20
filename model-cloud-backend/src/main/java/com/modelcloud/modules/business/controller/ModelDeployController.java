package com.modelcloud.modules.business.controller;

import com.modelcloud.common.web.domain.response.Result;
import com.modelcloud.modules.business.model.domain.BsModelingProject;
import com.modelcloud.modules.business.model.dto.ComponentVO;
import com.modelcloud.modules.business.model.dto.MatlabComponentVO;
import com.modelcloud.modules.business.model.dto.MatlabConfigVO;
import com.modelcloud.modules.business.model.domain.BsSimulationTask;
import com.modelcloud.modules.business.model.request.ModelingProjectRequest;
import com.modelcloud.modules.business.model.request.SimulationRequest;
import com.modelcloud.modules.business.service.ModelDeployService;
import com.modelcloud.modules.business.service.MatlabConfigService;
import com.mybatisflex.core.paginate.Page;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.multipart.MultipartFile;

import java.nio.charset.StandardCharsets;
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
    private final MatlabConfigService matlabConfigService;
    
    public ModelDeployController(
            ModelDeployService modelDeployService,
            MatlabConfigService matlabConfigService) {
        this.modelDeployService = modelDeployService;
        this.matlabConfigService = matlabConfigService;
    }
    
    /**
     * 获取可用于建模的组件列表（从静态目录扫描，bs_component 已弃用）
     */
    @GetMapping("/components")
    public Result<List<ComponentVO>> getComponents(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String keyword) {
        try {
            List<ComponentVO> components = modelDeployService.getComponents(category, keyword);
            return Result.success(components);
        } catch (Exception e) {
            log.error("获取组件列表失败", e);
            return Result.error("获取组件列表失败，请稍后重试");
        }
    }

    /**
     * 分页获取组件列表（支持模块筛选）
     */
    @GetMapping("/components/paged")
    public Result<Map<String, Object>> getComponentsPaged(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String module,
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "200") int pageSize) {
        try {
            Map<String, Object> data = modelDeployService.getComponentsPaged(category, keyword, module, pageNum, pageSize);
            return Result.success(data);
        } catch (Exception e) {
            log.error("分页获取组件列表失败", e);
            return Result.error("分页获取组件列表失败，请稍后重试");
        }
    }

    /**
     * 获取组件详情（按 className，包括参数、端口等）
     */
    @GetMapping("/components/by-class")
    public Result<Map<String, Object>> getComponentDetailByClassName(
            @RequestParam String className) {
        try {
            Map<String, Object> detail = modelDeployService.getComponentDetailByClassName(className);
            return Result.success(detail);
        } catch (Exception e) {
            log.error("获取组件详情失败", e);
            return Result.error("获取组件详情失败，请稍后重试");
        }
    }

    /**
     * 组件元数据调试（查看端口是否来自 OMC 集合）
     */
    @GetMapping("/components/debug/by-class")
    public Result<Map<String, Object>> getComponentMetaDebugByClassName(
            @RequestParam String className) {
        try {
            Map<String, Object> detail = modelDeployService.getComponentMetaDebugByClassName(className);
            return Result.success(detail);
        } catch (Exception e) {
            log.error("获取组件调试信息失败", e);
            return Result.error("获取组件调试信息失败，请稍后重试");
        }
    }

    /**
     * 获取MATLAB函数组件列表。第一阶段仅返回单标量示例组件。
     */
    @GetMapping("/matlab/components")
    public Result<List<MatlabComponentVO>> getMatlabComponents() {
        try {
            return Result.success(modelDeployService.getMatlabComponents());
        } catch (Exception e) {
            log.error("获取MATLAB组件列表失败", e);
            return Result.error("获取MATLAB组件列表失败，请稍后重试");
        }
    }

    @GetMapping("/matlab/config-template")
    public ResponseEntity<byte[]> downloadMatlabConfigTemplate(
            @RequestParam(value = "componentId", required = false) String componentId) {
        byte[] bytes = matlabConfigService.templateBytes(componentId);
        ContentDisposition disposition = ContentDisposition.attachment()
                .filename("PMSM电机配置模板.xlsx", StandardCharsets.UTF_8)
                .build();
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(
                        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                .contentLength(bytes.length)
                .header(HttpHeaders.CONTENT_DISPOSITION, disposition.toString())
                .body(bytes);
    }

    @GetMapping("/matlab/config-schema")
    public Result<Map<String, Object>> getMatlabConfigSchema(
            @RequestParam(value = "componentId", required = false) String componentId) {
        return Result.success(matlabConfigService.schema(componentId));
    }

    @PostMapping(value = "/matlab/configs", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public Result<MatlabConfigVO> uploadMatlabConfig(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "name", required = false) String name,
            @RequestParam(value = "componentId", required = false) String componentId) {
        return Result.success(matlabConfigService.upload(file, name, componentId));
    }

    @GetMapping("/matlab/configs/my")
    public Result<List<MatlabConfigVO>> listMyMatlabConfigs() {
        return Result.success(matlabConfigService.listMine());
    }

    @GetMapping("/matlab/configs/{configId}")
    public Result<MatlabConfigVO> getMatlabConfig(@PathVariable String configId) {
        return Result.success(matlabConfigService.getMine(configId));
    }

    @DeleteMapping("/matlab/configs/{configId}")
    public Result<String> deleteMatlabConfig(@PathVariable String configId) {
        matlabConfigService.softDelete(configId);
        return Result.success("删除成功");
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
            return Result.error("保存项目失败，请稍后重试");
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
            return Result.error("更新项目失败，请稍后重试");
        }
    }
    
    /**
     * 获取建模项目
     */
    @GetMapping("/projects/{projectId}")
    public Result<BsModelingProject> getProject(@PathVariable Long projectId,
                                                @RequestParam(required = false) String projectType) {
        try {
            BsModelingProject project = modelDeployService.getProject(projectId, projectType);
            return Result.success(project);
        } catch (Exception e) {
            log.error("获取项目失败", e);
            return Result.error("获取项目失败，请稍后重试");
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
            return Result.error("删除项目失败，请稍后重试");
        }
    }
    
    /**
     * 获取用户的项目列表
     */
    @GetMapping("/projects")
    public Result<Page<BsModelingProject>> getUserProjects(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String projectType) {
        try {
            Page<BsModelingProject> page = modelDeployService.getUserProjects(pageNum, pageSize, projectType);
            return Result.success(page);
        } catch (Exception e) {
            log.error("获取项目列表失败", e);
            return Result.error("获取项目列表失败，请稍后重试");
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
            return Result.error("提交仿真任务失败，请稍后重试");
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
            return Result.error("查询任务状态失败，请稍后重试");
        }
    }

    /**
     * 获取仿真任务的图片产物。返回原始PNG响应，任务所有权由服务层校验。
     */
    @GetMapping(value = "/simulation/{taskId}/artifacts/{artifactId}",
            produces = MediaType.IMAGE_PNG_VALUE)
    public ResponseEntity<byte[]> getSimulationArtifact(
            @PathVariable Long taskId, @PathVariable String artifactId) {
        return modelDeployService.getSimulationArtifact(taskId, artifactId);
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
            return Result.error("获取任务列表失败，请稍后重试");
        }
    }
}
