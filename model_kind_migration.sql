-- 将历史数据迁移为“模型 / 基础组件”双类型
-- 执行前请先备份数据库

USE `model_cloud`;

-- 1) 先把历史空值统一为模型（避免影响公开模型/我的模型/收藏列表）
UPDATE `bs_model`
SET `attr_type` = 'model'
WHERE (`attr_type` IS NULL OR `attr_type` = '')
  AND `is_del` = 0;

-- 2) 将需要作为“基础组件”的记录改为 component（请按实际ID替换）
-- 示例：
-- UPDATE `bs_model`
-- SET `attr_type` = 'component', `is_public` = 0, `status` = 20
-- WHERE `id` IN (101, 102, 103);

-- 3) 可选：为类型字段加索引，提升部署页组件查询性能
-- MySQL 8 推荐先判断是否存在同名索引后再执行
CREATE INDEX `idx_bs_model_attr_type` ON `bs_model` (`attr_type`);
