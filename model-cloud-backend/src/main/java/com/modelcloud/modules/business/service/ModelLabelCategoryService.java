package com.modelcloud.modules.business.service;

import com.modelcloud.modules.business.model.domain.ModelLabelCategory;
import java.util.List;

/**
 * 模型标签分类服务接口
 * 
 * @author model-cloud
 */
public interface ModelLabelCategoryService {
    /**
     * 获取所有分类列表
     */
    List<ModelLabelCategory> getAllCategories();
}

