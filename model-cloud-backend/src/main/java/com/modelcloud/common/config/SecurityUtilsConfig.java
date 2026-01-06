package com.modelcloud.common.config;

import com.modelcloud.common.tools.SecurityUtils;
import com.modelcloud.modules.sys.mapper.SysRoleMapper;
import com.modelcloud.modules.sys.mapper.SysUserRoleMapper;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;

/**
 * SecurityUtils配置类，用于初始化Mapper
 * 
 * @author model-cloud
 */
@Configuration
@RequiredArgsConstructor
public class SecurityUtilsConfig {
    
    private final SysUserRoleMapper userRoleMapper;
    private final SysRoleMapper roleMapper;
    
    @PostConstruct
    public void init() {
        SecurityUtils.setMappers(userRoleMapper, roleMapper);
    }
}

