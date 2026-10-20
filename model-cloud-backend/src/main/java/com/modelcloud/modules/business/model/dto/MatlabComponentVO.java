package com.modelcloud.modules.business.model.dto;

import lombok.Data;

import java.io.Serializable;
import java.util.Map;
import java.util.List;

/**
 * MATLAB函数组件元数据。
 */
@Data
public class MatlabComponentVO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String id;
    private String name;
    private String engineType;
    private String executorType;
    private String componentKind;
    private String functionName;
    private String description;
    private String library;
    private String category;
    /** Stable ordering for the engine-configuration section of the component library. */
    private Integer catalogOrder;
    private String sourceRelativePath;
    private String iconRelativePath;
    private String fallbackIconRelativePath;
    private String coverImage;
    private String fallbackIcon;
    /** Internal execution adapter; retained for trusted compilation but not shown as a user component. */
    private Boolean hiddenFromCatalog;
    /** Optional editor-only definition used by recursive subsystem nodes. */
    private Map<String, Object> templateDefinition;
    /** Editable callable entry scenes, remapped when a PMSM template is instantiated. */
    private Map<String, String> modelEntrypoints;
    /** Optional physical assembly defaults; never treated as executable code. */
    private Map<String, Object> assemblyDefaults;
    /**
     * 发动机部件的物理能力声明（flow 端口、shaft/bleed 可加入性）。
     * 普通组件（PMSM、Bus、普通 MATLAB 函数）不得携带该字段。
     */
    private Map<String, Object> physicalCapabilities;
    /** Stable display/compatibility name for catalog migrations. */
    private String legacyName;
    private List<ResourceVO> resources;
    private List<PortVO> inputs;
    private List<PortVO> outputs;
    private InvocationVO invocation;

    @Data
    public static class PortVO implements Serializable {
        private static final long serialVersionUID = 1L;

        private String name;
        private String type;
        private String unit;
        private List<Integer> shape;
        /** Optional vector dimension tied to a relation-group collection. */
        private Map<String, Object> dynamicLength;
        private Boolean required;
        private Object defaultValue;
        private Double min;
        private Double max;
        private String description;
    }

    @Data
    public static class ResourceVO implements Serializable {
        private static final long serialVersionUID = 1L;

        private String name;
        private String type;
        private List<String> accept;
        private Boolean required;
        private String description;
    }

    /** MATLAB函数参数和返回值的声明式绑定，不承载执行模式判断。 */
    @Data
    public static class InvocationVO implements Serializable {
        private static final long serialVersionUID = 1L;

        private String function;
        private List<ArgumentVO> arguments;
        private List<ReturnVO> returns;
    }

    @Data
    public static class ArgumentVO implements Serializable {
        private static final long serialVersionUID = 1L;

        private String source;
        private String name;
        private List<BindingVO> bindings;
    }

    @Data
    public static class BindingVO implements Serializable {
        private static final long serialVersionUID = 1L;

        private String target;
        private String source;
        private String name;
        private String property;
        private Boolean optional;
    }

    @Data
    public static class ReturnVO implements Serializable {
        private static final long serialVersionUID = 1L;

        private String output;
        private Integer returnIndex;
        private String path;
    }
}
