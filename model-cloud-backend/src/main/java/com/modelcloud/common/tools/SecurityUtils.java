package com.modelcloud.common.tools;

import com.modelcloud.common.exception.BusinessException;
import com.modelcloud.modules.sys.mapper.SysRoleMapper;
import com.modelcloud.modules.sys.mapper.SysUserRoleMapper;
import com.modelcloud.modules.sys.model.domain.SysRole;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.List;
import java.util.Map;

/**
 * 安全工具类
 */
public class SecurityUtils {

    private static SysUserRoleMapper userRoleMapper;
    private static SysRoleMapper roleMapper;

    /**
     * 设置Mapper（通过Spring容器注入）
     */
    public static void setMappers(SysUserRoleMapper userRoleMapper, SysRoleMapper roleMapper) {
        SecurityUtils.userRoleMapper = userRoleMapper;
        SecurityUtils.roleMapper = roleMapper;
    }

    /**
     * 获取当前登录用户ID
     */
    public static Long getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            return null;
        }
        
        Object principal = authentication.getPrincipal();
        if (principal instanceof Long) {
            return (Long) principal;
        } else if (principal instanceof Integer) {
            return ((Integer) principal).longValue();
        } else if (principal instanceof Map) {
            Map<?, ?> claims = (Map<?, ?>) principal;
            Object userId = claims.get("userId");
            if (userId instanceof Integer) {
                return ((Integer) userId).longValue();
            } else if (userId instanceof Long) {
                return (Long) userId;
            }
        }
        
        return null;
    }

    /**
     * 检查当前用户是否是管理员（包括超级管理员和管理员）
     */
    public static boolean isAdmin() {
        Long userId = getCurrentUserId();
        if (userId == null || userRoleMapper == null || roleMapper == null) {
            return false;
        }
        
        List<Long> roleIds = userRoleMapper.selectRoleIdsByUserId(userId);
        if (roleIds == null || roleIds.isEmpty()) {
            return false;
        }
        
        for (Long roleId : roleIds) {
            SysRole role = roleMapper.selectOneById(roleId);
            if (role != null && ("admin".equals(role.getRoleCode()) || "super_admin".equals(role.getRoleCode()))) {
                return true;
            }
        }
        
        return false;
    }

    /**
     * 检查当前用户是否是超级管理员
     */
    public static boolean isSuperAdmin() {
        Long userId = getCurrentUserId();
        if (userId == null || userRoleMapper == null || roleMapper == null) {
            return false;
        }
        
        List<Long> roleIds = userRoleMapper.selectRoleIdsByUserId(userId);
        if (roleIds == null || roleIds.isEmpty()) {
            return false;
        }
        
        for (Long roleId : roleIds) {
            SysRole role = roleMapper.selectOneById(roleId);
            if (role != null && "super_admin".equals(role.getRoleCode())) {
                return true;
            }
        }
        
        return false;
    }

    /**
     * 检查当前用户是否是管理员，如果不是则抛出异常
     */
    public static void requireAdmin() {
        if (!isAdmin()) {
            throw new BusinessException("无权限访问，需要管理员权限");
        }
    }

    /**
     * 检查当前用户是否是超级管理员，如果不是则抛出异常
     */
    public static void requireSuperAdmin() {
        if (!isSuperAdmin()) {
            throw new BusinessException("无权限访问，需要超级管理员权限");
        }
    }
}

