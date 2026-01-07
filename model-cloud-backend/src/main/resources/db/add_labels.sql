-- 添加模型标签数据
-- 使用方法: 在MySQL客户端中连接到model_cloud数据库后执行此脚本

USE `model_cloud`;

-- 清空现有标签数据（如果需要重新初始化）
-- DELETE FROM `bs_model_label` WHERE 1=1;

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
ON DUPLICATE KEY UPDATE `name`=VALUES(`name`), `description`=VALUES(`description`), `sort`=VALUES(`sort`);

-- 查询验证
SELECT * FROM `bs_model_label` ORDER BY `sort`;

