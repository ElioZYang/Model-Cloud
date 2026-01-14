package com.modelcloud.modules.business.model.domain;

import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;
import lombok.Data;
import java.io.Serializable;

/**
 * 模型标签分类实体类
 * 
 * @author model-cloud
 */
@Data
@Table("model_label_category")
public class ModelLabelCategory implements Serializable {
    private static final long serialVersionUID = 1L;
    
    @Id
    private Long id;
    private String name;
    private Integer sort;
}

