package com.modelcloud.common.exception;

import com.modelcloud.common.web.domain.response.Result;
import com.modelcloud.common.web.domain.response.ResultCode;
import lombok.extern.slf4j.Slf4j;
import org.springframework.validation.BindException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.stream.Collectors;

/**
 * 全局异常处理器
 * 
 * @author model-cloud
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    /**
     * 业务异常处理
     */
    @ExceptionHandler(BusinessException.class)
    public Result<?> handleBusinessException(BusinessException e) {
        log.error("业务异常: {}", e.getMessage());
        return Result.error(e.getCode(), e.getMessage());
    }
    
    /**
     * 参数校验异常处理
     */
    @ExceptionHandler({MethodArgumentNotValidException.class, BindException.class})
    public Result<?> handleValidationException(Exception e) {
        String message = "参数校验失败";
        if (e instanceof MethodArgumentNotValidException) {
            MethodArgumentNotValidException ex = (MethodArgumentNotValidException) e;
            message = ex.getBindingResult().getFieldErrors().stream()
                    .map(FieldError::getDefaultMessage)
                    .collect(Collectors.joining(", "));
        } else if (e instanceof BindException) {
            BindException ex = (BindException) e;
            message = ex.getBindingResult().getFieldErrors().stream()
                    .map(FieldError::getDefaultMessage)
                    .collect(Collectors.joining(", "));
        }
        log.error("参数校验异常: {}", message);
        return Result.error(ResultCode.VALIDATION_ERROR.getCode(), message);
    }
    
    /**
     * 其他异常处理
     */
    @ExceptionHandler(Exception.class)
    public Result<?> handleException(Exception e) {
        log.error("系统异常: ", e);
        // 在开发环境下返回详细错误信息，生产环境返回通用提示
        String message = "系统异常，请联系管理员";
        String errorMsg = e.getMessage();
        if (errorMsg != null && !errorMsg.isEmpty()) {
            // 如果是常见的连接错误，返回更友好的提示
            if (errorMsg.contains("Connection refused") || errorMsg.contains("无法连接")) {
                if (errorMsg.contains("redis") || errorMsg.contains("Redis")) {
                    message = "Redis服务连接失败，请检查Redis是否启动";
                } else if (errorMsg.contains("mysql") || errorMsg.contains("MySQL")) {
                    message = "数据库连接失败，请检查MySQL是否启动";
                } else {
                    message = "服务连接失败: " + errorMsg;
                }
            } else {
                // 开发环境显示详细错误
                message = "系统异常: " + errorMsg;
            }
        }
        return Result.error(ResultCode.ERROR.getCode(), message);
    }
}

























