package com.modelcloud.common.web.domain.request;

import lombok.Data;
import java.io.Serializable;

/**
 * 分页请求基类
 * 
 * @author model-cloud
 */
@Data
public class PageRequest implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /**
     * 当前页码
     */
    private Integer pageNum = 1;
    
    /**
     * 每页数量
     */
    private Integer pageSize = 10;
    
    /**
     * 排序字段
     */
    private String orderBy;
    
    /**
     * 排序方式 ASC/DESC
     */
    private String orderDirection = "DESC";
}



