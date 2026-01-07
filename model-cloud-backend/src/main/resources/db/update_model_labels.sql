-- 更新标签分类与默认标签（独立执行，不依赖 init.sql 重跑）
-- 作用：
-- 1) 新建标签分类表 model_label_category（若不存在）
-- 2) 在 bs_model_label 增加 category_id 外键
-- 3) 重置默认分类与标签数据
-- 使用前请先备份数据，执行环境：MySQL 8+

-- 1. 创建标签分类表（若不存在）
CREATE TABLE IF NOT EXISTS `model_label_category` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `name` VARCHAR(50) NOT NULL COMMENT '分类名称',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='模型标签分类表';

-- 2. 在 bs_model_label 上增加 category_id 列与外键（存在则跳过）
-- 2.1 增加列
SET @col_exists := (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'bs_model_label'
      AND column_name = 'category_id'
);
SET @sql := IF(@col_exists = 0,
    'ALTER TABLE `bs_model_label` ADD COLUMN `category_id` BIGINT DEFAULT NULL COMMENT ''分类ID（外键，指向model_label_category）''',
    'DO 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 2.2 增加索引
SET @idx_exists := (
    SELECT COUNT(*) FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = 'bs_model_label'
      AND index_name = 'idx_category_id'
);
SET @sql := IF(@idx_exists = 0,
    'ALTER TABLE `bs_model_label` ADD INDEX `idx_category_id`(`category_id`)',
    'DO 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 2.3 增加外键（若不存在）
SET @fk_exists := (
    SELECT COUNT(*) FROM information_schema.table_constraints
    WHERE table_schema = DATABASE()
      AND table_name = 'bs_model_label'
      AND constraint_type = 'FOREIGN KEY'
      AND constraint_name = 'fk_label_category'
);
SET @sql := IF(@fk_exists = 0,
    'ALTER TABLE `bs_model_label` ADD CONSTRAINT `fk_label_category` FOREIGN KEY (`category_id`) REFERENCES `model_label_category`(`id`)',
    'DO 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 3. 重置默认分类与标签数据
DELETE FROM `bs_model_label`;
DELETE FROM `model_label_category`;

INSERT INTO `model_label_category` (`name`) VALUES
('语言类型'),
('用途');

-- 语言类型 (category_id = 1)
INSERT INTO `bs_model_label` (`name`, `description`, `sort`, `category_id`) VALUES
('python', 'Python语言模型', 1, 1),
('java', 'Java语言模型', 2, 1),
('c/c++', 'C/C++语言模型', 3, 1),
('julia', 'Julia语言模型', 4, 1),
('matlab', 'MATLAB语言模型', 5, 1),
('simulink', 'Simulink模型', 6, 1),
('modelica', 'Modelica语言模型', 7, 1);

-- 用途 (category_id = 2)
INSERT INTO `bs_model_label` (`name`, `description`, `sort`, `category_id`) VALUES
('建模', '建模相关', 8, 2),
('仿真', '仿真相关', 9, 2),
('控制', '控制相关', 10, 2),
('优化', '优化相关', 11, 2),
('机器学习', '机器学习相关', 12, 2),
('深度学习', '深度学习相关', 13, 2);

