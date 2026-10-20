function [YO,OP]=OFFDESIGN(XO,DP,OP)
MAP=DP.MAP;
XO=real(XO);
% 进行涡扇发动机的设计点分析Y=OFFDESIGN(X,DP,OP);
% X包括压气机&涡轮BETA值共NC+NT个，转轴转速NS个，共NC+NT+NS个方程
% Y包括NC+NT-1个流量平衡方程，NS个功率平衡方程，1个推力平衡方程，共NC+NT+NS个方程
N_ref=OP.N_ref;% 非设计点设定转速
temp_pmsm_ref=OP.temp_pmsm_ref;
temp_pmsm0=DP.temp_pmsm;
temp_pmsm=OP.temp_pmsm;
dT_pmsm_partial=DP.dT_pmsm_partial;
lastvalue=1+DP.NBY;
nextvalue=lastvalue-1+DP.NC;
% 部件MAP插值参数赋值
R_COMP=XO(lastvalue:nextvalue); % 非设计点压气机BETA值
lastvalue=nextvalue+1;nextvalue=nextvalue+DP.NT;
R_TURB=XO(lastvalue:nextvalue); % 非设计点涡轮BETA值
OP.R_COMP=R_COMP;
OP.R_TURB=R_TURB;
N_REF=N_ref;
COMP_WP=[];
COMP_SURGE=[];
COMP_CHOKE=[];
COMP_OVERLOAD=[];
TURB_WP=[];
TURB_OVERLOAD=[];
MOTOR_WP=[];
WA1=0;
WF=0;
P_airflow=10;% Punish Factor For air flow
k=1;
E_mech=OP.E_mech;% 机械效率（NS*1矩阵）
E_motor=OP.E_motor;
E_heat=OP.EFF_heat_exchange;
PWG_motor=OP.PWG;
PWS_motor=DP.PWS;
% 转速赋值
for n=1:DP.NS
    if N_ref(n)<0
    N_REF(n)=XO(nextvalue+k);% 非设计点相对换算转速未知
    k=k+1;
    end
    if PWG_motor(n)<0
        PWS_motor(n)=PWG_motor(n)*E_motor(n);
    else
        PWS_motor(n)=PWG_motor(n)/E_motor(n);
    end
end
PWH_motor=abs(PWG_motor-PWS_motor);
% 核心温度赋值
for nm=1:DP.NM1
    for nh=1:DP.NH
    if temp_pmsm_ref(nh,nm)<0
    temp_pmsm(nh,nm)=XO(nextvalue+k)*temp_pmsm0(nh,nm);
    k=k+1;
    end
    end
end
OP.temp_pmsm=temp_pmsm;
OP.N_REF=N_REF;
OP.N=N_REF.*DP.N;
T_REQ=OP.T_REQ;
% 涡轮前温度赋值
if T_REQ>0
    XB=XO(end);
