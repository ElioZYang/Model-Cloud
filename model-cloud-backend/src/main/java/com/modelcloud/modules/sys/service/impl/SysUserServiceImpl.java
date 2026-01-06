package com.modelcloud.modules.sys.service.impl;

import cn.hutool.core.util.StrUtil;
import com.modelcloud.common.constant.CommonConstant;
import com.modelcloud.common.exception.BusinessException;
import com.modelcloud.common.tools.PasswordUtil;
import com.modelcloud.modules.sys.mapper.SysRoleMapper;
import com.modelcloud.modules.sys.mapper.SysUserMapper;
import com.modelcloud.modules.sys.mapper.SysUserRoleMapper;
import com.modelcloud.modules.sys.model.domain.SysRole;
import com.modelcloud.modules.sys.model.domain.SysUser;
import com.modelcloud.modules.sys.model.domain.SysUserRole;
import com.modelcloud.modules.sys.model.dto.*;
import com.modelcloud.modules.sys.service.SysUserService;
import com.mybatisflex.core.paginate.Page;
import com.mybatisflex.core.query.QueryWrapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import static com.modelcloud.modules.sys.model.domain.table.SysUserTableDef.SYS_USER;

/**
 * 用户服务实现类
 * 
 * @author model-cloud
 */
@Slf4j
@Service
public class SysUserServiceImpl implements SysUserService {
    
    private final SysUserMapper userMapper;
    private final SysUserRoleMapper userRoleMapper;
    private final SysRoleMapper roleMapper;
    private final PasswordUtil passwordUtil;
    
    public SysUserServiceImpl(
            SysUserMapper userMapper,
            SysUserRoleMapper userRoleMapper,
            SysRoleMapper roleMapper,
            PasswordUtil passwordUtil) {
        this.userMapper = userMapper;
        this.userRoleMapper = userRoleMapper;
        this.roleMapper = roleMapper;
        this.passwordUtil = passwordUtil;
    }
    
    @Override
    public Page<UserVO> pageUsers(UserQueryRequest request) {
        Long currentUserId = com.modelcloud.common.tools.SecurityUtils.getCurrentUserId();
        boolean isSuperAdmin = com.modelcloud.common.tools.SecurityUtils.isSuperAdmin();
        boolean isAdmin = com.modelcloud.common.tools.SecurityUtils.isAdmin();
        
        QueryWrapper queryWrapper = QueryWrapper.create()
                .where(SYS_USER.IS_DEL.eq(CommonConstant.IS_DEL_NO));
        
        // 权限过滤
        if (isSuperAdmin) {
            // 超级管理员：显示所有用户（包括自己）
            // 不需要过滤
        } else if (isAdmin) {
            // 管理员：排除超级管理员，显示所有其他用户（包括自己和其他管理员）
            // 查询所有超级管理员的用户ID
            List<Long> superAdminUserIds = getSuperAdminUserIds();
            if (superAdminUserIds != null && !superAdminUserIds.isEmpty()) {
                queryWrapper.and(SYS_USER.ID.notIn(superAdminUserIds));
            }
        }
        
        // 添加查询条件
        queryWrapper.and(SYS_USER.USERNAME.like(request.getUsername()).when(StrUtil.isNotBlank(request.getUsername())))
                .and(SYS_USER.NICKNAME.like(request.getNickname()).when(StrUtil.isNotBlank(request.getNickname())))
                .and(SYS_USER.EMAIL.like(request.getEmail()).when(StrUtil.isNotBlank(request.getEmail())))
                .and(SYS_USER.STATUS.eq(request.getStatus()).when(request.getStatus() != null))
                .orderBy(SYS_USER.CREATE_TIME.asc()); // 先按创建时间升序，后面会按角色优先级重新排序
        
        Page<SysUser> page = userMapper.paginate(request.getPageNum(), request.getPageSize(), queryWrapper);
        
        // 转换为VO
        List<UserVO> voList = page.getRecords().stream()
                .map(this::convertToVO)
                .collect(Collectors.toList());
        
        // 按角色优先级排序：super_admin > admin > user，同级别按创建时间
        voList.sort((u1, u2) -> {
            int roleCompare = compareRoleCode(u1.getHighestRoleCode(), u2.getHighestRoleCode());
            if (roleCompare != 0) {
                return roleCompare;
            }
            // 同级别按创建时间升序
            if (u1.getCreateTime() != null && u2.getCreateTime() != null) {
                return u1.getCreateTime().compareTo(u2.getCreateTime());
            }
            return 0;
        });
        
        Page<UserVO> result = new Page<>();
        result.setRecords(voList);
        result.setTotalRow(page.getTotalRow());
        result.setPageNumber(page.getPageNumber());
        result.setPageSize(page.getPageSize());
        result.setTotalPage(page.getTotalPage());
        
        return result;
    }
    
