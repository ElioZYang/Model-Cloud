package com.modelcloud.modules.business.model.domain;

import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.KeyType;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.Table;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 模型实体类
 * 
 * @author model-cloud
 */
@Data
@Table("bs_model")
public class BsModel implements Serializable {
    private static final long serialVersionUID = 1L;
    
    /**
     * 模型编号
     */
    @Id(keyType = KeyType.Auto)
    private Long id;
    
    /**
     * 模型名称
     */
    private String name;
    
    /**
     * 模型作者ID
     */
    private Long userId;
    
    /**
     * 模型属性-类型
     */
    private String attrType;
    
    /**
     * 模型属性-共享协议
     */
    private String attrProtocol;
    
    /**
     * 模型属性-计费方式
     */
    private String attrBillingMethod;
    
    /**
     * 模型属性-构建工具
     */
    private String attrBuildTool;
    
    /**
     * 模型属性-格式
     */
    private String attrFormat;
    
    /**
     * 模型标签编号集合
     */
    private String attrLabelIds;
    
    /**
     * 模型标签名称集合
     */
    private String attrLabelNames;
    
    /**
     * 模型属性-依赖库
     */
    private String attrDependencyLib;
    
    /**
     * 模型属性-参数规模
     */
    private String attrParamsNumber;
    
    /**
     * 模型描述
     */
    private String description;
    
    /**
     * 模型使用说明
     */
    private String useDescription;
    
    /**
     * 模型维数：1,2,3
     */
    private Long dimension;
    
    /**
     * 模型状态：0初始状态，10待审状态，20审核通过，30审核不通过
     */
    private Integer status;
    
    /**
     * 是否公开：0不公开，1公开
     */
    private Integer isPublic;
    
    /**
     * Gitea仓库名称
     */
    private String repoName;

    /**
     * Gitea仓库链接
     */
    private String repoUrl;

    /**
     * 封面图片链接
     */
    private String coverImage;
    
    /**
     * 创建时间
     */
    private LocalDateTime createTime;
    
    /**
     * 更新时间
     */
    private LocalDateTime updateTime;
    
    /**
     * 是否删除：0未删除，1已删除
     */
    private Integer isDel;

    /**
     * 作者名称 (仅展示用)
     */
    @Column(ignore = true)
    private String authorName;
}
