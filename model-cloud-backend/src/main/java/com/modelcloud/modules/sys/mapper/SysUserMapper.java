package com.modelcloud.modules.sys.mapper;

import com.mybatisflex.core.BaseMapper;
import com.mybatisflex.core.query.QueryWrapper;
import com.modelcloud.modules.sys.model.domain.SysUser;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

/**
 * 系统用户Mapper接口
 * 
 * @author model-cloud
 */
@Mapper
public interface SysUserMapper extends BaseMapper<SysUser> {
    
    /**
     * 根据用户名查询用户
     */
    @Select("SELECT * FROM sys_user WHERE username = #{username} AND is_del = 0 LIMIT 1")
    SysUser selectByUsername(@Param("username") String username);
    
    /**
     * 根据邮箱查询用户
     */
    @Select("SELECT * FROM sys_user WHERE email = #{email} AND is_del = 0 LIMIT 1")
    SysUser selectByEmail(@Param("email") String email);
}

