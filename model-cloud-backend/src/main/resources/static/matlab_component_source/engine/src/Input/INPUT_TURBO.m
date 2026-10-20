function[DP]=INPUT_TURBO(DP)
DP=INPUT_TURBO_COMMON_HEAD(DP);
switch DP.type
    case "ducted fan"
        %% 涵道风扇
        NS=1;% 轴数
        NW=0;% 气路数
        DP.THRUST=-1;% 推力需求（对于涵道风扇，-1代表给定功率需求）
        DP.WA=0;% 空气流量
        % 部件图
        DP.F=["inlet","lpc","nozzle"];
        NF = length(DP.F);
        % 总压恢复系数
        DP.TPR=ones(1,NF);% 总压恢复系数（-1则根据经验公式计算）
        DP.TPR(strcmpi(DP.F,"inlet"))=-1;
        DP.TPR(strcmpi(DP.F,"duct"))=0.97;
        DP.TPR(strcmpi(DP.F,"nozzle"))=0.97;
        % 效率
        DP.EFFC=0.87;% 压气机效率
        DP.PRC=1.1;% 压气机压比
        DP.EFFT=1;% 涡轮效率
        DP.PRT=0;% 涡轮膨胀比（<=0则需手动计算）
        DP.E_motor=0.97;% 电机效率（NS个）
        DP.TO=1;
        DP.EB=1;
        DP.HU=1;
        % 轴接
        DP.SHAFT=zeros(NS,NF);
        DP.SHAFT(1,strcmpi(DP.F,"lpc"))=1;
        DP.E_mech=0.985;%
        % 引气
        DP.WA_extraction=zeros(1,NF);
        DP.EXT=zeros(1,NF);
    case "turboshaft"
        %% 单轴涡轴
        NS=1;NW=1;
        DP.THRUST=0;% 推力需求
        DP.WA=0;% 空气流量
        % 部件图
        %      进气道→ 管道→ 压气机→ 燃烧室→ 涡轮→ 喷管
        DP.F=["inlet","duct","hpc","burn","hpt","nozzle"];
        NF = length(DP.F);
        % 总压恢复系数
        DP.TPR=ones(1,NF);
        DP.TPR(strcmpi(DP.F,"inlet"))=-1;
        DP.TPR(strcmpi(DP.F,"duct"))=0.97;
        DP.TPR(strcmpi(DP.F,"outer duct"))=0.97;
        DP.TPR(strcmpi(DP.F,"nozzle"))=0.97;
        DP.TPR(strcmpi(DP.F,"burn"))=0.99;
        DP.TPR(strcmpi(DP.F,"afterburn"))=0.9;
        DP.TPRM=0.5;% 混合器总压恢复系数
        % 效率
        DP.EFFC=0.85;% 压气机效率
        DP.EFFT=0.89;% 涡轮效率
        DP.PRC=4;% 压气机压比
        DP.PRT=0;% 涡轮压比（计算得）
        DP.EB=0.99;% 燃烧室效率（NB个）
        DP.E_motor=0.97;% 电机效率（NM个）
        DP.HU=43.124E6;% 燃料热值（NB个）
        DP.TO=1450;% 燃烧室温度（NB个）
        % 轴接
        DP.SHAFT=zeros(NS,NF);
        DP.SHAFT(1,strcmpi(DP.F,"fan"))=1;
        DP.SHAFT(1,strcmpi(DP.F,"hpc"))=1;
        DP.SHAFT(1,strcmpi(DP.F,"hpt"))=1;
        DP.E_mech=0.985;
        
        DP.WA_extraction=zeros(1,NF);
        DP.EXT=zeros(NW,NF);
        % 指定引气管道连接的部件
        DP.EXT(1,find(strcmpi(DP.F,"hpc")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"hpt")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"lpt")))=1;
        % 指定引气量
        DP.WA_extraction(1,strcmpi(DP.F,"hpc"))=0;
        DP.WA_extraction(1,strcmpi(DP.F,"hpt"))=0;
        DP.WA_extraction(1,strcmpi(DP.F,"lpt"))=0;
    case "hpcgv pmsm"
        NS=1;NW=0;
        DP.WA=0;
        DP.F="hpcgv pmsm";
        DP.PRC=1;DP.EFFC=1;
        DP.PRT=-1;DP.EFFT=1;
        DP.TO=0;
        NF=length(DP.F);
        DP.SHAFT=1;
        DP.TPR=1;
        DP.TPRM=1;
        DP.WA_extraction=0;
        DP.EXT=1;
