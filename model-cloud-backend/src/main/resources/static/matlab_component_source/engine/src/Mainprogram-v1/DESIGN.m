% 进行涡轮发动机的设计点分析
function [YD,DP]=DESIGN(XD,DP)
% MAP=DP.MAP;
nx=1;
if DP.WA<=0
    WA=XD(nx);% 对推力有要求
    nx=nx+1;
else
    WA=DP.WA;% 对推力无要求
end
YD=[];
PRT0=DP.PRT;
PRT=PRT0;
for nt=1:DP.NT
    if PRT(nt)<=0
        PRT(nt)=XD(nx);
        nx=nx+1;
    end
end
NH=DP.NH;NM1=DP.NM1;
dT_pmsm_partial=[];
temp_pmsm=DP.temp_pmsm;
temp_pmsm_ref=DP.temp_pmsm_ref;
for nm1=1:NM1
    for nh=1:NH
        if temp_pmsm_ref(nh,nm1)<0
        temp_pmsm(nh,nm1)=XD(nx);
        nx=nx+1;
        end
    end
end
DP.temp_pmsm=temp_pmsm;
DP.dT_pmsm_partial=0*temp_pmsm;
% NC,NT,NS,NB分别指压气机（含风扇）、涡轮、轴、燃烧室数量
% H=DP.H;% 高度
% DT=DP.DT;% 与大气温差（K）
% QP=DP.QP;% 与大气压强之比（%）
% D=DP.D;% 湿度
V=DP.V;% 速度（m/s）
F=DP.F;% 部件图（eg.['inlet','duct','compressor','burn','turbine','afterburn','nozzle']共NF个元素）
NF=DP.NF;
PRC=DP.PRC;% 设计点压气机压比（NC个）
PRC_outerfan=DP.PRC_outerfan;
% PRT=0，待求解；PRT≠0，该轴对功率无要求
EFFC=DP.EFFC;% 设计点压气机效率（NC个）
% 涡轮膨胀比经计算得到
EFFT=DP.EFFT;% 涡轮效率（NT个）
EB=DP.EB;% 燃烧室效率（NB个）
TO=DP.TO;% 燃烧室后温度（NB个）
HU=DP.HU;% 燃料热值（NB个）
SHAFT=DP.SHAFT;% NS*NF ARRAY,表示旋转部件连接关系（例如[1 0 1 1 0;0 1 0 0 1]表示1、3、4共轴，2、5共轴）
SHAFT_CONTROL=DP.SHAFT_CONTROL;
PW=0*SHAFT;% NS*NF ARRAY,表示旋转部件输出功率大小
PWS_max=zeros(DP.NS,1);
TPR=DP.TPR;% 总压恢复系数（NF个）
E_mech=DP.E_mech;% 机械效率（NS*1矩阵）
E_motor=DP.E_motor;% 电机效率（NS*1矩阵）
E_heat=DP.EFF_heat_exchange;
nc=0;
nt=0;
nb=0;
nm=0;
THRUST=0;
PW_REF=0;% 动能增加量
GAS_PROPERTY=[];
WCOR=[];
GAS_PROPERTY_1=GAS_PROPERTY;
SECOND_FLOW=DP.SECOND_FLOW;
Q=DP.Q;
EXT=DP.EXT;
WA_extraction=DP.WA_extraction;
DP.AN_outerfan=-1;
PRN=[];
dT_air=[];
for k=1:NF
    if(strcmpi(F(k),"inlet"))
        I_inlet.V=DP.V;
        I_inlet.M=DP.M;
        I_inlet.H=DP.H;
        I_inlet.DT=DP.DT;
        I_inlet.QP=DP.QP;
        I_inlet.D=DP.D;
        I_inlet.FAR=0;
        I_inlet.TPR=TPR(k);
        I_inlet.WA=WA;
        I_inlet.mode="design";
        O=INLET(I_inlet);
        DP.TPR_intake=O.TPR;
        WCOR(k)=O.WCOR;
        DP.WA_cor=O.WCOR;
        Ps0=O.Ps0;
        Ts0=O.Ts0;
        DP.M=O.M;
        if DP.M>0
            DP.M_ext=DP.M;
        end
        DP.V=O.V;
        T0=O.T0;
        P0=O.P0;
        DP.T0=T0;
        DP.P0=P0;
        GAS_PROPERTY=[GAS_PROPERTY,[O.WA;O.FAR;O.P;O.T]];
        THRUST=THRUST-WA*DP.V/1000;
    end
    if(strcmpi(F(k),"fan"))
        nc=nc+1;
        I_fan=O;
        I_fan.PR=PRC(nc);
        I_fan.EFF=EFFC(nc);
        I_fan.N=DP.N'*DP.SHAFT(:,k);
        I_fan.WA_extraction=WA_extraction(k);
        I_fan.mode="design";
        I_fan.WA=O.WA/(1+DP.BYPASS_RATIO);
        I_fan1=I_fan;
        I_fan1.WA_extraction=0;
        I_fan1.PR=PRC_outerfan;
        I_fan1.WA=WA*DP.BYPASS_RATIO/(1+DP.BYPASS_RATIO);
        O=COMPRESSOR(I_fan);
        O1=COMPRESSOR(I_fan1);
        DP.PWC(nc)=O.PWC+O1.PWC;
        DP.WAC(nc)=O.WAC;
        DP.WAC_outerfan=O1.WAC;
        DP.NC0(nc)=O.NC0;
        dPW=SHAFT(:,k)*(O.PWC+O1.PWC);
        PW(:,k)=PW(:,k)-dPW;
        SECOND_FLOW(:,k)=[I_fan.WA;O.FAR;O.P;O.T];
        if strcmpi(DP.flow,"separated") % 分排
            O1.TPR=TPR(k);
            O1.TR=DP.THRUST>1E-3;
            O1.M_ext=DP.M_ext;
            O1.V0=DP.V;
            O2=NOZZLE(O1);
            PRN=[PRN,O2.PR];
            WCOR(k)=O2.WCOR;
            DP.AN_outerfan=O2.AN;
            PW_REF=PW_REF+O2.WA*0.5*(O2.V)^2/1000;
            THRUST=THRUST+O2.THRUST;
            DP.THRUST_fan=THRUST;
        end
        GAS_PROPERTY=[GAS_PROPERTY,[O.WA;O.FAR;O.P;O.T]];
    end
    if(strcmpi(F(k),"duct"))
        I_duct=O;
        I_duct.TPR=TPR(k);
        I_duct.WA_extraction=WA_extraction(k);
        I_duct.dH=Q(k);% 与外界的换热量
        I_duct.mode="design";
        O=DUCT(I_duct);
        WCOR(k)=O.WCOR;
        SECOND_FLOW(:,k)=[O.WA/(1-WA_extraction(k));O.FAR;O.P;O.T];
        GAS_PROPERTY=[GAS_PROPERTY,[O.WA;O.FAR;O.P;O.T]];
    end
    if(strcmpi(F(k),"outer duct"))
        I_outerduct=O1;
        I_outerduct.WA_extraction=WA_extraction(k);
        I_outerduct.TPR=TPR(k);
        I_outerduct.dH=Q(k);% 与外界的换热量
        I_outerduct.mode="design";
        O1=DUCT(I_outerduct);
        WCOR(k)=O1.WCOR;
        SECOND_FLOW(:,k)=[O.WA/(1-WA_extraction(k));O.FAR;O.P;O.T];
        GAS_PROPERTY_1=[GAS_PROPERTY_1,[O1.WA;O1.FAR;O1.P;O1.T]];
    end
    if(strcmpi(F(k),"lpc")||strcmpi(F(k),"hpc")||strcmpi(F(k),"ipc"))
        nc=nc+1;
        I_comp=O;
        I_comp.PR=PRC(nc);
        I_comp.EFF=EFFC(nc);
        I_comp.N=DP.N'*DP.SHAFT(:,k);
        I_comp.WA_extraction=WA_extraction(k);
        I_comp.mode="design";
        O=COMPRESSOR(I_comp);
        DP.PWC(nc)=O.PWC;
        DP.WAC(nc)=O.WAC;
        DP.NC0(nc)=O.NC0;
        dPW=SHAFT(:,k)*O.PWC;
        PW(:,k)=PW(:,k)-dPW;
        SECOND_FLOW(:,k)=[O.WA/(1-WA_extraction(k));O.FAR;O.P;O.T];
        GAS_PROPERTY=[GAS_PROPERTY,[O.WA;O.FAR;O.P;O.T]];
    end
    if(strcmpi(F(k),"burn"))
        nb=nb+1;
        I_burn=O;
        I_burn.TO=TO(nb);
        I_burn.HU=HU(nb);
        I_burn.EB=EB(nb);
        I_burn.KB=0;
        I_burn.WF=0;
        I_burn.TPR=TPR(k);
        O=BURN(I_burn);
        DP.FAR(nb)=O.FAR;
        DP.KB(nb)=O.KB;
        GAS_PROPERTY=[GAS_PROPERTY,[O.WA;O.FAR;O.P;O.T]];
    end
    if(strcmpi(F(k),"lpt")||strcmpi(F(k),"hpt")||strcmpi(F(k),"ipt"))
        nt=nt+1;
        I_turb=O;
        I_turb.EFF=EFFT(nt);
        I_turb.N=DP.N'*DP.SHAFT(:,k);
        I_turb.mode="design";
        I_turb.PR=PRT(nt);
        DP.PRT(nt)=PRT(nt);
        % 压气机引气混合
        if WA_extraction(k)>=1E-6
        WA_extra=WA_extraction(k)*sum(WA_extraction.*SECOND_FLOW(1,:));
        FAR_extra=EXT(k)*sum(EXT.*SECOND_FLOW(2,:));
        P_extra=EXT(k)*sum(EXT.*SECOND_FLOW(3,:));
        T_extra=EXT(k)*sum(EXT.*SECOND_FLOW(4,:));
        I_hotflow=I_turb;
        I_hotflow.AREA=[I_turb.WA*(1+I_turb.FAR);WA_extra;0];
        I_coldflow.WA=WA_extra;
        I_coldflow.FAR=FAR_extra;
        I_coldflow.D=DP.D;
        I_coldflow.P=P_extra;
        I_coldflow.T=T_extra;
        I_coldflow.TPR=DP.TPRM;
        OUTPUT=MIXER(I_hotflow,I_coldflow);
        I_turb.WA=OUTPUT.WA;
        I_turb.FAR=OUTPUT.FAR;
        I_turb.T=OUTPUT.T;
        I_turb.P=OUTPUT.P;
        I_turb.D=OUTPUT.D;
        end
        % 涡轮性能计算
        O=TURBINE(I_turb);
        DP.PWT(nt)=O.PWT;
        DP.WGC(nt)=O.WGC;
        DP.NT0(nt)=O.NT0;
        dPW=SHAFT(:,k)*O.PWT;
        PW(:,k)=PW(:,k)-dPW;
        PWS_max=PWS_max-dPW;
        GAS_PROPERTY=[GAS_PROPERTY,[O.WA;O.FAR;O.P;O.T]];
    end
    if(strcmpi(F(k),"pmsm 0d"))
        nm=nm+1;
        s=find(SHAFT_CONTROL==nm);
        I_motor=O;
        I_motor.mode="design";
        I_motor.NM=DP.N(s);
        I_motor.PWG=DP.PWG(s);
        I_motor.EFFM=E_motor(s);
        I_motor.Ts0=Ts0;
        O=MOTOR(I_motor);
        PWG_motor(nm)=O.PWG;
        PWH_motor(nm)=O.PWH;
        % 考虑机匣对气流影响
        I_duct=O;
        I_duct.TPR=TPR(k);
        I_duct.WA_extraction=WA_extraction(k);
        I_duct.dH=Q(k)+O.PWH*E_heat(nm);% 与外界的换热量
        I_duct.mode="design";
        O=DUCT(I_duct);
        dT_air=[dT_air;O.dT];
        WCOR(k)=O.WCOR;
        SECOND_FLOW(:,k)=[O.WA/(1-WA_extraction(k));O.FAR;O.P;O.T];
        GAS_PROPERTY=[GAS_PROPERTY,[O.WA;O.FAR;O.P;O.T]];
    end
    if(strcmpi(F(k),"hpcgv pmsm")) % 电磁+热耦合模型
        nm=nm+1;
        s=find(SHAFT_CONTROL==nm);
        I_motor=O;
        I_motor.mode="design";
        I_motor.pmsm_input=DP.pmsm_input(nm);
        I_motor.pmsm_input.thermal.temp_values=temp_pmsm(:,nm);
        I_motor.NM=DP.N(s);
        I_motor.PWG=DP.PWG(s);
        I_motor.EFFH=E_heat(nm);
        O=component_engine_pmsm(I_motor,DP,nm);
        dT_air=[dT_air;O.pmsm_params.thermal.dT_air];
        dT_pmsm_partial(:,nm)=O.pmsm_params.thermal.dT_pmsm_partial;
        dH_pmsm(:,nm)=O.pmsm_params.thermal.dH_pmsm_partial;
        pmsm_params=O.pmsm_params;
        DP.pmsm_parameters(nm)=pmsm_params;
        DP.TPR(k)=O.TPR;
        WCOR(k)=O.WCOR;
        E_motor(s)=pmsm_params.performance.efficiency;
        SECOND_FLOW(:,k)=[O.WA/(1-WA_extraction(k));O.FAR;O.P;O.T];
        GAS_PROPERTY=[GAS_PROPERTY,[O.WA;O.FAR;O.P;O.T]];
    end
    if(strcmpi(F(k),"mixer"))
        I_mixer=O;
        I_mixer.TPR=TPR(k);
        I_mixer1=O1;
        I_mixer.M_mixed=DP.M_mixed;
        [O]=MIXER(I_mixer,I_mixer1);
        DP.AN_mixer=O.AN_mixer;
        DP.M_unmixed=O.M_unmixed;
        DP.AN_outerfan=sum(O.AN_mixer);
        GAS_PROPERTY=[GAS_PROPERTY,[O.WA;O.FAR;O.P;O.T]];
    end
    if(strcmpi(F(k),"afterburn"))
        if DP.reheat==1
        nb=nb+1;
        I_afterburn=O;
        I_afterburn.TO=TO(nb);
        I_afterburn.HU=HU(nb);
        I_afterburn.EB=EB(nb);
        I_afterburn.TPR=TPR(k);
        O=AFTERBURN(I_afterburn);
        DP.FAR(nb)=O.FAR;
        DP.KB(nb)=O.KB;
        end
        GAS_PROPERTY=[GAS_PROPERTY,[O.WA;O.FAR;O.P;O.T]];
    end
    if(strcmpi(F(k),"nozzle"))
        I_nozzle=O;
        I_nozzle.TPR=TPR(k);
        I_nozzle.Ps0=Ps0;
        I_nozzle.PO=P0;
        I_nozzle.TO=T0;
        I_nozzle.V0=V;
        I_nozzle.WA0=WA;
        I_nozzle.TR=(DP.THRUST>sum(DP.PWG)/SV(ASP(DP.H,0,100),0,0)); %推力型发动机
        I_nozzle.M_ext=DP.M_ext;
        I_nozzle.mode="design";
        O=NOZZLE(I_nozzle);
        dP=O.dP;
        PRN=[PRN,O.PR];
        WCOR(k)=O.WCOR;
        DP.V_EXT=O.V;
        DP.AN=O.AN;
        PW_REF=PW_REF+O.WA*(1+O.FAR)*0.5*(O.V)^2/1000;
        THRUST=THRUST+O.THRUST;
        if THRUST<=0.001
            THRUST=0;
        end
        GAS_PROPERTY=[GAS_PROPERTY,[O.WA;O.FAR;O.P;O.T]];
    end
