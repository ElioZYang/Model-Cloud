package com.modelcloud.modules.sys.service;

import com.modelcloud.modules.sys.model.dto.*;
import com.modelcloud.modules.sys.model.domain.SysUser;
import com.mybatisflex.core.paginate.Page;

import java.util.List;

/**
 * 用户服务接口
 * 
 * @author model-cloud
 */
public interface SysUserService {
    
    /**
     * 分页查询用户列表
     */
    Page<UserVO> pageUsers(UserQueryRequest request);
    
    /**
     * 根据ID查询用户详情
     */
    UserVO getUserById(Long id);
    
    /**
     * 创建用户
     */
    void createUser(UserCreateRequest request);
    
    /**
     * 更新用户
     */
    void updateUser(UserUpdateRequest request);
    
    /**
     * 删除用户（逻辑删除）
     */
    void deleteUser(Long id);
    
    /**
     * 批量删除用户（逻辑删除）
     */
    void batchDeleteUsers(List<Long> ids);
    
    /**
     * 启用用户
     */
    void enableUser(Long id);
    
    /**
     * 禁用用户
     */
    void disableUser(Long id);
    
    /**
     * 重置密码
     */
    void resetPassword(ResetPasswordRequest request);
}

