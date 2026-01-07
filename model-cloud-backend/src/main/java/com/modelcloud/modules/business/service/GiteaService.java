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
        body.put("description", description != null ? description : "");
        body.put("private", false);
        body.put("auto_init", true); // 自动初始化仓库，创建README
        body.put("default_branch", "main"); // 设置默认分支为main

        String apiUrl = giteaConfig.getUrl() + "/api/v1/user/repos";
        log.info("Creating Gitea repository: {} at {}", repoName, apiUrl);

        HttpResponse response = HttpRequest.post(apiUrl)
                .header("Authorization", "token " + giteaConfig.getToken())
                .header("Content-Type", "application/json")
                .body(JSONUtil.toJsonStr(body))
                .timeout(30000) // 30秒超时
                .execute();

        if (response.isOk() || response.getStatus() == 201) {
            String cloneUrl = JSONUtil.parseObj(response.body()).getStr("clone_url");
            log.info("Repository created successfully: {}", cloneUrl);
            
            // 等待一小段时间，确保仓库完全初始化
            try {
                Thread.sleep(2000);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
            
            return cloneUrl;
        } else {
            log.error("Failed to create Gitea repository. Status: {}, Response: {}", 
                    response.getStatus(), response.body());
            throw new BusinessException("创建Gitea仓库失败 (状态码: " + response.getStatus() + "): " + response.body());
        }
    }

    /**
     * 确保仓库存在（不存在则创建），返回 clone_url
     * 按当前配置，所有仓库都创建在配置中的全局账号（如 yangxz）的名下
     */
    public String ensureRepository(String repoName, String description) {
        // 1. 先尝试查询仓库是否已存在
        String repoApi = giteaConfig.getUrl() + "/api/v1/repos/" + giteaConfig.getUsername() + "/" + repoName;
        log.info("Checking if Gitea repository exists: {}", repoApi);

        HttpResponse getResp = HttpRequest.get(repoApi)
                .header("Authorization", "token " + giteaConfig.getToken())
                .timeout(15000)
                .execute();

        if (getResp.isOk()) {
            String cloneUrl = JSONUtil.parseObj(getResp.body()).getStr("clone_url");
            log.info("Repository already exists: {}", cloneUrl);
            return cloneUrl;
        }

        if (getResp.getStatus() != 404) {
            log.error("Failed to check Gitea repository. Status: {}, Response: {}",
                    getResp.getStatus(), getResp.body());
            throw new BusinessException("查询Gitea仓库失败 (状态码: " + getResp.getStatus() + "): " + getResp.body());
        }

        // 2. 不存在则创建
        return createRepository(repoName, description);
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

            // 对文件路径进行URL编码，防止特殊字符导致请求失败
            String encodedPath = cn.hutool.core.util.URLUtil.encode(filePath);
            
            String apiUrl = giteaConfig.getUrl() + "/api/v1/repos/" + giteaConfig.getUsername() + "/" + repoName + "/contents/" + encodedPath;
            log.info("Uploading file to Gitea: {}", apiUrl);
            
            // 首先尝试使用 main 分支
            body.put("branch", "main");
            HttpResponse response = HttpRequest.post(apiUrl)
                    .header("Authorization", "token " + giteaConfig.getToken())
                    .header("Content-Type", "application/json")
                    .body(JSONUtil.toJsonStr(body))
                    .timeout(60000) // 设置60秒超时
                    .execute();

            // 如果 main 分支失败，尝试 master 分支
            if (!response.isOk() && response.getStatus() != 201) {
                log.warn("Failed to upload to main branch, trying master branch. Status: {}, Response: {}", 
                        response.getStatus(), response.body());
                body.put("branch", "master");
                response = HttpRequest.post(apiUrl)
                        .header("Authorization", "token " + giteaConfig.getToken())
                        .header("Content-Type", "application/json")
                        .body(JSONUtil.toJsonStr(body))
                        .timeout(60000)
                        .execute();
            }

            if (!response.isOk() && response.getStatus() != 201) {
                log.error("Failed to upload file to Gitea: {} - Status: {}", response.body(), response.getStatus());
                throw new BusinessException("上传文件到Gitea失败 (状态码: " + response.getStatus() + "): " + response.body());
            }
            
            log.info("File uploaded successfully: {}", filePath);
        } catch (IOException e) {
            log.error("Error reading file bytes", e);
            throw new BusinessException("读取文件失败: " + e.getMessage());
        }
    }

    /**
     * 上传文本内容为文件到仓库（用于 README 等）
     */
    public void uploadContent(String repoName, String filePath, String textContent) {
        byte[] fileBytes = textContent != null ? textContent.getBytes(java.nio.charset.StandardCharsets.UTF_8) : new byte[0];
        String content = Base64.getEncoder().encodeToString(fileBytes);

        Map<String, Object> body = new HashMap<>();
        body.put("content", content);
        body.put("message", "Upload file: " + filePath);

        String encodedPath = cn.hutool.core.util.URLUtil.encode(filePath);
        String apiUrl = giteaConfig.getUrl() + "/api/v1/repos/" + giteaConfig.getUsername() + "/" + repoName + "/contents/" + encodedPath;
        log.info("Uploading text content to Gitea: {}", apiUrl);

        body.put("branch", "main");
        HttpResponse response = HttpRequest.post(apiUrl)
                .header("Authorization", "token " + giteaConfig.getToken())
                .header("Content-Type", "application/json")
                .body(JSONUtil.toJsonStr(body))
                .timeout(60000)
                .execute();

        if (!response.isOk() && response.getStatus() != 201) {
            log.warn("Failed to upload to main branch, trying master branch. Status: {}, Response: {}",
                    response.getStatus(), response.body());
            body.put("branch", "master");
            response = HttpRequest.post(apiUrl)
                    .header("Authorization", "token " + giteaConfig.getToken())
                    .header("Content-Type", "application/json")
                    .body(JSONUtil.toJsonStr(body))
                    .timeout(60000)
                    .execute();
        }

        if (!response.isOk() && response.getStatus() != 201) {
            log.error("Failed to upload text content to Gitea: {} - Status: {}", response.body(), response.getStatus());
            throw new BusinessException("上传文件到Gitea失败 (状态码: " + response.getStatus() + "): " + response.body());
        }

        log.info("Text file uploaded successfully: {}", filePath);
    }

    /**
     * 更新文件内容（需要先获取文件的sha）
     */
    public void updateFile(String repoName, String filePath, String content, String sha) {
        String encodedPath = cn.hutool.core.util.URLUtil.encode(filePath);
        String apiUrl = giteaConfig.getUrl() + "/api/v1/repos/" + giteaConfig.getUsername() + "/" + repoName + "/contents/" + encodedPath;
        log.info("Updating file in Gitea: {}", apiUrl);

        Map<String, Object> body = new HashMap<>();
        body.put("content", content);
        body.put("message", "Update file: " + filePath);
        body.put("sha", sha);
        body.put("branch", "main");

        HttpResponse response = HttpRequest.put(apiUrl)
                .header("Authorization", "token " + giteaConfig.getToken())
                .header("Content-Type", "application/json")
                .body(JSONUtil.toJsonStr(body))
                .timeout(60000)
                .execute();

        if (!response.isOk() && response.getStatus() != 200) {
            log.warn("Failed to update on main branch, trying master branch. Status: {}, Response: {}",
                    response.getStatus(), response.body());
            body.put("branch", "master");
            response = HttpRequest.put(apiUrl)
                    .header("Authorization", "token " + giteaConfig.getToken())
                    .header("Content-Type", "application/json")
                    .body(JSONUtil.toJsonStr(body))
                    .timeout(60000)
                    .execute();
        }

        if (!response.isOk() && response.getStatus() != 200) {
            log.error("Failed to update file in Gitea: {} - Status: {}", response.body(), response.getStatus());
            throw new BusinessException("更新文件失败 (状态码: " + response.getStatus() + "): " + response.body());
        }

        log.info("File updated successfully: {}", filePath);
    }

    /**
     * 获取文件内容
     */
    public String getFileContent(String repoName, String filePath) {
        String encodedPath = cn.hutool.core.util.URLUtil.encode(filePath);
        String apiUrl = giteaConfig.getUrl() + "/api/v1/repos/" + giteaConfig.getUsername() + "/" + repoName + "/contents/" + encodedPath;
        log.info("Getting file content from Gitea: {}", apiUrl);

        HttpResponse response = HttpRequest.get(apiUrl)
                .header("Authorization", "token " + giteaConfig.getToken())
                .timeout(30000)
                .execute();

        if (!response.isOk()) {
            log.error("Failed to get file content from Gitea: {} - Status: {}", response.body(), response.getStatus());
            throw new BusinessException("获取文件内容失败 (状态码: " + response.getStatus() + "): " + response.body());
        }

        cn.hutool.json.JSONObject jsonObject = JSONUtil.parseObj(response.body());
        String content = jsonObject.getStr("content");
        if (content != null) {
            // Gitea返回的content是Base64编码的，这里按UTF-8解码，避免中文乱码
            try {
                byte[] bytes = Base64.getDecoder().decode(content.replaceAll("\\s", ""));
                return new String(bytes, java.nio.charset.StandardCharsets.UTF_8);
            } catch (IllegalArgumentException e) {
                log.error("Failed to decode base64 content", e);
                throw new BusinessException("解码文件内容失败: " + e.getMessage());
            }
        }
        return null;
    }

    /**
     * 获取文件的sha值（用于更新文件）
     */
    public String getFileSha(String repoName, String filePath) {
        String encodedPath = cn.hutool.core.util.URLUtil.encode(filePath);
        String apiUrl = giteaConfig.getUrl() + "/api/v1/repos/" + giteaConfig.getUsername() + "/" + repoName + "/contents/" + encodedPath;
        log.info("Getting file sha from Gitea: {}", apiUrl);

        HttpResponse response = HttpRequest.get(apiUrl)
                .header("Authorization", "token " + giteaConfig.getToken())
                .timeout(30000)
                .execute();

        if (!response.isOk()) {
            log.error("Failed to get file sha from Gitea: {} - Status: {}", response.body(), response.getStatus());
            throw new BusinessException("获取文件sha失败 (状态码: " + response.getStatus() + "): " + response.body());
        }

        cn.hutool.json.JSONObject jsonObject = JSONUtil.parseObj(response.body());
        return jsonObject.getStr("sha");
    }

    /**
     * 获取仓库存档(zip)下载链接
     */
    public String getArchiveUrl(String repoName) {
        // 返回 main 分支的zip下载链接
        String archiveUrl = giteaConfig.getUrl() + "/" + giteaConfig.getUsername() + "/" + repoName + "/archive/main.zip";
        log.debug("Generated archive URL: {}", archiveUrl);
        return archiveUrl;
    }

    /**
     * 获取文件下载链接（原始文件）
     */
    public String getDownloadUrl(String repoName, String filePath) {
        // 返回文件的原始下载链接，Gitea格式: /owner/repo/raw/branch/filepath
        // 对文件路径进行URL编码
        String encodedPath = cn.hutool.core.util.URLUtil.encode(filePath);
        String downloadUrl = giteaConfig.getUrl() + "/" + giteaConfig.getUsername() + "/" + repoName + "/raw/branch/main/" + encodedPath;
        log.debug("Generated download URL: {}", downloadUrl);
        return downloadUrl;
    }
    
    /**
     * 获取仓库的Web访问链接
     */
    public String getRepoWebUrl(String repoName) {
        return giteaConfig.getUrl() + "/" + giteaConfig.getUsername() + "/" + repoName;
    }
    
    /**
     * 获取默认封面图片URL
     * 默认封面图片位于 imgs 仓库中的 default-cover-img.png
     */
    public String getDefaultCoverImageUrl() {
        String defaultCoverUrl = giteaConfig.getUrl() + "/" + giteaConfig.getUsername() + "/imgs/raw/branch/main/default-cover-img.png";
        log.debug("Generated default cover image URL: {}", defaultCoverUrl);
        return defaultCoverUrl;
    }
    
    /**
     * 列出文件夹内容
     */
    public java.util.List<cn.hutool.json.JSONObject> listFolderContents(String repoName, String folderPath) {
        String encodedPath = cn.hutool.core.util.URLUtil.encode(folderPath);
        String apiUrl = giteaConfig.getUrl() + "/api/v1/repos/" + giteaConfig.getUsername() + "/" + repoName + "/contents/" + encodedPath;
        log.info("Listing folder contents from Gitea: {}", apiUrl);

        HttpResponse response = HttpRequest.get(apiUrl)
                .header("Authorization", "token " + giteaConfig.getToken())
                .timeout(30000)
                .execute();

        if (!response.isOk()) {
            log.error("Failed to list folder contents from Gitea: {} - Status: {}", response.body(), response.getStatus());
            throw new BusinessException("获取文件夹内容失败 (状态码: " + response.getStatus() + "): " + response.body());
        }

        // 返回 JSON 对象列表，避免 Map 泛型推断问题
        cn.hutool.json.JSONArray array = JSONUtil.parseArray(response.body());
        return array.toList(cn.hutool.json.JSONObject.class);
    }

    /**
     * 删除仓库
     */
    public void deleteRepository(String repoName) {
        String apiUrl = giteaConfig.getUrl() + "/api/v1/repos/" + giteaConfig.getUsername() + "/" + repoName;
        log.info("Deleting Gitea repository: {}", apiUrl);
        
        HttpResponse response = HttpRequest.delete(apiUrl)
                .header("Authorization", "token " + giteaConfig.getToken())
                .timeout(30000)
                .execute();
        
        if (response.isOk() || response.getStatus() == 204) {
            log.info("Repository deleted successfully: {}", repoName);
        } else {
            log.error("Failed to delete Gitea repository. Status: {}, Response: {}", 
                    response.getStatus(), response.body());
            throw new BusinessException("删除Gitea仓库失败 (状态码: " + response.getStatus() + "): " + response.body());
        }
    }
}
