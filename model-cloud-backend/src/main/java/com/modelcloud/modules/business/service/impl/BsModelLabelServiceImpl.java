package com.modelcloud.modules.business.service.impl;

import com.modelcloud.modules.business.mapper.BsModelLabelMapper;
import com.modelcloud.modules.business.model.domain.BsModelLabel;
import com.modelcloud.modules.business.service.BsModelLabelService;
import com.mybatisflex.core.query.QueryWrapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

import static com.modelcloud.modules.business.model.domain.table.BsModelLabelTableDef.BS_MODEL_LABEL;

/**
 * 模型标签服务实现类
 * 
 * @author model-cloud
 */
@Slf4j
@Service
public class BsModelLabelServiceImpl implements BsModelLabelService {

    private final BsModelLabelMapper bsModelLabelMapper;

    public BsModelLabelServiceImpl(BsModelLabelMapper bsModelLabelMapper) {
        this.bsModelLabelMapper = bsModelLabelMapper;
    }

    @Override
    public List<BsModelLabel> getAllLabels() {
        QueryWrapper queryWrapper = QueryWrapper.create()
                .where(BS_MODEL_LABEL.IS_DEL.eq(0))
                .orderBy(BS_MODEL_LABEL.SORT.asc(), BS_MODEL_LABEL.ID.asc());
        return bsModelLabelMapper.selectListByQuery(queryWrapper);
    }
}

