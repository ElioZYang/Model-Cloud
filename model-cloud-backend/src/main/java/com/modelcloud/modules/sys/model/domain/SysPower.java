package com.modelcloud.modules.sys.model.domain;

import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 系统权限实体类
 * 
 * @author model-cloud
 */
@Data
@Table("sys_power")
public class SysPower implements Serializable {
    private static final long serialVersionUID = 1L;
    
    @Id
    private Long id;
    private String powerName;
    private String powerCode;
    private String path;
    private String method;
    private Long parentId;
    private Integer sort;
    private String description;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    private Integer isDel;
}

























