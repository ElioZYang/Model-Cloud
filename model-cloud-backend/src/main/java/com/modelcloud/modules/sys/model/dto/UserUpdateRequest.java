package com.modelcloud.modules.sys.model.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * 更新用户请求DTO
 * 
 * @author model-cloud
 */
@Data
public class UserUpdateRequest {
    
    @NotNull(message = "用户ID不能为空")
    private Long id;
    
    @Size(max = 50, message = "昵称长度不能超过50个字符")
    private String nickname;
    
    @Email(message = "邮箱格式不正确")
    @Size(max = 100, message = "邮箱长度不能超过100个字符")
    private String email;
    
    @Size(max = 20, message = "手机号长度不能超过20个字符")
    private String phone;
    
    @Size(max = 255, message = "头像URL长度不能超过255个字符")
    private String avatar;
    
    /**
     * 角色ID列表（逗号分隔）
     */
    private String roleIds;
    
    /**
     * 状态：0禁用，1启用
     */
    private Integer status;
}