    /**
     * 获取所有超级管理员的用户ID列表
     */
    private List<Long> getSuperAdminUserIds() {
        SysRole superAdminRole = roleMapper.selectOneByQuery(
            QueryWrapper.create()
                .where("role_code = ?", "super_admin")
                .and("is_del = ?", CommonConstant.IS_DEL_NO)
        );
        if (superAdminRole == null) {
            return new ArrayList<>();
        }
        List<Long> userIds = userRoleMapper.selectUserIdsByRoleId(superAdminRole.getId());
        return userIds != null ? userIds : new ArrayList<>();
    }
    
    /**
     * 比较角色代码优先级：super_admin > admin > user
     */
    private int compareRoleCode(String role1, String role2) {
        int priority1 = getRolePriority(role1);
        int priority2 = getRolePriority(role2);
        return Integer.compare(priority1, priority2);
    }
    
    /**
     * 获取角色优先级：数字越小优先级越高
     */
    private int getRolePriority(String roleCode) {
        if ("super_admin".equals(roleCode)) {
            return 1;
        } else if ("admin".equals(roleCode)) {
            return 2;
        } else if ("user".equals(roleCode)) {
            return 3;
        }
        return 99; // 未知角色优先级最低
    }
    
    @Override
    public UserVO getUserById(Long id) {
        SysUser user = userMapper.selectOneById(id);
        if (user == null || user.getIsDel() == CommonConstant.IS_DEL_YES) {
            throw new BusinessException("用户不存在");
        }
        return convertToVO(user);
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createUser(UserCreateRequest request) {
        // 检查用户名是否已存在
        SysUser existUser = userMapper.selectByUsername(request.getUsername());
        if (existUser != null) {
            throw new BusinessException("用户名已存在");
        }
        
        // 检查邮箱是否已存在
        if (StrUtil.isNotBlank(request.getEmail())) {
            existUser = userMapper.selectByEmail(request.getEmail());
            if (existUser != null) {
                throw new BusinessException("邮箱已被注册");
            }
        }
        
        // 创建用户
        SysUser user = new SysUser();
        user.setUsername(request.getUsername());
        user.setPassword(passwordUtil.encode(request.getPassword()));
        user.setNickname(StrUtil.isNotBlank(request.getNickname()) ? request.getNickname() : request.getUsername());
        user.setEmail(request.getEmail());
        user.setPhone(StrUtil.isNotBlank(request.getPhone()) ? request.getPhone() : null);
        user.setStatus(request.getStatus() != null ? request.getStatus() : CommonConstant.STATUS_ENABLE);
        user.setIsDel(CommonConstant.IS_DEL_NO);
        user.setCreateTime(LocalDateTime.now());
        user.setUpdateTime(LocalDateTime.now());
        
        userMapper.insert(user);
        
        // 保存用户角色关联（只有超级管理员可以设置用户角色）
        if (StrUtil.isNotBlank(request.getRoleIds())) {
            com.modelcloud.common.tools.SecurityUtils.requireSuperAdmin();
            saveUserRoles(user.getId(), request.getRoleIds());
        } else {
            // 如果没有指定角色，默认分配普通用户角色
            SysRole userRole = roleMapper.selectOneByQuery(
                com.mybatisflex.core.query.QueryWrapper.create()
                    .where("role_code = ?", "user")
                    .and("is_del = ?", CommonConstant.IS_DEL_NO)
            );
            if (userRole != null) {
                SysUserRole sysUserRole = new SysUserRole();
                sysUserRole.setUserId(user.getId());
                sysUserRole.setRoleId(userRole.getId());
                sysUserRole.setCreateTime(LocalDateTime.now());
                userRoleMapper.insert(sysUserRole);
            }
        }
        
        log.info("创建用户成功: {}", user.getUsername());
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateUser(UserUpdateRequest request) {
        SysUser user = userMapper.selectOneById(request.getId());
        if (user == null || user.getIsDel() == CommonConstant.IS_DEL_YES) {
            throw new BusinessException("用户不存在");
        }
        
        Long currentUserId = com.modelcloud.common.tools.SecurityUtils.getCurrentUserId();
        boolean isSuperAdmin = com.modelcloud.common.tools.SecurityUtils.isSuperAdmin();
        
        // 此方法只用于修改角色和状态，不允许修改其他用户信息
        // 如果传入了昵称、邮箱、手机号等，说明是非法调用
        // 只有当这些字段有实际值（非空字符串）时才抛出异常
        if (StrUtil.isNotBlank(request.getNickname()) || 
            StrUtil.isNotBlank(request.getEmail()) || 
            StrUtil.isNotBlank(request.getPhone())) {
            throw new BusinessException("不允许通过此接口修改用户信息，请使用个人信息页面");
        }
        
        if (request.getStatus() != null) {
            // 只有超级管理员可以修改状态，但不能修改自己的状态
            if (!isSuperAdmin) {
                throw new BusinessException("无权修改用户状态");
            }
            if (request.getId().equals(currentUserId)) {
                throw new BusinessException("不能修改自己的账户状态");
            }
            user.setStatus(request.getStatus());
            user.setUpdateTime(LocalDateTime.now());
            userMapper.update(user);
        }
        
        // 更新用户角色关联（只有超级管理员可以设置用户角色）
        if (StrUtil.isNotBlank(request.getRoleIds())) {
            com.modelcloud.common.tools.SecurityUtils.requireSuperAdmin();
            
            // 不能修改自己的角色
            if (request.getId().equals(currentUserId)) {
                throw new BusinessException("不能修改自己的角色");
            }
            
            // 不能修改超级管理员的角色
            List<Long> currentRoleIds = userRoleMapper.selectRoleIdsByUserId(request.getId());
            for (Long roleId : currentRoleIds) {
                SysRole role = roleMapper.selectOneById(roleId);
                if (role != null && "super_admin".equals(role.getRoleCode())) {
                    throw new BusinessException("不能修改超级管理员的角色");
                }
            }
            
            // 验证角色：只允许设置为admin或user，不允许super_admin，不允许多角色
            String[] roleIdArray = request.getRoleIds().split(",");
            if (roleIdArray.length > 1) {
                throw new BusinessException("用户只能拥有一个角色");
            }
            
            String roleIdStr = roleIdArray[0].trim();
            if (StrUtil.isNotBlank(roleIdStr) && StrUtil.isNumeric(roleIdStr)) {
                Long roleId = Long.parseLong(roleIdStr);
                SysRole role = roleMapper.selectOneById(roleId);
                if (role != null) {
                    if ("super_admin".equals(role.getRoleCode())) {
                        throw new BusinessException("不能将用户设置为超级管理员");
                    }
                    if (!"admin".equals(role.getRoleCode()) && !"user".equals(role.getRoleCode())) {
                        throw new BusinessException("无效的角色");
                    }
                }
            }
            
            userRoleMapper.deleteByUserId(user.getId());
            saveUserRoles(user.getId(), request.getRoleIds());
            log.info("修改用户角色成功: {}", user.getUsername());
        }
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteUser(Long id) {
        // 只有超级管理员可以删除用户
        com.modelcloud.common.tools.SecurityUtils.requireSuperAdmin();
        
        SysUser user = userMapper.selectOneById(id);
        if (user == null || user.getIsDel() == CommonConstant.IS_DEL_YES) {
            throw new BusinessException("用户不存在");
        }
        
        Long currentUserId = com.modelcloud.common.tools.SecurityUtils.getCurrentUserId();
        if (id.equals(currentUserId)) {
            throw new BusinessException("不能删除自己的账户");
        }
        
        // 不能删除超级管理员
        List<Long> roleIds = userRoleMapper.selectRoleIdsByUserId(id);
        for (Long roleId : roleIds) {
            SysRole role = roleMapper.selectOneById(roleId);
            if (role != null && "super_admin".equals(role.getRoleCode())) {
                throw new BusinessException("不能删除超级管理员账户");
            }
        }
        
        // 逻辑删除
        user.setIsDel(CommonConstant.IS_DEL_YES);
        user.setUpdateTime(LocalDateTime.now());
        userMapper.update(user);
        
        // 删除用户角色关联
        userRoleMapper.deleteByUserId(id);
        
        log.info("删除用户成功: {}", id);
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void batchDeleteUsers(List<Long> ids) {
        for (Long id : ids) {
            if (id == 1L) {
                continue; // 跳过管理员用户
            }
            deleteUser(id);
        }
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void enableUser(Long id) {
        SysUser user = userMapper.selectOneById(id);
        if (user == null || user.getIsDel() == CommonConstant.IS_DEL_YES) {
            throw new BusinessException("用户不存在");
        }
        
        boolean isSuperAdmin = com.modelcloud.common.tools.SecurityUtils.isSuperAdmin();
        
        // 检查权限：管理员不能启用其他管理员
        if (!isSuperAdmin) {
            // 检查目标用户是否是管理员或超级管理员
            List<Long> roleIds = userRoleMapper.selectRoleIdsByUserId(id);
            for (Long roleId : roleIds) {
                SysRole role = roleMapper.selectOneById(roleId);
                if (role != null && ("admin".equals(role.getRoleCode()) || "super_admin".equals(role.getRoleCode()))) {
                    throw new BusinessException("无权启用管理员账户");
                }
            }
        } else {
            // 超级管理员不能启用超级管理员（虽然不太可能，但为了安全）
            List<Long> roleIds = userRoleMapper.selectRoleIdsByUserId(id);
            for (Long roleId : roleIds) {
                SysRole role = roleMapper.selectOneById(roleId);
                if (role != null && "super_admin".equals(role.getRoleCode())) {
                    throw new BusinessException("不能启用超级管理员账户");
                }
            }
        }
        
        user.setStatus(CommonConstant.STATUS_ENABLE);
        user.setUpdateTime(LocalDateTime.now());
        userMapper.update(user);
        log.info("启用用户成功: {}", id);
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void disableUser(Long id) {
        SysUser user = userMapper.selectOneById(id);
        if (user == null || user.getIsDel() == CommonConstant.IS_DEL_YES) {
            throw new BusinessException("用户不存在");
        }
        
        Long currentUserId = com.modelcloud.common.tools.SecurityUtils.getCurrentUserId();
        boolean isSuperAdmin = com.modelcloud.common.tools.SecurityUtils.isSuperAdmin();
        
        // 不能禁用自己的账户
        if (id.equals(currentUserId)) {
            throw new BusinessException("不能禁用自己的账户");
        }
        
        // 检查权限：管理员不能禁用其他管理员
        if (!isSuperAdmin) {
            // 检查目标用户是否是管理员或超级管理员
            List<Long> roleIds = userRoleMapper.selectRoleIdsByUserId(id);
            for (Long roleId : roleIds) {
                SysRole role = roleMapper.selectOneById(roleId);
                if (role != null && ("admin".equals(role.getRoleCode()) || "super_admin".equals(role.getRoleCode()))) {
                    throw new BusinessException("无权禁用管理员账户");
                }
            }
        } else {
            // 超级管理员不能禁用超级管理员
            List<Long> roleIds = userRoleMapper.selectRoleIdsByUserId(id);
            for (Long roleId : roleIds) {
                SysRole role = roleMapper.selectOneById(roleId);
                if (role != null && "super_admin".equals(role.getRoleCode())) {
                    throw new BusinessException("不能禁用超级管理员账户");
                }
            }
        }
        
        user.setStatus(CommonConstant.STATUS_DISABLE);
        user.setUpdateTime(LocalDateTime.now());
        userMapper.update(user);
        log.info("禁用用户成功: {}", id);
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void resetPassword(ResetPasswordRequest request) {
        SysUser user = userMapper.selectOneById(request.getId());
        if (user == null || user.getIsDel() == CommonConstant.IS_DEL_YES) {
            throw new BusinessException("用户不存在");
        }
        
        Long currentUserId = com.modelcloud.common.tools.SecurityUtils.getCurrentUserId();
        boolean isSuperAdmin = com.modelcloud.common.tools.SecurityUtils.isSuperAdmin();
        
        // 不能重置自己的密码
        if (request.getId().equals(currentUserId)) {
            throw new BusinessException("不能重置自己的密码，请使用修改密码功能");
        }
        
        // 检查权限：管理员不能重置其他管理员的密码
        if (!isSuperAdmin) {
            // 检查目标用户是否是管理员或超级管理员
            List<Long> roleIds = userRoleMapper.selectRoleIdsByUserId(request.getId());
            for (Long roleId : roleIds) {
                SysRole role = roleMapper.selectOneById(roleId);
                if (role != null && ("admin".equals(role.getRoleCode()) || "super_admin".equals(role.getRoleCode()))) {
                    throw new BusinessException("无权重置管理员账户密码");
                }
            }
        } else {
            // 超级管理员不能重置超级管理员的密码
            List<Long> roleIds = userRoleMapper.selectRoleIdsByUserId(request.getId());
            for (Long roleId : roleIds) {
                SysRole role = roleMapper.selectOneById(roleId);
                if (role != null && "super_admin".equals(role.getRoleCode())) {
                    throw new BusinessException("不能重置超级管理员账户密码");
                }
            }
        }
        
        user.setPassword(passwordUtil.encode(request.getNewPassword()));
        user.setUpdateTime(LocalDateTime.now());
        userMapper.update(user);
        
        log.info("重置密码成功: {}", user.getUsername());
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateProfile(Long userId, com.modelcloud.modules.sys.model.dto.UserProfileUpdateRequest request) {
        SysUser user = userMapper.selectOneById(userId);
        if (user == null || user.getIsDel() == CommonConstant.IS_DEL_YES) {
            throw new BusinessException("用户不存在");
        }
        
        // 更新用户信息
        if (StrUtil.isNotBlank(request.getNickname())) {
            user.setNickname(request.getNickname());
        }
        if (StrUtil.isNotBlank(request.getEmail())) {
            // 检查邮箱是否被其他用户使用
            SysUser existUser = userMapper.selectByEmail(request.getEmail());
            if (existUser != null && !existUser.getId().equals(userId)) {
                throw new BusinessException("邮箱已被其他用户使用");
            }
            user.setEmail(request.getEmail());
        }
        if (request.getPhone() != null) {
            user.setPhone(StrUtil.isNotBlank(request.getPhone()) ? request.getPhone() : null);
        }
        user.setUpdateTime(LocalDateTime.now());
        
        userMapper.update(user);
        log.info("更新个人信息成功: {}", user.getUsername());
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void changePassword(Long userId, com.modelcloud.modules.sys.model.dto.ChangePasswordRequest request) {
        SysUser user = userMapper.selectOneById(userId);
        if (user == null || user.getIsDel() == CommonConstant.IS_DEL_YES) {
            throw new BusinessException("用户不存在");
        }
        
        // 验证原密码
        if (!passwordUtil.matches(request.getOldPassword(), user.getPassword())) {
            throw new BusinessException("原密码错误");
        }
        
        // 更新密码
        user.setPassword(passwordUtil.encode(request.getNewPassword()));
        user.setUpdateTime(LocalDateTime.now());
        userMapper.update(user);
        
        log.info("修改密码成功: {}", user.getUsername());
    }
    
    /**
     * 保存用户角色关联
     */
    private void saveUserRoles(Long userId, String roleIdsStr) {
        List<String> roleIdList = Arrays.asList(roleIdsStr.split(","));
        List<SysUserRole> userRoles = new ArrayList<>();
        
        for (String roleIdStr : roleIdList) {
            if (StrUtil.isNotBlank(roleIdStr) && StrUtil.isNumeric(roleIdStr)) {
                Long roleId = Long.parseLong(roleIdStr.trim());
                // 验证角色是否存在
                SysRole role = roleMapper.selectOneById(roleId);
                if (role != null && role.getIsDel() == CommonConstant.IS_DEL_NO) {
                    SysUserRole userRole = new SysUserRole();
                    userRole.setUserId(userId);
                    userRole.setRoleId(roleId);
                    userRole.setCreateTime(LocalDateTime.now());
                    userRoles.add(userRole);
                }
            }
        }
        
        if (!userRoles.isEmpty()) {
            for (SysUserRole userRole : userRoles) {
                userRoleMapper.insert(userRole);
            }
        }
    }
    
    /**
     * 转换为VO
     */
    private UserVO convertToVO(SysUser user) {
        UserVO vo = new UserVO();
        vo.setId(user.getId());
        vo.setUsername(user.getUsername());
        vo.setNickname(user.getNickname());
        vo.setEmail(user.getEmail());
        vo.setPhone(user.getPhone());
        vo.setAvatar(user.getAvatar());
        vo.setStatus(user.getStatus());
        vo.setStatusText(user.getStatus() == CommonConstant.STATUS_ENABLE ? "启用" : "禁用");
        vo.setCreateTime(user.getCreateTime());
        vo.setUpdateTime(user.getUpdateTime());
        
        // 查询用户角色
        List<Long> roleIds = userRoleMapper.selectRoleIdsByUserId(user.getId());
        String highestRoleCode = "user"; // 默认最低角色
        if (roleIds != null && !roleIds.isEmpty()) {
            List<RoleVO> roles = new ArrayList<>();
            for (Long roleId : roleIds) {
                        SysRole role = roleMapper.selectOneById(roleId);
                        if (role != null) {
                            RoleVO roleVO = new RoleVO();
                            roleVO.setId(role.getId());
                            roleVO.setRoleName(role.getRoleName());
                            roleVO.setRoleCode(role.getRoleCode());
                            roleVO.setDescription(role.getDescription());
                            roleVO.setStatus(role.getStatus());
                    roles.add(roleVO);
                    
                    // 更新最高角色代码
                    String roleCode = role.getRoleCode();
                    if ("super_admin".equals(roleCode)) {
                        highestRoleCode = "super_admin";
                    } else if ("admin".equals(roleCode) && !"super_admin".equals(highestRoleCode)) {
                        highestRoleCode = "admin";
                    }
                }
            }
            vo.setRoles(roles);
        } else {
            vo.setRoles(new ArrayList<>());
        }
        vo.setHighestRoleCode(highestRoleCode);
        
        return vo;
    }
}

