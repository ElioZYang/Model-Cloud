package com.modelcloud.modules.business.service.impl;

import cn.hutool.core.util.IdUtil;
import cn.hutool.core.util.StrUtil;
import com.modelcloud.common.exception.BusinessException;
import com.modelcloud.common.tools.SecurityUtils;
import com.modelcloud.modules.business.mapper.BsModelMapper;
import com.modelcloud.modules.business.model.domain.BsModel;
import com.modelcloud.modules.business.model.request.ModelUploadRequest;
import com.modelcloud.modules.business.service.BsModelService;
import com.modelcloud.modules.business.service.GiteaService;
import com.modelcloud.modules.sys.mapper.SysUserMapper;
import com.modelcloud.modules.sys.model.domain.SysUser;
import com.mybatisflex.core.paginate.Page;
import com.mybatisflex.core.query.QueryWrapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import static com.modelcloud.modules.business.model.domain.table.BsModelTableDef.BS_MODEL;

/**
 * 模型服务实现类
 * 
 * @author model-cloud
 */
@Slf4j
@Service
public class BsModelServiceImpl implements BsModelService {

    private final BsModelMapper bsModelMapper;
    private final GiteaService giteaService;
    private final SysUserMapper sysUserMapper;
    private final com.modelcloud.modules.business.service.BsModelCollectService collectService;

    public BsModelServiceImpl(
            BsModelMapper bsModelMapper, 
            GiteaService giteaService, 
            SysUserMapper sysUserMapper,
            com.modelcloud.modules.business.service.BsModelCollectService collectService) {
        this.bsModelMapper = bsModelMapper;
        this.giteaService = giteaService;
        this.sysUserMapper = sysUserMapper;
        this.collectService = collectService;
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

        // 3. 为本次上传的模型生成独立文件夹
        String modelFolder = "model-" + IdUtil.simpleUUID() + "/";

        // 4. 上传模型文件到该文件夹
        if (request.getModelFile() != null && !request.getModelFile().isEmpty()) {
            String modelFileName = request.getModelFile().getOriginalFilename();
            String modelFilePath = modelFolder + modelFileName;
            log.info("Uploading model file: {} to repo: {}, path: {}", modelFileName, repoName, modelFilePath);
            giteaService.uploadFile(repoName, modelFilePath, request.getModelFile());
        } else {
            throw new BusinessException("请上传模型文件");
        }

        // 5. 上传封面图片（同样放在模型文件夹下）
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

        // 6. 生成 README 文件，放在模型文件夹中
        try {
            StringBuilder readme = new StringBuilder();
            readme.append("# ").append(request.getName()).append("\n\n");
            if (StrUtil.isNotBlank(request.getDescription())) {
                readme.append("## 模型描述\n\n").append(request.getDescription()).append("\n\n");
            }
            readme.append("## 基本信息\n\n");
            readme.append("- 作者：").append(displayName).append("\n");
            readme.append("- 上传时间：").append(LocalDateTime.now()).append("\n");
            if (request.getTags() != null && !request.getTags().isEmpty()) {
                readme.append("- 标签：").append(String.join(", ", request.getTags())).append("\n");
            }

            String readmePath = modelFolder + "README.md";
            giteaService.uploadContent(repoName, readmePath, readme.toString());
        } catch (Exception e) {
            // README 生成失败不影响主流程，记录日志即可
            log.warn("生成或上传README失败，但不影响模型上传主流程", e);
        }

        // 7. 保存元数据到数据库
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
        model.setCreateTime(LocalDateTime.now());
        model.setUpdateTime(LocalDateTime.now());

        // 处理标签
        if (request.getTags() != null && !request.getTags().isEmpty()) {
            model.setAttrLabelNames(String.join(",", request.getTags()));
        }

        bsModelMapper.insert(model);
        log.info("Model uploaded and saved successfully: {}", model.getId());
        return model;
    }

    @Override
    public Page<BsModel> pageModels(int pageNum, int pageSize, String keyword) {
        QueryWrapper queryWrapper = QueryWrapper.create()
                .where(BS_MODEL.IS_DEL.eq(0)) // 只查询未删除的记录
                .and(BS_MODEL.IS_PUBLIC.eq(1)) // 只显示公开的模型
                .and(BS_MODEL.STATUS.eq(20)) // 只显示审核通过的模型
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
            
            // 浏览量（暂时返回0，后续可以扩展）
            stats.put("viewCount", 0);
            
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

    @Override
    public Page<BsModel> pageMyModels(int pageNum, int pageSize, String keyword, Integer isPublic) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new BusinessException("用户未登录");
        }

        QueryWrapper queryWrapper = QueryWrapper.create()
                .where(BS_MODEL.IS_DEL.eq(0)) // 只查询未删除的记录
                .and(BS_MODEL.USER_ID.eq(userId)) // 只查询当前用户的模型
                .and(BS_MODEL.IS_PUBLIC.eq(isPublic).when(isPublic != null)) // 根据公开状态过滤
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
}
