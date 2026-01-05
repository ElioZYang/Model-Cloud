package com.modelcloud.modules.sys.model.domain;

import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 系统文件实体类
 * 
 * @author model-cloud
 */
@Data
@Table("sys_file")
public class SysFile implements Serializable {
    private static final long serialVersionUID = 1L;
    
    @Id
    private Long id;
    private String fileName;
    private String originalName;
    private String filePath;
    private String fileType;
    private Long fileSize;
    private String uploadUser;
    private LocalDateTime uploadTime;
    private Integer isDel;
}

























