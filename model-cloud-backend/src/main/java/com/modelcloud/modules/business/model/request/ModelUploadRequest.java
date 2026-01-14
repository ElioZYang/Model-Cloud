package com.modelcloud.modules.business.model.request;

import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

/**
 * 模型上传请求对象
 */
@Data
public class ModelUploadRequest {
    /**
     * 模型名称
     */
    private String name;

    /**
     * 模型描述
     */
    private String description;

    /**
     * 标签名称列表
     */
    private List<String> tags;

    /**
     * 封面图片
     */
    private MultipartFile coverImage;

    /**
     * 模型文件
     */
    private MultipartFile modelFile;

    /**
     * 是否公开：0不公开，1公开
     */
    private Integer isPublic;

    /**
     * 共享协议
     */
    private String license;

    /**
     * 模型格式
     */
    private String format;
}

