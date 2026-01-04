package com.modelcloud.modules.auth.model.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * 注册请求DTO
 * 
 * @author model-cloud
 */
@Data
public class RegisterRequest {
    
    @NotBlank(message = "用户名不能为空")
    @Size(min = 3, max = 20, message = "用户名长度为3-20个字符")
    @Pattern(regexp = "^[a-zA-Z0-9_]+$", message = "用户名只能包含字母、数字和下划线")
    private String username;
    
    @Size(max = 20, message = "昵称长度不能超过20个字符")
    private String nickname;
    
    @NotBlank(message = "邮箱不能为空")
    @Email(message = "邮箱格式不正确")
    private String email;
    
    @Pattern(regexp = "^$|^1[3-9]\\d{9}$", message = "手机号格式不正确")
    private String phone;
    
    @NotBlank(message = "密码不能为空")
    @Size(min = 6, max = 20, message = "密码长度为6-20个字符")
    @Pattern(regexp = "^(?=.*[a-zA-Z])(?=.*\\d).+$", message = "密码必须包含字母和数字")
    private String password;
    
    @NotBlank(message = "确认密码不能为空")
    private String confirmPassword;
    
    @NotBlank(message = "验证码不能为空")
    @Size(min = 4, max = 4, message = "验证码为4位字符")
    private String captcha;
    
    @NotBlank(message = "验证码key不能为空")
    private String captchaKey;
}


