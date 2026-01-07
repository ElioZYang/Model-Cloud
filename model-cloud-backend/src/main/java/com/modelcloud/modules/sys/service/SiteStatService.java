package com.modelcloud.modules.sys.service;

/**
 * 站点统计服务
 */
public interface SiteStatService {

    /**
     * 记录一次登录访问
     * @param userId 登录用户ID
     */
    void recordVisit(Long userId);

    /**
     * 获取全站总访问次数（统计表中记录的总数）
     */
    long getTotalVisitCount();
}


