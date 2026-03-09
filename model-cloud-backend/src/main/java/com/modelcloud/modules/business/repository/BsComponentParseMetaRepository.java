package com.modelcloud.modules.business.repository;

import com.modelcloud.modules.business.model.domain.BsComponentParseMeta;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface BsComponentParseMetaRepository extends MongoRepository<BsComponentParseMeta, String> {
}
