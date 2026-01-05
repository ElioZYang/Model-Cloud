package com.modelcloud.modules.business.model.domain;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import java.io.Serializable;

/**
 * 模型参数实体类（MongoDB）
 * 
 * @author model-cloud
 */
@Data
@Document(collection = "bs_model_params")
public class BsModelParams implements Serializable {
    private static final long serialVersionUID = 1L;
    
    @Id
    private String id;
    private Long modelId;
    private String paramsJson;
    private String description;
}

























