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
    
    /**
     * 删除模型（删除数据库记录和Gitea仓库）
     */
    void deleteModel(Long id);

    /**
     * 分页查询我的模型列表
     */
    Page<BsModel> pageMyModels(int pageNum, int pageSize, String keyword, Integer isPublic);

    /**
     * 更新模型公开状态
     */
    void updateModelPublic(Long id, Integer isPublic);

    /**
     * 分页查询待审核的公开模型（管理员）
     */
    Page<BsModel> pagePendingModels(int pageNum, int pageSize, String keyword);

    /**
     * 审核模型（管理员）
     * @param id 模型ID
     * @param approved true=通过，false=驳回
     */
    void auditModel(Long id, boolean approved);

    /**
     * 获取当前用户最近活动（主要用于提示审核失败等）
     */
    java.util.List<BsModel> listMyActivities(int limit);
}



