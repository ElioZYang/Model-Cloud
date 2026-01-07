package com.modelcloud.modules.business.model.domain;

import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 模型收藏实体类
 * 
 * @author model-cloud
 */
@Data
@Table("bs_model_collect")
public class BsModelCollect implements Serializable {
    private static final long serialVersionUID = 1L;
    
    @Id
    private Long id;
    private Long userId;
    private Long modelId;
    private LocalDateTime createTime;
    private Integer isDel;
}


























