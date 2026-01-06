package com.modelcloud.modules.sys.controller;

import com.modelcloud.common.tools.SecurityUtils;
import com.modelcloud.common.web.domain.response.Result;
import com.modelcloud.modules.sys.model.dto.*;
import com.modelcloud.modules.sys.model.domain.SysRole;
import com.modelcloud.modules.sys.service.SysRoleService;
import com.modelcloud.modules.sys.service.SysUserService;
import com.mybatisflex.core.paginate.Page;
import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 系统用户管理控制器
 * 
 * @author model-cloud
 */
@Slf4j
@RestController
@RequestMapping("/sys/user")
public class SysUserController {
    
    private final SysUserService userService;
    private final SysRoleService roleService;
    
    public SysUserController(SysUserService userService, SysRoleService roleService) {
        this.userService = userService;
        this.roleService = roleService;
    }
    
    /**
     * 分页查询用户列表（需要管理员权限）
     */
    @GetMapping("/page")
    public Result<Page<UserVO>> pageUsers(UserQueryRequest request) {
        SecurityUtils.requireAdmin();
        Page<UserVO> page = userService.pageUsers(request);
        return Result.success(page);
    }
    
    /**
     * 根据ID查询用户详情（需要管理员权限）
     */
    @GetMapping("/{id}")
    public Result<UserVO> getUserById(@PathVariable Long id) {
        SecurityUtils.requireAdmin();
        UserVO user = userService.getUserById(id);
        return Result.success(user);
    }
    
    /**
     * 创建用户（需要管理员权限）
     */
    @PostMapping
    public Result<Void> createUser(@Valid @RequestBody UserCreateRequest request) {
        SecurityUtils.requireAdmin();
        userService.createUser(request);
        return Result.success("创建用户成功", null);
    }
    
    /**
     * 更新用户（需要管理员权限）
     */
    @PutMapping
    public Result<Void> updateUser(@Valid @RequestBody UserUpdateRequest request) {
        SecurityUtils.requireAdmin();
        userService.updateUser(request);
        return Result.success("更新用户成功", null);
    }
    
    /**
     * 删除用户（需要管理员权限）
     */
    @DeleteMapping("/{id}")
    public Result<Void> deleteUser(@PathVariable Long id) {
        SecurityUtils.requireAdmin();
        userService.deleteUser(id);
        return Result.success("删除用户成功", null);
    }
    
    /**
     * 批量删除用户（需要管理员权限）
     */
    @DeleteMapping("/batch")
    public Result<Void> batchDeleteUsers(@RequestBody List<Long> ids) {
        SecurityUtils.requireAdmin();
        userService.batchDeleteUsers(ids);
        return Result.success("批量删除用户成功", null);
    }
    
    /**
     * 启用用户（需要管理员权限）
     */
    @PutMapping("/{id}/enable")
    public Result<Void> enableUser(@PathVariable Long id) {
        SecurityUtils.requireAdmin();
        userService.enableUser(id);
        return Result.success("启用用户成功", null);
    }
    
    /**
     * 禁用用户（需要管理员权限）
     */
    @PutMapping("/{id}/disable")
    public Result<Void> disableUser(@PathVariable Long id) {
        SecurityUtils.requireAdmin();
        userService.disableUser(id);
        return Result.success("禁用用户成功", null);
    }
    
    /**
     * 重置密码（需要管理员权限）
     */
    @PutMapping("/reset-password")
    public Result<Void> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        SecurityUtils.requireAdmin();
        userService.resetPassword(request);
        return Result.success("重置密码成功", null);
    }
    
    /**
     * 查询所有角色（用于下拉选择，需要管理员权限）
     */
    @GetMapping("/roles")
    public Result<List<SysRole>> listRoles() {
        SecurityUtils.requireAdmin();
        List<SysRole> roles = roleService.listEnabledRoles();
        return Result.success(roles);
    }
    
    /**
     * 获取当前用户个人信息（需要登录）
     */
    @GetMapping("/profile")
    public Result<UserVO> getProfile() {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new com.modelcloud.common.exception.BusinessException("用户未登录");
        }
        UserVO user = userService.getUserById(userId);
        return Result.success(user);
    }
    
    /**
     * 更新当前用户个人信息（需要登录）
     */
    @PutMapping("/profile")
    public Result<Void> updateProfile(@Valid @RequestBody com.modelcloud.modules.sys.model.dto.UserProfileUpdateRequest request) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new com.modelcloud.common.exception.BusinessException("用户未登录");
        }
        userService.updateProfile(userId, request);
        return Result.success("更新成功", null);
    }
    
    /**
     * 修改当前用户密码（需要登录）
     */
    @PutMapping("/change-password")
    public Result<Void> changePassword(@Valid @RequestBody com.modelcloud.modules.sys.model.dto.ChangePasswordRequest request) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new com.modelcloud.common.exception.BusinessException("用户未登录");
        }
        userService.changePassword(userId, request);
        return Result.success("密码修改成功", null);
    }
}
