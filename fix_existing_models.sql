-- 修复已上传但 is_del 为 NULL 的模型记录
-- 将所有 is_del 为 NULL 的记录设置为 0（未删除）

USE model_cloud;

-- 更新 is_del 为 NULL 的记录
UPDATE bs_model 
SET is_del = 0 
WHERE is_del IS NULL;

-- 查看更新结果
SELECT id, name, is_del, create_time 
FROM bs_model 
ORDER BY create_time DESC;

