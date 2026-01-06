package com.modelcloud.modules.auth.service.impl;

import com.modelcloud.common.constant.CommonConstant;
import com.modelcloud.common.exception.BusinessException;
import com.modelcloud.common.tools.JwtUtil;
import com.modelcloud.common.tools.PasswordUtil;
import com.modelcloud.modules.auth.model.dto.LoginRequest;
import com.modelcloud.modules.auth.model.dto.LoginResponse;
import com.modelcloud.modules.auth.model.dto.RegisterRequest;
import com.modelcloud.modules.auth.service.AuthService;
import com.modelcloud.modules.auth.service.CaptchaService;
import com.modelcloud.modules.sys.mapper.SysRoleMapper;
import com.modelcloud.modules.sys.mapper.SysUserMapper;
import com.modelcloud.modules.sys.mapper.SysUserRoleMapper;
import com.modelcloud.modules.sys.model.domain.SysRole;
import com.modelcloud.modules.sys.model.domain.SysUser;
import com.mybatisflex.core.query.QueryWrapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 认证服务实现类
 * 
 * @author model-cloud
 */
@Slf4j
@Service
public class AuthServiceImpl implements AuthService {
    
    private final SysUserMapper userMapper;
    private final SysUserRoleMapper userRoleMapper;
    private final SysRoleMapper roleMapper;
    private final CaptchaService captchaService;
    private final PasswordUtil passwordUtil;
    private final JwtUtil jwtUtil;
    
    public AuthServiceImpl(
            SysUserMapper userMapper,
            SysUserRoleMapper userRoleMapper,
            SysRoleMapper roleMapper,
            CaptchaService captchaService,
            PasswordUtil passwordUtil,
            JwtUtil jwtUtil) {
        this.userMapper = userMapper;
        this.userRoleMapper = userRoleMapper;
        this.roleMapper = roleMapper;
        this.captchaService = captchaService;
        this.passwordUtil = passwordUtil;
        this.jwtUtil = jwtUtil;
    }
    
    @Override
    public LoginResponse login(LoginRequest request) {
        // 验证验证码
        if (!captchaService.validateCaptcha(request.getCaptchaKey(), request.getCaptcha())) {
            throw new BusinessException("验证码错误或已过期");
        }
        
        // 查询用户
        SysUser user = userMapper.selectByUsername(request.getUsername());
        if (user == null) {
            throw new BusinessException("用户名或密码错误");
        }
        
        // 检查用户状态
        if (user.getStatus() == null || user.getStatus() == CommonConstant.STATUS_DISABLE) {
            throw new BusinessException("用户已被禁用");
        }
        
        // 检查是否删除
        if (user.getIsDel() != null && user.getIsDel() == CommonConstant.IS_DEL_YES) {
            throw new BusinessException("用户不存在");
        }
        
        // 验证密码
        if (!passwordUtil.matches(request.getPassword(), user.getPassword())) {
            throw new BusinessException("用户名或密码错误");
        }
        
        // 生成Token
        String token = jwtUtil.generateToken(user.getId(), user.getUsername());
        
        // 查询用户角色
        List<String> roleCodes = new ArrayList<>();
        List<Long> roleIds = userRoleMapper.selectRoleIdsByUserId(user.getId());
        if (roleIds != null && !roleIds.isEmpty()) {
            for (Long roleId : roleIds) {
                SysRole role = roleMapper.selectOneById(roleId);
                if (role != null && role.getStatus() == CommonConstant.STATUS_ENABLE) {
                    roleCodes.add(role.getRoleCode());
                }
            }
        }
        
        // 构建用户信息
        LoginResponse.UserInfo userInfo = new LoginResponse.UserInfo(
            user.getId(),
            user.getUsername(),
            user.getNickname() != null ? user.getNickname() : user.getUsername(),
            user.getEmail(),
            user.getAvatar(),
            roleCodes
        );
        
        log.info("用户登录成功: {}, 角色: {}", user.getUsername(), roleCodes);
        
        return new LoginResponse(token, userInfo);
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void register(RegisterRequest request) {
        // 验证验证码
        if (!captchaService.validateCaptcha(request.getCaptchaKey(), request.getCaptcha())) {
            throw new BusinessException("验证码错误或已过期");
        }
        
        // 验证密码确认
        if (!request.getPassword().equals(request.getConfirmPassword())) {
            throw new BusinessException("两次输入的密码不一致");
        }
        
        // 检查用户名是否已存在
        SysUser existUser = userMapper.selectByUsername(request.getUsername());
        if (existUser != null) {
            throw new BusinessException("用户名已存在");
        }
        
        // 检查邮箱是否已存在
        if (request.getEmail() != null) {
            existUser = userMapper.selectByEmail(request.getEmail());
            if (existUser != null) {
                throw new BusinessException("邮箱已被注册");
            }
        }
        
        // 创建新用户
        SysUser user = new SysUser();
        user.setUsername(request.getUsername());
        user.setPassword(passwordUtil.encode(request.getPassword()));
        user.setNickname(request.getNickname() != null && !request.getNickname().trim().isEmpty() 
                ? request.getNickname() : request.getUsername());
        user.setEmail(request.getEmail());
        // 如果手机号为空字符串，则设置为null
        user.setPhone(request.getPhone() != null && !request.getPhone().trim().isEmpty() 
                ? request.getPhone() : null);
        user.setStatus(CommonConstant.STATUS_ENABLE);
        user.setIsDel(CommonConstant.IS_DEL_NO);
        user.setCreateTime(LocalDateTime.now());
        user.setUpdateTime(LocalDateTime.now());
        
        userMapper.insert(user);
        
        // 为新注册的用户自动分配普通用户角色
        SysRole userRole = roleMapper.selectOneByQuery(
            QueryWrapper.create()
                .where("role_code = ?", "user")
                .and("is_del = ?", 0)
        );
        if (userRole != null) {
            com.modelcloud.modules.sys.model.domain.SysUserRole sysUserRole = 
                new com.modelcloud.modules.sys.model.domain.SysUserRole();
            sysUserRole.setUserId(user.getId());
            sysUserRole.setRoleId(userRole.getId());
            sysUserRole.setCreateTime(LocalDateTime.now());
            userRoleMapper.insert(sysUserRole);
            log.info("为新用户 {} 分配普通用户角色", user.getUsername());
        }
        
        log.info("用户注册成功: {}", user.getUsername());
    }
    
    @Override
    public void logout(String token) {
        // TODO: 可以将token加入黑名单（使用Redis）
        // 目前JWT是无状态的，登出主要靠前端删除token
        log.info("用户登出: token={}", token);
    }
    
    @Override
    public LoginResponse.UserInfo getCurrentUser(Long userId) {
        // 使用QueryWrapper查询
        SysUser user = userMapper.selectOneByQuery(
            QueryWrapper.create()
                .where("id = ?", userId)
                .and("is_del = ?", 0)
        );
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        
        // 查询用户角色
        List<String> roleCodes = new ArrayList<>();
        List<Long> roleIds = userRoleMapper.selectRoleIdsByUserId(user.getId());
        if (roleIds != null && !roleIds.isEmpty()) {
            for (Long roleId : roleIds) {
                SysRole role = roleMapper.selectOneById(roleId);
                if (role != null && role.getStatus() == CommonConstant.STATUS_ENABLE) {
                    roleCodes.add(role.getRoleCode());
                }
            }
        }
        
        return new LoginResponse.UserInfo(
            user.getId(),
            user.getUsername(),
            user.getNickname() != null ? user.getNickname() : user.getUsername(),
            user.getEmail(),
            user.getAvatar(),
            roleCodes
        );
    }
}

