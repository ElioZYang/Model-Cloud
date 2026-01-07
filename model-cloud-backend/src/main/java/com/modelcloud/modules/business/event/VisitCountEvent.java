package com.modelcloud.modules.business.event;

import lombok.Getter;
import org.springframework.context.ApplicationEvent;

/**
 * 访问次数更新事件
 * 当有新用户登录时触发此事件
 */
@Getter
public class VisitCountEvent extends ApplicationEvent {
    
    private final Long totalVisitCount;
    
    public VisitCountEvent(Object source, Long totalVisitCount) {
        super(source);
        this.totalVisitCount = totalVisitCount;
    }
}

