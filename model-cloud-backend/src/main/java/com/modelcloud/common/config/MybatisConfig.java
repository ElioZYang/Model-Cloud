package com.modelcloud.common.config;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.annotation.Configuration;

/**
 * MyBatis-Flex配置类
 */
@Configuration
@MapperScan({"com.modelcloud.modules.auth.mapper", "com.modelcloud.modules.business.mapper", "com.modelcloud.modules.sys.mapper"})
public class MybatisConfig {
}
