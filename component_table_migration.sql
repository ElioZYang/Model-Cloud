-- 模型/组件分表迁移脚本
-- 目的：
-- 1) 组件从 bs_model 拆分到 bs_component
-- 2) 后续 bs_model 只存“模型”，不再依赖 attr_type 区分

USE `model_cloud`;

-- 1. 创建组件表
CREATE TABLE IF NOT EXISTS `bs_component` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(255) NOT NULL COMMENT '组件名称',
  `class_name` varchar(512) DEFAULT NULL COMMENT '完整类名，如 Modelica.Electrical.Analog.Basic.Resistor',
  `description` text COMMENT '组件描述',
  `index_path` varchar(512) DEFAULT NULL COMMENT '组件索引路径，如 Modelica/Electrical/Analog/Basic',
  `repo_name` varchar(128) NOT NULL COMMENT 'Gitea仓库名',
  `source_path` varchar(1024) NOT NULL COMMENT '源码在仓库中的相对路径',
  `icon_path` varchar(1024) DEFAULT NULL COMMENT '图标在仓库中的相对路径',
  `cover_image` varchar(1024) DEFAULT NULL COMMENT '图标/封面可访问URL',
  `user_id` bigint DEFAULT NULL COMMENT '创建者用户ID',
  `is_del` tinyint NOT NULL DEFAULT '0' COMMENT '逻辑删除 0否 1是',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_bs_component_name` (`name`),
  KEY `idx_bs_component_class_name` (`class_name`),
  KEY `idx_bs_component_index_path` (`index_path`),
  KEY `idx_bs_component_is_del` (`is_del`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='基础组件表';

-- 2. 将历史“组件”数据从 bs_model 迁移到 bs_component（若历史使用 attr_type=component）
-- 注意：以下迁移仅做通用路径推断，迁移后建议抽查 class_name/index_path 的准确性。
INSERT INTO `bs_component` (
  `name`, `class_name`, `description`, `index_path`, `repo_name`,
  `source_path`, `icon_path`, `cover_image`, `user_id`, `is_del`, `create_time`, `update_time`
)
SELECT
  m.`name`,
  CONCAT(
    REPLACE(
      IF(
        LEFT(
          REPLACE(
            SUBSTRING_INDEX(
              REPLACE(
                CASE
                  WHEN m.`repo_url` LIKE '%/raw/branch/main/%' THEN SUBSTRING_INDEX(m.`repo_url`, '/raw/branch/main/', -1)
                  WHEN m.`repo_url` LIKE '%/raw/branch/master/%' THEN SUBSTRING_INDEX(m.`repo_url`, '/raw/branch/master/', -1)
                  ELSE m.`repo_url`
                END,
                'component-library/source/', ''
              ),
              '/',
              (LENGTH(
                REPLACE(
                  CASE
                    WHEN m.`repo_url` LIKE '%/raw/branch/main/%' THEN SUBSTRING_INDEX(m.`repo_url`, '/raw/branch/main/', -1)
                    WHEN m.`repo_url` LIKE '%/raw/branch/master/%' THEN SUBSTRING_INDEX(m.`repo_url`, '/raw/branch/master/', -1)
                    ELSE m.`repo_url`
                  END,
                  'component-library/source/', ''
                )
              ) - LENGTH(REPLACE(
                REPLACE(
                  CASE
                    WHEN m.`repo_url` LIKE '%/raw/branch/main/%' THEN SUBSTRING_INDEX(m.`repo_url`, '/raw/branch/main/', -1)
                    WHEN m.`repo_url` LIKE '%/raw/branch/master/%' THEN SUBSTRING_INDEX(m.`repo_url`, '/raw/branch/master/', -1)
                    ELSE m.`repo_url`
                  END,
                  'component-library/source/', ''
                ),
                '/',
                ''
              )))
            ),
            '/',
            '.'
          ),
          9
        ) = 'Modelica.',
        REPLACE(
          SUBSTRING_INDEX(
            REPLACE(
              CASE
                WHEN m.`repo_url` LIKE '%/raw/branch/main/%' THEN SUBSTRING_INDEX(m.`repo_url`, '/raw/branch/main/', -1)
                WHEN m.`repo_url` LIKE '%/raw/branch/master/%' THEN SUBSTRING_INDEX(m.`repo_url`, '/raw/branch/master/', -1)
                ELSE m.`repo_url`
              END,
              'component-library/source/', ''
            ),
            '/',
            (LENGTH(
              REPLACE(
                CASE
                  WHEN m.`repo_url` LIKE '%/raw/branch/main/%' THEN SUBSTRING_INDEX(m.`repo_url`, '/raw/branch/main/', -1)
                  WHEN m.`repo_url` LIKE '%/raw/branch/master/%' THEN SUBSTRING_INDEX(m.`repo_url`, '/raw/branch/master/', -1)
                  ELSE m.`repo_url`
                END,
                'component-library/source/', ''
              )
            ) - LENGTH(REPLACE(
              REPLACE(
                CASE
                  WHEN m.`repo_url` LIKE '%/raw/branch/main/%' THEN SUBSTRING_INDEX(m.`repo_url`, '/raw/branch/main/', -1)
                  WHEN m.`repo_url` LIKE '%/raw/branch/master/%' THEN SUBSTRING_INDEX(m.`repo_url`, '/raw/branch/master/', -1)
                  ELSE m.`repo_url`
                END,
                'component-library/source/', ''
              ),
              '/',
              ''
            )))
          ),
          '/',
          '.'
        ),
        CONCAT(
          'Modelica.',
          REPLACE(
            SUBSTRING_INDEX(
              REPLACE(
                CASE
                  WHEN m.`repo_url` LIKE '%/raw/branch/main/%' THEN SUBSTRING_INDEX(m.`repo_url`, '/raw/branch/main/', -1)
                  WHEN m.`repo_url` LIKE '%/raw/branch/master/%' THEN SUBSTRING_INDEX(m.`repo_url`, '/raw/branch/master/', -1)
                  ELSE m.`repo_url`
                END,
                'component-library/source/', ''
              ),
              '/',
              (LENGTH(
                REPLACE(
                  CASE
                    WHEN m.`repo_url` LIKE '%/raw/branch/main/%' THEN SUBSTRING_INDEX(m.`repo_url`, '/raw/branch/main/', -1)
                    WHEN m.`repo_url` LIKE '%/raw/branch/master/%' THEN SUBSTRING_INDEX(m.`repo_url`, '/raw/branch/master/', -1)
                    ELSE m.`repo_url`
                  END,
                  'component-library/source/', ''
                )
              ) - LENGTH(REPLACE(
                REPLACE(
                  CASE
                    WHEN m.`repo_url` LIKE '%/raw/branch/main/%' THEN SUBSTRING_INDEX(m.`repo_url`, '/raw/branch/main/', -1)
                    WHEN m.`repo_url` LIKE '%/raw/branch/master/%' THEN SUBSTRING_INDEX(m.`repo_url`, '/raw/branch/master/', -1)
                    ELSE m.`repo_url`
                  END,
                  'component-library/source/', ''
                ),
                '/',
                ''
              )))
            ),
            '/',
            '.'
          )
        )
      ),
      '.',
      '.'
    )
  ) AS class_name,
  m.`description`,
  CONCAT(
    'Modelica/',
    SUBSTRING_INDEX(
      REPLACE(
        CASE
          WHEN m.`repo_url` LIKE '%/raw/branch/main/%' THEN SUBSTRING_INDEX(m.`repo_url`, '/raw/branch/main/', -1)
          WHEN m.`repo_url` LIKE '%/raw/branch/master/%' THEN SUBSTRING_INDEX(m.`repo_url`, '/raw/branch/master/', -1)
          ELSE m.`repo_url`
        END,
        'component-library/source/', ''
      ),
      '/',
      (LENGTH(
        REPLACE(
          CASE
            WHEN m.`repo_url` LIKE '%/raw/branch/main/%' THEN SUBSTRING_INDEX(m.`repo_url`, '/raw/branch/main/', -1)
            WHEN m.`repo_url` LIKE '%/raw/branch/master/%' THEN SUBSTRING_INDEX(m.`repo_url`, '/raw/branch/master/', -1)
            ELSE m.`repo_url`
          END,
          'component-library/source/', ''
        )
      ) - LENGTH(REPLACE(
        REPLACE(
          CASE
            WHEN m.`repo_url` LIKE '%/raw/branch/main/%' THEN SUBSTRING_INDEX(m.`repo_url`, '/raw/branch/main/', -1)
            WHEN m.`repo_url` LIKE '%/raw/branch/master/%' THEN SUBSTRING_INDEX(m.`repo_url`, '/raw/branch/master/', -1)
            ELSE m.`repo_url`
          END,
          'component-library/source/', ''
        ),
        '/',
        ''
      )))
    )
  ) AS index_path,
  m.`repo_name`,
  CASE
    WHEN m.`repo_url` LIKE '%/raw/branch/main/%' THEN SUBSTRING_INDEX(m.`repo_url`, '/raw/branch/main/', -1)
    WHEN m.`repo_url` LIKE '%/raw/branch/master/%' THEN SUBSTRING_INDEX(m.`repo_url`, '/raw/branch/master/', -1)
    ELSE m.`repo_url`
  END AS source_path,
  NULL AS icon_path,
  m.`cover_image`,
  m.`user_id`,
  m.`is_del`,
  m.`create_time`,
  m.`update_time`
FROM `bs_model` m
WHERE m.`is_del` = 0
  AND m.`attr_type` = 'component'
  AND NOT EXISTS (
    SELECT 1 FROM `bs_component` c
    WHERE c.`name` = m.`name`
      AND c.`repo_name` = m.`repo_name`
      AND c.`source_path` = (
        CASE
          WHEN m.`repo_url` LIKE '%/raw/branch/main/%' THEN SUBSTRING_INDEX(m.`repo_url`, '/raw/branch/main/', -1)
          WHEN m.`repo_url` LIKE '%/raw/branch/master/%' THEN SUBSTRING_INDEX(m.`repo_url`, '/raw/branch/master/', -1)
          ELSE m.`repo_url`
        END
      )
  );

-- 3. 迁移完成后，可选执行（保守起见建议先人工验证后再清理旧字段）
-- UPDATE `bs_model` SET `attr_type` = NULL WHERE `attr_type` = 'component';
