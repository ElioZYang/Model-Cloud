function [ M ] = mc_pmsm_MM( far )
%根据油气比计算气体摩尔质量
%Molar Mass
% far   油气比
%输出参数
% M     摩尔质量
M=28.97 - 0.946186*far;
end

