-- ===================================================================
-- 模型部署功能数据库脚本
-- 数据库: model_cloud
-- 用途: 创建建模项目和仿真任务相关表
-- 说明: 请在执行前备份数据库
-- ===================================================================

USE `model_cloud`;

-- ===================================================================
-- 1. 创建建模项目表
-- ===================================================================
CREATE TABLE IF NOT EXISTS `bs_modeling_project` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '项目ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `name` VARCHAR(200) NOT NULL COMMENT '项目名称',
  `description` TEXT DEFAULT NULL COMMENT '项目描述',
  `project_data` JSON NOT NULL COMMENT '项目数据（节点、连线等JSON格式）',
  `modelica_code` TEXT DEFAULT NULL COMMENT '生成的Modelica代码',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_del` INT DEFAULT 0 COMMENT '是否删除：0未删除，1已删除',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_is_del` (`is_del`),
  KEY `idx_create_time` (`create_time`),
  CONSTRAINT `fk_modeling_project_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='建模项目表';

-- ===================================================================
-- 2. 创建仿真任务表
-- ===================================================================
CREATE TABLE IF NOT EXISTS `bs_simulation_task` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `project_id` BIGINT DEFAULT NULL COMMENT '关联的建模项目ID（可为空，支持直接提交模型代码）',
  `task_id` VARCHAR(100) NOT NULL COMMENT '仿真服务返回的任务ID（唯一）',
  `model_code` TEXT NOT NULL COMMENT 'Modelica模型代码',
  `simulation_params` JSON NOT NULL COMMENT '仿真参数（JSON格式）',
  `status` VARCHAR(50) NOT NULL DEFAULT 'pending' COMMENT '任务状态：pending/running/completed/failed/cancelled',
  `progress` INT DEFAULT 0 COMMENT '进度百分比（0-100）',
  `result_file_url` VARCHAR(500) DEFAULT NULL COMMENT '结果文件URL',
  `result_data` JSON DEFAULT NULL COMMENT '结果数据（JSON格式，用于快速预览）',
  `error_message` TEXT DEFAULT NULL COMMENT '错误信息',
  `start_time` DATETIME DEFAULT NULL COMMENT '开始时间',
  `end_time` DATETIME DEFAULT NULL COMMENT '结束时间',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_task_id` (`task_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_project_id` (`project_id`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`),
  CONSTRAINT `fk_simulation_task_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_simulation_task_project` FOREIGN KEY (`project_id`) REFERENCES `bs_modeling_project` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='仿真任务表';

-- ===================================================================
-- 3. 创建组件元数据缓存表（可选，用于缓存组件解析结果）
-- ===================================================================
CREATE TABLE IF NOT EXISTS `bs_component_metadata` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `model_id` BIGINT NOT NULL COMMENT '关联的模型ID',
  `component_name` VARCHAR(200) NOT NULL COMMENT '组件名称（从.mo文件解析）',
  `component_type` VARCHAR(100) DEFAULT NULL COMMENT '组件类型（如Resistor、VoltageSource等）',
  `parameters` JSON DEFAULT NULL COMMENT '参数定义（JSON格式）',
  `ports` JSON DEFAULT NULL COMMENT '端口定义（JSON格式，包含输入输出端口）',
  `source_code` TEXT DEFAULT NULL COMMENT '组件源码（.mo文件内容）',
  `metadata_version` INT DEFAULT 1 COMMENT '元数据版本（用于缓存失效）',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_model_component` (`model_id`, `component_name`),
  KEY `idx_component_type` (`component_type`),
  KEY `idx_model_id` (`model_id`),
  CONSTRAINT `fk_component_metadata_model` FOREIGN KEY (`model_id`) REFERENCES `bs_model` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='组件元数据缓存表';

-- ===================================================================
-- 4. 插入完成提示
-- ===================================================================
SELECT '数据库表创建完成！' AS message;
SELECT '已创建以下表：' AS info;
SELECT '  - bs_modeling_project (建模项目表)' AS tables;
SELECT '  - bs_simulation_task (仿真任务表)' AS tables;
SELECT '  - bs_component_metadata (组件元数据缓存表)' AS tables;

