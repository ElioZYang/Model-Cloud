package com.modelcloud.modules.business.controller;

import com.modelcloud.common.web.domain.response.Result;
import com.modelcloud.modules.business.model.domain.BsModel;
import com.modelcloud.modules.business.service.BsModelCollectService;
import com.mybatisflex.core.paginate.Page;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

/**
 * 模型收藏控制器
 * 
 * @author model-cloud
 */
@Slf4j
@RestController
@RequestMapping("/business/collect")
public class BsModelCollectController {
    
    private final BsModelCollectService collectService;
    
    public BsModelCollectController(BsModelCollectService collectService) {
        this.collectService = collectService;
    }
    
    /**
     * 收藏模型
     */
    @PostMapping("/{modelId}")
    public Result<?> collect(@PathVariable Long modelId) {
        try {
            collectService.collectModel(modelId);
            return Result.success("收藏成功");
        } catch (Exception e) {
            log.error("收藏模型失败", e);
            return Result.error("收藏失败: " + e.getMessage());
        }
    }
    
    /**
     * 取消收藏
     */
    @DeleteMapping("/{modelId}")
    public Result<?> uncollect(@PathVariable Long modelId) {
        try {
            collectService.uncollectModel(modelId);
            return Result.success("取消收藏成功");
        } catch (Exception e) {
            log.error("取消收藏失败", e);
            return Result.error("取消收藏失败: " + e.getMessage());
        }
    }
    
    /**
     * 检查是否已收藏
     */
    @GetMapping("/check/{modelId}")
    public Result<Boolean> checkCollected(@PathVariable Long modelId) {
        boolean isCollected = collectService.isCollected(modelId);
        return Result.success(isCollected);
    }
    
    /**
     * 获取我的收藏列表
     */
    @GetMapping("/list")
    public Result<Page<BsModel>> getMyCollects(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String tag) {
        Page<BsModel> page = collectService.getMyCollectModels(pageNum, pageSize, keyword, tag);
        return Result.success(page);
    }
}


