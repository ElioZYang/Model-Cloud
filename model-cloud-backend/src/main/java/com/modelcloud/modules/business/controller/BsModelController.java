package com.modelcloud.modules.business.controller;

import com.modelcloud.common.web.domain.response.Result;
import com.modelcloud.modules.business.model.domain.BsModel;
import com.modelcloud.modules.business.model.request.ModelUploadRequest;
import com.modelcloud.modules.business.service.BsModelService;
import com.mybatisflex.core.paginate.Page;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

/**
 * 模型管理控制器
 * 
 * @author model-cloud
 */
@Slf4j
@RestController
@RequestMapping("/business/model")
public class BsModelController {

    private final BsModelService bsModelService;

    public BsModelController(BsModelService bsModelService) {
        this.bsModelService = bsModelService;
    }

    /**
     * 上传模型
     */
    @PostMapping(value = "/upload", consumes = "multipart/form-data")
    public Result<BsModel> upload(
            @RequestParam("name") String name,
            @RequestParam("description") String description,
            @RequestParam(value = "isPublic", defaultValue = "0") Integer isPublic,
            @RequestParam(value = "tags", required = false) String[] tags,
            @RequestParam(value = "coverImage", required = false) org.springframework.web.multipart.MultipartFile coverImage,
            @RequestParam("modelFile") org.springframework.web.multipart.MultipartFile modelFile) {
        try {
            ModelUploadRequest request = new ModelUploadRequest();
            request.setName(name);
            request.setDescription(description);
            request.setIsPublic(isPublic != null ? isPublic : 0);
            if (tags != null) {
                request.setTags(java.util.Arrays.asList(tags));
            }
            request.setCoverImage(coverImage);
            request.setModelFile(modelFile);
            
            BsModel model = bsModelService.uploadModel(request);
            return Result.success(model);
        } catch (Exception e) {
            log.error("上传模型失败", e);
            return Result.error("上传模型失败: " + e.getMessage());
        }
    }

    /**
     * 分页查询模型列表（只显示公开且审核通过的模型）
     */
    @GetMapping("/list")
    public Result<Page<BsModel>> list(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String tag) {
        Page<BsModel> page = bsModelService.pageModels(pageNum, pageSize, keyword, tag);
        return Result.success(page);
    }

    /**
     * 分页查询我的模型列表
     */
    @GetMapping("/my")
    public Result<Page<BsModel>> myModels(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer isPublic,
            @RequestParam(required = false) String tag) {
        Page<BsModel> page = bsModelService.pageMyModels(pageNum, pageSize, keyword, isPublic, tag);
        return Result.success(page);
    }

    /**
     * 分页查询待审核模型（管理员）
     */
    @GetMapping("/pending")
    public Result<Page<BsModel>> pending(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String keyword) {
        Page<BsModel> page = bsModelService.pagePendingModels(pageNum, pageSize, keyword);
        return Result.success(page);
    }

    /**
     * 更新模型公开状态
     */
    @PutMapping("/{id}/public")
    public Result<?> updatePublic(@PathVariable Long id, @RequestBody java.util.Map<String, Integer> request) {
        try {
            Integer isPublic = request.get("isPublic");
            if (isPublic == null) {
                return Result.error("isPublic参数不能为空");
            }
            bsModelService.updateModelPublic(id, isPublic);
            return Result.success("更新成功");
        } catch (Exception e) {
            log.error("更新模型公开状态失败", e);
            return Result.error("更新失败: " + e.getMessage());
        }
    }

    /**
     * 获取模型详情
     */
    @GetMapping("/{id}")
    public Result<BsModel> detail(@PathVariable Long id) {
        BsModel model = bsModelService.getModelDetail(id);
        return Result.success(model);
    }

    /**
     * 审核模型（管理员）
     */
    @PostMapping("/{id}/audit")
    public Result<?> audit(@PathVariable Long id, @RequestBody java.util.Map<String, Boolean> request) {
        Boolean approved = request.get("approved");
        if (approved == null) {
            return Result.error("approved参数不能为空");
        }
        bsModelService.auditModel(id, approved);
        return Result.success("审核完成");
    }

    /**
     * 获取模型统计信息
     */
    @GetMapping("/statistics")
    public Result<java.util.Map<String, Object>> statistics() {
        java.util.Map<String, Object> stats = bsModelService.getStatistics();
        return Result.success(stats);
    }

    /**
     * 获取当前用户最近活动（主要用于审核失败提示）
     */
    @GetMapping("/my-activities")
    public Result<java.util.List<BsModel>> myActivities(@RequestParam(defaultValue = "10") int limit) {
        java.util.List<BsModel> list = bsModelService.listMyActivities(limit);
        return Result.success(list);
    }

    /**
     * 删除模型
     */
    @DeleteMapping("/{id}")
    public Result<?> delete(@PathVariable Long id) {
        try {
            bsModelService.deleteModel(id);
            return Result.success("删除成功");
        } catch (Exception e) {
            log.error("删除模型失败", e);
            return Result.error("删除失败: " + e.getMessage());
        }
    }
}