%% 单独计算案例（共四个）
    case "1 spool turbo electric front"
        % 单轴前置电机
        NS=1;NW=1;
        DP.THRUST=0;% 推力需求
        DP.WA=0;% 空气流量
        % 部件图
        DP.F=["inlet","pmsm 0d","duct","hpc","burn","hpt","nozzle"];
        NF = length(DP.F);
        % 总压恢复系数
        DP.TPR=ones(1,NF);
        DP.TPR(strcmpi(DP.F,"inlet"))=-1;
        DP.TPR(strcmpi(DP.F,"duct"))=0.97;
        DP.TPR(strcmpi(DP.F,"outer duct"))=0.97;
        DP.TPR(strcmpi(DP.F,"nozzle"))=0.97;
        DP.TPR(strcmpi(DP.F,"burn"))=0.99;
        DP.TPR(strcmpi(DP.F,"afterburn"))=0.9;
        DP.TPRM=0.5;% 混合器总压恢复系数
        % 效率
        DP.EFFC=0.85;% 压气机效率
        DP.EFFT=0.89;% 涡轮效率
        DP.PRC=3.5;% 压气机压比
        DP.PRT=0;% 涡轮压比（计算得）
        DP.EB=0.99;% 燃烧室效率（NB个）
        DP.E_motor=0.97;% 电机效率（NM个）
        DP.HU=43.124E6;% 燃料热值（NB个）
        DP.TO=1223;% 燃烧室温度（NB个）
        % 轴接
        DP.SHAFT=zeros(NS,NF);
        DP.SHAFT(1,strcmpi(DP.F,"fan"))=1;
        DP.SHAFT(1,strcmpi(DP.F,"hpc"))=1;
        DP.SHAFT(1,strcmpi(DP.F,"hpt"))=1;
        DP.SHAFT_CONTROL=1;
        DP.E_mech=0.985;
        
        DP.WA_extraction=zeros(1,NF);
        DP.EXT=zeros(NW,NF);
        % 指定引气管道连接的部件
        DP.EXT(1,find(strcmpi(DP.F,"hpc")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"hpt")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"lpt")))=1;
        % 指定引气量
        DP.WA_extraction(1,strcmpi(DP.F,"hpc"))=0;
        DP.WA_extraction(1,strcmpi(DP.F,"hpt"))=0;
        DP.WA_extraction(1,strcmpi(DP.F,"lpt"))=0;
    case "1 spool turbo electric back"
        % 单轴前置电机
        NS=1;NW=1;
        DP.THRUST=0;% 推力需求
        DP.WA=0;% 空气流量
        % 部件图
        DP.F=["inlet","duct","hpc","burn","hpt","pmsm 0d","nozzle"];
        NF = length(DP.F);
        % 总压恢复系数
        DP.TPR=ones(1,NF);
        DP.TPR(strcmpi(DP.F,"inlet"))=-1;
        DP.TPR(strcmpi(DP.F,"duct"))=0.97;
        DP.TPR(strcmpi(DP.F,"outer duct"))=0.97;
        DP.TPR(strcmpi(DP.F,"nozzle"))=0.97;
        DP.TPR(strcmpi(DP.F,"burn"))=0.99;
        DP.TPR(strcmpi(DP.F,"afterburn"))=0.9;
        DP.TPRM=0.5;% 混合器总压恢复系数
        % 效率
        DP.EFFC=0.85;% 压气机效率
        DP.EFFT=0.89;% 涡轮效率
        DP.PRC=3.5;% 压气机压比
        DP.PRT=0;% 涡轮压比（计算得）
        DP.EB=0.99;% 燃烧室效率（NB个）
        DP.E_motor=0.97;% 电机效率（NM个）
        DP.HU=43.124E6;% 燃料热值（NB个）
        DP.TO=1223;% 燃烧室温度（NB个）
        % 轴接
        DP.SHAFT=zeros(NS,NF);
        DP.SHAFT(1,strcmpi(DP.F,"fan"))=1;
        DP.SHAFT(1,strcmpi(DP.F,"hpc"))=1;
        DP.SHAFT(1,strcmpi(DP.F,"hpt"))=1;
        DP.SHAFT_CONTROL=1;
        DP.E_mech=0.985;
        DP.WA_extraction=zeros(1,NF);
        DP.EXT=zeros(NW,NF);
        % 指定引气管道连接的部件
        DP.EXT(1,find(strcmpi(DP.F,"hpc")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"hpt")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"lpt")))=1;
        % 指定引气量
        DP.WA_extraction(1,strcmpi(DP.F,"hpc"))=0;
        DP.WA_extraction(1,strcmpi(DP.F,"hpt"))=0;
        DP.WA_extraction(1,strcmpi(DP.F,"lpt"))=0;
    case "2 spool turbo electric front"
        %% 自由涡轮涡轴
        NS=2;NW=1;
        DP.THRUST=0;% 推力需求
        DP.WA=0;% 空气流量
        % 部件图
        DP.F=["inlet","pmsm 0d","duct","hpc","burn","hpt","duct","lpt","duct","nozzle"];
        NF = length(DP.F);
        % 总压恢复系数
        DP.TPR=ones(1,NF);
        DP.TPR(strcmpi(DP.F,"inlet"))=-1;
        DP.TPR(strcmpi(DP.F,"duct"))=0.97;
        DP.TPR(strcmpi(DP.F,"nozzle"))=0.97;
        DP.TPR(strcmpi(DP.F,"burn"))=0.99;
        DP.TPRM=0.5;% 混合器总压恢复系数
        % 效率
        DP.EFFC=0.79;% 压气机效率
        DP.EFFT=[0.89 0.89];% 涡轮效率
        DP.PRC=7;% 压气机压比
        DP.PRT=[0,0];% 涡轮压比（计算得）
        DP.EB=0.99;% 燃烧室效率（NB个）
        DP.E_motor=[1,0.97]; %电机效率（NM个）
        DP.EFF_heat_exchange=0;
        DP.HU=43.124E6;% 燃料热值（NB个）
        DP.TO=1800;% 燃烧室温度（NB个）
        % 轴接
        DP.SHAFT=zeros(NS,NF);
        DP.SHAFT(1,strcmpi(DP.F,"hpc"))=1;
        DP.SHAFT(1,strcmpi(DP.F,"hpt"))=1;
        DP.SHAFT(2,strcmpi(DP.F,"lpt"))=1;
        DP.SHAFT_CONTROL=[0,1];
        DP.E_mech=[0.985;0.985];
        DP.WA_extraction=zeros(1,NF);
        DP.EXT=zeros(NW,NF);
        % 引气（待改进）
        DP.EXT(1,find(strcmpi(DP.F,"hpc")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"hpt")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"lpt")))=1;
        % 引气量
        DP.WA_extraction(1,strcmpi(DP.F,"hpc"))=0;
        DP.WA_extraction(1,strcmpi(DP.F,"hpt"))=0;
        DP.WA_extraction(1,strcmpi(DP.F,"lpt"))=0;
    case "2 spool turbo electric back"
        %% 自由涡轮涡轴
        NS=2;NW=1;
        DP.THRUST=0;% 推力需求
        DP.WA=0;% 空气流量
        % 部件图
        DP.F=["inlet","duct","hpc","burn","hpt","duct","lpt","duct","pmsm 0d","nozzle"];
        NF = length(DP.F);
        % 总压恢复系数
        DP.TPR=ones(1,NF);
        DP.TPR(strcmpi(DP.F,"inlet"))=-1;
        DP.TPR(strcmpi(DP.F,"duct"))=0.97;
        DP.TPR(strcmpi(DP.F,"nozzle"))=0.97;
        DP.TPR(strcmpi(DP.F,"burn"))=0.99;
        DP.TPRM=0.5;% 混合器总压恢复系数
        % 效率
        DP.EFFC=0.79;% 压气机效率
        DP.EFFT=[0.89 0.89];% 涡轮效率
        DP.PRC=7;% 压气机压比
        DP.PRT=[0,0];% 涡轮压比（计算得）
        DP.EB=0.99;% 燃烧室效率（NB个）
        DP.E_motor=[1,0.97]; %电机效率（NM个）
        DP.EFF_heat_exchange=0;
        DP.HU=43.124E6;% 燃料热值（NB个）
        DP.TO=1800;% 燃烧室温度（NB个）
        % 轴接
        DP.SHAFT=zeros(NS,NF);
        DP.SHAFT(1,strcmpi(DP.F,"hpc"))=1;
        DP.SHAFT(1,strcmpi(DP.F,"hpt"))=1;
        DP.SHAFT(2,strcmpi(DP.F,"lpt"))=1;
        DP.SHAFT_CONTROL=[0,1];
        DP.E_mech=[0.985;0.985];
        DP.WA_extraction=zeros(1,NF);
        DP.EXT=zeros(NW,NF);
        % 引气（待改进）
        DP.EXT(1,find(strcmpi(DP.F,"hpc")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"hpt")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"lpt")))=1;
        % 引气量
        DP.WA_extraction(1,strcmpi(DP.F,"hpc"))=0;
        DP.WA_extraction(1,strcmpi(DP.F,"hpt"))=0;
        DP.WA_extraction(1,strcmpi(DP.F,"lpt"))=0;
    case "hpcgv turboshaft"
        %% 单轴涡轴
        NS=1;NW=1;
        DP.THRUST=0;% 推力需求
        DP.WA=0;% 空气流量
        % 部件图
        DP.F=["inlet","hpcgv pmsm","duct","hpc","burn","hpt","nozzle"];
        NF = length(DP.F);
        % 总压恢复系数
        DP.TPR=ones(1,NF);
        DP.TPR(strcmpi(DP.F,"inlet"))=-1;
        DP.TPR(strcmpi(DP.F,"duct"))=0.97;
        DP.TPR(strcmpi(DP.F,"outer duct"))=0.97;
        DP.TPR(strcmpi(DP.F,"nozzle"))=0.97;
        DP.TPR(strcmpi(DP.F,"burn"))=0.99;
        DP.TPR(strcmpi(DP.F,"afterburn"))=0.9;
        DP.TPRM=0.5;% 混合器总压恢复系数
        % 效率
        DP.EFFC=0.85;% 压气机效率
        DP.EFFT=0.89;% 涡轮效率
        DP.PRC=3.5;% 压气机压比
        DP.PRT=0;% 涡轮压比（计算得）
        DP.EB=0.99;% 燃烧室效率（NB个）
        DP.E_motor=0.97;% 电机效率（NM个）
        DP.HU=43.124E6;% 燃料热值（NB个）
        DP.TO=1223;% 燃烧室温度（NB个）
        % 轴接
        DP.SHAFT=zeros(NS,NF);
        DP.SHAFT(1,strcmpi(DP.F,"fan"))=1;
        DP.SHAFT(1,strcmpi(DP.F,"hpc"))=1;
        DP.SHAFT(1,strcmpi(DP.F,"hpt"))=1;
        DP.E_mech=0.985;
        
        DP.WA_extraction=zeros(1,NF);
        DP.EXT=zeros(NW,NF);
        % 指定引气管道连接的部件
        DP.EXT(1,find(strcmpi(DP.F,"hpc")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"hpt")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"lpt")))=1;
        % 指定引气量
        DP.WA_extraction(1,strcmpi(DP.F,"hpc"))=0;
        DP.WA_extraction(1,strcmpi(DP.F,"hpt"))=0;
        DP.WA_extraction(1,strcmpi(DP.F,"lpt"))=0;    
    case "2 spool turboshaft"
        %% 双轴涡轴
        NS=2;NW=2;
        DP.THRUST=98;% 推力需求
        DP.WA=0;% 空气流量
        DP.F=["inlet","duct","lpc","duct","hpc","burn","hpt","duct","lpt","duct","nozzle"];
        NF = length(DP.F);
        % 总压恢复系数
        DP.TPR=ones(1,NF);
        DP.TPR(strcmpi(DP.F,"inlet"))=-1;
        DP.TPR(strcmpi(DP.F,"duct"))=0.97;
        DP.TPR(strcmpi(DP.F,"outer duct"))=0.97;
        DP.TPR(strcmpi(DP.F,"nozzle"))=0.97;
        DP.TPR(strcmpi(DP.F,"burn"))=0.99;
        DP.TPR(strcmpi(DP.F,"afterburn"))=0.9;
        DP.TPRM=0.5;% 混合器总压恢复系数
        % 效率
        DP.EFFC=[0.79 0.79];% 压气机效率
        DP.EFFT=[0.89 0.89];% 涡轮效率
        DP.PRC=[4 7];% 压气机压比
        DP.PRT=[0,0];% 涡轮压比（计算得）
        DP.EB=0.99;% 燃烧室效率（NB个）
        DP.E_motor=[0.97,0.97];%发电机效率（NS个）
        DP.HU=43.124E6;% 燃料热值（NB个）
        DP.TO=1800;% 燃烧室温度（NB个）
        % 轴接
        DP.SHAFT=zeros(NS,NF);
        DP.SHAFT(1,strcmpi(DP.F,"fan"))=1;
        DP.SHAFT(1,strcmpi(DP.F,"hpc"))=1;
        DP.SHAFT(1,strcmpi(DP.F,"hpt"))=1;
        DP.SHAFT(2,strcmpi(DP.F,"lpc"))=1;
        DP.SHAFT(2,strcmpi(DP.F,"lpt"))=1;
        DP.E_mech=[0.985;0.985];
        DP.WA_extraction=zeros(1,NF);
        DP.EXT=zeros(NW,NF);
        % 引气
        DP.EXT(1,find(strcmpi(DP.F,"hpc")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"hpt")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"lpt")))=1;
        % 引气量
        DP.WA_extraction(1,strcmpi(DP.F,"hpc"))=0;
        DP.WA_extraction(1,strcmpi(DP.F,"hpt"))=0;
        DP.WA_extraction(1,strcmpi(DP.F,"lpt"))=0;
    case "turboshaft with free turbine"
        %% 自由涡轮涡轴
        NS=2;NW=1;
        DP.THRUST=0;% 推力需求
        DP.WA=0;% 空气流量
        % 部件图
        DP.F=["inlet","pmsm 0d","duct","hpc","burn","hpt","duct","lpt","afterburn","nozzle"];
        NF = length(DP.F);
        % 总压恢复系数
        DP.TPR=ones(1,NF);
        DP.TPR(strcmpi(DP.F,"inlet"))=-1;
        DP.TPR(strcmpi(DP.F,"duct"))=0.97;
        DP.TPR(strcmpi(DP.F,"outer duct"))=0.97;
        DP.TPR(strcmpi(DP.F,"nozzle"))=0.97;
        DP.TPR(strcmpi(DP.F,"burn"))=0.99;
        DP.TPR(strcmpi(DP.F,"afterburn"))=0.9;
        DP.TPRM=0.5;% 混合器总压恢复系数
        % 效率
        DP.EFFC=0.79;% 压气机效率
        DP.EFFT=[0.89 0.89];% 涡轮效率
        DP.PRC=7;% 压气机压比
        DP.PRT=[0,0];% 涡轮压比（计算得）
        DP.EB=0.99;% 燃烧室效率（NB个）
        DP.E_motor=[0.97,0.97]; %电机效率（NM个）
        DP.EFF_heat_exchange=0;
        DP.HU=43.124E6;% 燃料热值（NB个）
        DP.TO=[1800,2200];% 燃烧室温度（NB个）
        % 轴接
        DP.SHAFT=zeros(NS,NF);
        DP.SHAFT(1,strcmpi(DP.F,"fan"))=1;
        DP.SHAFT(1,strcmpi(DP.F,"hpc"))=1;
        DP.SHAFT(1,strcmpi(DP.F,"hpt"))=1;
        DP.SHAFT(2,strcmpi(DP.F,"lpt"))=1;
        DP.SHAFT_CONTROL=[0,1];
        DP.E_mech=[0.985;0.985];
        DP.WA_extraction=zeros(1,NF);
        DP.EXT=zeros(NW,NF);
        % 引气（待改进）
        DP.EXT(1,find(strcmpi(DP.F,"hpc")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"hpt")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"lpt")))=1;
        % 引气量
        DP.WA_extraction(1,strcmpi(DP.F,"hpc"))=0;
        DP.WA_extraction(1,strcmpi(DP.F,"hpt"))=0;
        DP.WA_extraction(1,strcmpi(DP.F,"lpt"))=0;

    case "mixed turbofan"
        %% 混排涡扇
        NS=1;NW=1;
        DP.THRUST=98;% 推力需求
        DP.WA=0;% 空气流量
        DP.BYPASS_RATIO=0.25;
        % 部件图
        DP.F=["inlet","duct","fan","outer duct","hpc","burn","hpt","mixer","afterburn","nozzle"];
        NF = length(DP.F);
        % 总压恢复系数
        DP.TPR=ones(1,NF);
        DP.TPR(strcmpi(DP.F,"inlet"))=-1;
        DP.TPR(strcmpi(DP.F,"duct"))=0.97;
        DP.TPR(strcmpi(DP.F,"outer duct"))=0.97;
        DP.TPR(strcmpi(DP.F,"nozzle"))=0.97;
        DP.TPR(strcmpi(DP.F,"burn"))=0.99;
        DP.TPR(strcmpi(DP.F,"afterburn"))=0.9;
        DP.TPRM=0.8;% 混合器总压恢复系数
        % 效率
        DP.EFFC=[0.79,0.79];% 压气机效率
        DP.EFFT=0.89;% 涡轮效率
        DP.PRC_outerfan=1.6;
        DP.PRC=[1.5 7];% 压气机压比
        DP.PRT=0;% 涡轮压比（<0则需根据功率平衡计算得到）
        DP.EB=[0.99,0.99];% 燃烧室效率（NB个）
        DP.E_motor=0.97;% 电机效率（NM个）
        DP.HU=[43.124E6,43.124E6];% 燃料热值（NB个）
        DP.TO=[1800,2200];% 燃烧室温度（NB个）
        % 轴接
        DP.SHAFT=zeros(NS,NF);
        DP.SHAFT(1,strcmpi(DP.F,"fan"))=1;
        DP.SHAFT(1,strcmpi(DP.F,"hpc"))=1;
        DP.SHAFT(1,strcmpi(DP.F,"hpt"))=1;
        DP.E_mech=[0.985;0.985];% 机械效率（NS个）
        
        DP.WA_extraction=zeros(1,NF);
        DP.EXT=zeros(NW,NF);
        % 引气（待改进）
        DP.EXT(1,find(strcmpi(DP.F,"hpc")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"hpt")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"lpt")))=1;
        % 引气量
        DP.WA_extraction(1,strcmpi(DP.F,"hpc"))=0.0;
        DP.WA_extraction(1,strcmpi(DP.F,"hpt"))=0.0;
        DP.WA_extraction(1,strcmpi(DP.F,"lpt"))=0.0;

    case "separated turbofan"
        %% 单排涡扇 
        DP.flow="separated";
        NS=1;NW=1;
        DP.THRUST=98;% 推力需求
        DP.WA=0;% 空气流量
        DP.BYPASS_RATIO=5;
        % 部件图
        DP.F=["inlet","duct","fan","outer duct","hpc","burn","hpt","duct","nozzle"];
        NF = length(DP.F);
        
        % 总压恢复系数
        DP.TPR=ones(1,NF);
        DP.TPR(strcmpi(DP.F,"inlet"))=-1;
        DP.TPR(strcmpi(DP.F,"duct"))=0.97;
        DP.TPR(strcmpi(DP.F,"outer duct"))=0.97;
        DP.TPR(strcmpi(DP.F,"nozzle"))=0.97;
        DP.TPR(strcmpi(DP.F,"burn"))=0.99;
        DP.TPR(strcmpi(DP.F,"afterburn"))=0.9;
        DP.TPRM=0.8;% 混合器总压恢复系数
        % 效率
        DP.EFFC=[0.79,0.79];% 压气机效率
        DP.EFFT=0.89;% 涡轮效率
        DP.PRC_outerfan=1.6;
        DP.PRC=[1.5 7];% 压气机压比
        DP.PRT=0;% 涡轮压比（计算得）
        DP.EB=0.99;% 燃烧室效率（NB个）
        DP.E_motor=0.97;%发电机效率（NS个）
        DP.HU=43.124E6;% 燃料热值（NB个）
        DP.TO=[1700,2200];% 燃烧室温度（NB个）
        % 轴接
        DP.SHAFT=zeros(NS,NF);
        DP.SHAFT(1,strcmpi(DP.F,"fan"))=1;
        DP.SHAFT(1,strcmpi(DP.F,"hpc"))=1;
        DP.SHAFT(1,strcmpi(DP.F,"hpt"))=1;
        DP.E_mech=[0.985;0.985];
        
        DP.WA_extraction=zeros(1,NF);
        DP.EXT=zeros(NW,NF);
        % 引气（待改进）
        DP.EXT(1,find(strcmpi(DP.F,"hpc")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"hpt")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"lpt")))=1;
        % 引气量
        DP.WA_extraction(1,strcmpi(DP.F,"hpc"))=0.0;
        DP.WA_extraction(1,strcmpi(DP.F,"hpt"))=0.0;
        DP.WA_extraction(1,strcmpi(DP.F,"lpt"))=0.0;

    case "2 spool mixed turbofan"
        %% 双轴混排涡扇
        NS=2;NW=1;
        DP.THRUST=98;% 推力需求
        DP.WA=0;% 空气流量
        DP.BYPASS_RATIO=0.25;% 涵道比
        % 部件图
        DP.F=["inlet","duct","fan","outer duct","hpc","burn","hpt","duct","lpt","mixer","afterburn","nozzle"];
        NF = length(DP.F);
        
        % 总压恢复系数
        DP.TPR=ones(1,NF);
        DP.TPR(strcmpi(DP.F,"inlet"))=-1;
        DP.TPR(strcmpi(DP.F,"duct"))=0.97;
        DP.TPR(strcmpi(DP.F,"outer duct"))=0.97;
        DP.TPR(strcmpi(DP.F,"nozzle"))=0.97;
        DP.TPR(strcmpi(DP.F,"burn"))=0.99;
        DP.TPR(strcmpi(DP.F,"afterburn"))=0.9;
        DP.TPRM=0.8;% 混合器总压恢复系数
        % 效率
        DP.EFFC=[0.79,0.79,0.79];% 压气机效率
        DP.EFFT=[0.89,0.89];% 涡轮效率
        DP.PRC_outerfan=1.5;
        DP.PRC=[4 7];% 压气机压比
        DP.PRT=[0 0];% 涡轮压比（计算得）
        DP.EB=[0.99,0.99];% 燃烧室效率（NB个）
        DP.E_motor=[0.97,0.97];%发电机效率（NS个）
        DP.HU=[43.124E6,43.124E6];% 燃料热值（NB个）
        DP.TO=[1800,2200];% 燃烧室温度（NB个）
        % 轴接
        DP.SHAFT=zeros(NS,NF);
        DP.SHAFT(1,strcmpi(DP.F,"fan"))=1;
        DP.SHAFT(1,strcmpi(DP.F,"lpt"))=1;
        DP.SHAFT(2,strcmpi(DP.F,"hpc"))=1;
        DP.SHAFT(2,strcmpi(DP.F,"hpt"))=1;
        DP.E_mech=[0.985;0.985];
        DP.WA_extraction=zeros(1,NF);
        DP.EXT=zeros(NW,NF);
        % 引气（待改进）
        DP.EXT(1,find(strcmpi(DP.F,"hpc")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"hpt")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"lpt")))=1;
        % 引气量
        DP.WA_extraction(1,strcmpi(DP.F,"hpc"))=0.0;
        DP.WA_extraction(1,strcmpi(DP.F,"hpt"))=0.0;
        DP.WA_extraction(1,strcmpi(DP.F,"lpt"))=0.0;

    case "2 spool separated turbofan"
        %% 双轴分排涡扇
        NS=2;NW=1;
        DP.flow="separated";
        DP.THRUST=98;% 推力需求
        DP.WA=0;% 空气流量
        DP.BYPASS_RATIO=5;
        % 部件图
        DP.F=["inlet","duct","fan","duct","hpc","burn","hpt","duct","lpt","duct","afterburn","nozzle"];
        NF = length(DP.F);
        
        % 总压恢复系数
        DP.TPR=ones(1,NF);
        DP.TPR(strcmpi(DP.F,"inlet"))=-1;
        DP.TPR(strcmpi(DP.F,"duct"))=0.97;
        DP.TPR(strcmpi(DP.F,"outer duct"))=0.97;
        DP.TPR(strcmpi(DP.F,"nozzle"))=0.97;
        DP.TPR(strcmpi(DP.F,"burn"))=0.99;
        DP.TPR(strcmpi(DP.F,"afterburn"))=0.9;
        DP.TPRM=0.8;% 混合器总压恢复系数
        % 效率
        DP.EFFC=[0.79,0.79,0.79];% 压气机效率
        DP.EFFT=[0.89,0.89];% 涡轮效率
        DP.PRC_outerfan=1.5;
        DP.PRC=[2 3 7];% 压气机压比
        DP.PRT=[0 0];% 涡轮压比（计算得）
        DP.EB=[0.99,0.99];% 燃烧室效率（NB个）
        DP.E_motor=[0.97,0.97];%发电机效率（NS个）
        DP.HU=[43.124E6,43.124E6];% 燃料热值（NB个）
        DP.TO=[1800,2200];% 燃烧室温度（NB个）
        % 轴接
        DP.SHAFT=zeros(NS,NF);
        DP.SHAFT(1,strcmpi(DP.F,"fan"))=1;
        DP.SHAFT(1,strcmpi(DP.F,"lpt"))=1;
        DP.SHAFT(2,strcmpi(DP.F,"hpc"))=1;
        DP.SHAFT(2,strcmpi(DP.F,"hpt"))=1;
        DP.E_mech=[0.985;0.985];
        DP.WA_extraction=zeros(1,NF);
        DP.EXT=zeros(NW,NF);
        % 引气（待改进）
        DP.EXT(1,find(strcmpi(DP.F,"hpc")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"hpt")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"lpt")))=1;
        % 引气量
        DP.WA_extraction(1,strcmpi(DP.F,"hpc"))=0;
        DP.WA_extraction(1,strcmpi(DP.F,"hpt"))=0;
        DP.WA_extraction(1,strcmpi(DP.F,"lpt"))=0;
    case "CFM56"
        %% CFM56-7B发动机
        NS=2;NW=2;
        DP.flow="separated";
        DP.WA=358.28;% 空气流量
        DP.THRUST=120;
        DP.BYPASS_RATIO=4.8;
        % 部件图
        DP.F=["inlet","duct","fan","duct","lpc","duct","hpc","burn","hpt","duct","lpt","duct","nozzle"];
        NF = length(DP.F);
        
        % 部件进口-喉部-出口面积/内涵进口-外涵进口-出口面积（3*NF矩阵，需要）
        % DP.AREA(:,strcmpi(DP.F,"fan"))=[1/(1+B);B/(1+B);1];
        % 总压恢复系数
        DP.TPR=ones(1,NF);
        DP.TPR(strcmpi(DP.F,"inlet"))=-1;
        DP.TPR(strcmpi(DP.F,"duct"))=0.98;
        DP.TPR(strcmpi(DP.F,"outer duct"))=0.98;
        DP.TPR(strcmpi(DP.F,"nozzle"))=0.98;
        DP.TPR(strcmpi(DP.F,"burn"))=0.95;
        DP.TPRM=0.8;% 混合器总压恢复系数
        % 效率
        DP.EFFC=[0.87,0.89,0.83];% 压气机效率
        DP.EFFT=[0.88,0.91];% 涡轮效率
        DP.PRC_outerfan=1.765;
        DP.PRC=[1.344 2.004 11.317];% 压气机压比
        DP.PRT=[0 0];% 涡轮压比（计算得）
        DP.EB=[0.999,0.9];% 燃烧室效率（NB个）
        DP.E_mech=[0.985;0.985];%机械效率（NS个）
        DP.E_motor=[0.97,0.97];%发电机效率（NS个）
        DP.HU=43.124E6;% 燃料热值（NB个）
        DP.TO=1690;% 燃烧室温度（NB个）
        % 轴接
        DP.SHAFT=zeros(NS,NF);
        DP.SHAFT(1,strcmpi(DP.F,"fan"))=1;
        DP.SHAFT(1,strcmpi(DP.F,"lpt"))=1;
        DP.SHAFT(1,strcmpi(DP.F,"lpc"))=1;
        DP.SHAFT(2,strcmpi(DP.F,"hpc"))=1;
        DP.SHAFT(2,strcmpi(DP.F,"hpt"))=1;
        DP.WA_extraction=zeros(1,NF);
        DP.EXT=zeros(NW,NF);
        % 引气（待改进）
        DP.EXT(1,find(strcmpi(DP.F,"fan")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"hpt")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"lpt")))=1;
        DP.EXT(2,find(strcmpi(DP.F,"hpc")))=1;
        DP.EXT(2,find(strcmpi(DP.F,"hpt")))=1;
        % 引气量
        DP.WA_extraction(1,strcmpi(DP.F,"fan"))=0;
        DP.WA_extraction(1,strcmpi(DP.F,"lpc"))=0;
        DP.WA_extraction(1,strcmpi(DP.F,"hpc"))=0.1;
        DP.WA_extraction(1,strcmpi(DP.F,"hpt"))=0;
        DP.WA_extraction(1,strcmpi(DP.F,"lpt"))=0;
    case "3 spool mixed turbofan"
        %% 三轴混排涡扇
        NS=3;NW=1;
        DP.THRUST=98;% 推力需求
        DP.WA=0;% 空气流量
        DP.BYPASS_RATIO=5;
        % 部件图
        DP.F=["inlet","duct","fan","outer duct","lpc","duct","hpc","burn","hpt","duct","ipt","duct","lpt","mixer","afterburn","nozzle"];
        NF = length(DP.F);
        
        % 总压恢复系数
        DP.TPR=ones(1,NF);
        DP.TPR(strcmpi(DP.F,"inlet"))=-1;
        DP.TPR(strcmpi(DP.F,"duct"))=0.97;
        DP.TPR(strcmpi(DP.F,"outer duct"))=0.97;
        DP.TPR(strcmpi(DP.F,"nozzle"))=0.97;
        DP.TPR(strcmpi(DP.F,"burn"))=0.99;
        DP.TPR(strcmpi(DP.F,"afterburn"))=0.9;
        DP.TPRM=0.8;% 混合器总压恢复系数
        % 效率
        DP.EFFC=[0.79,0.79,0.79];% 压气机效率
        DP.EFFT=[0.89,0.89,0.89];% 涡轮效率
        DP.PRC_outerfan=1.5;
        DP.PRC=[2 3 7];% 压气机压比
        DP.PRT=[0 0 0];% 涡轮压比（计算得）
        DP.EB=[0.99,0.99];% 燃烧室效率（NB个）
        DP.E_mech=[0.985;0.985;0.985];%机械效率（NS个）
        DP.E_motor=[0.97,0.97,0.97];%发电机效率（NS个）
        DP.HU=[43.124E6,43.124E6];% 燃料热值（NB个）
        DP.TO=[1800,2200];% 燃烧室温度（NB个）
        % 轴接
        DP.SHAFT=zeros(NS,NF);
        DP.SHAFT(1,strcmpi(DP.F,"fan"))=1;
        DP.SHAFT(1,strcmpi(DP.F,"lpt"))=1;
        DP.SHAFT(2,strcmpi(DP.F,"lpc"))=1;
        DP.SHAFT(2,strcmpi(DP.F,"ipt"))=1;
        DP.SHAFT(3,strcmpi(DP.F,"hpc"))=1;
        DP.SHAFT(3,strcmpi(DP.F,"hpt"))=1;
        
        DP.WA_extraction=zeros(1,NF);
        DP.EXT=zeros(NW,NF);
        % 引气（待改进）
        DP.EXT(1,find(strcmpi(DP.F,"hpc")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"hpt")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"lpt")))=1;
        % 引气量
        DP.WA_extraction(1,strcmpi(DP.F,"hpc"))=0;
        DP.WA_extraction(1,strcmpi(DP.F,"hpt"))=0;
        DP.WA_extraction(1,strcmpi(DP.F,"lpt"))=0;

    case "3 spool separated turbofan"
        %% 三轴分排涡扇
        NS=3;NW=1;
        DP.flow="separated";
        DP.THRUST=98;% 推力需求
        DP.WA=313.798;% 空气流量
        DP.BYPASS_RATIO=4.9373;
        % 部件图
        DP.F=["inlet","duct","fan","duct","lpc","duct","hpc","burn","hpt","duct","ipt","duct","lpt","duct","afterburn","nozzle"];
        NF = length(DP.F);
        
        % 总压恢复系数
        DP.TPR=ones(1,NF);
        DP.TPR(strcmpi(DP.F,"inlet"))=-1;
        DP.TPR(strcmpi(DP.F,"duct"))=0.97;
        DP.TPR(strcmpi(DP.F,"outer duct"))=0.97;
        DP.TPR(strcmpi(DP.F,"nozzle"))=0.97;
        DP.TPR(strcmpi(DP.F,"burn"))=0.95;
        DP.TPR(strcmpi(DP.F,"afterburn"))=0.9;
        DP.TPRM=0.8;% 混合器总压恢复系数
        % 效率
        DP.EFFC=[0.89,0.8777,0.8677];% 压气机效率
        DP.EFFT=[0.89,0.89,0.89];% 涡轮效率
        DP.PRC_outerfan=1.655;
        DP.PRC=[1.5 2.18 11.069];% 压气机压比
        DP.PRT=[0 0 0];% 涡轮压比（计算得）
        DP.EB=[0.999,0.9];% 燃烧室效率（NB个）
        DP.E_mech=[0.985;0.985;0.985];%机械效率（NS个）
        DP.E_motor=[0.97,0.97,0.97];%发电机效率（NS个）
        DP.HU=[43.124E6,43.124E6];% 燃料热值（NB个）
        DP.TO=[1577.55,2200];% 燃烧室温度（NB个）
        % 轴接
        DP.SHAFT=zeros(NS,NF);
        DP.SHAFT(1,strcmpi(DP.F,"fan"))=1;
        DP.SHAFT(1,strcmpi(DP.F,"lpt"))=1;
        DP.SHAFT(2,strcmpi(DP.F,"lpc"))=1;
        DP.SHAFT(2,strcmpi(DP.F,"ipt"))=1;
        DP.SHAFT(3,strcmpi(DP.F,"hpc"))=1;
        DP.SHAFT(3,strcmpi(DP.F,"hpt"))=1;
        DP.WA_extraction=zeros(1,NF);
        DP.EXT=zeros(NW,NF);
        % 引气（待改进）
        DP.EXT(1,find(strcmpi(DP.F,"hpc")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"hpt")))=1;
        DP.EXT(1,find(strcmpi(DP.F,"lpt")))=1;
        % 引气量
        DP.WA_extraction(1,strcmpi(DP.F,"hpc"))=0;
        DP.WA_extraction(1,strcmpi(DP.F,"hpt"))=0;
        DP.WA_extraction(1,strcmpi(DP.F,"lpt"))=0;
end
DP=INPUT_TURBO_COMMON_TAIL(DP,NS,NW,NF);