end
dT_air=[];
% 下标1代表外涵道
% NC,NT,NS,NB分别指压气机（含风扇）、涡轮、轴、燃烧室数量
H=OP.H;% 高度
DT=OP.DT;% 与大气温差（K）
QP=OP.QP;% 与大气压强之比（%）
M=OP.M;% 马赫数
V=OP.V;% 速度
D=OP.D;% 湿度
F=DP.F;% 部件图（eg.['inlet','duct','compressor','burn','turbine','afterburn','nozzle']共NF个元素）
NF=DP.NF;% 部件数
% PRC=DP.PRC;% 设计点压气机压比（NC个）
% EFFC=DP.EFFC;% 设计点压气机效率（NC个）
% PRT=DP.PRT;% 设计点涡轮膨胀比（NT个）
% EFFT=DP.EFFT;% 涡轮效率（NT个）
EB=OP.EB;% 燃烧室效率（NB个）
HU=OP.HU;% 燃料热值（NB个）
SHAFT=DP.SHAFT;% NS*NF ARRAY,表示旋转部件连接关系（例如[1 0 1 1 0;0 1 0 0 1]表示1、3、4共轴，2、5共轴）
SHAFT_CONTROL=DP.SHAFT_CONTROL;
PW=0*SHAFT;% NS*NF ARRAY,表示旋转部件输出功率大小
PWS_max=zeros(DP.NS,1);
TPR=DP.TPR;% 总压恢复系数（NF个）
WCOR=DP.WCOR;
THRUST=0;
PRN=[];
PW_REF=0;% 动能增加量
GAS_PROPERTY=[];
GAS_PROPERTY_1=GAS_PROPERTY;
SECOND_FLOW=OP.SECOND_FLOW;
WA_extraction=OP.WA_extraction;
Q=OP.Q;
EXT=DP.EXT;
nn=0;nc=0;nt=0;nm=0;nb=0;YO=[];
YO_element=[];XO_element=[];
for k=1:NF
    if(strcmpi(F(k),"inlet"))
        I_inlet.H=H;
        I_inlet.DT=DT;
        I_inlet.QP=QP;
        I_inlet.V=V;
        I_inlet.M=M;
        I_inlet.D=D;
        I_inlet.FAR=0;
        I_inlet.WCOR=DP.WA_cor;
        I_inlet.WA_cor_ref=1;
        I_inlet.TPR=TPR(k);
        I_inlet.mode="offdesign";
        O=INLET(I_inlet);
        WA0=O.WA;
        OP.WA=WA0;
        M=O.M;
        V=O.V;
        OP.M=M;
        OP.V=V;
        THRUST=THRUST-WA0*OP.V/1000;
        T0=O.T0;
        P0=O.P0;
        Ts0=O.Ts0;
        Ps0=O.Ps0;
        GAS_PROPERTY=[GAS_PROPERTY,[O.WA;O.FAR;O.P;O.T]];
    end
    if(strcmpi(F(k),"fan"))
        B=DP.BYPASS_RATIO*XO(2);
        OP.BYPASS_RATIO=B;
        nc=nc+1;
        I_fan=O;
        I_fan.N=OP.N'*DP.SHAFT(:,k);
        I_fan.R=R_COMP(nc);
        I_fan.WA=WA0/(1+B);
        I_fan.WA_extraction=WA_extraction(k);
        I_fan.mode="offdesign";
        I_fan.MAP=MAP.COMPRESSOR(nc);
        I_fan.NC0=DP.NC0(nc);
        I_fan.WAC0=DP.WAC(nc);
        I_fan.PRC0=DP.PRC(nc);
        I_fan.EFFC0=DP.EFFC(nc);
        I_fan1=I_fan;
        I_fan1.WA=WA0*B/(1+B);
        I_fan1.WA_extraction=0;
        I_fan1.WAC0=DP.WAC_outerfan;
        I_fan1.PRC0=DP.PRC_outerfan;
        O=COMPRESSOR(I_fan);
        COMP_SURGE=[COMP_SURGE,O.surge];
        COMP_CHOKE=[COMP_CHOKE,O.choke];
        COMP_OVERLOAD=[COMP_OVERLOAD,O.overload];
        if nc>1
        YO=[YO;P_airflow*O.DW];
        YO_element=[YO_element;"air flow"];
        XO_element=[XO_element;[F(k),"beta/airflow"]];
        else
            OP.WA=O.WA*(1+B)/B;
        end
        O1=COMPRESSOR(I_fan1);
        OP.PWC(nc)=O.PWC+O1.PWC;
        OP.NC_ref(nc)=O.NCOR_ref;
        OP.WAC_ref(nc)=O.WAC_ref;
        OP.EFFC(nc)=O.EFF;
        OP.PRC(nc)=O.PR;
        OP.PRC_ref(nc)=O.PR_ref;
        COMP_WP=[COMP_WP;O.WAC_ref;O.PR_ref];
        dPW=SHAFT(:,k)*(O.PWC+O1.PWC);
        PW(:,k)=PW(:,k)-dPW; % 混排（无推力）
        SECOND_FLOW(:,k)=[I_fan.WA;O.FAR;O.P;O.T];
        if strcmpi(DP.flow,"separated") % 分排
            nn=nn+1;
            O1.TPR=TPR(k);
            O1.WCOR=WCOR(k);
            O1.AN=DP.AN_outerfan;
            O1.PR0=DP.PRN(nn);
            O1.V0=OP.V;
            O2=NOZZLE(O1);
            PRN=[PRN,O2.PR];
            YO=[YO;O2.DW];
            YO_element=[YO_element;"air flow"];
            XO_element=[XO_element;["bypass","BPR"]];
            WA1=O2.WA;
            PW_REF=PW_REF+O2.WA*0.5*(O2.V)^2/1000;
            THRUST=THRUST+O2.THRUST;
            OP.THRUST_fan=THRUST;
        end
        GAS_PROPERTY=[GAS_PROPERTY,[O.WA;O.FAR;O.P;O.T]];
    end
    if(strcmpi(F(k),"duct"))
        I_duct=O;
        I_duct.TPR=TPR(k);
        I_duct.WCOR=WCOR(k);
        I_duct.WA_extraction=WA_extraction(k);
        I_duct.dH=Q(k);
        I_duct.mode="offdesign";
        O=DUCT(I_duct);
        SECOND_FLOW(:,k)=[I_duct.WA;O.FAR;O.P;O.T];
        GAS_PROPERTY=[GAS_PROPERTY,[O.WA;O.FAR;O.P;O.T]];
    end
    if(strcmpi(F(k),"outer duct"))
        I_outerduct=O1;
        I_outerduct.TPR=TPR(k);
        I_outerduct.WCOR=WCOR(k);
        I_outerduct.WA_extraction=WA_extraction(k);
        I_outerduct.dH=Q(k);
        I_outerduct.mode="offdesign";
        O1=DUCT(I_outerduct);
        SECOND_FLOW(:,k)=[I_outerduct.WA;O.FAR;O.P;O.T];
        GAS_PROPERTY_1=[GAS_PROPERTY_1,[O1.WA;O1.FAR;O1.P;O1.T]];    
    end
    if(strcmpi(F(k),"lpc")||strcmpi(F(k),"hpc")||strcmpi(F(k),"ipc"))
        nc=nc+1;
        I_comp=O;
        I_comp.N=OP.N'*DP.SHAFT(:,k);
        I_comp.R=R_COMP(nc);
        I_comp.WA_extraction=WA_extraction(k);
        I_comp.mode='offdesign';
        I_comp.MAP=MAP.COMPRESSOR(nc);
        I_comp.NC0=DP.NC0(nc);
        I_comp.WAC0=DP.WAC(nc);
        I_comp.PRC0=DP.PRC(nc);
        I_comp.EFFC0=DP.EFFC(nc);
        O=COMPRESSOR(I_comp);
        COMP_SURGE=[COMP_SURGE,O.surge];
        COMP_CHOKE=[COMP_CHOKE,O.choke];
        COMP_OVERLOAD=[COMP_OVERLOAD,O.overload];
        OP.PWC(nc)=O.PWC;
        OP.NC_ref(nc)=O.NCOR_ref;
        OP.WAC_ref(nc)=O.WAC_ref;
        OP.EFFC(nc)=O.EFF;
        OP.PRC_ref(nc)=O.PR_ref;
        OP.PRC(nc)=O.PR;
        COMP_WP=[COMP_WP;O.WAC_ref;O.PR_ref];
        dPW=SHAFT(:,k)*O.PWC;
        PW(:,k)=PW(:,k)-dPW;
        % 考虑引气
        SECOND_FLOW(:,k)=[I_comp.WA;O.FAR;O.P;O.T];
        if nc>1
        YO=[YO;P_airflow*O.DW];
        YO_element=[YO_element;"air flow"];
        XO_element=[XO_element;[F(k),"beta"]];
        else
        OP.WA=O.WA;
        end

        GAS_PROPERTY=[GAS_PROPERTY,[O.WA;O.FAR;O.P;O.T]];
    end
    if(strcmpi(F(k),"burn"))
        nb=nb+1;
        I_burn=O;
        if T_REQ>0 % 是否指定非设计点推力？
        I_burn.TO=XB*DP.TO(end);
        else
        I_burn.TO=OP.TO(nb);
        end
        I_burn.KB=DP.KB(nb);
        I_burn.WF=OP.WF;
        I_burn.HU=HU(nb);
        I_burn.EB=EB(nb);
        I_burn.TPR=TPR(k);
        O=BURN(I_burn);
        OP.TO(nb)=O.T;
        WF=WF+O.WF;
        OP.FAR(nb)=O.FAR;
        OP.KB(nb)=O.KB;
        GAS_PROPERTY=[GAS_PROPERTY,[O.WA;O.FAR;O.P;O.T]];
    end
    if(strcmpi(F(k),"lpt")||strcmpi(F(k),"hpt")||strcmpi(F(k),"ipt"))
        nt=nt+1;
        I_turb=O;
        I_turb.N=OP.N'*DP.SHAFT(:,k);
        I_turb.R=R_TURB(nt);
        I_turb.mode='offdesign';
        I_turb.MAP=MAP.TURBINE(nt);
        I_turb.NT0=DP.NT0(nt);
        I_turb.WGC0=DP.WGC(nt);
        I_turb.PRT0=DP.PRT(nt);
        I_turb.EFFT0=DP.EFFT(nt);
        I_turb.PR=DP.PRT(nt)*OP.PRC(nc)/DP.PRC(nc);
        % 压气机引气混合
        if WA_extraction(k)>=1E-6
        WA_extra=WA_extraction(k)*sum(WA_extraction.*SECOND_FLOW(1,:));
        FAR_extra=EXT(k)*sum(EXT.*SECOND_FLOW(2,:));
        P_extra=EXT(k)*sum(EXT.*SECOND_FLOW(3,:));
        T_extra=EXT(k)*sum(EXT.*SECOND_FLOW(4,:));
        I_coldflow=I_turb;
        I_coldflow.AREA=[I_turb.WA*(1+I_turb.FAR);WA_extra;0];
        I_hotflow.WA=WA_extra;
        I_hotflow.FAR=FAR_extra;
        I_hotflow.D=OP.D;
        I_hotflow.P=P_extra;
        I_hotflow.T=T_extra;
        I_hotflow.TPR=OP.TPRM;
        OUTPUT=MIXER(I_coldflow,I_hotflow);
        I_turb.WA=OUTPUT.WA;
        I_turb.FAR=OUTPUT.FAR;
        I_turb.P=OUTPUT.P;
        I_turb.T=OUTPUT.T;
        I_turb.D=OUTPUT.D;
        end
        % 涡轮性能计算
        O=TURBINE(I_turb);
        TURB_OVERLOAD=[TURB_OVERLOAD,O.overload];
        OP.PWT(nt)=O.PWT;
        OP.PRT_ref(nt)=O.PR_ref;
        OP.PRT(nt)=O.PR;
        OP.PWT(nt)=O.PWT;
        OP.WGC_ref(nt)=O.WGC_ref;
        OP.NT_ref(nt)=O.NCOR_ref;
        TURB_WP=[TURB_WP;O.WGC_ref*N_REF'*OP.SHAFT(:,k);O.PR_ref];
        dPW=SHAFT(:,k)*O.PWT;
        PW(:,k)=PW(:,k)-dPW;
        PWS_max=PWS_max-dPW;
        YO=[YO;P_airflow*O.DW];
        YO_element=[YO_element;"air flow"];
        XO_element=[XO_element;[F(k),"beta"]];
        GAS_PROPERTY=[GAS_PROPERTY,[O.WA;O.FAR;O.P;O.T]];
    end
    if(strcmpi(F(k),"pmsm 0d"))
        nm=nm+1;
        s=find(SHAFT_CONTROL==nm);
        I_motor=O;
        I_motor.mode="offdesign";
        I_motor.PWG=OP.PWG(s);
        I_motor.N_ref=N_REF(s);
        I_motor.NM=DP.N(s);
        I_motor.PWG_rated=DP.PWG_rated(s);
        I_motor.MAP=MAP.MOTOR(nm);
        I_motor.EFFM=OP.E_motor(s);
        I_motor.Ts0=Ts0;
        O=MOTOR(I_motor);
        PWS_motor(s)=O.PWS;
        PWG_motor(s)=O.PWG;
        PWH_motor(s)=O.PWH;
        MOTOR_WP=[MOTOR_WP;O.WP];
        I_duct=O;
        I_duct.TPR=TPR(k);% 考虑增加换热器对TPR的影响
        I_duct.WCOR=WCOR(k);
        I_duct.WA_extraction=WA_extraction(k);
        I_duct.dH=Q(k)+O.PWH*E_heat(nm);% 考虑换热器效率
        I_duct.mode="offdesign";
        O=DUCT(I_duct);
        dT_air=[dT_air;O.dT];
        SECOND_FLOW(:,k)=[I_duct.WA;O.FAR;O.P;O.T];
        GAS_PROPERTY=[GAS_PROPERTY,[O.WA;O.FAR;O.P;O.T]];
    end
    if(strcmpi(F(k),"hpcgv pmsm"))
        nm=nm+1;
        s=find(SHAFT_CONTROL==nm);
        I_motor=O;
        I_motor.mode="offdesign";
        pmsm_input=DP.pmsm_parameters(nm);
        % 非设计点实时参数
        pmsm_input.thermal.temp_values=temp_pmsm(:,nm);
        I_motor.pmsm_input=pmsm_input;
        I_motor.PWG_ref=OP.PWG(s)/DP.PWG(s);
        I_motor.N_ref=N_REF(s);
        I_motor.PWG=DP.PWG(s);
        I_motor.NM=DP.N(s);
        I_motor.TPR=TPR(k);
        I_motor.EFFH=E_heat(nm);
        I_motor.WCOR=WCOR(k);
        O=component_engine_pmsm(I_motor,DP,nm);
        motor_perf=O.pmsm_params.performance;
        motor_design_perf=DP.pmsm_parameters(nm).performance;
        motor_speed_ref=motor_perf.speed/motor_design_perf.rated_speed;
        motor_torque_ref=NaN;
        if isfinite(motor_speed_ref)&&abs(motor_speed_ref)>eps&&...
                isfinite(motor_design_perf.mechanical_power)&&abs(motor_design_perf.mechanical_power)>eps
            motor_torque_ref=(motor_perf.mechanical_power/motor_design_perf.mechanical_power)/motor_speed_ref;
        end
        MOTOR_WP(2*nm-1:2*nm,1)=[motor_speed_ref;motor_torque_ref];
        E_motor(s)=O.pmsm_params.performance.efficiency;
        E_motor(s)=O.pmsm_params.performance.efficiency;
        PWS_motor(s)=O.PWS;
        PWG_motor(s)=O.PWG;
        PWH_motor(s)=O.PWH;
        OP.pmsm_parameters(nm)=O.pmsm_params;
        dT_air=[dT_air;O.pmsm_params.thermal.dT_air];
        dT_pmsm_partial(:,nm)=O.pmsm_params.thermal.dT_pmsm_partial;
        SECOND_FLOW(:,k)=[O.WA/(1-WA_extraction(k));O.FAR;O.P;O.T];
        GAS_PROPERTY=[GAS_PROPERTY,[O.WA;O.FAR;O.P;O.T]];
    end
    if(strcmpi(F(k),"mixer"))
        I_mixer=O;
        I_mixer.TPR=TPR(k);
        I_mixer1=O1;
        I_mixer.AN_mixer=DP.AN_mixer;
        I_mixer.M_unmixed=DP.M_unmixed;
        I_mixer.M_mixed=DP.M_mixed;
        [O]=MIXER(I_mixer,I_mixer1);
        YO=[YO;O.DPs];
        YO_element=[YO_element;"dP"];
        XO_element=[XO_element;[F(k),"BPR"]];
        GAS_PROPERTY=[GAS_PROPERTY,[O.WA;O.FAR;O.P;O.T]];
    end
    if(strcmpi(F(k),"afterburn"))
        if OP.reheat==1
        nb=nb+1;
        I_afterburn=O;
        I_afterburn.TO=OP.TO(nb);
        I_afterburn.HU=HU(nb);
        I_afterburn.EB=EB(nb);
        I_afterburn.TPR=TPR(k);
        O=AFTERBURN(I_afterburn);
        WF=WF+O.WF;
        OP.FAR(nb)=O.FAR;
        OP.KB(nb)=O.KB;
        end
        GAS_PROPERTY=[GAS_PROPERTY,[O.WA;O.FAR;O.P;O.T]];
    end
    if(strcmpi(F(k),"nozzle"))
        nn=nn+1;
        I_nozzle=O;
        I_nozzle.TPR=TPR(k);
        I_nozzle.WCOR=WCOR(k);
        I_nozzle.Ps0=Ps0;
        I_nozzle.PO=P0;
        I_nozzle.TO=T0;
        I_nozzle.V0=V;
        I_nozzle.mode="offdesign";
        I_nozzle.AN=DP.AN;
        I_nozzle.PR0=DP.PRN(nn);
        O=NOZZLE(I_nozzle);
        P_ext=O.P;
        dP_nozzle=O.dPR;
        dW_nozzle=O.DW;
        PRN=[PRN,O.PR];
        OP.V_EXT=O.V;
        YO=[YO;P_airflow*O.DW];
        YO_element=[YO_element;"air flow"];
        XO_element=[XO_element;[F(k),"beta"]];
        PW_REF=PW_REF+O.WA*(1+O.FAR)*0.5*(O.V)^2/1000;
        THRUST=THRUST+O.THRUST;
%         disp(O.THRUST)
        if THRUST<=0.001
        THRUST=0;
        end
        GAS_PROPERTY=[GAS_PROPERTY,[O.WA;O.FAR;O.P;O.T]];
    end
    if O.T<0
        warning("temperature below 0K")
        disp(O.T)
    end
    if O.T>1e9
        warning("temperature too high")
        disp(O.T)
    end
%     disp(F(k))
%     disp([O.WA,O.FAR,O.P,O.T])
end
    OP.GAS_PROPERTY=[[OP.WA;0;P0;T0],GAS_PROPERTY];
    OP.GAS_PROPERTY_1=GAS_PROPERTY_1;
    OP.PW=PW;
    PWS=E_mech.*sum(PW,2); %轴功（NS*1矩阵）
    PWS_recess=PWS-PWS_motor;
    dN_partial=1000*PWS_recess./DP.J./OP.N/(pi/30)^2;
    % 计算功率平衡残差
    for k=1:DP.NS
        if N_ref(k)<0 % 对轴功率有要求的轴
        dPW=PWS_recess(k);
        YO=[YO;dPW];
        YO_element=[YO_element;"shaft power"];
        XO_element=[XO_element;[sprintf("shaft %d",k),"Nref"]];
        end
    end
    for k=1:DP.NM1
        for k1=1:DP.NH
            if temp_pmsm_ref(k1,k)<0
                YO=[YO;dT_pmsm_partial(k1,k)];
                YO_element=[YO_element;"dT pmsm"];
                XO_element=[XO_element;[sprintf("pmsm %d node %d",k,k1),"T_pmsm"]];
            end
        end
    end
    OP.dT_air=dT_air;
    OP.dT_pmsm_partial=dT_pmsm_partial;
    if T_REQ>0% 对推力是否有要求
        if DP.M_ext>=0.3% 推力型发动机
        if OP.THRUST<=1e-3
        dTR=max(0,1000*THRUST/DP.V_EXT/DP.WA-1);
        tag="pressure";
        else
        dTR=(THRUST/OP.THRUST-1); %有推力，推力残差    
        tag="thrust";
        end
        else
%         if OP.THRUST<=1e-3% 在非设计点是否提供推力
%         dTR=THRUST;
%         else
%         dTR=(THRUST/OP.THRUST-1); %有推力，推力残差
%         end
        dTR=sum(abs(dN_partial));
        tag="power offtake";
        end
        YO=[YO;dTR];
        YO_element=[YO_element;tag];
        XO_element=[XO_element;["burner","TIT"]];
    end
    PW_REF=PW_REF+abs(sum(sum(PW)))-(WA0+WA1)*0.5*V^2/1000;
    OP.PW_REF=PW_REF;
    V_EXT_cor=(2*(1000*PW_REF/(WA0+WA1)+0.5*V^2))^0.5;
    OP.THRUST_REF=(WA0+WA1)*(V_EXT_cor-V)/1000;
    OP.PRN=PRN;
    OP.NREF=OP.N./DP.N;
    OP.COMP_WP=COMP_WP;
    OP.COMP_SURGE=COMP_SURGE;
    OP.COMP_CHOKE=COMP_CHOKE;
    OP.COMP_OVERLOAD=COMP_OVERLOAD;
    OP.TURB_WP=TURB_WP;
    OP.TURB_OVERLOAD=TURB_OVERLOAD;
    OP.MOTOR_WP=MOTOR_WP;
    OP.E_motor=E_motor;
    OP.PWS_max=PWS_max;
    OP.PWS=PWS;%轴功
    OP.PWH=PWH_motor;%产热
    OP.PWS_recess=PWS_recess;
    OP.dN_partial=dN_partial;
    OP.PWE=sum(OP.PWG);
    OP.THRUST=THRUST;
    OP.XO_element=XO_element;
    OP.YO_element=YO_element;
    OP.YO=YO;
    OP.MSE=(mean(YO'*YO))^0.5;
    OP.WF=WF;
    OP.EFF=OP.PW_REF/(OP.WF*OP.HU(1)/1000); 
    OP.EFF_turboelectric=OP.PWE/(OP.WF*OP.HU(1)/1000); 
    OP.SFC=3.6E3*OP.WF/OP.PW_REF;
end
