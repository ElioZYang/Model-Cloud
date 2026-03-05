package com.modelcloud.modules.business.service;

import com.modelcloud.modules.business.model.domain.BsComponent;
import com.modelcloud.modules.business.model.domain.BsModel;
import com.modelcloud.modules.business.model.request.ComponentUploadRequest;
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
     * 上传基础组件（仅超级管理员）
     */
    BsComponent uploadComponent(ComponentUploadRequest request);

    /**
     * 超级管理员分页查询基础组件
     */
    com.mybatisflex.core.paginate.Page<BsComponent> pageComponents(int pageNum, int pageSize, String keyword);

    /**
     * 分页查询模型列表
     */
    Page<BsModel> pageModels(int pageNum, int pageSize, String keyword, String tag);

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
    Page<BsModel> pageMyModels(int pageNum, int pageSize, String keyword, Integer isPublic, String tag);

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

    /**
     * 更新模型封面图片（仅上传者）
     */
    void updateModelCover(Long id, org.springframework.web.multipart.MultipartFile coverImage);

    /**
     * 更新模型描述（仅上传者）
     */
    void updateModelDescription(Long id, String description);

    /**
     * 获取模型源码内容（仅上传者可修改，其他用户只能查看）
     * 返回Map包含content和fileName
     */
    java.util.Map<String, String> getModelSourceCode(Long id);

    /**
     * 更新模型源码（仅上传者）
     */
    void updateModelSourceCode(Long id, String sourceCode, String fileName);

    /**
     * 超级管理员分页查询模型（按类型）
     * modelKind: all/model/component
     */
    Page<BsModel> pageAdminModels(int pageNum, int pageSize, String keyword, String tag, String modelKind);

    /**
     * 超级管理员批量设置模型类型
     * modelKind: model/component
     */
    void batchUpdateModelKind(java.util.List<Long> ids, String modelKind);

    /**
     * 超级管理员批量生成模型图标（OpenModelica Icon）
     */
    java.util.Map<Long, String> batchGenerateModelIcons(java.util.List<Long> ids);

    /**
     * 获取模型图标物理文件路径
     */
    String getModelIconFilePath(Long modelId);
}



