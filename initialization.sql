-- ===================================================================
-- 模型管理系统数据库初始化脚本
-- 数据库: model_cloud
-- 字符集: utf8mb4
-- 用途: 服务器端MySQL数据库完整初始化
-- 说明: 此脚本仅用于初始化数据库结构，不包含业务数据
-- ===================================================================

-- 1. 创建数据库
CREATE DATABASE IF NOT EXISTS `model_cloud` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `model_cloud`;

-- ===================================================================
-- 2. 创建基础表（无外键依赖的表）
-- ===================================================================

-- 2.1 系统用户表
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

-- 2.2 系统角色表
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

-- 2.4 标签分类表
CREATE TABLE IF NOT EXISTS `model_label_category` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `name` VARCHAR(50) NOT NULL COMMENT '分类名称',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='模型标签分类表';


-- ===================================================================
-- 3. 创建关联表（有外键依赖的表）
-- ===================================================================

-- 3.1 用户角色关联表
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


-- 3.3 模型标签表
CREATE TABLE IF NOT EXISTS `bs_model_label` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '标签ID',
  `name` VARCHAR(50) NOT NULL COMMENT '标签名称',
  `description` VARCHAR(255) DEFAULT NULL COMMENT '描述',
  `sort` INT DEFAULT 0 COMMENT '排序',
  `category_id` BIGINT DEFAULT NULL COMMENT '分类ID（外键，指向model_label_category）',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_del` INT DEFAULT 0 COMMENT '是否删除：0未删除，1已删除',
  PRIMARY KEY (`id`),
  KEY `idx_is_del` (`is_del`),
  KEY `idx_category_id` (`category_id`),
  CONSTRAINT `fk_label_category` FOREIGN KEY (`category_id`) REFERENCES `model_label_category` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='模型标签表';

-- ===================================================================
-- 4. 创建业务表（有外键依赖的表）
-- ===================================================================

-- 4.1 模型表
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
  KEY `idx_is_del` (`is_del`),
  CONSTRAINT `fk_model_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='模型表';

-- 4.2 模型收藏表
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

