package com.modelcloud.common.web.domain.response;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 响应码枚举
 * 
 * @author model-cloud
 */
@Getter
@AllArgsConstructor
public enum ResultCode {
    SUCCESS(200, "操作成功"),
    ERROR(500, "操作失败"),
    UNAUTHORIZED(401, "未授权"),
    FORBIDDEN(403, "无权限"),
    NOT_FOUND(404, "资源不存在"),
    BAD_REQUEST(400, "请求参数错误"),
    VALIDATION_ERROR(422, "参数校验失败");
    
    private final Integer code;
    private final String message;
}


























