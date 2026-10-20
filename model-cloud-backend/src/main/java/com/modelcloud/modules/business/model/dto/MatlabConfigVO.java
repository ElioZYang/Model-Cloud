package com.modelcloud.modules.business.model.dto;

import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;

@Data
public class MatlabConfigVO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String configId;
    private String name;
    private String fileName;
    private Long fileSize;
    private String sha256;
    private String templateVersion;
    /** 只有校验通过的配置才会入库，该状态由服务层生成而不持久化。 */
    private String status;
    private LocalDateTime createTime;
    private Map<String, Integer> summary = new LinkedHashMap<>();
}
