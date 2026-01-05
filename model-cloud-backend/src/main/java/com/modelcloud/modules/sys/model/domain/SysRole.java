package com.modelcloud.modules.sys.model.domain;

import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 系统角色实体类
 * 
 * @author model-cloud
 */
@Data
@Table("sys_role")
public class SysRole implements Serializable {
    private static final long serialVersionUID = 1L;
    
    @Id
    private Long id;
    private String roleName;
    private String roleCode;
    private String description;
    private Integer status;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    private Integer isDel;
}

























