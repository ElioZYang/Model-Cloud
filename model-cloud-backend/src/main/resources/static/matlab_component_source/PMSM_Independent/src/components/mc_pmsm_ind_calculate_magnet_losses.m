function [magnet_loss_W,mag_params] = mc_pmsm_ind_calculate_magnet_losses( ...
    mag_params,electrical_frequency_Hz, ...
    equivalent_airgap_flux_density_T,operating_speed_rpm)
% CALCULATE_MAGNET_LOSSES 估算当前工况下的永磁体涡流损耗。
%
% 本函数使用已经确定的磁钢材料和几何参数，根据当前电频率、
% 气隙磁密及转速，通过经验修正模型估算全部磁钢的总损耗。
% 设计点和非设计点均可调用本函数；它不负责磁钢尺寸设计。
%
% 输入：
%   mag_params - 磁钢参数结构体，至少包含：
%       .volume       全部磁钢的总体积 [m^3]
%       .segments     磁钢分段数 [-]
%       .magnet_type  磁钢材料类型，支持 'NdFeB'、'SmCo'
%   electrical_frequency_Hz - 当前电频率 [Hz]
%   equivalent_airgap_flux_density_T - 当前等效气隙磁密 [T]
%   operating_speed_rpm - 当前机械转速 [r/min]
%
% 输出：
%   magnet_loss_W - 全部磁钢的总涡流损耗 [W]
%   mag_params - 更新后的磁钢参数结构体，增加：
%       .resistivity  磁钢材料电阻率 [ohm·m]
%       .loss_density 磁钢体积损耗密度 [W/m^3]
%
% 说明：
%   1. 当前模型为工程经验模型，不包含磁场谐波时步或有限元计算。
%   2. 材料电阻率目前仅写入输出结构体，尚未直接进入损耗公式。
%   3. 如果调用方只接收第一个输出，更新后的 mag_params 不会被保存。
    
    %% 1. 提取磁钢几何和材料参数
    magnet_volume_m3 = mag_params.volume;
    segment_count = mag_params.segments;
    magnet_type = mag_params.magnet_type;

    %% 2. 设置材料经验参数
    switch magnet_type
        case 'NdFeB'
            magnet_resistivity_ohm_m = 1.6e-6;
            loss_coefficient = 0.8;
        case 'SmCo'
            magnet_resistivity_ohm_m = 0.9e-6;
            loss_coefficient = 0.6;
        otherwise
            error('unknown:%s', magnet_type);
    end
    
    %% 3. 计算经验基准损耗
    % 以 100 Hz、0.8 T 为归一化基准，损耗随 f^2、B_g^2 和体积变化。
    base_magnet_loss_W = loss_coefficient ...
        * (electrical_frequency_Hz/100)^2 ...
        * (equivalent_airgap_flux_density_T/0.8)^2 ...
        * magnet_volume_m3;
    
    % 频率升高时的经验谐波增强系数。
    harmonic_factor = 1+0.05*(electrical_frequency_Hz/100)^0.7;
    
    % 磁钢分段可缩短涡流路径；当前采用分段数平方根的经验修正。
    segmentation_factor = 1/sqrt(segment_count);
    
    % 当转速高于 8000 rpm 时引入高速经验修正。
    if operating_speed_rpm > 8000
        speed_factor = 1 + 0.001*(operating_speed_rpm/1000)^1.5;
    else
        speed_factor = 1.0;
    end
    
    %% 4. 汇总磁钢损耗
    magnet_loss_W = base_magnet_loss_W ...
        * harmonic_factor*segmentation_factor*speed_factor;
    
    %% 5. 补充磁钢损耗相关属性
    mag_params.resistivity = magnet_resistivity_ohm_m;
    mag_params.loss_density = magnet_loss_W/magnet_volume_m3;
end
