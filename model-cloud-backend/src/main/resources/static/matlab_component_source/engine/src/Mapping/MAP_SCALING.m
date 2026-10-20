% 由已知压气机MAP图缩放得到新MAP图（KURKZE-PROPULSION AND POWER）
% 输入原MAP图，新MAP图压比/膨胀比，得到新MAP图
function[MAP1]=MAP_SCALING(MAP0,PR1)
k=1.4;kk=(k-1)/k;
MAP1=MAP0;
PR0=MAP0.PR0;% 原MAP图的设计点压比
EFF0=MAP0.EFF0;% 原MAP图的设计点效率
MAP1.PR0=PR1;
flowtype=MAP0.flowtype;% 流道
maxeff=MAP0.maxeff;% 最大效率线的位置
pr=MAP0.PR;% 相对压比图(PR-1)/(PR_design-1)
pr_abs=pr*(PR0-1)+1;% 原MAP绝对压比
pr_abs_1=pr*(PR1-1)+1;% 新MAP绝对压比
wcor=MAP0.WCOR;
eff=MAP0.EFF;% 效率
ncor=MAP0.NCOR;% 相对换算转速
% N=[0 0.2 0.4 0.6 0.8 1.0]
% W=[NX*NN] 由堵塞（当前转速最大流量）向喘振（当前转速最小流量）发展
wcor_surge=wcor(1,:);wcor_maxeff=wcor(maxeff,:);wcor_choke=wcor(end,:);
wcor_range80=interp1(ncor.^2,wcor_choke,0.8.^2)-interp1(ncor.^2,wcor_surge,0.8.^2);
pr_max_eff=pr(maxeff,:);
switch flowtype
    case "axial"
% AXIAL FLOW COMPRESSOR
pr_ref_1=0.1961+0.08*log(PR1);% 50%流量对应的相对压比(PR-1)/(PR_design-1)
wcor_range80_1=0.1751*exp(-0.1042*PR1);% 80%转速对应的相对换算流量范围
    case "centrifugal"
% CENTRIFUGAL COMPRESSOR
pr_ref_1=0.33;% 50%流量对应的相对压比(PR-1)/(PR_design-1)
wcor_range80_1=0.14;% 80%转速对应的相对换算流量范围
end
    kw=wcor_range80_1/wcor_range80;
    xcp=((1-pr_ref_1)^2-3/4)/(1-2*pr_ref_1);% 最大效率线圆弧中心
    ycp=1-xcp;
    rr=xcp^2+ycp^2;
    wcor_maxeff_1=xcp+(rr-(pr_max_eff-ycp).^2).^0.5;
    wcor_choke_1=kw*(wcor_choke-wcor_maxeff)+wcor_maxeff_1;
    wcor_1=wcor_choke_1-kw*(wcor_choke-wcor);
    ncor1=ncor.*(pr_abs_1(maxeff,:).^kk-1)./(pr_abs(maxeff,:).^kk-1)*(PR0^kk-1)/(PR1^kk-1);
    eff_polytropic=kk*log(PR0)./log((PR0^kk-1)./eff/EFF0+1);
    eff_1=(pr_abs_1.^kk-1)./(pr_abs_1.^(kk./eff_polytropic)-1);
    MAP1.EFF0=(PR1.^kk-1)./(PR1.^(kk./(kk*log(PR0)./log((PR0^kk-1)./EFF0+1)))-1);
    MAP1.WCOR=wcor_1;
    MAP1.NCOR=ncor1;
    MAP1.EFF=eff_1/MAP1.EFF0;
end