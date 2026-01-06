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
        QueryWrapper queryWrapper = QueryWrapper.create()
                .where(SYS_USER.IS_DEL.eq(CommonConstant.IS_DEL_NO))
                .and(SYS_USER.USERNAME.like(request.getUsername()).when(StrUtil.isNotBlank(request.getUsername())))
                .and(SYS_USER.NICKNAME.like(request.getNickname()).when(StrUtil.isNotBlank(request.getNickname())))
                .and(SYS_USER.EMAIL.like(request.getEmail()).when(StrUtil.isNotBlank(request.getEmail())))
                .and(SYS_USER.STATUS.eq(request.getStatus()).when(request.getStatus() != null))
                .orderBy(SYS_USER.CREATE_TIME.desc());
        
        Page<SysUser> page = userMapper.paginate(request.getPageNum(), request.getPageSize(), queryWrapper);
        
        // 转换为VO
        List<UserVO> voList = page.getRecords().stream()
                .map(this::convertToVO)
                .collect(Collectors.toList());
        
        Page<UserVO> result = new Page<>();
        result.setRecords(voList);
        result.setTotalRow(page.getTotalRow());
        result.setPageNumber(page.getPageNumber());
        result.setPageSize(page.getPageSize());
        result.setTotalPage(page.getTotalPage());
        
        return result;
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
        
        // 更新用户信息
        if (StrUtil.isNotBlank(request.getNickname())) {
            user.setNickname(request.getNickname());
        }
        if (StrUtil.isNotBlank(request.getEmail())) {
            // 检查邮箱是否被其他用户使用
            SysUser existUser = userMapper.selectByEmail(request.getEmail());
            if (existUser != null && !existUser.getId().equals(user.getId())) {
                throw new BusinessException("邮箱已被其他用户使用");
            }
            user.setEmail(request.getEmail());
        }
        if (request.getPhone() != null) {
            user.setPhone(StrUtil.isNotBlank(request.getPhone()) ? request.getPhone() : null);
        }
        if (StrUtil.isNotBlank(request.getAvatar())) {
            user.setAvatar(request.getAvatar());
        }
        if (request.getStatus() != null) {
            user.setStatus(request.getStatus());
        }
        user.setUpdateTime(LocalDateTime.now());
        
        userMapper.update(user);
        
        // 更新用户角色关联（只有超级管理员可以设置用户角色）
        if (StrUtil.isNotBlank(request.getRoleIds())) {
            com.modelcloud.common.tools.SecurityUtils.requireSuperAdmin();
            userRoleMapper.deleteByUserId(user.getId());
            saveUserRoles(user.getId(), request.getRoleIds());
        }
        
        log.info("更新用户成功: {}", user.getUsername());
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteUser(Long id) {
        SysUser user = userMapper.selectOneById(id);
        if (user == null || user.getIsDel() == CommonConstant.IS_DEL_YES) {
            throw new BusinessException("用户不存在");
        }
        
        // 不能删除管理员用户（假设ID为1的是管理员）
        if (id == 1L) {
            throw new BusinessException("不能删除管理员用户");
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
        
        // 不能禁用自己的账户
        // 这里需要从SecurityContext获取当前用户ID，暂时跳过检查
        
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
        
        user.setPassword(passwordUtil.encode(request.getNewPassword()));
        user.setUpdateTime(LocalDateTime.now());
        userMapper.update(user);
        
        log.info("重置密码成功: {}", user.getUsername());
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
        if (roleIds != null && !roleIds.isEmpty()) {
            List<RoleVO> roles = roleIds.stream()
                    .map(roleId -> {
                        SysRole role = roleMapper.selectOneById(roleId);
                        if (role != null) {
                            RoleVO roleVO = new RoleVO();
                            roleVO.setId(role.getId());
                            roleVO.setRoleName(role.getRoleName());
                            roleVO.setRoleCode(role.getRoleCode());
                            roleVO.setDescription(role.getDescription());
                            roleVO.setStatus(role.getStatus());
                            return roleVO;
                        }
                        return null;
                    })
                    .filter(role -> role != null)
                    .collect(Collectors.toList());
            vo.setRoles(roles);
        } else {
            vo.setRoles(new ArrayList<>());
        }
        
        return vo;
    }
}

