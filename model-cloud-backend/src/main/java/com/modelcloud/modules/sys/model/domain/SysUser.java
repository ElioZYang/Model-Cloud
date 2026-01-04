package com.modelcloud.modules.sys.model.domain;

import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 系统用户实体类
 * 
 * @author model-cloud
 */
@Data
@Table("sys_user")
public class SysUser implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /**
     * 用户ID
     */
    @Id
    private Long id;
    
    /**
     * 用户名
     */
    private String username;
    
    /**
     * 密码
     */
    private String password;
    
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



