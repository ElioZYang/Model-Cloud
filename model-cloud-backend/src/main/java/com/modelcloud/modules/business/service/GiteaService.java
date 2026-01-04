package com.modelcloud.modules.business.service;

import cn.hutool.http.HttpRequest;
import cn.hutool.http.HttpResponse;
import cn.hutool.json.JSONUtil;
import com.modelcloud.common.config.GiteaConfig;
import com.modelcloud.common.exception.BusinessException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

/**
 * Gitea集成服务
 */
@Slf4j
@Service
public class GiteaService {

    private final GiteaConfig giteaConfig;

    public GiteaService(GiteaConfig giteaConfig) {
        this.giteaConfig = giteaConfig;
    }

    /**
     * 创建仓库
     */
    public String createRepository(String repoName, String description) {
        Map<String, Object> body = new HashMap<>();
        body.put("name", repoName);
        body.put("description", description);
        body.put("private", false);
        body.put("auto_init", true);

        HttpResponse response = HttpRequest.post(giteaConfig.getUrl() + "/api/v1/user/repos")
                .header("Authorization", "token " + giteaConfig.getToken())
                .body(JSONUtil.toJsonStr(body))
                .execute();

        if (response.isOk()) {
            return JSONUtil.parseObj(response.body()).getStr("clone_url");
        } else {
            log.error("Failed to create Gitea repository: {}", response.body());
            throw new BusinessException("创建Gitea仓库失败: " + response.body());
        }
    }

    /**
     * 上传文件到仓库
     */
    public void uploadFile(String repoName, String filePath, MultipartFile file) {
        try {
            byte[] fileBytes = file.getBytes();
            String content = Base64.getEncoder().encodeToString(fileBytes);

            Map<String, Object> body = new HashMap<>();
            body.put("content", content);
            body.put("message", "Upload file: " + filePath);
            body.put("branch", "master");

            HttpResponse response = HttpRequest.post(giteaConfig.getUrl() + "/api/v1/repos/" + giteaConfig.getUsername() + "/" + repoName + "/contents/" + filePath)
                    .header("Authorization", "token " + giteaConfig.getToken())
                    .body(JSONUtil.toJsonStr(body))
                    .execute();

            if (!response.isOk() && response.getStatus() != 201) {
                log.error("Failed to upload file to Gitea: {}", response.body());
                throw new BusinessException("上传文件到Gitea失败: " + response.body());
            }
        } catch (IOException e) {
            log.error("Error reading file bytes", e);
            throw new BusinessException("读取文件失败");
        }
    }

    /**
     * 获取仓库存档(zip)下载链接
     */
    public String getArchiveUrl(String repoName) {
        return giteaConfig.getUrl() + "/" + giteaConfig.getUsername() + "/" + repoName + "/archive/master.zip";
    }

    /**
     * 获取文件下载链接
     */
    public String getDownloadUrl(String repoName, String filePath) {
        return giteaConfig.getUrl() + "/" + giteaConfig.getUsername() + "/" + repoName + "/raw/branch/master/" + filePath;
    }
}

