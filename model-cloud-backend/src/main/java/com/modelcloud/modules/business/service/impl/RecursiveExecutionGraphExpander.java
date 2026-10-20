package com.modelcloud.modules.business.service.impl;

import java.util.Map;

/**
 * 兼容门面：展开流程已拆分为
 * {@link MatlabHierarchyCompiler}（工作流递归编译）与
 * {@link EngineAssemblyCompiler}（显式装配数据编译）。
 * 既有调用方与测试继续经由本类入口 {@code expand}。
 */
final class RecursiveExecutionGraphExpander {
    private RecursiveExecutionGraphExpander() {
    }

    static Map<String, Object> expand(Map<String, Object> rawPayload) {
        return MatlabHierarchyCompiler.expand(rawPayload);
    }

    static Map<String, Object> expand(Map<String, Object> rawPayload, Object physicalAssemblies) {
        return MatlabHierarchyCompiler.expand(rawPayload, physicalAssemblies);
    }
}
