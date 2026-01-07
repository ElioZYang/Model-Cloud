package com.modelcloud;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.mongodb.repository.config.EnableMongoRepositories;

/**
 * 模型管理系统后端启动类
 * 
 * @author model-cloud
 * @date 2025-01-XX
 */
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.Environment;
import lombok.extern.slf4j.Slf4j;
import java.net.InetAddress;
import java.net.UnknownHostException;

/**
 * 模型管理系统后端启动类
 * 
 * @author model-cloud
 */
@Slf4j
@SpringBootApplication
@EnableMongoRepositories("com.modelcloud.modules.**.repository")
@org.springframework.scheduling.annotation.EnableAsync
public class ModelCloudApplication {
    public static void main(String[] args) throws UnknownHostException {
        ConfigurableApplicationContext application = SpringApplication.run(ModelCloudApplication.class, args);
        Environment env = application.getEnvironment();
        String ip = InetAddress.getLocalHost().getHostAddress();
        String port = env.getProperty("server.port");
        String path = env.getProperty("server.servlet.context-path");
        if (path == null) {
            path = "";
        }
        log.info("\n----------------------------------------------------------\n\t" +
                "应用实例运行成功! 访问连接:\n\t" +
                "本地: \t\thttp://localhost:" + port + path + "/\n\t" +
                "外部: \t\thttp://" + ip + ":" + port + path + "/\n" +
                "----------------------------------------------------------");
    }
}



