package com.modelcloud.modules.business.model.domain;

import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.KeyType;
import com.mybatisflex.annotation.Table;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 仿真任务实体类
 * 
 * @author model-cloud
 */
@Data
@Table("bs_simulation_task")
public class BsSimulationTask implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /**
     * 任务ID
     */
    @Id(keyType = KeyType.Auto)
    private Long id;
    
    /**
     * 用户ID
     */
    private Long userId;
    
    /**
     * 关联的建模项目ID（可为空）
     */
    private Long projectId;
    
    /**
     * 仿真服务返回的任务ID（唯一）
     */
    private String taskId;
    
    /**
     * Modelica模型代码
     */
    private String modelCode;
    
    /**
     * 仿真参数（JSON格式）
     */
    private String simulationParams;
    
    /**
     * 任务状态：pending/running/completed/failed/cancelled
     */
    private String status;
    
    /**
     * 进度百分比（0-100）
     */
    private Integer progress;
    
    /**
     * 结果文件URL
     */
    private String resultFileUrl;
    
    /**
     * 结果数据（JSON格式，用于快速预览）
     */
    private String resultData;
    
    /**
     * 错误信息
     */
    private String errorMessage;
    
    /**
     * 开始时间
     */
    private LocalDateTime startTime;
    
    /**
     * 结束时间
     */
    private LocalDateTime endTime;
    
    /**
     * 创建时间
     */
    private LocalDateTime createTime;
    
    /**
     * 更新时间
     */
    private LocalDateTime updateTime;
}

