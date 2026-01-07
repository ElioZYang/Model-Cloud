package com.modelcloud.modules.sys.service.impl;

import com.modelcloud.modules.business.event.VisitCountEvent;
import com.modelcloud.modules.sys.mapper.SysSiteStatMapper;
import com.modelcloud.modules.sys.model.domain.SysSiteStat;
import com.modelcloud.modules.sys.service.SiteStatService;
import com.mybatisflex.core.query.QueryWrapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

/**
 * 站点统计服务实现
 */
@Slf4j
@Service
public class SiteStatServiceImpl implements SiteStatService {

    private final SysSiteStatMapper sysSiteStatMapper;
    private final ApplicationEventPublisher eventPublisher;

    public SiteStatServiceImpl(SysSiteStatMapper sysSiteStatMapper, ApplicationEventPublisher eventPublisher) {
        this.sysSiteStatMapper = sysSiteStatMapper;
        this.eventPublisher = eventPublisher;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void recordVisit(Long userId) {
        try {
            log.info("开始插入站点访问记录，userId={}", userId);
            // 每次登录插入一条新记录
            SysSiteStat stat = new SysSiteStat();
            stat.setUserId(userId);
            stat.setLoginTime(LocalDateTime.now());
            int result = sysSiteStatMapper.insert(stat);
            log.info("插入站点访问记录完成，userId={}, 插入结果={}, 记录ID={}, 时间={}", 
                userId, result, stat.getId(), stat.getLoginTime());
            
            // 获取更新后的总访问次数
            long totalVisitCount = getTotalVisitCount();
            log.info("当前总访问次数: {}", totalVisitCount);
            
            // 发布访问次数更新事件，触发SSE推送
            eventPublisher.publishEvent(new VisitCountEvent(this, totalVisitCount));
            log.info("发布访问次数更新事件成功，总访问次数: {}", totalVisitCount);
        } catch (Exception e) {
            log.error("recordVisit方法执行失败，userId={}", userId, e);
            throw e; // 重新抛出异常，让调用者知道失败了
        }
    }

    @Override
    public long getTotalVisitCount() {
        // 总访问次数 = 统计表中记录的总数
        return sysSiteStatMapper.selectCountByQuery(
            QueryWrapper.create()
        );
    }
}


