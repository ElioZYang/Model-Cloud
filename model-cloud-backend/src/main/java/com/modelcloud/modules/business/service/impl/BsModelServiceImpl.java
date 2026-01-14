package com.modelcloud.modules.business.service.impl;

import cn.hutool.core.util.IdUtil;
import cn.hutool.core.util.StrUtil;
import com.modelcloud.common.config.GiteaConfig;
import com.modelcloud.common.exception.BusinessException;
import com.modelcloud.common.tools.SecurityUtils;
import com.modelcloud.modules.business.mapper.BsModelMapper;
import com.modelcloud.modules.business.mapper.BsModelCollectMapper;
import com.modelcloud.modules.business.model.domain.BsModel;
import com.modelcloud.modules.business.model.domain.BsModelCollect;
import com.modelcloud.modules.business.model.request.ModelUploadRequest;
import com.modelcloud.modules.business.service.BsModelService;
import com.modelcloud.modules.business.service.GiteaService;
import com.modelcloud.modules.sys.mapper.SysUserMapper;
import com.modelcloud.modules.sys.model.domain.SysUser;
import com.modelcloud.modules.sys.service.SiteStatService;
import com.mybatisflex.core.paginate.Page;
import com.mybatisflex.core.query.QueryWrapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Base64;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import static com.modelcloud.modules.business.model.domain.table.BsModelTableDef.BS_MODEL;
import static com.modelcloud.modules.business.model.domain.table.BsModelCollectTableDef.BS_MODEL_COLLECT;

/**
 * 模型服务实现类
 * 
 * @author model-cloud
 */
@Slf4j
@Service
public class BsModelServiceImpl implements BsModelService {

    private final BsModelMapper bsModelMapper;
    private final BsModelCollectMapper bsModelCollectMapper;
    private final GiteaService giteaService;
    private final SysUserMapper sysUserMapper;
    private final com.modelcloud.modules.business.service.BsModelCollectService collectService;
    private final GiteaConfig giteaConfig;
    private final SiteStatService siteStatService;

    public BsModelServiceImpl(
            BsModelMapper bsModelMapper,
            BsModelCollectMapper bsModelCollectMapper, 
            GiteaService giteaService, 
            SysUserMapper sysUserMapper,
            com.modelcloud.modules.business.service.BsModelCollectService collectService,
            GiteaConfig giteaConfig,
            SiteStatService siteStatService) {
        this.bsModelMapper = bsModelMapper;
        this.bsModelCollectMapper = bsModelCollectMapper;
        this.giteaService = giteaService;
        this.sysUserMapper = sysUserMapper;
        this.collectService = collectService;
        this.giteaConfig = giteaConfig;
        this.siteStatService = siteStatService;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public BsModel uploadModel(ModelUploadRequest request) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new BusinessException("用户未登录");
        }

        if (StrUtil.isBlank(request.getName())) {
            throw new BusinessException("模型名称不能为空");
        }

