package com.modelcloud.modules.business.model.dto;

import lombok.Data;

import java.io.Serializable;

/**
 * 组件视图对象（来自静态目录，id 为 className）
 */
@Data
public class ComponentVO implements Serializable {
    private static final long serialVersionUID = 1L;

    /** 组件标识，使用 className（bs_component 已弃用） */
    private String id;

    private String name;
    private String className;
    private String description;
    private String indexPath;
    private String sourcePath;
    private String coverImage;
    private String restriction;
    private String nodeType;
    private Boolean partial;
    private Boolean leaf;
    private Boolean draggable;
    private Boolean connectable;
    private String parentClassName;
    private Integer childrenCount;
}