end
    DP.GAS_PROPERTY=[[WA;0;P0;T0],GAS_PROPERTY];
    DP.GAS_PROPERTY_1=GAS_PROPERTY_1;
    % 对外做功为正，吸收功率为负
    PWS=E_mech.*sum(PW,2); %轴功（NS*1矩阵,kW）
    % 计算轴功率残差
    PWG=zeros(DP.NS,1);PWH=PWG;
    if DP.WA<=0
        if DP.THRUST>sum(DP.PWG)/SV(ASP(DP.H,0,100),0,0) %推力型发动机
            YD=[YD;THRUST-DP.THRUST];
        else
            YD=[YD;dP];
        end
    end
    for k=1:DP.NS
        if PWS(k)>0
    PWG(k)=PWS(k)*E_motor(k);
        else
    PWG(k)=PWS(k)/E_motor(k);
        end
    PWH(k)=abs(PWS(k)-PWG(k));
    end
    nt=0;
    for k=1:DP.NF
    if (strcmpi(F(k),"lpt")||strcmpi(F(k),"hpt")||strcmpi(F(k),"ipt"))
        nt = nt+1;
        ns=find(SHAFT(:,k)==1);
        if PRT0(nt)<=0
            dPW=PWG(ns)-DP.PWG(ns);
            YD=[YD;dPW];
        end
    end
    end
    for k=1:DP.NM1
        for k1=1:DP.NH
            if temp_pmsm_ref(k1,k)<0
                YD=[YD;dT_pmsm_partial(k1,k)];
            end
        end
    end
    PW_REF=PW_REF+abs(sum(sum(PW)))-WA*0.5*V^2/1000;
    DP.WCOR=WCOR;
    DP.PRN=PRN;
    DP.PW_REF=PW_REF;
    DP.dT_air=dT_air;
    DP.temp_pmsm=temp_pmsm;
    DP.dT_pmsm_partial=dT_pmsm_partial;
    V_EXT_cor=(2*(1000*PW_REF/WA+0.5*V^2))^0.5;
    THRUST_REF=WA*(V_EXT_cor-V)/1000;
    DP.THRUST_REF=THRUST_REF;
    DP.THRUST=THRUST;
    DP.PW=PW;
    DP.PWS_max=PWS_max;
    DP.PWS=PWS;
    DP.PWG=PWG;
    DP.E_motor=E_motor;
    DP.PWG_rated=PWG;
    DP.PWH=PWH;%产热（kW）
    DP.PWE=sum(DP.PWG);%总的电功率输出（kW）
    DP.WF=O.WA*O.FAR;%总的耗油量（kg/s）
    DP.EFF=DP.PW_REF/(DP.WF*DP.HU(1)/1000);    
    DP.EFF_turboelectric=DP.PWE/(DP.WF*DP.HU(1)/1000);  
    DP.SFC=3.6E3*DP.WF/DP.PW_REF;
    DP.WA=WA;
    DP.XD=XD;
%     fprintf('design process completed!\n')
end
