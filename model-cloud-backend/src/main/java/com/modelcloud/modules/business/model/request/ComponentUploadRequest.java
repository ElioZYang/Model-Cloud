package com.modelcloud.modules.business.model.request;

import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

/**
 * 基础组件上传请求
 */
@Data
public class ComponentUploadRequest {
    private String name;
    private String description;
    /**
     * 脚本传入的本地Modelica路径（用于还原标准库层级）
     * 示例: D:/Modelica/Modelica/Electrical/Analog/Basic/Resistor.mo
     */
    private String localPath;
    private MultipartFile sourceFile;
    private MultipartFile iconFile;
}
