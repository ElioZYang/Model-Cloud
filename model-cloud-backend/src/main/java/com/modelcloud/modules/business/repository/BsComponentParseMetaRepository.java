package com.modelcloud.modules.business.repository;

import com.modelcloud.modules.business.model.domain.BsComponentParseMeta;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;

public interface BsComponentParseMetaRepository extends MongoRepository<BsComponentParseMeta, String> {
    Optional<BsComponentParseMeta> findByComponentId(Long componentId);
}
