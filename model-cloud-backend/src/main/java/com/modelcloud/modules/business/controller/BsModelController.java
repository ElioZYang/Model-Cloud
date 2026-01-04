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
    @PostMapping("/upload")
    public Result<BsModel> upload(ModelUploadRequest request) {
        try {
            BsModel model = bsModelService.uploadModel(request);
            return Result.success(model);
        } catch (Exception e) {
            log.error("上传模型失败", e);
            return Result.error("上传模型失败: " + e.getMessage());
        }
    }

    /**
     * 分页查询模型列表
     */
    @GetMapping("/list")
    public Result<Page<BsModel>> list(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String keyword) {
        Page<BsModel> page = bsModelService.pageModels(pageNum, pageSize, keyword);
        return Result.success(page);
    }

    /**
     * 获取模型详情
     */
    @GetMapping("/{id}")
    public Result<BsModel> detail(@PathVariable Long id) {
        BsModel model = bsModelService.getModelDetail(id);
        return Result.success(model);
    }
}



