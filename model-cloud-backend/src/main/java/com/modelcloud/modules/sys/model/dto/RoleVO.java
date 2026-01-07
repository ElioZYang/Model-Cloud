package com.modelcloud.modules.sys.model.dto;

import lombok.Data;
import java.io.Serializable;

/**
 * 角色视图对象
 * 
 * @author model-cloud
 */
@Data
public class RoleVO implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /**
     * 角色ID
     */
    private Long id;
    
    /**
     * 角色名称
     */
    private String roleName;
    
    /**
     * 角色编码
     */
    private String roleCode;
    
    /**
     * 描述
     */
    private String description;
    
    /**
     * 状态：0禁用，1启用
     */
    private Integer status;
}


