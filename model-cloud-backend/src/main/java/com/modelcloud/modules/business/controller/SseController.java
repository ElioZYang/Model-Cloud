package com.modelcloud.modules.business.controller;

import com.modelcloud.modules.business.event.VisitCountEvent;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.concurrent.CopyOnWriteArraySet;

/**
 * SSE (Server-Sent Events) 控制器
 * 用于实时推送浏览量更新给所有连接的客户端
 */
@Slf4j
@RestController
@RequestMapping("/api/sse")
public class SseController {
    
    // 存储所有活跃的SSE连接
    private final CopyOnWriteArraySet<SseEmitter> emitters = new CopyOnWriteArraySet<>();
    
    /**
     * 建立SSE连接
     * 前端通过 EventSource 连接此端点
     */
    @GetMapping(value = "/visit-count", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public ResponseEntity<SseEmitter> subscribeVisitCount() {
        // 创建SSE发射器，设置超时时间为30分钟
        SseEmitter emitter = new SseEmitter(30 * 60 * 1000L);
        
        // 添加到连接集合
        emitters.add(emitter);
        log.info("新的SSE连接建立，当前连接数: {}", emitters.size());
        
        // 连接关闭时的清理逻辑
        emitter.onCompletion(() -> {
            emitters.remove(emitter);
            log.info("SSE连接关闭，当前连接数: {}", emitters.size());
        });
        
        emitter.onTimeout(() -> {
            emitters.remove(emitter);
            log.info("SSE连接超时，当前连接数: {}", emitters.size());
        });
        
        emitter.onError((ex) -> {
            emitters.remove(emitter);
            log.error("SSE连接错误", ex);
        });
        
        // 发送初始连接成功消息
        try {
            emitter.send(SseEmitter.event()
                .name("connected")
                .data("连接成功"));
        } catch (IOException e) {
            log.error("发送初始SSE消息失败", e);
            emitters.remove(emitter);
            return ResponseEntity.internalServerError().build();
        }
        
        return ResponseEntity.ok(emitter);
    }
    
    /**
     * 监听访问次数更新事件
     * 当有新用户登录时，向所有连接的客户端推送更新
     */
    @EventListener
    @org.springframework.scheduling.annotation.Async("sseTaskExecutor")
    public void handleVisitCountEvent(VisitCountEvent event) {
        Long totalVisitCount = event.getTotalVisitCount();
        log.info("收到访问次数更新事件，总访问次数: {}, 当前连接数: {}", totalVisitCount, emitters.size());
        
        // 向所有连接的客户端推送更新
        CopyOnWriteArraySet<SseEmitter> deadEmitters = new CopyOnWriteArraySet<>();
        
        for (SseEmitter emitter : emitters) {
            try {
                emitter.send(SseEmitter.event()
                    .name("visitCountUpdate")
                    .data(totalVisitCount));
            } catch (IOException e) {
                log.warn("推送SSE消息失败，移除连接", e);
                deadEmitters.add(emitter);
            }
        }
        
        // 清理失效的连接
        emitters.removeAll(deadEmitters);
        
        if (!deadEmitters.isEmpty()) {
            log.info("清理了 {} 个失效连接，当前连接数: {}", deadEmitters.size(), emitters.size());
        }
    }
}

