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
import java.util.List;
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

    public BsModelServiceImpl(BsModelMapper bsModelMapper, GiteaService giteaService, SysUserMapper sysUserMapper) {
        this.bsModelMapper = bsModelMapper;
        this.giteaService = giteaService;
        this.sysUserMapper = sysUserMapper;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public BsModel uploadModel(ModelUploadRequest request) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new BusinessException("用户未登录");
        }

        // 1. 生成仓库名称 (使用UUID避免冲突)
        String repoName = "model-" + IdUtil.simpleUUID();
        
        // 2. 创建Gitea仓库
        giteaService.createRepository(repoName, request.getDescription());

        // 3. 上传模型文件
        if (request.getModelFile() != null && !request.getModelFile().isEmpty()) {
            giteaService.uploadFile(repoName, request.getModelFile().getOriginalFilename(), request.getModelFile());
        }

        // 4. 上传封面图片
        String coverImageUrl = null;
        if (request.getCoverImage() != null && !request.getCoverImage().isEmpty()) {
            String coverFileName = "cover-" + IdUtil.simpleUUID() + "-" + request.getCoverImage().getOriginalFilename();
            giteaService.uploadFile(repoName, coverFileName, request.getCoverImage());
            coverImageUrl = giteaService.getDownloadUrl(repoName, coverFileName);
        }

        // 5. 保存元数据到数据库
        BsModel model = new BsModel();
        model.setName(request.getName());
        model.setDescription(request.getDescription());
        model.setUserId(userId);
        model.setRepoName(repoName);
        // 使用存档下载链接作为 repoUrl，方便前端直接下载
        model.setRepoUrl(giteaService.getArchiveUrl(repoName));
        model.setCoverImage(coverImageUrl);
        model.setStatus(10); // 待审核
        model.setIsPublic(1); // 默认公开
        model.setCreateTime(LocalDateTime.now());
        model.setUpdateTime(LocalDateTime.now());
        model.setIsDel(0);

        // 处理标签
        if (request.getTags() != null && !request.getTags().isEmpty()) {
            model.setAttrLabelNames(String.join(",", request.getTags()));
        }

        bsModelMapper.insert(model);
        return model;
    }

    @Override
    public Page<BsModel> pageModels(int pageNum, int pageSize, String keyword) {
        QueryWrapper queryWrapper = QueryWrapper.create()
                .where(BS_MODEL.IS_DEL.eq(0))
                .and(BS_MODEL.NAME.like(keyword).or(BS_MODEL.DESCRIPTION.like(keyword)))
                .orderBy(BS_MODEL.CREATE_TIME.desc());
        
        Page<BsModel> page = bsModelMapper.paginate(pageNum, pageSize, queryWrapper);
        if (page.getRecords() != null) {
            for (BsModel model : page.getRecords()) {
                fillAuthorName(model);
            }
        }
        return page;
    }

    @Override
    public BsModel getModelDetail(Long id) {
        BsModel model = bsModelMapper.selectOneById(id);
        if (model == null || model.getIsDel() == 1) {
            throw new BusinessException("模型不存在");
        }
        fillAuthorName(model);
        return model;
    }

    private void fillAuthorName(BsModel model) {
        if (model.getUserId() != null) {
            SysUser user = sysUserMapper.selectOneById(model.getUserId());
            if (user != null) {
                model.setAuthorName(user.getNickname());
            }
        }
    }
}
