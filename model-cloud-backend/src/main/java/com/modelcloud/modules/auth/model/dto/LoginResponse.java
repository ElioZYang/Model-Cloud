package com.modelcloud.modules.auth.model.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

/**
 * 登录响应DTO
 * 
 * @author model-cloud
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LoginResponse {
    
    /**
     * Token
     */
    private String token;
    
    /**
     * 用户信息
     */
    private UserInfo userInfo;
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UserInfo {
        private Long id;
        private String username;
        private String nickname;
        private String email;
        private String phone;
        private String avatar;
        private List<String> roles;
        
        // 兼容旧版本的构造函数（不包含roles和phone）
        public UserInfo(Long id, String username, String nickname, String email, String avatar) {
            this.id = id;
            this.username = username;
            this.nickname = nickname;
            this.email = email;
            this.phone = null;
            this.avatar = avatar;
            this.roles = new ArrayList<>();
        }
        
        // 包含phone但不包含roles的构造函数
        public UserInfo(Long id, String username, String nickname, String email, String phone, String avatar) {
            this.id = id;
            this.username = username;
            this.nickname = nickname;
            this.email = email;
            this.phone = phone;
            this.avatar = avatar;
            this.roles = new ArrayList<>();
        }
    }
}

























