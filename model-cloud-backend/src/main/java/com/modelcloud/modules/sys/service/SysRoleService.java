package com.modelcloud.modules.sys.service;

import com.modelcloud.modules.sys.model.domain.SysRole;
import java.util.List;

/**
 * 角色服务接口
 * 
 * @author model-cloud
 */
public interface SysRoleService {
    
    /**
     * 查询所有启用的角色
     */
    List<SysRole> listEnabledRoles();
    
    /**
     * 根据ID查询角色
     */
    SysRole getById(Long id);
    
    /**
     * 查询所有角色
     */
    List<SysRole> listAll();
}

