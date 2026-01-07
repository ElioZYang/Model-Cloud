package com.modelcloud.modules.auth.model.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 验证码响应DTO
 * 
 * @author model-cloud
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CaptchaResponse {
    
    /**
     * 验证码key
     */
    private String key;
    
    /**
     * 验证码图片（Base64）
     */
    private String image;
}


























