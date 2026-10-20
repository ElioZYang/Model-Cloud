function DP = INPUT_TURBO_COMMON_TAIL(DP, NS, NW, NF)
%INPUT_TURBO_COMMON_TAIL Apply the shared legacy INPUT_TURBO finalisation.
% The assignment order is intentionally the same as INPUT_TURBO.m.  Do not
% reshape or broadcast values here; MATLAB's native indexing and assignment
% behaviour is part of the legacy contract.
DP.SECOND_FLOW=zeros(4,NF);
DP.PRESSURE_RATIO=prod(DP.PRC);
DP.STRUCTURE=[DP.F;DP.SHAFT;DP.WA_extraction];
NN = sum(strcmpi(DP.F, "nozzle") | strcmpi(DP.F, "fan"));
NC = sum(strcmpi(DP.F, "lpc") | strcmpi(DP.F, "ipc") | strcmpi(DP.F, "hpc") | strcmpi(DP.F, "fan"));
NT = sum(strcmpi(DP.F, "lpt") | strcmpi(DP.F, "ipt") | strcmpi(DP.F, "hpt"));
NB = sum(strcmpi(DP.F, "burn") | strcmpi(DP.F, "afterburn"));
NBY = sum(strcmpi(DP.F, "fan"));
NM = sum(strcmpi(DP.F, "pmsm 0d"))+sum(strcmpi(DP.F, "hpcgv pmsm"));
NM1 = sum(strcmpi(DP.F, "hpcgv pmsm"));
DP.PWG=zeros(NS,1);
DP.Q=zeros(1,NF);% 热量增加值
DP.N_ref=ones(NS,1);% 用于非设计点计算
DP.dN_partial=zeros(NS,1);
DP.N=1E4*ones(NS,1);% 转速
DP.J=2*ones(NS,1);
DP.T_REQ=-1;
DP.NS=NS;
DP.NW=NW;
DP.NN=NN;
DP.NC=NC;
DP.NT=NT;
DP.NB=NB;
DP.NBY=NBY;
DP.NF=NF;
DP.NM=NM;
DP.NM1=NM1;
DP.EFF_heat_exchange=ones(NM,1);
DP.COMP_WP=ones(2*NC,1);
DP.TURB_WP=ones(2*NT,1);
DP.N_REF=ones(NS,1);
DP.M_ext=0.03;
if(sum(strcmpi(DP.F,"mixer")))
    DP.M_mixed=0.5;
end
end
