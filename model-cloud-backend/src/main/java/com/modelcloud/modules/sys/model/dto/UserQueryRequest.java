package com.modelcloud.modules.sys.model.dto;

import lombok.Data;

/**
 * 用户查询请求DTO
 * 
 * @author model-cloud
 */
@Data
public class UserQueryRequest {
    
    /**
     * 用户名（模糊查询）
     */
    private String username;
    
    /**
     * 昵称（模糊查询）
     */
    private String nickname;
    
    /**
     * 邮箱（模糊查询）
     */
    private String email;
    
    /**
     * 状态：0禁用，1启用
     */
    private Integer status;
    
    /**
     * 页码（从1开始）
     */
    private Integer pageNum = 1;
    
    /**
     * 每页大小
     */
    private Integer pageSize = 10;
}


