package com.modelcloud.modules.auth.controller;

import com.modelcloud.common.tools.JwtUtil;
import com.modelcloud.common.web.domain.response.Result;
import com.modelcloud.modules.auth.model.dto.CaptchaResponse;
import com.modelcloud.modules.auth.model.dto.LoginRequest;
import com.modelcloud.modules.auth.model.dto.LoginResponse;
import com.modelcloud.modules.auth.model.dto.RegisterRequest;
import com.modelcloud.modules.auth.service.AuthService;
import com.modelcloud.modules.auth.service.CaptchaService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 认证控制器
 * 
 * @author model-cloud
 */
@Slf4j
@RestController
@RequestMapping("/auth")
public class AuthController {
    
    private final AuthService authService;
    private final CaptchaService captchaService;
    private final JwtUtil jwtUtil;
    
    public AuthController(AuthService authService, CaptchaService captchaService, JwtUtil jwtUtil) {
        this.authService = authService;
        this.captchaService = captchaService;
        this.jwtUtil = jwtUtil;
    }
    
    /**
     * 用户登录
     */
    @PostMapping("/login")
    public Result<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        LoginResponse response = authService.login(request);
        return Result.success(response);
    }
    
    /**
     * 用户注册
     */
    @PostMapping("/register")
    public Result<?> register(@Valid @RequestBody RegisterRequest request) {
        authService.register(request);
        return Result.success("注册成功");
    }
    
    /**
     * 用户登出
     */
    @PostMapping("/logout")
    public Result<?> logout(HttpServletRequest request) {
        String token = getTokenFromRequest(request);
        authService.logout(token);
        return Result.success("登出成功");
    }
    
    /**
     * 获取验证码
     */
    @GetMapping("/captcha")
    public Result<CaptchaResponse> getCaptcha() {
        Map<String, String> captcha = captchaService.generateCaptcha();
        CaptchaResponse response = new CaptchaResponse(captcha.get("key"), captcha.get("image"));
        return Result.success(response);
    }
    
    /**
     * 获取当前用户信息
     */
    @GetMapping("/user")
    public Result<LoginResponse.UserInfo> getCurrentUser(HttpServletRequest request) {
        String token = getTokenFromRequest(request);
        Long userId = jwtUtil.getUserIdFromToken(token);
        if (userId == null) {
            return Result.error(401, "未登录或Token无效");
        }
        LoginResponse.UserInfo userInfo = authService.getCurrentUser(userId);
        return Result.success(userInfo);
    }
    
    /**
     * 从请求中获取Token
     */
    private String getTokenFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}

