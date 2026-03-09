package com.modelcloud.modules.business.service;

import com.modelcloud.modules.business.model.domain.BsModelingProject;
import com.modelcloud.modules.business.model.domain.BsSimulationTask;
import com.modelcloud.modules.business.model.dto.ComponentVO;
import com.modelcloud.modules.business.model.request.ModelingProjectRequest;
import com.modelcloud.modules.business.model.request.SimulationRequest;

import java.util.List;
import java.util.Map;

/**
 * 模型部署服务接口
 * 组件来源：静态目录 component_source（bs_component 已弃用）
 *
 * @author model-cloud
 */
public interface ModelDeployService {

    /**
     * 获取可用于建模的组件列表（从静态目录扫描）
     *
     * @param category 组件类别（可选）
     * @param keyword  关键词搜索（可选）
     * @return 组件列表，id 为 className
     */
    List<ComponentVO> getComponents(String category, String keyword);

    /**
     * 获取组件详情（按 className，包括参数、端口等）
     *
     * @param className 完整类名，如 Modelica.Electrical.Analog.Basic.Resistor
     * @return 组件详情
     */
    Map<String, Object> getComponentDetailByClassName(String className);
    
    /**
     * 保存建模项目
     * 
     * @param request 项目请求对象
     * @return 保存的项目ID
     */
    Long saveProject(ModelingProjectRequest request);
    
    /**
     * 更新建模项目
     * 
     * @param projectId 项目ID
     * @param request 项目请求对象
     */
    void updateProject(Long projectId, ModelingProjectRequest request);
    
    /**
     * 获取建模项目
     * 
     * @param projectId 项目ID
     * @return 项目对象
     */
    BsModelingProject getProject(Long projectId);
    
    /**
     * 删除建模项目
     * 
     * @param projectId 项目ID
     */
    void deleteProject(Long projectId);
    
    /**
     * 获取用户的项目列表
     * 
     * @param pageNum 页码
     * @param pageSize 每页大小
     * @return 项目列表
     */
    com.mybatisflex.core.paginate.Page<BsModelingProject> getUserProjects(int pageNum, int pageSize);
    
    /**
     * 提交仿真任务
     * 
     * @param request 仿真请求
     * @return 任务ID（数据库ID）
     */
    Long submitSimulation(SimulationRequest request);
    
    /**
     * 查询仿真任务状态
     * 
     * @param taskId 任务ID（数据库ID）
     * @return 任务对象
     */
    BsSimulationTask getSimulationTask(Long taskId);
    
    /**
     * 获取用户的仿真任务列表
     * 
     * @param pageNum 页码
     * @param pageSize 每页大小
     * @return 任务列表
     */
    com.mybatisflex.core.paginate.Page<BsSimulationTask> getUserSimulationTasks(int pageNum, int pageSize);
}

