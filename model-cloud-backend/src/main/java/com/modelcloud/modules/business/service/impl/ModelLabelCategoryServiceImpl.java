package com.modelcloud.modules.business.service.impl;

import com.modelcloud.modules.business.mapper.ModelLabelCategoryMapper;
import com.modelcloud.modules.business.model.domain.ModelLabelCategory;
import com.modelcloud.modules.business.service.ModelLabelCategoryService;
import com.mybatisflex.core.query.QueryWrapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

import static com.modelcloud.modules.business.model.domain.table.ModelLabelCategoryTableDef.MODEL_LABEL_CATEGORY;

/**
 * 模型标签分类服务实现类
 * 
 * @author model-cloud
 */
@Slf4j
@Service
public class ModelLabelCategoryServiceImpl implements ModelLabelCategoryService {

    private final ModelLabelCategoryMapper modelLabelCategoryMapper;

    public ModelLabelCategoryServiceImpl(ModelLabelCategoryMapper modelLabelCategoryMapper) {
        this.modelLabelCategoryMapper = modelLabelCategoryMapper;
    }

    @Override
    public List<ModelLabelCategory> getAllCategories() {
        QueryWrapper queryWrapper = QueryWrapper.create()
                .orderBy(MODEL_LABEL_CATEGORY.SORT.asc(), MODEL_LABEL_CATEGORY.ID.asc());
        return modelLabelCategoryMapper.selectListByQuery(queryWrapper);
    }
}

