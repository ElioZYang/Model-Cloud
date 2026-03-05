package com.modelcloud.modules.business.model.domain;

import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.KeyType;
import com.mybatisflex.annotation.Table;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 基础组件实体
 */
@Data
@Table("bs_component")
public class BsComponent implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id(keyType = KeyType.Auto)
    private Long id;

    /**
     * 组件名称（如 Resistor）
     */
    private String name;

    /**
     * 完整类名（如 Modelica.Electrical.Analog.Basic.Resistor）
     */
    private String className;

    /**
     * 组件描述
     */
    private String description;

    /**
     * 索引位置（如 Modelica/Electrical/Analog/Basic）
     */
    private String indexPath;

    /**
     * Gitea仓库名
     */
    private String repoName;

    /**
     * 源码路径（仓库内相对路径）
     */
    private String sourcePath;

    /**
     * 图标路径（仓库内相对路径）
     */
    private String iconPath;

    /**
     * 封面图可访问URL
     */
    private String coverImage;

    /**
     * 创建者用户ID
     */
    private Long userId;

    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    private Integer isDel;
}
