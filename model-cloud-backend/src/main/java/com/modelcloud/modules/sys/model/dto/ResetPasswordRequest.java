package com.modelcloud.modules.sys.model.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * 重置密码请求DTO
 * 
 * @author model-cloud
 */
@Data
public class ResetPasswordRequest {
    
    @NotNull(message = "用户ID不能为空")
    private Long id;
    
    @NotBlank(message = "新密码不能为空")
    @Size(min = 6, max = 20, message = "密码长度为6-20个字符")
    private String newPassword;
}


