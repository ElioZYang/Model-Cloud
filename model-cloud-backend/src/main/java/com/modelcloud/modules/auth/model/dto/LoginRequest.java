package com.modelcloud.modules.auth.model.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * 登录请求DTO
 * 
 * @author model-cloud
 */
@Data
public class LoginRequest {
    
    @NotBlank(message = "用户名不能为空")
    @Size(min = 3, max = 20, message = "用户名长度为3-20个字符")
    private String username;
    
    @NotBlank(message = "密码不能为空")
    @Size(min = 6, max = 20, message = "密码长度为6-20个字符")
    private String password;
    
    @NotBlank(message = "验证码不能为空")
    @Size(min = 4, max = 4, message = "验证码为4位字符")
    private String captcha;
    
    @NotBlank(message = "验证码key不能为空")
    private String captchaKey;
}


























