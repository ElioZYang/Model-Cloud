package com.modelcloud.modules.auth.service;

import java.util.Map;

/**
 * 验证码服务接口
 * 
 * @author model-cloud
 */
public interface CaptchaService {
    
    /**
     * 生成验证码
     * @return Map包含key和base64图片
     */
    Map<String, String> generateCaptcha();
    
    /**
     * 验证验证码
     * @param key 验证码key
     * @param code 用户输入的验证码
     * @return 是否验证通过
     */
    boolean validateCaptcha(String key, String code);
}

























