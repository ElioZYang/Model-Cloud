-- 模型管理系统数据库初始化脚本
-- 数据库: model_cloud
-- 字符集: utf8mb4

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS `model_cloud` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `model_cloud`;

-- 系统用户表
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

-- 系统角色表
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

-- 系统权限表
CREATE TABLE IF NOT EXISTS `sys_power` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '权限ID',
  `power_name` VARCHAR(50) NOT NULL COMMENT '权限名称',
  `power_code` VARCHAR(100) NOT NULL COMMENT '权限编码',
  `path` VARCHAR(255) DEFAULT NULL COMMENT '路径',
  `method` VARCHAR(10) DEFAULT NULL COMMENT '请求方法',
  `parent_id` BIGINT DEFAULT 0 COMMENT '父权限ID',
  `sort` INT DEFAULT 0 COMMENT '排序',
  `description` VARCHAR(255) DEFAULT NULL COMMENT '描述',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_del` INT DEFAULT 0 COMMENT '是否删除：0未删除，1已删除',
  PRIMARY KEY (`id`),
  KEY `idx_parent_id` (`parent_id`),
  KEY `idx_power_code` (`power_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统权限表';

-- 用户角色关联表
CREATE TABLE IF NOT EXISTS `sys_user_role` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `role_id` BIGINT NOT NULL COMMENT '角色ID',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_role` (`user_id`, `role_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_role_id` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户角色关联表';

-- 角色权限关联表
CREATE TABLE IF NOT EXISTS `sys_role_power` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `role_id` BIGINT NOT NULL COMMENT '角色ID',
  `power_id` BIGINT NOT NULL COMMENT '权限ID',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_power` (`role_id`, `power_id`),
  KEY `idx_role_id` (`role_id`),
  KEY `idx_power_id` (`power_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色权限关联表';

-- 模型表
CREATE TABLE IF NOT EXISTS `bs_model` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '模型ID',
  `name` VARCHAR(200) NOT NULL COMMENT '模型名称',
  `user_id` BIGINT NOT NULL COMMENT '用户ID（作者）',
  `attr_type` VARCHAR(50) DEFAULT NULL COMMENT '模型属性-类型',
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
  `dimension` BIGINT DEFAULT NULL COMMENT '模型维数：1,2,3',
  `status` INT DEFAULT 0 COMMENT '模型状态：0初始状态，10待审状态，20审核通过，30审核不通过',
  `is_public` INT DEFAULT 0 COMMENT '是否公开：0不公开，1公开',
  `repo_name` VARCHAR(255) DEFAULT NULL COMMENT 'Gitea仓库名称',
  `repo_url` VARCHAR(500) DEFAULT NULL COMMENT 'Gitea仓库链接',
  `cover_image` VARCHAR(500) DEFAULT NULL COMMENT '封面图片链接',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_del` INT DEFAULT 0 COMMENT '是否删除：0未删除，1已删除',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_is_public` (`is_public`),
  KEY `idx_is_del` (`is_del`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='模型表';

-- 模型标签表
CREATE TABLE IF NOT EXISTS `bs_model_label` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '标签ID',
  `name` VARCHAR(50) NOT NULL COMMENT '标签名称',
  `description` VARCHAR(255) DEFAULT NULL COMMENT '描述',
  `sort` INT DEFAULT 0 COMMENT '排序',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_del` INT DEFAULT 0 COMMENT '是否删除：0未删除，1已删除',
  PRIMARY KEY (`id`),
  KEY `idx_is_del` (`is_del`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='模型标签表';

-- 模型收藏表
CREATE TABLE IF NOT EXISTS `bs_model_collect` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `model_id` BIGINT NOT NULL COMMENT '模型ID',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `is_del` INT DEFAULT 0 COMMENT '是否删除：0未删除，1已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_model` (`user_id`, `model_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_model_id` (`model_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='模型收藏表';

-- 系统文件表
CREATE TABLE IF NOT EXISTS `sys_file` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '文件ID',
  `file_name` VARCHAR(255) NOT NULL COMMENT '文件名',
  `original_name` VARCHAR(255) NOT NULL COMMENT '原始文件名',
  `file_path` VARCHAR(500) NOT NULL COMMENT '文件路径',
  `file_type` VARCHAR(50) DEFAULT NULL COMMENT '文件类型',
  `file_size` BIGINT DEFAULT NULL COMMENT '文件大小（字节）',
  `upload_user` VARCHAR(50) DEFAULT NULL COMMENT '上传用户',
  `upload_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
  `is_del` INT DEFAULT 0 COMMENT '是否删除：0未删除，1已删除',
  PRIMARY KEY (`id`),
  KEY `idx_upload_user` (`upload_user`),
  KEY `idx_is_del` (`is_del`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统文件表';

-- 插入默认管理员用户（密码：admin123）
-- 注意：实际使用时请修改密码
INSERT INTO `sys_user` (`username`, `password`, `nickname`, `email`, `status`, `is_del`) 
VALUES ('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iwy8pL5O', '管理员', 'admin@modelcloud.com', 1, 0)
ON DUPLICATE KEY UPDATE `username`=`username`;

-- 插入默认模型标签
INSERT INTO `bs_model_label` (`name`, `description`, `sort`) VALUES
('python', 'Python语言相关模型', 1),
('modelica', 'Modelica语言模型', 2),
('fmi', 'FMI标准模型', 3),
('simulink', 'Simulink模型', 4),
('matlab', 'MATLAB相关模型', 5),
('c++', 'C++语言模型', 6),
('java', 'Java语言模型', 7),
('深度学习', '深度学习模型', 8),
('机器学习', '机器学习模型', 9),
('仿真', '仿真模型', 10),
('优化', '优化算法模型', 11),
('控制', '控制系统模型', 12)
ON DUPLICATE KEY UPDATE `name`=`name`;



