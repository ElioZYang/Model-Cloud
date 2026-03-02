package com.modelcloud.modules.business.model.domain;

import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.KeyType;
import com.mybatisflex.annotation.Table;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 组件元数据实体类
 * 
 * @author model-cloud
 */
@Data
@Table("bs_component_metadata")
public class BsComponentMetadata implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /**
     * ID
     */
    @Id(keyType = KeyType.Auto)
    private Long id;
    
    /**
     * 关联的模型ID
     */
    private Long modelId;
    
    /**
     * 组件名称（从.mo文件解析）
     */
    private String componentName;
    
    /**
     * 组件类型（如Resistor、VoltageSource等）
     */
    private String componentType;
    
    /**
     * 参数定义（JSON格式）
     */
    private String parameters;
    
    /**
     * 端口定义（JSON格式，包含输入输出端口）
     */
    private String ports;
    
    /**
     * 组件源码（.mo文件内容）
     */
    private String sourceCode;
    
    /**
     * 元数据版本（用于缓存失效）
     */
    private Integer metadataVersion;
    
    /**
     * 创建时间
     */
    private LocalDateTime createTime;
    
    /**
     * 更新时间
     */
    private LocalDateTime updateTime;
}

