package com.modelcloud.modules.business.model.request;

import lombok.Data;
import java.io.Serializable;

/**
 * 建模项目请求对象
 * 
 * @author model-cloud
 */
@Data
public class ModelingProjectRequest implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /**
     * 项目名称
     */
    private String name;
    
    /**
     * 项目描述
     */
    private String description;
    
    /**
     * 项目数据（JSON格式，包含节点、连线等）
     */
    private String projectData;
    
    /**
     * 生成的Modelica代码（可选）
     */
    private String modelicaCode;
}

