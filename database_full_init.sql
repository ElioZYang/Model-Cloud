-- ===================================================================
-- model-cloud 全量数据库初始化脚本（MySQL 8+）
-- 目标：一次执行后可满足当前项目运行所需的 MySQL 表结构与基础数据
-- ===================================================================

CREATE DATABASE IF NOT EXISTS `model_cloud` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `model_cloud`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -------------------------------------------------------------------
-- 1) 系统表
-- -------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `sys_user` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` VARCHAR(50) NOT NULL COMMENT '用户名',
  `password` VARCHAR(255) NOT NULL COMMENT '密码（加密）',
  `nickname` VARCHAR(50) DEFAULT NULL COMMENT '昵称',
  `email` VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
  `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号',
  `avatar` VARCHAR(255) DEFAULT NULL COMMENT '头像',
  `status` INT DEFAULT 1 COMMENT '状态：0禁用，1启用',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_del` INT DEFAULT 0 COMMENT '是否删除：0未删除，1已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_email` (`email`),
  KEY `idx_status` (`status`),
  KEY `idx_is_del` (`is_del`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统用户表';

CREATE TABLE IF NOT EXISTS `sys_role` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` VARCHAR(50) NOT NULL COMMENT '角色名称',
  `role_code` VARCHAR(50) NOT NULL COMMENT '角色编码',
  `description` VARCHAR(255) DEFAULT NULL COMMENT '描述',
  `status` INT DEFAULT 1 COMMENT '状态：0禁用，1启用',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_del` INT DEFAULT 0 COMMENT '是否删除：0未删除，1已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_code` (`role_code`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统角色表';

CREATE TABLE IF NOT EXISTS `sys_user_role` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `role_id` BIGINT NOT NULL COMMENT '角色ID',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_role` (`user_id`, `role_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_role_id` (`role_id`),
  CONSTRAINT `fk_user_role_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_user_role_role` FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户角色关联表';

CREATE TABLE IF NOT EXISTS `sys_site_stat` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `user_id` BIGINT NOT NULL COMMENT '登录用户ID',
  `login_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '登录时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_login_time` (`login_time`),
  CONSTRAINT `fk_site_stat_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='站点统计表';

CREATE TABLE IF NOT EXISTS `sys_power` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `power_name` VARCHAR(100) DEFAULT NULL,
  `power_code` VARCHAR(100) DEFAULT NULL,
  `path` VARCHAR(255) DEFAULT NULL,
  `method` VARCHAR(20) DEFAULT NULL,
  `parent_id` BIGINT DEFAULT NULL,
  `sort` INT DEFAULT 0,
  `description` VARCHAR(255) DEFAULT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_del` INT DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_parent_id` (`parent_id`),
  KEY `idx_power_code` (`power_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统权限表';

CREATE TABLE IF NOT EXISTS `sys_file` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `file_name` VARCHAR(255) DEFAULT NULL,
  `original_name` VARCHAR(255) DEFAULT NULL,
  `file_path` VARCHAR(1024) DEFAULT NULL,
  `file_type` VARCHAR(100) DEFAULT NULL,
  `file_size` BIGINT DEFAULT NULL,
  `upload_user` VARCHAR(100) DEFAULT NULL,
  `upload_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `is_del` INT DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_upload_user` (`upload_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统文件表';

-- -------------------------------------------------------------------
-- 2) 标签与模型主表
-- -------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `model_label_category` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `name` VARCHAR(50) NOT NULL COMMENT '分类名称',
  `sort` INT DEFAULT 0 COMMENT '排序',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='模型标签分类表';

CREATE TABLE IF NOT EXISTS `bs_model_label` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '标签ID',
  `name` VARCHAR(50) NOT NULL COMMENT '标签名称',
  `description` VARCHAR(255) DEFAULT NULL COMMENT '描述',
  `sort` INT DEFAULT 0 COMMENT '排序',
  `category_id` BIGINT DEFAULT NULL COMMENT '分类ID',
  `is_del` INT DEFAULT 0 COMMENT '是否删除：0未删除，1已删除',
  PRIMARY KEY (`id`),
  KEY `idx_is_del` (`is_del`),
  KEY `idx_category_id` (`category_id`),
  CONSTRAINT `fk_label_category` FOREIGN KEY (`category_id`) REFERENCES `model_label_category` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='模型标签表';

CREATE TABLE IF NOT EXISTS `bs_model` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '模型ID',
  `name` VARCHAR(200) NOT NULL COMMENT '模型名称',
  `user_id` BIGINT NOT NULL COMMENT '用户ID（作者）',
  `attr_type` VARCHAR(50) DEFAULT NULL COMMENT '模型属性-类型（历史字段）',
  `attr_protocol` VARCHAR(50) DEFAULT NULL COMMENT '模型属性-共享协议',
  `attr_billing_method` VARCHAR(50) DEFAULT NULL COMMENT '模型属性-计费方式',
  `attr_build_tool` VARCHAR(50) DEFAULT NULL COMMENT '模型属性-构建工具',
  `attr_format` VARCHAR(50) DEFAULT NULL COMMENT '模型属性-格式',
  `attr_label_ids` VARCHAR(500) DEFAULT NULL COMMENT '模型标签编号集合',
  `attr_label_names` VARCHAR(500) DEFAULT NULL COMMENT '模型标签名称集合',
  `attr_dependency_lib` VARCHAR(500) DEFAULT NULL COMMENT '模型属性-依赖库',
  `attr_params_number` VARCHAR(50) DEFAULT NULL COMMENT '模型属性-参数规模',
  `description` TEXT DEFAULT NULL COMMENT '模型描述',
  `use_description` TEXT DEFAULT NULL COMMENT '模型使用说明',
  `dimension` BIGINT DEFAULT NULL COMMENT '模型维数',
  `status` INT DEFAULT 0 COMMENT '模型状态',
  `is_public` INT DEFAULT 0 COMMENT '是否公开',
  `repo_name` VARCHAR(255) DEFAULT NULL COMMENT 'Gitea仓库名称',
  `repo_url` VARCHAR(500) DEFAULT NULL COMMENT 'Gitea仓库链接',
  `cover_image` VARCHAR(500) DEFAULT NULL COMMENT '封面图片链接',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_del` INT DEFAULT 0 COMMENT '是否删除',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_is_public` (`is_public`),
  KEY `idx_is_del` (`is_del`),
  KEY `idx_bs_model_attr_type` (`attr_type`),
  CONSTRAINT `fk_model_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='模型表';

CREATE TABLE IF NOT EXISTS `bs_model_collect` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `model_id` BIGINT NOT NULL COMMENT '模型ID',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `is_del` INT DEFAULT 0 COMMENT '是否删除：0未删除，1已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_model` (`user_id`, `model_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_model_id` (`model_id`),
  CONSTRAINT `fk_collect_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_collect_model` FOREIGN KEY (`model_id`) REFERENCES `bs_model` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='模型收藏表';

-- -------------------------------------------------------------------
-- 3) 组件与部署仿真相关
-- -------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `bs_component` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` VARCHAR(255) NOT NULL COMMENT '组件名称',
  `class_name` VARCHAR(512) DEFAULT NULL COMMENT '完整类名',
  `description` TEXT DEFAULT NULL COMMENT '组件描述',
  `index_path` VARCHAR(512) DEFAULT NULL COMMENT '组件索引路径',
  `repo_name` VARCHAR(128) DEFAULT NULL COMMENT '历史字段（兼容）',
  `source_path` VARCHAR(1024) NOT NULL COMMENT '源码相对路径',
  `icon_path` VARCHAR(1024) DEFAULT NULL COMMENT '图标相对路径',
  `cover_image` VARCHAR(1024) DEFAULT NULL COMMENT '封面图URL',
  `user_id` BIGINT DEFAULT NULL COMMENT '创建者用户ID',
  `is_del` TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_bs_component_name` (`name`),
  KEY `idx_bs_component_class_name` (`class_name`),
  KEY `idx_bs_component_index_path` (`index_path`),
  KEY `idx_bs_component_is_del` (`is_del`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='基础组件表';

CREATE TABLE IF NOT EXISTS `bs_modeling_project` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '项目ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `name` VARCHAR(200) NOT NULL COMMENT '项目名称',
  `description` TEXT DEFAULT NULL COMMENT '项目描述',
  `project_data` JSON NOT NULL COMMENT '项目数据',
  `modelica_code` TEXT DEFAULT NULL COMMENT '生成的Modelica代码',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_del` INT DEFAULT 0 COMMENT '是否删除',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_is_del` (`is_del`),
  KEY `idx_create_time` (`create_time`),
  CONSTRAINT `fk_modeling_project_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='建模项目表';

CREATE TABLE IF NOT EXISTS `bs_simulation_task` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `project_id` BIGINT DEFAULT NULL COMMENT '关联项目ID',
  `task_id` VARCHAR(100) NOT NULL COMMENT '仿真任务唯一ID',
  `model_code` TEXT NOT NULL COMMENT '模型代码',
  `simulation_params` JSON NOT NULL COMMENT '仿真参数',
  `status` VARCHAR(50) NOT NULL DEFAULT 'pending' COMMENT '任务状态',
  `progress` INT DEFAULT 0 COMMENT '进度',
  `result_file_url` VARCHAR(500) DEFAULT NULL COMMENT '结果文件URL',
  `result_data` JSON DEFAULT NULL COMMENT '结果数据',
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

-- -------------------------------------------------------------------
-- 4) 基础数据
-- -------------------------------------------------------------------

INSERT INTO `sys_role` (`role_name`, `role_code`, `description`, `status`, `is_del`) VALUES
('超级管理员', 'super_admin', '超级管理员，拥有所有权限', 1, 0),
('管理员', 'admin', '管理员，可以管理用户和模型', 1, 0),
('普通用户', 'user', '普通用户，可以上传和管理自己的模型', 1, 0)
ON DUPLICATE KEY UPDATE `role_name`=`role_name`;

INSERT INTO `sys_user` (`username`, `password`, `nickname`, `email`, `status`, `is_del`) VALUES
('admin', '$2a$10$n/ohGNTsJHLlQz6pi7fINu5pkrY78voa7Rmi.upuheLITNHvzgo.q', '超级管理员', 'yangxz1100@163.com', 1, 0)
ON DUPLICATE KEY UPDATE `username`=`username`;

INSERT INTO `sys_user_role` (`user_id`, `role_id`, `create_time`)
SELECT u.id, r.id, NOW()
FROM `sys_user` u, `sys_role` r
WHERE u.username = 'admin' AND r.role_code = 'super_admin'
ON DUPLICATE KEY UPDATE `user_id`=`user_id`;

DELETE FROM `bs_model_label`;
DELETE FROM `model_label_category`;

INSERT INTO `model_label_category` (`id`, `name`, `sort`) VALUES
(1, '处理器', 1),
(2, '文件格式', 2),
(3, '仿真领域', 3),
(4, '主要功能', 4),
(5, '操作系统', 5),
(6, '软件依赖', 6),
(7, '编程语言', 7)
ON DUPLICATE KEY UPDATE `name`=`name`, `sort`=VALUES(`sort`);

INSERT INTO `bs_model_label` (`name`, `category_id`, `is_del`) VALUES
('CPU', 1, 0), ('GPU', 1, 0),
('FMU', 2, 0), ('M', 2, 0), ('INP', 2, 0),
('动力性能', 3, 0), ('结构安全', 3, 0), ('热管理', 3, 0), ('电控系统', 3, 0),
('建模', 4, 0), ('分析仿真', 4, 0), ('后处理', 4, 0),
('Windows', 5, 0), ('CentOS', 5, 0), ('Ubuntu', 5, 0),
('OpenModelica', 6, 0), ('Matlab/Simulink', 6, 0), ('Ansys', 6, 0), ('AutoCAD', 6, 0), ('Fluent', 6, 0),
('C', 7, 0), ('Modelica', 7, 0), ('Matlab', 7, 0), ('Python', 7, 0);

-- -------------------------------------------------------------------
-- 5) 触发器（与当前项目逻辑保持一致）
-- -------------------------------------------------------------------

DROP TRIGGER IF EXISTS `trg_user_delete_collect`;
DROP TRIGGER IF EXISTS `trg_model_delete_collect`;
DROP TRIGGER IF EXISTS `trg_sys_role_forbid_delete`;
DROP TRIGGER IF EXISTS `trg_bs_model_label_forbid_delete`;
DROP TRIGGER IF EXISTS `trg_sys_user_forbid_admin_delete`;
DROP TRIGGER IF EXISTS `trg_sys_user_role_forbid_admin_delete`;

DELIMITER $$

CREATE TRIGGER `trg_user_delete_collect`
AFTER UPDATE ON `sys_user`
FOR EACH ROW
BEGIN
  IF OLD.is_del = 0 AND NEW.is_del = 1 THEN
    UPDATE `bs_model_collect`
    SET `is_del` = 1
    WHERE `user_id` = NEW.id
      AND `is_del` = 0;
  END IF;
END$$

CREATE TRIGGER `trg_model_delete_collect`
AFTER UPDATE ON `bs_model`
FOR EACH ROW
BEGIN
  IF OLD.is_del = 0 AND NEW.is_del = 1 THEN
    UPDATE `bs_model_collect`
    SET `is_del` = 1
    WHERE `model_id` = NEW.id
      AND `is_del` = 0;
  END IF;
END$$

CREATE TRIGGER `trg_sys_role_forbid_delete`
BEFORE DELETE ON `sys_role`
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '禁止删除 sys_role 表中的记录';
END$$

CREATE TRIGGER `trg_bs_model_label_forbid_delete`
BEFORE DELETE ON `bs_model_label`
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '禁止删除 bs_model_label 表中的记录';
END$$

CREATE TRIGGER `trg_sys_user_forbid_admin_delete`
BEFORE DELETE ON `sys_user`
FOR EACH ROW
BEGIN
  IF OLD.username = 'admin' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '禁止删除 admin 账号';
  END IF;
END$$

CREATE TRIGGER `trg_sys_user_role_forbid_admin_delete`
BEFORE DELETE ON `sys_user_role`
FOR EACH ROW
BEGIN
  DECLARE admin_username VARCHAR(50) DEFAULT '';
  SELECT username INTO admin_username FROM sys_user WHERE id = OLD.user_id LIMIT 1;
  IF admin_username = 'admin' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '禁止删除 admin 的角色关联';
  END IF;
END$$

DELIMITER ;

SET FOREIGN_KEY_CHECKS = 1;

SELECT 'database_full_init.sql 执行完成' AS message;
