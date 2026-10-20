package com.modelcloud.modules.business.model.domain;

import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.KeyType;
import com.mybatisflex.annotation.Table;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/** 用户上传的MATLAB/PMSM配置文件元数据。 */
@Data
@Table("bs_matlab_config")
public class BsMatlabConfig implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id(keyType = KeyType.Auto)
    private Long id;
    private String configId;
    private Long userId;
    private String name;
    private String originalFilename;
    private String repoName;
    private String repoPath;
    private Long fileSize;
    private String sha256;
    private String templateVersion;
    private Integer designParameterCount;
    private Integer optimizationParameterCount;
    private Integer materialCount;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    private Integer isDel;
}
