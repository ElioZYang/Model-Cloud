package com.modelcloud.modules.business.service;

import com.modelcloud.modules.business.model.domain.BsModelLabel;
import java.util.List;

/**
 * 模型标签服务接口
 * 
 * @author model-cloud
 */
public interface BsModelLabelService {
    
    /**
     * 获取所有标签列表
     */
    List<BsModelLabel> getAllLabels();
}