-- 4.3 站点统计表（记录每次登录访问）
CREATE TABLE IF NOT EXISTS `sys_site_stat` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `user_id` BIGINT NOT NULL COMMENT '登录用户ID',
  `login_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '登录时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_login_time` (`login_time`),
  CONSTRAINT `fk_site_stat_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='站点统计表（记录每次登录访问）';

-- ===================================================================
-- 5. 插入基础数据（系统必需的基础数据）
-- ===================================================================

-- 5.1 插入默认角色
INSERT INTO `sys_role` (`role_name`, `role_code`, `description`, `status`, `is_del`) VALUES
('超级管理员', 'super_admin', '超级管理员，拥有所有权限', 1, 0),
('管理员', 'admin', '管理员，可以管理用户和模型', 1, 0),
('普通用户', 'user', '普通用户，可以上传和管理自己的模型', 1, 0)
ON DUPLICATE KEY UPDATE `role_name`=`role_name`;

INSERT INTO `sys_user` (`username`, `password`, `nickname`, `email`, `status`, `is_del`) 
VALUES ('admin', '$2a$10$n/ohGNTsJHLlQz6pi7fINu5pkrY78voa7Rmi.upuheLITNHvzgo.q', '超级管理员', 'yangxz1100@163.com', 1, 0)
ON DUPLICATE KEY UPDATE `username`=`username`;

INSERT INTO `sys_user_role` (`user_id`, `role_id`, `create_time`)
SELECT u.id, r.id, NOW()
FROM `sys_user` u, `sys_role` r
WHERE u.username = 'admin' AND r.role_code = 'super_admin'
ON DUPLICATE KEY UPDATE `user_id`=`user_id`;

-- 5.2 插入标签分类
INSERT INTO `model_label_category` (`name`) VALUES
('语言类型'),
('用途')
ON DUPLICATE KEY UPDATE `name`=`name`;

-- 5.3 插入模型标签（语言类型）
INSERT INTO `bs_model_label` (`name`, `description`, `sort`, `category_id`) VALUES
('python', 'Python语言模型', 1, (SELECT `id` FROM `model_label_category` WHERE `name` = '语言类型' LIMIT 1)),
('java', 'Java语言模型', 2, (SELECT `id` FROM `model_label_category` WHERE `name` = '语言类型' LIMIT 1)),
('c/c++', 'C/C++语言模型', 3, (SELECT `id` FROM `model_label_category` WHERE `name` = '语言类型' LIMIT 1)),
('julia', 'Julia语言模型', 4, (SELECT `id` FROM `model_label_category` WHERE `name` = '语言类型' LIMIT 1)),
('matlab', 'MATLAB语言模型', 5, (SELECT `id` FROM `model_label_category` WHERE `name` = '语言类型' LIMIT 1)),
('simulink', 'Simulink模型', 6, (SELECT `id` FROM `model_label_category` WHERE `name` = '语言类型' LIMIT 1)),
('modelica', 'Modelica语言模型', 7, (SELECT `id` FROM `model_label_category` WHERE `name` = '语言类型' LIMIT 1))
ON DUPLICATE KEY UPDATE `name`=VALUES(`name`), `description`=VALUES(`description`), `sort`=VALUES(`sort`), `category_id`=VALUES(`category_id`);

-- 5.4 插入模型标签（用途）
INSERT INTO `bs_model_label` (`name`, `description`, `sort`, `category_id`) VALUES
('建模', '建模相关', 8, (SELECT `id` FROM `model_label_category` WHERE `name` = '用途' LIMIT 1)),
('仿真', '仿真相关', 9, (SELECT `id` FROM `model_label_category` WHERE `name` = '用途' LIMIT 1)),
('控制', '控制相关', 10, (SELECT `id` FROM `model_label_category` WHERE `name` = '用途' LIMIT 1)),
('优化', '优化相关', 11, (SELECT `id` FROM `model_label_category` WHERE `name` = '用途' LIMIT 1)),
('机器学习', '机器学习相关', 12, (SELECT `id` FROM `model_label_category` WHERE `name` = '用途' LIMIT 1)),
('深度学习', '深度学习相关', 13, (SELECT `id` FROM `model_label_category` WHERE `name` = '用途' LIMIT 1))
ON DUPLICATE KEY UPDATE `name`=VALUES(`name`), `description`=VALUES(`description`), `sort`=VALUES(`sort`), `category_id`=VALUES(`category_id`);


-- 5.5 设置重要记录不可删除

DELIMITER //  -- 临时修改语句结束符为 //，避免触发器内的 ; 提前终止语句

CREATE TRIGGER trg_sys_role_forbid_delete
BEFORE DELETE ON sys_role  -- 在 sys_role 表执行 DELETE 前触发
FOR EACH ROW  -- 对每一行待删除记录生效
BEGIN
    -- 抛出错误，终止删除操作（错误码 45000 是自定义非保留错误码，提示信息可自定义）
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = '禁止删除 sys_role 表中的记录！该表数据不允许删除';
END //

CREATE TRIGGER trg_bs_model_label_forbid_delete
BEFORE DELETE ON bs_model_label  -- 在 bs_model_label 表执行 DELETE 前触发
FOR EACH ROW  -- 对每一行待删除记录生效
BEGIN
    -- 抛出错误，终止删除操作（错误码 45000 是自定义非保留错误码，提示信息可自定义）
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = '禁止删除 bs_model_label 表中的记录！该表数据不允许删除';
END //

CREATE TRIGGER trg_sys_user_forbid_admin_delete
BEFORE DELETE ON sys_user  -- 在 sys_user 表执行 DELETE 操作前触发
FOR EACH ROW  -- 对每一条待删除的记录生效
BEGIN
    -- 核心逻辑：判断待删除记录的 username 是否为 'admin'，若是则抛出错误阻断删除
    IF OLD.username = 'admin' THEN
        SIGNAL SQLSTATE '45000'  -- 自定义异常错误码（45000 为通用用户自定义码）
        SET MESSAGE_TEXT = '禁止删除 username 为 admin 的记录！该账号为系统核心账号，不允许删除';
    END IF;
END //

CREATE TRIGGER trg_sys_user_role_forbid_admin_delete
BEFORE DELETE ON sys_user_role  -- 在sys_user_role表执行DELETE前触发
FOR EACH ROW  -- 对每一条待删除的记录生效
BEGIN
    -- 定义变量存储匹配到的username（默认值为空）
    DECLARE admin_username VARCHAR(50) DEFAULT '';
    
    -- 核心逻辑：通过待删除记录的user_id，查询sys_user表对应的username
    SELECT username INTO admin_username
    FROM sys_user
    WHERE sys_user.id = OLD.user_id  -- OLD.user_id是sys_user_role待删记录的user_id
    LIMIT 1;  -- 确保只查一条，避免多行返回报错
    
    -- 判断：如果查询到的username是admin，则抛出错误阻断删除
    IF admin_username = 'admin' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '禁止删除系统管理员（admin）的角色关联记录！';
    END IF;
END //


-- 恢复 MySQL 默认的语句结束符为 ;
DELIMITER ;


-- ===================================================================
-- 6. 初始化完成提示
-- ===================================================================

SELECT '数据库初始化完成！' AS message;
SELECT '已创建以下表：' AS info;
SELECT '  - sys_user (系统用户表)' AS tables;
SELECT '  - sys_role (系统角色表)' AS tables;
SELECT '  - sys_user_role (用户角色关联表)' AS tables;
SELECT '  - model_label_category (标签分类表)' AS tables;
SELECT '  - bs_model_label (模型标签表)' AS tables;
SELECT '  - bs_model (模型表)' AS tables;
SELECT '  - bs_model_collect (模型收藏表)' AS tables;
SELECT '  - sys_site_stat (站点统计表)' AS tables;

-- ===================================================================
-- 6. 创建数据库触发器
-- 当用户或模型的 is_del 被设置为 1 时，自动将 bs_model_collect 中相应记录的 is_del 也设置为 1
-- ===================================================================

-- 删除已存在的触发器（如果存在）
DROP TRIGGER IF EXISTS `trg_user_delete_collect`;
DROP TRIGGER IF EXISTS `trg_model_delete_collect`;

-- 创建用户删除触发器
DELIMITER $$

CREATE TRIGGER `trg_user_delete_collect`
AFTER UPDATE ON `sys_user`
FOR EACH ROW
BEGIN
    -- 检查 is_del 是否从 0 变为 1
    IF OLD.is_del = 0 AND NEW.is_del = 1 THEN
        -- 更新该用户的所有收藏记录（只更新 is_del=0 的记录，避免重复更新）
        UPDATE `bs_model_collect`
        SET `is_del` = 1
        WHERE `user_id` = NEW.id
          AND `is_del` = 0;
    END IF;
END$$

DELIMITER ;

-- 创建模型删除触发器
DELIMITER $$

CREATE TRIGGER `trg_model_delete_collect`
AFTER UPDATE ON `bs_model`
FOR EACH ROW
BEGIN
    -- 检查 is_del 是否从 0 变为 1
    IF OLD.is_del = 0 AND NEW.is_del = 1 THEN
        -- 更新该模型的所有收藏记录（只更新 is_del=0 的记录，避免重复更新）
        UPDATE `bs_model_collect`
        SET `is_del` = 1
        WHERE `model_id` = NEW.id
          AND `is_del` = 0;
    END IF;
END$$

DELIMITER ;

SELECT '已插入基础数据：' AS info;
SELECT '  - 3个系统角色（超级管理员、管理员、普通用户）' AS data;
SELECT '  - 2个标签分类（语言类型、用途）' AS data;
SELECT '  - 13个模型标签' AS data;
SELECT '已创建触发器：' AS info;
SELECT '  - trg_user_delete_collect (用户删除时自动删除收藏记录)' AS triggers;
SELECT '  - trg_model_delete_collect (模型删除时自动删除收藏记录)' AS triggers;

