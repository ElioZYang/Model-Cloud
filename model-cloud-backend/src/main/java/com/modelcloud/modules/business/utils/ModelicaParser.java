package com.modelcloud.modules.business.utils;

import cn.hutool.core.util.StrUtil;
import lombok.extern.slf4j.Slf4j;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Modelica模型解析工具类
 * 用于解析.mo文件，提取组件信息、参数、接口等
 * 
 * @author model-cloud
 */
@Slf4j
public class ModelicaParser {
    
    /**
     * 解析Modelica模型，提取组件信息
     */
    public static ModelicaComponentInfo parseModel(String modelicaCode) {
        ModelicaComponentInfo info = new ModelicaComponentInfo();
        
        if (StrUtil.isBlank(modelicaCode)) {
            return info;
        }
        
        // 提取类名
        info.setClassName(extractClassName(modelicaCode));
        
        // 提取参数
        info.setParameters(extractParameters(modelicaCode));
        
        // 提取接口（connector）
        info.setConnectors(extractConnectors(modelicaCode));
        
        return info;
    }
    
    /**
     * 提取类名
     */
    private static String extractClassName(String code) {
        // 匹配 class、model、package、function 等关键字后的类名
        Pattern pattern = Pattern.compile("(?:class|model|package|function|connector|record|block|type)\\s+(\\w+)", Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(code);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }
    
    /**
     * 提取参数
     */
    private static List<ParameterInfo> extractParameters(String code) {
        List<ParameterInfo> parameters = new ArrayList<>();
        
        // 匹配 parameter 声明
        // 格式：parameter Type name = value;
        Pattern pattern = Pattern.compile(
            "parameter\\s+(\\w+(?:\\.\\w+)*)\\s+(\\w+)\\s*(?:=\\s*([^;]+))?\\s*;",
            Pattern.CASE_INSENSITIVE | Pattern.MULTILINE
        );
        
        Matcher matcher = pattern.matcher(code);
        while (matcher.find()) {
            ParameterInfo param = new ParameterInfo();
            param.setType(matcher.group(1));
            param.setName(matcher.group(2));
            if (matcher.groupCount() >= 3 && matcher.group(3) != null) {
                param.setDefaultValue(matcher.group(3).trim());
            }
            parameters.add(param);
        }
        
        return parameters;
    }
    
    /**
     * 提取接口（connector）
     */
    private static List<ConnectorInfo> extractConnectors(String code) {
        List<ConnectorInfo> connectors = new ArrayList<>();
        
        // 匹配 connector 声明
        // 格式：ConnectorType connectorName;
        // 或者：Modelica.Electrical.Analog.Interfaces.PositivePin p;
        Pattern pattern = Pattern.compile(
            "(?:\\w+(?:\\.\\w+)*)\\s+(\\w+)\\s*;",
            Pattern.CASE_INSENSITIVE | Pattern.MULTILINE
        );
        
        // 先查找所有可能的connector声明
        // 简化处理：查找包含"Pin"、"Port"、"Connector"等关键字的行
        String[] lines = code.split("\n");
        for (String line : lines) {
            line = line.trim();
            if (line.contains("Pin") || line.contains("Port") || line.contains("Connector") || 
                line.contains("p ") || line.contains("n ") || line.contains("positive") || line.contains("negative")) {
                Matcher matcher = pattern.matcher(line);
                if (matcher.find()) {
                    ConnectorInfo connector = new ConnectorInfo();
                    connector.setName(matcher.group(1));
                    // 尝试提取类型
                    String type = extractConnectorType(line);
                    connector.setType(type);
                    connectors.add(connector);
                }
            }
        }
        
        // 如果没有找到，使用默认的p和n（Modelica电气库常用）
        if (connectors.isEmpty()) {
            connectors.add(createDefaultConnector("p", "PositivePin"));
            connectors.add(createDefaultConnector("n", "NegativePin"));
        }
        
        return connectors;
    }
    
    /**
     * 提取connector类型
     */
    private static String extractConnectorType(String line) {
        // 尝试从行中提取类型
        Pattern typePattern = Pattern.compile("(\\w+(?:\\.\\w+)*)\\s+\\w+\\s*;");
        Matcher matcher = typePattern.matcher(line);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return "Modelica.Electrical.Analog.Interfaces.PositivePin";
    }
    
    /**
     * 创建默认connector
     */
    private static ConnectorInfo createDefaultConnector(String name, String type) {
        ConnectorInfo connector = new ConnectorInfo();
        connector.setName(name);
        connector.setType(type);
        return connector;
    }
    
    /**
     * Modelica组件信息
     */
    public static class ModelicaComponentInfo {
        private String className;
        private List<ParameterInfo> parameters = new ArrayList<>();
        private List<ConnectorInfo> connectors = new ArrayList<>();
        
        public String getClassName() { return className; }
        public void setClassName(String className) { this.className = className; }
        public List<ParameterInfo> getParameters() { return parameters; }
        public void setParameters(List<ParameterInfo> parameters) { this.parameters = parameters; }
        public List<ConnectorInfo> getConnectors() { return connectors; }
        public void setConnectors(List<ConnectorInfo> connectors) { this.connectors = connectors; }
    }
    
    /**
     * 参数信息
     */
    public static class ParameterInfo {
        private String type;
        private String name;
        private String defaultValue;
        
        public String getType() { return type; }
        public void setType(String type) { this.type = type; }
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public String getDefaultValue() { return defaultValue; }
        public void setDefaultValue(String defaultValue) { this.defaultValue = defaultValue; }
    }
    
    /**
     * 接口信息
     */
    public static class ConnectorInfo {
        private String name;
        private String type;
        
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public String getType() { return type; }
        public void setType(String type) { this.type = type; }
    }
}

