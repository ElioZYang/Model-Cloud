package com.modelcloud.modules.business.model.domain;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * OMC 解析元数据（MongoDB）
 */
@Data
@Document(collection = "bs_component_parse_meta_omc")
public class BsComponentParseMetaOmc implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    private String id;

    private String name;
    private String description;
    private String sourcePath;
    private String iconPath;
    private String indexPath;
    private String restriction;
    private String nodeType;
    private Boolean partial;
    private Boolean leaf;
    private Boolean draggable;
    private Boolean connectable;
    private String parentClassName;
    private Integer childrenCount;

    private List<ParamMeta> parameters = new ArrayList<>();
    private List<ConnectorMeta> inputConnectors = new ArrayList<>();
    private List<ConnectorMeta> outputConnectors = new ArrayList<>();
    private List<ConnectorMeta> connectors = new ArrayList<>();

    private LocalDateTime createTime;
    private LocalDateTime updateTime;

    @Data
    public static class ParamMeta implements Serializable {
        private static final long serialVersionUID = 1L;
        private String name;
        private String type;
        private String defaultValue;
        private String unit;
        private String description;
    }

    @Data
    public static class ConnectorMeta implements Serializable {
        private static final long serialVersionUID = 1L;
        private String name;
        private String type;
    }
}
