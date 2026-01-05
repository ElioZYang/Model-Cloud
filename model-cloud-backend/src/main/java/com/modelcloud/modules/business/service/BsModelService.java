package com.modelcloud.modules.business.service;

import com.modelcloud.modules.business.model.domain.BsModel;
import com.modelcloud.modules.business.model.request.ModelUploadRequest;
import com.mybatisflex.core.paginate.Page;

import java.util.List;

/**
 * 模型服务接口
 * 
 * @author model-cloud
 */
public interface BsModelService {
    
    /**
     * 上传模型
     */
    BsModel uploadModel(ModelUploadRequest request);

    /**
     * 分页查询模型列表
     */
    Page<BsModel> pageModels(int pageNum, int pageSize, String keyword);

    /**
     * 获取模型详情
     */
    BsModel getModelDetail(Long id);

    /**
     * 获取模型统计信息
     */
    java.util.Map<String, Object> getStatistics();
}



