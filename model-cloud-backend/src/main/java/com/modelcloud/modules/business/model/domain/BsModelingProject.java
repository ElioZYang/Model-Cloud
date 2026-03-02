package com.modelcloud.modules.business.model.domain;

import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.KeyType;
import com.mybatisflex.annotation.Table;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 建模项目实体类
 * 
 * @author model-cloud
 */
@Data
@Table("bs_modeling_project")
public class BsModelingProject implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /**
     * 项目ID
     */
    @Id(keyType = KeyType.Auto)
    private Long id;
    
    /**
     * 用户ID
     */
    private Long userId;
    
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
     * 生成的Modelica代码
     */
    private String modelicaCode;
    
    /**
     * 创建时间
     */
    private LocalDateTime createTime;
    
    /**
     * 更新时间
     */
    private LocalDateTime updateTime;
    
    /**
     * 是否删除：0未删除，1已删除
     */
    private Integer isDel;
}

