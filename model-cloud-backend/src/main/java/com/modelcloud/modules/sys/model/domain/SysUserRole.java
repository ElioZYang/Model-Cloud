package com.modelcloud.modules.sys.model.domain;

import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.KeyType;
import com.mybatisflex.annotation.Table;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 用户角色关联实体类
 * 
 * @author model-cloud
 */
@Data
@Table("sys_user_role")
public class SysUserRole implements Serializable {
    private static final long serialVersionUID = 1L;
    
    @Id(keyType = KeyType.Auto)
    private Long id;
    
    /**
     * 用户ID
     */
    private Long userId;
    
    /**
     * 角色ID
     */
    private Long roleId;
    
    /**
     * 创建时间
     */
    private LocalDateTime createTime;
}