        // 查询当前用户信息
        SysUser user = sysUserMapper.selectOneById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }

        // 1. 每个业务用户在 yangxz 的 Gitea 下对应一个固定仓库
        String username = user.getUsername();
        String displayName = StrUtil.isNotBlank(user.getNickname()) ? user.getNickname() : username;
        String repoName = "models-" + username;
        String repoDesc = "用户 " + displayName + " 的模型仓库";

        log.info("Ensuring Gitea repository: {} for user: {}", repoName, userId);

        // 2. 确保用户仓库存在（不存在则创建）
        try {
            giteaService.ensureRepository(repoName, repoDesc);
        } catch (Exception e) {
            log.error("Failed to ensure Gitea repository", e);
            throw new BusinessException("创建或获取Gitea仓库失败: " + e.getMessage());
        }

        // 3. 使用模型名称和创建时间生成文件夹名称
        // 格式：model-{模型名称}-{创建时间}，例如：model-ResNet50-20260109
        LocalDateTime createTime = LocalDateTime.now();
        String dateStr = createTime.format(java.time.format.DateTimeFormatter.ofPattern("yyyyMMdd"));
        // 清理模型名称中的特殊字符，替换为下划线，避免文件夹命名问题
        String safeModelName = request.getName()
            .replaceAll("[\\\\/:*?\"<>|]", "_")  // 替换Windows/Linux不允许的字符
            .replaceAll("\\s+", "_")             // 替换空格为下划线
            .replaceAll("[^\\w\\-]", "_");        // 替换其他特殊字符为下划线
        String modelFolder = "model-" + safeModelName + "-" + dateStr + "/";
        log.info("生成模型文件夹: {}", modelFolder);

        // 5. 上传模型文件到该文件夹
        if (request.getModelFile() != null && !request.getModelFile().isEmpty()) {
            String modelFileName = request.getModelFile().getOriginalFilename();
            String modelFilePath = modelFolder + modelFileName;
            log.info("Uploading model file: {} to repo: {}, path: {}", modelFileName, repoName, modelFilePath);
            giteaService.uploadFile(repoName, modelFilePath, request.getModelFile());
        } else {
            throw new BusinessException("请上传模型文件");
        }

        // 6. 上传封面图片（同样放在模型文件夹下）
        String coverImageUrl = null;
        if (request.getCoverImage() != null && !request.getCoverImage().isEmpty()) {
            String originalFilename = request.getCoverImage().getOriginalFilename();
            String extension = StrUtil.subAfter(originalFilename, ".", true);
            String coverFileName = "cover-" + IdUtil.simpleUUID() + (StrUtil.isNotBlank(extension) ? "." + extension : "");
            String coverFilePath = modelFolder + coverFileName;
            
            log.info("Uploading cover image: {} as {} to repo: {}, path: {}", originalFilename, coverFileName, repoName, coverFilePath);
            giteaService.uploadFile(repoName, coverFilePath, request.getCoverImage());
            coverImageUrl = giteaService.getDownloadUrl(repoName, coverFilePath);
        }

        // 7. 生成 README 文件（包含描述），放在模型文件夹中
        try {
            StringBuilder readme = new StringBuilder();
            // 模型名称
            readme.append("# ").append(request.getName()).append("\n\n");
            
            // 基本信息
            readme.append("## 基本信息\n\n");
            readme.append("- 作者：").append(displayName).append("\n");
            readme.append("- 上传时间：").append(LocalDateTime.now()).append("\n");
            if (StrUtil.isNotBlank(request.getLicense())) {
                readme.append("- 协议类型：").append(request.getLicense()).append("\n");
            }
            if (StrUtil.isNotBlank(request.getFormat())) {
                readme.append("- 模型格式：").append(request.getFormat()).append("\n");
            }
            if (request.getTags() != null && !request.getTags().isEmpty()) {
                readme.append("- 标签：").append(String.join(", ", request.getTags())).append("\n");
            }
            readme.append("\n");
            
            // 模型描述
            readme.append("## 模型描述\n\n");
            if (StrUtil.isNotBlank(request.getDescription())) {
                readme.append(request.getDescription()).append("\n");
            } else {
                readme.append("暂无描述\n");
            }

            String readmePath = modelFolder + "README.md";
            giteaService.uploadContent(repoName, readmePath, readme.toString());
        } catch (Exception e) {
            // README 生成失败不影响主流程，记录日志即可
            log.warn("生成或上传README失败，但不影响模型上传主流程", e);
        }

        // 8. 保存元数据到数据库（一次性保存所有信息）
        BsModel model = new BsModel();
        model.setName(request.getName());
        model.setDescription(request.getDescription());
        model.setUserId(userId);
        model.setRepoName(repoName);
        // 使用存档下载链接作为 repoUrl，方便前端直接下载
        model.setRepoUrl(giteaService.getArchiveUrl(repoName));
        model.setCoverImage(coverImageUrl);
        // 根据是否公开设置审核状态：
        // - 普通用户公开模型需要审核（10）
        // - 管理员/超级管理员公开模型可直接通过（20）
        // - 不公开模型直接通过（20）
        Integer isPublic = request.getIsPublic() != null ? request.getIsPublic() : 0;
        model.setIsPublic(isPublic);
        boolean isAdmin = SecurityUtils.isAdmin();
        if (isPublic == 1) {
            if (isAdmin) {
                model.setStatus(20); // 管理员上传公开模型，直接审核通过
            } else {
                model.setStatus(10); // 普通用户公开模型需要审核
            }
        } else {
            model.setStatus(20); // 不公开模型直接通过
        }
        model.setIsDel(0); // 设置为未删除
        model.setCreateTime(createTime);
        model.setUpdateTime(createTime);

        // 处理标签
        model.setAttrLabelNames(buildLabelNames(request));

        bsModelMapper.insert(model);
        log.info("Model uploaded and saved successfully: modelId={}, folder={}", model.getId(), modelFolder);
        return model;
    }

    @Override
    public Page<BsModel> pageModels(int pageNum, int pageSize, String keyword, String tag) {
        QueryWrapper queryWrapper = QueryWrapper.create()
                .where(BS_MODEL.IS_DEL.eq(0)) // 只查询未删除的记录
                .and(BS_MODEL.IS_PUBLIC.eq(1)) // 只显示公开的模型
                .and(BS_MODEL.STATUS.eq(20)) // 只显示审核通过的模型
                .and(BS_MODEL.NAME.like(keyword).or(BS_MODEL.DESCRIPTION.like(keyword)).when(StrUtil.isNotBlank(keyword)))
                .and(BS_MODEL.ATTR_LABEL_NAMES.like(tag).when(StrUtil.isNotBlank(tag)))
                .orderBy(BS_MODEL.CREATE_TIME.desc());
        
        try {
            Page<BsModel> page = bsModelMapper.paginate(pageNum, pageSize, queryWrapper);
            if (page.getRecords() != null) {
                for (BsModel model : page.getRecords()) {
                    fillAuthorName(model);
                    fillDefaultCoverImage(model);
                }
            }
            return page;
        } catch (Exception e) {
            log.error("分页查询模型失败", e);
            throw new BusinessException("查询模型列表失败: " + e.getMessage());
        }
    }

    @Override
    public BsModel getModelDetail(Long id) {
        BsModel model = bsModelMapper.selectOneById(id);
        if (model == null || model.getIsDel() == 1) {
            throw new BusinessException("模型不存在");
        }
        fillAuthorName(model);
        fillDefaultCoverImage(model);
        return model;
    }

    @Override
    public Map<String, Object> getStatistics() {
        Long userId = SecurityUtils.getCurrentUserId();
        Map<String, Object> stats = new HashMap<>();
        
        try {
            // 模型总数（公开且审核通过的模型）
            QueryWrapper totalQuery = QueryWrapper.create()
                    .where(BS_MODEL.IS_DEL.eq(0))
                    .and(BS_MODEL.IS_PUBLIC.eq(1))
                    .and(BS_MODEL.STATUS.eq(20));
            long totalCount = bsModelMapper.selectCountByQuery(totalQuery);
            stats.put("totalCount", totalCount);
            
            // 当前用户已上传的模型数
            if (userId != null) {
                QueryWrapper myUploadQuery = QueryWrapper.create()
                        .where(BS_MODEL.IS_DEL.eq(0))
                        .and(BS_MODEL.USER_ID.eq(userId));
                long myUploadCount = bsModelMapper.selectCountByQuery(myUploadQuery);
                stats.put("myUploadCount", myUploadCount);
            } else {
                stats.put("myUploadCount", 0);
            }
            
            // 我的收藏数（从收藏服务获取）
            if (userId != null) {
                try {
                    long myCollectCount = collectService.getMyCollectCount();
                    stats.put("myCollectCount", myCollectCount);
                } catch (Exception e) {
                    log.warn("获取收藏数量失败", e);
                    stats.put("myCollectCount", 0);
                }
            } else {
                stats.put("myCollectCount", 0);
            }
            
            // 浏览量：全站总访问次数（成功登录次数）
            long totalVisitCount = siteStatService.getTotalVisitCount();
            stats.put("viewCount", totalVisitCount);
            
            return stats;
        } catch (Exception e) {
            log.error("获取统计信息失败", e);
            // 返回默认值
            stats.put("totalCount", 0);
            stats.put("myUploadCount", 0);
            stats.put("myCollectCount", 0);
            stats.put("viewCount", 0);
            return stats;
        }
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteModel(Long id) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new BusinessException("用户未登录");
        }
        
        // 查询模型
        BsModel model = bsModelMapper.selectOneById(id);
        if (model == null || model.getIsDel() == 1) {
            throw new BusinessException("模型不存在");
        }
        
        // 权限：
        // - 超级管理员可以删除任意模型
        // - 管理员和普通用户只能删除自己的模型
        boolean isSuperAdmin = SecurityUtils.isSuperAdmin();
        if (!isSuperAdmin && !model.getUserId().equals(userId)) {
            throw new BusinessException("无权删除该模型");
        }
        
        // 由于现在同一用户的多个模型共享同一个仓库，这里不再删除整个 Gitea 仓库，
        // 仅对数据库记录做逻辑删除，避免误删其他模型的文件。
        // 如果后续需要精细到按模型文件夹删除，可在模型表中增加文件夹路径字段并在此处实现。
        
        // 删除数据库记录（逻辑删除）
        model.setIsDel(1);
        model.setUpdateTime(LocalDateTime.now());
        bsModelMapper.update(model);

        // 同步逻辑删除该模型的所有收藏记录
        try {
            QueryWrapper collectQuery = QueryWrapper.create()
                    .where(BS_MODEL_COLLECT.MODEL_ID.eq(id))
                    .and(BS_MODEL_COLLECT.IS_DEL.eq(0));
            List<BsModelCollect> collects = bsModelCollectMapper.selectListByQuery(collectQuery);
            if (collects != null && !collects.isEmpty()) {
                for (BsModelCollect collect : collects) {
                    collect.setIsDel(1);
                    bsModelCollectMapper.update(collect);
                }
            }
        } catch (Exception e) {
            // 收藏记录的逻辑删除失败不影响模型删除主流程，只记录日志
            log.warn("删除模型时同步逻辑删除收藏记录失败: modelId={}", id, e);
        }

        // 更新 Gitea 中的 README 文件，添加删除信息
        try {
            // 获取模型文件夹路径
            String modelFolder = extractModelFolderFromCoverUrl(model.getCoverImage(), model.getRepoName());
            if (StrUtil.isBlank(modelFolder)) {
                modelFolder = findModelFolderByNameAndDate(model.getRepoName(), model.getName(), model.getCreateTime());
            }
            if (StrUtil.isBlank(modelFolder)) {
                modelFolder = findModelFolderByName(model.getRepoName(), model.getName());
            }
            
            if (StrUtil.isNotBlank(modelFolder)) {
                String readmePath = modelFolder + "README.md";
                
                // 读取现有的 README 内容
                String existingContent = giteaService.getFileContent(model.getRepoName(), readmePath);
                
                if (StrUtil.isNotBlank(existingContent)) {
                    // 检查是否已经包含删除信息，避免重复添加
                    String deleteNotice = "该模型已被删除";
                    if (!existingContent.contains(deleteNotice)) {
                        // 更新 README，添加删除信息
                        String updatedContent = updateReadmeWithDeleteInfo(existingContent, LocalDateTime.now());
                        
                        // 获取文件的 SHA 值（更新文件需要）
                        String sha = giteaService.getFileSha(model.getRepoName(), readmePath);
                        
                        // 更新文件内容
                        String base64Content = Base64.getEncoder().encodeToString(
                            updatedContent.getBytes(java.nio.charset.StandardCharsets.UTF_8));
                        giteaService.updateFile(model.getRepoName(), readmePath, base64Content, sha, 
                            "标记模型为已删除: " + model.getName());
                        
                        log.info("已更新模型 README 文件，添加删除信息: modelId={}, path={}", id, readmePath);
                    } else {
                        log.info("README 文件已包含删除信息，跳过更新: modelId={}", id);
                    }
                } else {
                    log.warn("无法读取 README 文件内容，跳过更新: modelId={}, path={}", id, readmePath);
                }
            } else {
                log.warn("无法确定模型文件夹路径，跳过更新 README: modelId={}", id);
            }
        } catch (Exception e) {
            // README 更新失败不影响模型删除主流程，只记录日志
            log.warn("删除模型时更新 README 文件失败: modelId={}", id, e);
        }

        log.info("Model deleted successfully: {}", id);
    }

    private void fillAuthorName(BsModel model) {
        if (model.getUserId() != null) {
            SysUser user = sysUserMapper.selectOneById(model.getUserId());
            if (user != null) {
                model.setAuthorName(user.getNickname() != null ? user.getNickname() : user.getUsername());
            }
        }
    }
    
    /**
     * 填充默认封面图片（如果封面图片为空）
     */
    private void fillDefaultCoverImage(BsModel model) {
        if (model != null && (StrUtil.isBlank(model.getCoverImage()))) {
            String defaultCoverUrl = giteaService.getDefaultCoverImageUrl();
            model.setCoverImage(defaultCoverUrl);
        }
    }

    /**
     * 构建标签字符串：合并用户选择的标签 + 根据文件扩展名自动识别的语言标签
     */
    private String buildLabelNames(ModelUploadRequest request) {
        Set<String> tags = new HashSet<>();
        // 用户选择的标签
        if (request.getTags() != null) {
            for (String tag : request.getTags()) {
                if (StrUtil.isNotBlank(tag)) {
                    tags.add(tag.trim());
                }
            }
        }

        // 根据文件扩展名自动识别语言标签
        if (request.getModelFile() != null && StrUtil.isNotBlank(request.getModelFile().getOriginalFilename())) {
            String filename = request.getModelFile().getOriginalFilename().toLowerCase();
            String autoTag = detectLanguageTag(filename);
            if (StrUtil.isNotBlank(autoTag)) {
                tags.add(autoTag);
            }
        }

        if (tags.isEmpty()) {
            return null;
        }
        return String.join(",", tags);
    }

    /**
     * 根据文件名推断语言标签
     */
    private String detectLanguageTag(String filename) {
        if (filename.endsWith(".py")) {
            return "python";
        }
        if (filename.endsWith(".java")) {
            return "java";
        }
        if (filename.endsWith(".jl")) {
            return "julia";
        }
        if (filename.endsWith(".mo")) {
            return "modelica";
        }
        if (filename.endsWith(".m")) {
            return "matlab";
        }
        if (filename.endsWith(".slx") || filename.endsWith(".mdl")) {
            return "simulink";
        }
        if (filename.endsWith(".c") || filename.endsWith(".cpp") || filename.endsWith(".cc")
                || filename.endsWith(".cxx") || filename.endsWith(".h") || filename.endsWith(".hpp")) {
            return "c/c++";
        }
        return null;
    }

    @Override
    public Page<BsModel> pageMyModels(int pageNum, int pageSize, String keyword, Integer isPublic, String tag) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new BusinessException("用户未登录");
        }

        QueryWrapper queryWrapper = QueryWrapper.create()
                .where(BS_MODEL.IS_DEL.eq(0)) // 只查询未删除的记录
                .and(BS_MODEL.USER_ID.eq(userId)) // 只查询当前用户的模型
                .and(BS_MODEL.IS_PUBLIC.eq(isPublic).when(isPublic != null)) // 根据公开状态过滤
                .and(BS_MODEL.NAME.like(keyword).or(BS_MODEL.DESCRIPTION.like(keyword)).when(StrUtil.isNotBlank(keyword)))
                .and(BS_MODEL.ATTR_LABEL_NAMES.like(tag).when(StrUtil.isNotBlank(tag)))
                .orderBy(BS_MODEL.CREATE_TIME.desc());
        
        try {
            Page<BsModel> page = bsModelMapper.paginate(pageNum, pageSize, queryWrapper);
            if (page.getRecords() != null) {
                for (BsModel model : page.getRecords()) {
                    fillAuthorName(model);
                    fillDefaultCoverImage(model);
                }
            }
            return page;
        } catch (Exception e) {
            log.error("分页查询我的模型失败", e);
            throw new BusinessException("查询我的模型列表失败: " + e.getMessage());
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateModelPublic(Long id, Integer isPublic) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new BusinessException("用户未登录");
        }

        BsModel model = bsModelMapper.selectOneById(id);
        if (model == null || model.getIsDel() == 1) {
            throw new BusinessException("模型不存在");
        }

        // 权限：
        // - 管理员/超级管理员可以自由设置自己的模型状态，不需审核
        // - 普通用户只能改自己的模型，且公开需要审核
        boolean isAdmin = SecurityUtils.isAdmin();
        boolean isSuperAdmin = SecurityUtils.isSuperAdmin();

        if (!model.getUserId().equals(userId)) {
            // 非作者：仅当超级管理员时允许修改
            if (!isSuperAdmin) {
                throw new BusinessException("无权修改其他用户的模型");
            }
        }

        model.setIsPublic(isPublic);
        if (isAdmin) {
            // 管理员/超级管理员设置任何状态都直接生效
            model.setStatus(20);
        } else {
            // 普通用户公开需要审核，不公开直接通过
            if (isPublic == 1) {
                model.setStatus(10); // 待审核
            } else {
                model.setStatus(20); // 不公开直接通过
            }
        }
        model.setUpdateTime(LocalDateTime.now());
        bsModelMapper.update(model);
        log.info("更新模型公开状态成功: modelId={}, isPublic={}", id, isPublic);
    }

    @Override
    public Page<BsModel> pagePendingModels(int pageNum, int pageSize, String keyword) {
        com.modelcloud.common.tools.SecurityUtils.requireAdmin();

        QueryWrapper queryWrapper = QueryWrapper.create()
                .where(BS_MODEL.IS_DEL.eq(0))
                .and(BS_MODEL.IS_PUBLIC.eq(1))
                .and(BS_MODEL.STATUS.eq(10)) // 待审核
                .and(BS_MODEL.NAME.like(keyword).or(BS_MODEL.DESCRIPTION.like(keyword)).when(StrUtil.isNotBlank(keyword)))
                .orderBy(BS_MODEL.CREATE_TIME.desc());

        try {
            Page<BsModel> page = bsModelMapper.paginate(pageNum, pageSize, queryWrapper);
            if (page.getRecords() != null) {
                for (BsModel model : page.getRecords()) {
                    fillAuthorName(model);
                    fillDefaultCoverImage(model);
                }
            }
            return page;
        } catch (Exception e) {
            log.error("分页查询待审核模型失败", e);
            throw new BusinessException("查询待审核模型失败: " + e.getMessage());
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void auditModel(Long id, boolean approved) {
        com.modelcloud.common.tools.SecurityUtils.requireAdmin();

        BsModel model = bsModelMapper.selectOneById(id);
        if (model == null || model.getIsDel() == 1) {
            throw new BusinessException("模型不存在");
        }

        if (approved) {
            model.setStatus(20); // 审核通过
            model.setIsPublic(1);
        } else {
            // 审核不通过：不再删除整个 Gitea 仓库，避免影响同一仓库中的其他模型
            model.setStatus(30); // 审核不通过
            model.setIsPublic(0); // 不公开
        }
        model.setUpdateTime(LocalDateTime.now());
        bsModelMapper.update(model);
        log.info("模型审核完成: id={}, approved={}", id, approved);
    }

    @Override
    public List<BsModel> listMyActivities(int limit) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new BusinessException("用户未登录");
        }

        QueryWrapper queryWrapper = QueryWrapper.create()
                .where(BS_MODEL.IS_DEL.eq(0))
                .and(BS_MODEL.USER_ID.eq(userId))
                .and(BS_MODEL.STATUS.eq(30)) // 审核失败
                .orderBy(BS_MODEL.UPDATE_TIME.desc())
                .limit(limit);

        List<BsModel> list = bsModelMapper.selectListByQuery(queryWrapper);
        if (list != null) {
            for (BsModel model : list) {
                fillAuthorName(model);
                fillDefaultCoverImage(model);
            }
        }
        return list;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateModelCover(Long id, org.springframework.web.multipart.MultipartFile coverImage) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new BusinessException("用户未登录");
        }

        BsModel model = bsModelMapper.selectOneById(id);
        if (model == null || model.getIsDel() == 1) {
            throw new BusinessException("模型不存在");
        }

        // 检查权限：只有上传者可以修改
        if (!model.getUserId().equals(userId)) {
            throw new BusinessException("无权修改该模型");
        }

        if (coverImage == null || coverImage.isEmpty()) {
            throw new BusinessException("请上传封面图片");
        }

        // 优先从封面URL提取模型文件夹路径，其次根据模型名称和日期查找，最后根据模型名称查找
        String modelFolder = extractModelFolderFromCoverUrl(model.getCoverImage(), model.getRepoName());
        if (StrUtil.isBlank(modelFolder)) {
            modelFolder = findModelFolderByNameAndDate(model.getRepoName(), model.getName(), model.getCreateTime());
        }
        if (StrUtil.isBlank(modelFolder)) {
            modelFolder = findModelFolderByName(model.getRepoName(), model.getName());
        }
        if (StrUtil.isBlank(modelFolder)) {
            throw new BusinessException("无法确定模型文件夹路径");
        }

        // 上传新的封面图片
        String originalFilename = coverImage.getOriginalFilename();
        String extension = StrUtil.subAfter(originalFilename, ".", true);
        String coverFileName = "cover-" + IdUtil.simpleUUID() + (StrUtil.isNotBlank(extension) ? "." + extension : "");
        String coverFilePath = modelFolder + coverFileName;

        giteaService.uploadFile(model.getRepoName(), coverFilePath, coverImage);
        String newCoverImageUrl = giteaService.getDownloadUrl(model.getRepoName(), coverFilePath);

        // 更新数据库
        model.setCoverImage(newCoverImageUrl);
        model.setUpdateTime(LocalDateTime.now());
        bsModelMapper.update(model);

        log.info("更新模型封面成功: modelId={}", id);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateModelDescription(Long id, String description) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new BusinessException("用户未登录");
        }

        BsModel model = bsModelMapper.selectOneById(id);
        if (model == null || model.getIsDel() == 1) {
            throw new BusinessException("模型不存在");
        }

        // 检查权限：只有上传者可以修改
        if (!model.getUserId().equals(userId)) {
            throw new BusinessException("无权修改该模型");
        }

        // 更新数据库
        model.setDescription(description);
        model.setUpdateTime(LocalDateTime.now());
        bsModelMapper.update(model);

        // 同步更新 Gitea 仓库中的 README.md 的描述部分
        try {
            // 优先从封面URL提取模型文件夹路径，失败则根据模型名称在仓库中扫描
            String modelFolder = extractModelFolderFromCoverUrl(model.getCoverImage(), model.getRepoName());
            log.info("从封面URL提取模型文件夹路径: modelId={}, folder={}", id, modelFolder);
            
            if (StrUtil.isBlank(modelFolder)) {
                log.info("从封面URL未找到文件夹，尝试根据模型名称和日期查找: modelId={}, modelName={}", id, model.getName());
                modelFolder = findModelFolderByNameAndDate(model.getRepoName(), model.getName(), model.getCreateTime());
                log.info("根据模型名称和日期查找到文件夹: modelId={}, folder={}", id, modelFolder);
            }
            if (StrUtil.isBlank(modelFolder)) {
                log.info("根据模型名称和日期未找到文件夹，尝试根据模型名称查找: modelId={}, modelName={}", id, model.getName());
                modelFolder = findModelFolderByName(model.getRepoName(), model.getName());
                log.info("根据模型名称查找到文件夹: modelId={}, folder={}", id, modelFolder);
            }
            
            if (StrUtil.isNotBlank(modelFolder)) {
                String readmePath = modelFolder + "README.md";
                log.info("准备更新 README 文件: modelId={}, path={}", id, readmePath);
                
                String existingContent = giteaService.getFileContent(model.getRepoName(), readmePath);
                log.info("读取 README 文件成功: modelId={}, contentLength={}", id, 
                    existingContent != null ? existingContent.length() : 0);
                
                if (StrUtil.isNotBlank(existingContent)) {
                    // 更新 README 中的描述部分
                    String updatedContent = updateReadmeDescription(existingContent, description);
                    log.info("更新 README 内容完成: modelId={}, originalLength={}, updatedLength={}", 
                        id, existingContent.length(), updatedContent.length());
                    
                    String sha = giteaService.getFileSha(model.getRepoName(), readmePath);
                    log.info("获取 README SHA 成功: modelId={}, sha={}", id, sha);
                    
                    String base64Content = Base64.getEncoder().encodeToString(
                        updatedContent.getBytes(java.nio.charset.StandardCharsets.UTF_8));
                    giteaService.updateFile(model.getRepoName(), readmePath, base64Content, sha,
                        "更新模型描述: " + model.getName());
                    
                    log.info("成功更新 Gitea README 文件: modelId={}, path={}", id, readmePath);
                } else {
                    log.warn("无法读取 README 文件内容为空，跳过更新描述: modelId={}, path={}", id, readmePath);
                }
            } else {
                log.warn("无法确定模型文件夹路径，跳过更新 README: modelId={}, repoName={}, coverImage={}", 
                    id, model.getRepoName(), model.getCoverImage());
            }
        } catch (Exception e) {
            // README 更新失败不影响主流程，但记录详细错误信息
            log.error("更新 Gitea README 描述部分失败，但不影响模型描述更新: modelId={}, error={}", 
                id, e.getMessage(), e);
        }

        log.info("更新模型描述成功并同步 README: modelId={}", id);
    }

    @Override
    public Map<String, String> getModelSourceCode(Long id) {
        BsModel model = bsModelMapper.selectOneById(id);
        if (model == null || model.getIsDel() == 1) {
            throw new BusinessException("模型不存在");
        }

        // 优先从封面URL提取模型文件夹路径，其次根据模型名称和日期查找，最后根据模型名称查找
        String modelFolder = extractModelFolderFromCoverUrl(model.getCoverImage(), model.getRepoName());
        if (StrUtil.isBlank(modelFolder)) {
            modelFolder = findModelFolderByNameAndDate(model.getRepoName(), model.getName(), model.getCreateTime());
        }
        if (StrUtil.isBlank(modelFolder)) {
            modelFolder = findModelFolderByName(model.getRepoName(), model.getName());
        }
        if (StrUtil.isBlank(modelFolder)) {
            throw new BusinessException("无法确定模型文件夹路径");
        }

        // 查找模型文件夹下的模型文件（排除cover和README）
        String modelFilePath = findModelFileInFolder(model.getRepoName(), modelFolder);
        if (StrUtil.isBlank(modelFilePath)) {
            throw new BusinessException("未找到模型文件");
        }

        // 获取文件内容
        String content = giteaService.getFileContent(model.getRepoName(), modelFilePath);
        
        // 提取文件名
        String fileName = modelFilePath.substring(modelFolder.length());
        
        Map<String, String> result = new HashMap<>();
        result.put("content", content);
        result.put("fileName", fileName);
        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateModelSourceCode(Long id, String sourceCode, String fileName) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new BusinessException("用户未登录");
        }

        BsModel model = bsModelMapper.selectOneById(id);
        if (model == null || model.getIsDel() == 1) {
            throw new BusinessException("模型不存在");
        }

        // 检查权限：只有上传者可以修改
        if (!model.getUserId().equals(userId)) {
            throw new BusinessException("无权修改该模型");
        }

        // 优先从封面URL提取模型文件夹路径，其次根据模型名称和日期查找，最后根据模型名称查找
        String modelFolder = extractModelFolderFromCoverUrl(model.getCoverImage(), model.getRepoName());
        if (StrUtil.isBlank(modelFolder)) {
            modelFolder = findModelFolderByNameAndDate(model.getRepoName(), model.getName(), model.getCreateTime());
        }
        if (StrUtil.isBlank(modelFolder)) {
            modelFolder = findModelFolderByName(model.getRepoName(), model.getName());
        }
        if (StrUtil.isBlank(modelFolder)) {
            throw new BusinessException("无法确定模型文件夹路径");
        }

        // 构建文件路径
        String filePath = modelFolder + fileName;

        // 获取文件的sha值（用于更新）
        String sha;
        try {
            sha = giteaService.getFileSha(model.getRepoName(), filePath);
        } catch (BusinessException e) {
            // 如果文件不存在，sha为null表示创建新文件
            sha = null;
        }

        // Base64编码内容
        String base64Content = Base64.getEncoder().encodeToString(sourceCode.getBytes(java.nio.charset.StandardCharsets.UTF_8));

        if (sha != null) {
            // 更新现有文件
            giteaService.updateFile(model.getRepoName(), filePath, base64Content, sha);
        } else {
            // 创建新文件
            giteaService.uploadContent(model.getRepoName(), filePath, sourceCode);
        }

        // 更新数据库更新时间
        model.setUpdateTime(LocalDateTime.now());
        bsModelMapper.update(model);

        log.info("更新模型源码成功: modelId={}, fileName={}", id, fileName);
    }

    /**
     * 从封面图片URL中提取模型文件夹路径
     * URL格式: http://localhost:3000/yangxz/models-username/raw/branch/main/model-0001-20260109/cover-UUID.ext
     * 新格式: model-{ID}-{日期}/
     */
    private String extractModelFolderFromCoverUrl(String coverImageUrl, String repoName) {
        if (StrUtil.isBlank(coverImageUrl)) {
            return null;
        }

        try {
            // 提取路径部分：/yangxz/models-username/raw/branch/main/model-0001-20260109/cover-UUID.ext
            String baseUrl = giteaConfig.getUrl() + "/" + giteaConfig.getUsername() + "/" + repoName + "/raw/branch/main/";
            if (!coverImageUrl.startsWith(baseUrl)) {
                // 尝试master分支
                baseUrl = giteaConfig.getUrl() + "/" + giteaConfig.getUsername() + "/" + repoName + "/raw/branch/master/";
                if (!coverImageUrl.startsWith(baseUrl)) {
                    return null;
                }
            }

            String relativePath = coverImageUrl.substring(baseUrl.length());
            // 提取文件夹路径：model-{ID}-{日期}/
            int lastSlashIndex = relativePath.lastIndexOf('/');
            if (lastSlashIndex > 0) {
                return relativePath.substring(0, lastSlashIndex + 1);
            }
        } catch (Exception e) {
            log.error("提取模型文件夹路径失败", e);
        }
        return null;
    }

    /**
     * 根据模型名称和创建时间查找模型文件夹
     * 文件夹格式：model-{模型名称}-{日期}/
     * 例如：model-ResNet50-20260109/
     */
    private String findModelFolderByNameAndDate(String repoName, String modelName, LocalDateTime createTime) {
        if (StrUtil.isBlank(modelName) || createTime == null) {
            return null;
        }
        
        try {
            // 使用相同的清理逻辑处理模型名称
            String safeModelName = modelName
                .replaceAll("[\\\\/:*?\"<>|]", "_")
                .replaceAll("\\s+", "_")
                .replaceAll("[^\\w\\-]", "_");
            String dateStr = createTime.format(java.time.format.DateTimeFormatter.ofPattern("yyyyMMdd"));
            String expectedFolder = "model-" + safeModelName + "-" + dateStr + "/";
            
            // 验证文件夹是否存在
            try {
                giteaService.listFolderContents(repoName, expectedFolder);
                return expectedFolder;
            } catch (Exception e) {
                log.debug("根据名称和日期构造的文件夹不存在，尝试扫描: {}", expectedFolder);
            }
            
            // 如果构造的文件夹不存在，扫描所有以 model- 开头的文件夹，查找匹配的名称和日期
            java.util.List<cn.hutool.json.JSONObject> rootContents = giteaService.listFolderContents(repoName, "");
            for (cn.hutool.json.JSONObject item : rootContents) {
                String type = item.getStr("type");
                String name = item.getStr("name");
                if (!"dir".equals(type) || name == null || !name.startsWith("model-")) {
                    continue;
                }
                
                // 从文件夹名中提取名称和日期：model-{名称}-{日期}
                // 格式：model-ResNet50-20260109
                if (name.matches("model-.*-\\d{8}")) {
                    String[] parts = name.split("-", 3);
                    if (parts.length >= 3) {
                        String folderName = parts[1];
                        String folderDate = parts[2];
                        // 比较清理后的名称和日期
                        if (folderName.equals(safeModelName) && folderDate.equals(dateStr)) {
                            return name + "/";
                        }
                    }
                }
            }
        } catch (Exception e) {
            log.error("根据模型名称和日期查找文件夹失败: modelName={}, createTime={}", modelName, createTime, e);
        }
        return null;
    }

    /**
     * 查找模型文件夹下的模型文件（排除cover和README）
     */
    private String findModelFileInFolder(String repoName, String modelFolder) {
        try {
            // 列出文件夹内容
            List<cn.hutool.json.JSONObject> contents = giteaService.listFolderContents(repoName, modelFolder);
            
            // 查找模型文件（排除cover和README）
            for (cn.hutool.json.JSONObject item : contents) {
                String name = item.getStr("name");
                String type = item.getStr("type");
                
                // 只处理文件（type为file），排除cover和README
                if ("file".equals(type) && name != null 
                    && !name.startsWith("cover-") 
                    && !name.equals("README.md")) {
                    return modelFolder + name;
                }
            }
        } catch (Exception e) {
            log.error("查找模型文件失败", e);
        }
        
        return null;
    }

    /**
     * 根据模型名称在仓库中查找对应的模型文件夹：
     * - 扫描仓库根目录下所有以 model- 开头的文件夹
     * - 读取每个文件夹下的 README.md，如果包含 \"# 模型名\" 或模型名字符串，则认为匹配
     */
    private String findModelFolderByName(String repoName, String modelName) {
        try {
            // 列出仓库根目录内容
            java.util.List<cn.hutool.json.JSONObject> rootContents = giteaService.listFolderContents(repoName, "");
            for (cn.hutool.json.JSONObject item : rootContents) {
                String type = item.getStr("type");
                String name = item.getStr("name");
                if (!"dir".equals(type) || name == null) {
                    continue;
                }
                if (!name.startsWith("model-")) {
                    continue;
                }
                String folder = name + "/";
                String readmePath = folder + "README.md";
                try {
                    String readme = giteaService.getFileContent(repoName, readmePath);
                    if (readme != null) {
                        // 简单匹配：README 中包含模型名称，或包含以 # 开头的标题行
                        if (readme.contains(modelName) || readme.contains("# " + modelName)) {
                            return folder;
                        }
                    }
                } catch (BusinessException e) {
                    // 该文件夹下没有 README，跳过
                    log.debug("文件夹 {} 下未找到 README.md，跳过", folder);
                }
            }
        } catch (Exception e) {
            log.error("根据模型名称查找模型文件夹失败", e);
        }
        return null;
    }

    /**
     * 更新 README 中的模型描述部分
     * README 结构：
     * # 模型名称
     * ## 基本信息
     * ## 模型描述
     * ## 删除信息（可选）
     */
    private String updateReadmeDescription(String readmeContent, String newDescription) {
        if (StrUtil.isBlank(readmeContent)) {
            return readmeContent;
        }

        StringBuilder result = new StringBuilder();
        String[] lines = readmeContent.split("\n", -1); // 使用 -1 保留空行
        boolean descriptionSectionFound = false;
        boolean deleteSectionFound = false;
        int descriptionStartIndex = -1;
        int descriptionEndIndex = -1;

        // 第一遍扫描：找到描述部分的开始和结束位置
        for (int i = 0; i < lines.length; i++) {
            String line = lines[i];
            if (line.trim().equals("## 模型描述")) {
                descriptionSectionFound = true;
                descriptionStartIndex = i;
                // 继续查找描述部分的结束位置（下一个二级标题或文件结束）
                for (int j = i + 1; j < lines.length; j++) {
                    String nextLine = lines[j];
                    if (nextLine.trim().startsWith("##")) {
                        descriptionEndIndex = j;
                        break;
                    }
                }
                if (descriptionEndIndex == -1) {
                    descriptionEndIndex = lines.length;
                }
                break;
            }
            if (line.trim().startsWith("## 删除信息")) {
                deleteSectionFound = true;
            }
        }

        // 第二遍扫描：构建新的 README 内容
        if (descriptionSectionFound) {
            // 如果找到了描述部分，替换它
            for (int i = 0; i < lines.length; i++) {
                if (i == descriptionStartIndex) {
                    // 添加描述标题
                    result.append("## 模型描述\n\n");
                    // 添加新的描述内容
                    result.append(StrUtil.isNotBlank(newDescription) ? newDescription : "暂无描述").append("\n\n");
                    // 跳过旧的描述内容
                    i = descriptionEndIndex - 1;
                } else {
                    result.append(lines[i]);
                    if (i < lines.length - 1) {
                        result.append("\n");
                    }
                }
            }
        } else {
            // 如果没有找到描述部分，在基本信息后添加
            boolean inserted = false;
            int basicInfoEndIndex = -1;
            
            // 先找到基本信息部分的结束位置
            for (int i = 0; i < lines.length; i++) {
                String line = lines[i];
                if (line.trim().equals("## 基本信息")) {
                    // 找到基本信息部分的结束位置（下一个二级标题之前）
                    for (int j = i + 1; j < lines.length; j++) {
                        String nextLine = lines[j];
                        if (nextLine.trim().startsWith("##")) {
                            basicInfoEndIndex = j;
                            break;
                        }
                    }
                    if (basicInfoEndIndex == -1) {
                        basicInfoEndIndex = lines.length;
                    }
                    break;
                }
            }
            
            // 构建新的内容
            for (int i = 0; i < lines.length; i++) {
                result.append(lines[i]);
                if (i < lines.length - 1) {
                    result.append("\n");
                }
                
                // 在基本信息部分结束后插入描述部分
                if (!inserted && basicInfoEndIndex != -1 && i == basicInfoEndIndex - 1) {
                    result.append("\n## 模型描述\n\n");
                    result.append(StrUtil.isNotBlank(newDescription) ? newDescription : "暂无描述").append("\n\n");
                    inserted = true;
                }
            }
            
            // 如果基本信息部分也没找到，在文件末尾添加
            if (!inserted) {
                result.append("\n## 模型描述\n\n");
                result.append(StrUtil.isNotBlank(newDescription) ? newDescription : "暂无描述").append("\n");
            }
        }

        return result.toString();
    }

    /**
     * 在 README 中添加删除信息
     * 如果已存在删除信息部分，则更新删除时间；否则添加新的删除信息部分
     */
    private String updateReadmeWithDeleteInfo(String readmeContent, LocalDateTime deleteTime) {
        if (StrUtil.isBlank(readmeContent)) {
            return readmeContent;
        }

        StringBuilder result = new StringBuilder();
        String[] lines = readmeContent.split("\n");
        boolean deleteSectionFound = false;
        boolean inDeleteSection = false;

        for (int i = 0; i < lines.length; i++) {
            String line = lines[i];
            
            // 检查是否进入删除信息部分
            if (line.trim().startsWith("## 删除信息")) {
                deleteSectionFound = true;
                inDeleteSection = true;
                result.append("## 删除信息\n\n");
                result.append("**⚠️ 该模型已被删除！**\n\n");
                result.append("- 删除时间：").append(deleteTime).append("\n");
                // 跳过旧的删除信息内容，直到下一个二级标题或文件结束
                i++;
                while (i < lines.length) {
                    String nextLine = lines[i];
                    if (nextLine.trim().startsWith("##")) {
                        // 遇到下一个二级标题，回退一步，让外层循环处理
                        i--;
                        break;
                    }
                    i++;
                }
                continue;
            }
            
            // 如果不在删除部分，正常添加行
            if (!inDeleteSection) {
                result.append(line).append("\n");
            }
        }

        // 如果没有找到删除信息部分，在文件末尾添加
        if (!deleteSectionFound) {
            result.append("\n## 删除信息\n\n");
            result.append("**⚠️ 该模型已被删除！**\n\n");
            result.append("- 删除时间：").append(deleteTime).append("\n");
        }

        return result.toString();
    }
}
