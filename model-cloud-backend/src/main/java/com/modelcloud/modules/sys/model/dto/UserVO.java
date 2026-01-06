package com.modelcloud.modules.sys.model.dto;

import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 用户视图对象
 * 
 * @author model-cloud
 */
@Data
public class UserVO implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /**
     * 用户ID
     */
    private Long id;
    
    /**
     * 用户名
     */
    private String username;
    
    /**
     * 昵称
     */
    private String nickname;
    
    /**
     * 邮箱
     */
    private String email;
    
    /**
     * 手机号
     */
    private String phone;
    
    /**
     * 头像
     */
    private String avatar;
    
    /**
     * 状态：0禁用，1启用
     */
    private Integer status;
    
    /**
     * 状态文本
     */
    private String statusText;
    
    /**
     * 创建时间
     */
    private LocalDateTime createTime;
    
    /**
     * 更新时间
     */
    private LocalDateTime updateTime;
    
    /**
     * 角色列表
     */
    private List<RoleVO> roles;
}

