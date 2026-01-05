package com.modelcloud.modules.business.model.domain;

import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 模型标签实体类
 * 
 * @author model-cloud
 */
@Data
@Table("bs_model_label")
public class BsModelLabel implements Serializable {
    private static final long serialVersionUID = 1L;
    
    @Id
    private Long id;
    private String name;
    private String description;
    private Integer sort;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    private Integer isDel;
}

























