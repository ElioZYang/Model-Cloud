package com.modelcloud.modules.business.model.request;

import lombok.Data;
import java.io.Serializable;
import java.util.Map;

/**
 * 仿真请求对象
 * 
 * @author model-cloud
 */
@Data
public class SimulationRequest implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /**
     * 关联的建模项目ID（可选，如果为空则使用modelCode）
     */
    private Long projectId;
    
    /**
     * Modelica模型代码（如果projectId为空则必填）
     */
    private String modelCode;
    
    /**
     * 仿真参数
     */
    private SimulationParams simulationParams;
    
    @Data
    public static class SimulationParams implements Serializable {
        private static final long serialVersionUID = 1L;
        
        /**
         * 开始时间
         */
        private Double startTime = 0.0;
        
        /**
         * 结束时间（仿真时长）
         */
        private Double stopTime = 10.0;
        
        /**
         * 步长
         */
        private Double stepSize = 0.01;
        
        /**
         * 求解器：dassl/euler/rk4/cvode等
         */
        private String solver = "dassl";
        
        /**
         * 输入参数（JSON格式，用于设置模型参数）
         */
        private Map<String, Object> inputParams;
    }
}

