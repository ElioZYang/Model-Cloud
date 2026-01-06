package com.modelcloud.modules.sys.service.impl;

import com.modelcloud.common.constant.CommonConstant;
import com.modelcloud.modules.sys.mapper.SysRoleMapper;
import com.modelcloud.modules.sys.model.domain.SysRole;
import com.modelcloud.modules.sys.service.SysRoleService;
import com.mybatisflex.core.query.QueryWrapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

import static com.modelcloud.modules.sys.model.domain.table.SysRoleTableDef.SYS_ROLE;

/**
 * 角色服务实现类
 * 
 * @author model-cloud
 */
@Slf4j
@Service
public class SysRoleServiceImpl implements SysRoleService {
    
    private final SysRoleMapper roleMapper;
    
    public SysRoleServiceImpl(SysRoleMapper roleMapper) {
        this.roleMapper = roleMapper;
    }
    
    @Override
    public List<SysRole> listEnabledRoles() {
        QueryWrapper queryWrapper = QueryWrapper.create()
                .where(SYS_ROLE.STATUS.eq(CommonConstant.STATUS_ENABLE))
                .and(SYS_ROLE.IS_DEL.eq(CommonConstant.IS_DEL_NO))
                .orderBy(SYS_ROLE.ID.asc());
        return roleMapper.selectListByQuery(queryWrapper);
    }
    
    @Override
    public SysRole getById(Long id) {
        return roleMapper.selectOneById(id);
    }
    
    @Override
    public List<SysRole> listAll() {
        QueryWrapper queryWrapper = QueryWrapper.create()
                .where(SYS_ROLE.IS_DEL.eq(CommonConstant.IS_DEL_NO))
                .orderBy(SYS_ROLE.ID.asc());
        return roleMapper.selectListByQuery(queryWrapper);
    }
}

