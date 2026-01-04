package com.modelcloud.common.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

/**
 * Gitea配置
 */
@Data
@Configuration
@ConfigurationProperties(prefix = "model-cloud.gitea")
public class GiteaConfig {
    private String url;
    private String token;
    private String username;
    private String password;
}

