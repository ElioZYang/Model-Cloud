package com.modelcloud.modules.business.service;

import com.modelcloud.modules.business.model.domain.BsModel;
import com.mybatisflex.core.paginate.Page;

import java.util.List;

/**
 * 模型收藏服务接口
 * 
 * @author model-cloud
 */
public interface BsModelCollectService {
    
    /**
     * 收藏模型
     */
    void collectModel(Long modelId);
    
    /**
     * 取消收藏
     */
    void uncollectModel(Long modelId);
    
    /**
     * 检查是否已收藏
     */
    boolean isCollected(Long modelId);
    
    /**
     * 获取用户收藏的模型列表
     */
    Page<BsModel> getMyCollectModels(int pageNum, int pageSize);
    
    /**
     * 获取用户收藏数量
     */
    long getMyCollectCount();
}


