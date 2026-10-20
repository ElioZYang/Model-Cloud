function [DP] = INPUT_DESIGN_PARAMETERS(DP)
%% 事先指定
% 发动机类型DP.type
% 空气流量DP.WA
% 速度DP.V
% 高度DP.H
% 是否对推力有要求DP.T_REQ
% 推力DP.THRUST（KN）
% 发电功率DP.PWG（1*NS的向量，KW）
% MAP0 初始部件MAP图
% XD 设计点参数向量
DP.DT=0;% 与大气温差（K）
DP.QP=100;% 与大气压强之比（%）
DP.D=0;% 湿度
if strcmpi(DP.type,"ICE")
    INPUT_ICE
else
    DP.display=1;
    
    DP=INPUT_TURBO(DP);        % 根据构型建立气路顺序、轴系连接、部件效率、压比、燃烧温度及部件数量

    pmsm_input=INPUT_ELECTRIC; % 读取电机参数
    temp_variables=pmsm_input.thermal.temp_variables;
    DP.temp_variables=temp_variables;
    DP.NH=length(temp_variables);
    DP.pmsm_input(1:DP.NM1)=pmsm_input;
    DP.pmsm_input(1)=pmsm_input;
    DP.temp_pmsm_ref=ones(DP.NH,DP.NM1);
    DP.temp_pmsm=pmsm_input.temperature_limit*DP.temp_pmsm_ref;
    
    DP.MAP=READMAP(DP);
end
end