package com.modelcloud.modules.business.controller;

import com.modelcloud.common.web.domain.response.Result;
import com.modelcloud.modules.business.model.domain.BsModelLabel;
import com.modelcloud.modules.business.service.BsModelLabelService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 模型标签控制器
 * 
 * @author model-cloud
 */
@Slf4j
@RestController
@RequestMapping("/business/label")
public class BsModelLabelController {

    private final BsModelLabelService bsModelLabelService;

    public BsModelLabelController(BsModelLabelService bsModelLabelService) {
        this.bsModelLabelService = bsModelLabelService;
    }

    /**
     * 获取所有标签列表
     */
    @GetMapping("/list")
    public Result<List<BsModelLabel>> list() {
        List<BsModelLabel> labels = bsModelLabelService.getAllLabels();
        return Result.success(labels);
    }
}

