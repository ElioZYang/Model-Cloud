package com.modelcloud.modules.auth.service;

import com.modelcloud.modules.auth.model.dto.LoginRequest;
import com.modelcloud.modules.auth.model.dto.LoginResponse;
import com.modelcloud.modules.auth.model.dto.RegisterRequest;

/**
 * 认证服务接口
 * 
 * @author model-cloud
 */
public interface AuthService {
    
    /**
     * 用户登录
     */
    LoginResponse login(LoginRequest request);
    
    /**
     * 用户注册
     */
    void register(RegisterRequest request);
    
    /**
     * 用户登出
     */
    void logout(String token);
    
    /**
     * 获取当前用户信息
     */
    LoginResponse.UserInfo getCurrentUser(Long userId);
}



