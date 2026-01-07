package com.modelcloud.modules.business.service.impl;

import com.modelcloud.common.exception.BusinessException;
import com.modelcloud.common.tools.SecurityUtils;
import com.modelcloud.modules.business.mapper.BsModelCollectMapper;
import com.modelcloud.modules.business.mapper.BsModelMapper;
import com.modelcloud.modules.business.model.domain.BsModel;
import com.modelcloud.modules.business.model.domain.BsModelCollect;
import com.modelcloud.modules.business.service.BsModelCollectService;
import com.modelcloud.modules.business.service.BsModelService;
import com.modelcloud.modules.business.service.GiteaService;
import com.modelcloud.modules.sys.mapper.SysUserMapper;
import cn.hutool.core.util.StrUtil;
import com.modelcloud.modules.sys.model.domain.SysUser;
import com.mybatisflex.core.paginate.Page;
import com.mybatisflex.core.query.QueryWrapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import static com.modelcloud.modules.business.model.domain.table.BsModelCollectTableDef.BS_MODEL_COLLECT;
import static com.modelcloud.modules.business.model.domain.table.BsModelTableDef.BS_MODEL;

/**
 * 模型收藏服务实现类
 * 
 * @author model-cloud
 */
@Slf4j
@Service
public class BsModelCollectServiceImpl implements BsModelCollectService {
    
    private final BsModelCollectMapper collectMapper;
    private final BsModelMapper modelMapper;
    private final SysUserMapper userMapper;
    private final GiteaService giteaService;
    
    public BsModelCollectServiceImpl(
            BsModelCollectMapper collectMapper,
            BsModelMapper modelMapper,
            SysUserMapper userMapper,
            GiteaService giteaService) {
        this.collectMapper = collectMapper;
        this.modelMapper = modelMapper;
        this.userMapper = userMapper;
        this.giteaService = giteaService;
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void collectModel(Long modelId) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new BusinessException("用户未登录");
        }
        
        // 检查模型是否存在
        BsModel model = modelMapper.selectOneById(modelId);
        if (model == null || model.getIsDel() == 1) {
            throw new BusinessException("模型不存在");
        }
        
        // 检查是否已收藏
        QueryWrapper queryWrapper = QueryWrapper.create()
                .where(BS_MODEL_COLLECT.USER_ID.eq(userId))
                .and(BS_MODEL_COLLECT.MODEL_ID.eq(modelId))
                .and(BS_MODEL_COLLECT.IS_DEL.eq(0));
        BsModelCollect existCollect = collectMapper.selectOneByQuery(queryWrapper);
        
        if (existCollect != null) {
            throw new BusinessException("已收藏该模型");
        }
        
        // 创建收藏记录
        BsModelCollect collect = new BsModelCollect();
        collect.setUserId(userId);
        collect.setModelId(modelId);
        collect.setIsDel(0);
        collect.setCreateTime(LocalDateTime.now());
        
        collectMapper.insert(collect);
        log.info("用户 {} 收藏了模型 {}", userId, modelId);
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void uncollectModel(Long modelId) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new BusinessException("用户未登录");
        }
        
        // 查找收藏记录
        QueryWrapper queryWrapper = QueryWrapper.create()
                .where(BS_MODEL_COLLECT.USER_ID.eq(userId))
                .and(BS_MODEL_COLLECT.MODEL_ID.eq(modelId))
                .and(BS_MODEL_COLLECT.IS_DEL.eq(0));
        BsModelCollect collect = collectMapper.selectOneByQuery(queryWrapper);
        
        if (collect == null) {
            throw new BusinessException("未收藏该模型");
        }
        
        // 逻辑删除
        collect.setIsDel(1);
        collectMapper.update(collect);
        log.info("用户 {} 取消收藏了模型 {}", userId, modelId);
    }
    
    @Override
    public boolean isCollected(Long modelId) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            return false;
        }
        
        QueryWrapper queryWrapper = QueryWrapper.create()
                .where(BS_MODEL_COLLECT.USER_ID.eq(userId))
                .and(BS_MODEL_COLLECT.MODEL_ID.eq(modelId))
                .and(BS_MODEL_COLLECT.IS_DEL.eq(0));
        
        BsModelCollect collect = collectMapper.selectOneByQuery(queryWrapper);
        return collect != null;
    }
    
    @Override
    public Page<BsModel> getMyCollectModels(int pageNum, int pageSize, String keyword, String tag) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new BusinessException("用户未登录");
        }
        
        // 先查询收藏的模型ID列表
        QueryWrapper collectQuery = QueryWrapper.create()
                .select(BS_MODEL_COLLECT.MODEL_ID)
                .where(BS_MODEL_COLLECT.USER_ID.eq(userId))
                .and(BS_MODEL_COLLECT.IS_DEL.eq(0));
        
        List<BsModelCollect> collects = collectMapper.selectListByQuery(collectQuery);
        if (collects.isEmpty()) {
            return new Page<>(pageNum, pageSize, 0);
        }
        
        List<Long> modelIds = collects.stream()
                .map(BsModelCollect::getModelId)
                .collect(Collectors.toList());
        
        // 查询模型列表
        QueryWrapper modelQuery = QueryWrapper.create()
                .where(BS_MODEL.ID.in(modelIds))
                .and(BS_MODEL.IS_DEL.eq(0))
                .and(BS_MODEL.NAME.like(keyword).or(BS_MODEL.DESCRIPTION.like(keyword)).when(cn.hutool.core.util.StrUtil.isNotBlank(keyword)))
                .and(BS_MODEL.ATTR_LABEL_NAMES.like(tag).when(cn.hutool.core.util.StrUtil.isNotBlank(tag)))
                .orderBy(BS_MODEL.CREATE_TIME.desc());
        
        Page<BsModel> page = modelMapper.paginate(pageNum, pageSize, modelQuery);
        
        // 填充作者名称和默认封面
        if (page.getRecords() != null) {
            for (BsModel model : page.getRecords()) {
                fillAuthorName(model);
                fillDefaultCoverImage(model);
            }
        }
        
        return page;
    }
    
    @Override
    public long getMyCollectCount() {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            return 0;
        }
        
        // 先查询用户收藏的模型ID列表（收藏记录未删除）
        QueryWrapper collectQuery = QueryWrapper.create()
                .select(BS_MODEL_COLLECT.MODEL_ID)
                .where(BS_MODEL_COLLECT.USER_ID.eq(userId))
                .and(BS_MODEL_COLLECT.IS_DEL.eq(0));
        
        List<BsModelCollect> collects = collectMapper.selectListByQuery(collectQuery);
        if (collects.isEmpty()) {
            return 0;
        }
        
        List<Long> modelIds = collects.stream()
                .map(BsModelCollect::getModelId)
                .collect(Collectors.toList());
        
        // 查询这些模型ID中，哪些模型未删除
        QueryWrapper modelQuery = QueryWrapper.create()
                .where(BS_MODEL.ID.in(modelIds))
                .and(BS_MODEL.IS_DEL.eq(0));
        
        return modelMapper.selectCountByQuery(modelQuery);
    }
    
    private void fillAuthorName(BsModel model) {
        if (model.getUserId() != null) {
            SysUser user = userMapper.selectOneById(model.getUserId());
            if (user != null) {
                model.setAuthorName(user.getNickname());
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
}

