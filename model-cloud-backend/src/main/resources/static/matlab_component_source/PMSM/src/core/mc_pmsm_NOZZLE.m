function [OUTPUT]=mc_pmsm_NOZZLE(INPUT)
%计算喷管相关参数
% PRcr=inf;
switch INPUT.mode
    case "design"
        OUTPUT=INPUT;
        dP=0;
        TR=INPUT.TR;
        M_ext=INPUT.M_ext;
        V0=INPUT.V0;
        if TR==1
        FAR=INPUT.FAR;
        WA=INPUT.WA;
        W=(1+FAR)*WA;
        D=INPUT.D;
        T=INPUT.T;
        K=mc_pmsm_AE(T,FAR,D);
        PRcr=((K+1)/2)^(K/(K-1));
        P=INPUT.P*INPUT.TPR;
        % 出口压力（压力平衡）
        Ps0=INPUT.Ps0;
        OUTPUT.P=P;
        PR=P/Ps0;
        Ts=T*PR^-((K-1)/K);
        OUTPUT.Ts=Ts;
        mc_pmsm_VC=((1-Ts/T)*(K+1)/(K-1))^0.5;
        Ps=Ps0;
        %计算临界状态参数
        if(PR>PRcr)
            mc_pmsm_VC=1;
            Ps=mc_pmsm_AFP(mc_pmsm_VC,K)*P; 
        end
        else % 不提供推力，为功率型发动机
        FAR=INPUT.FAR;
        WA=INPUT.WA;
        W=(1+FAR)*WA;
        D=INPUT.D;
        T=INPUT.T;
        K=mc_pmsm_AE(T,FAR,D);
        PRcr=((K+1)/2)^(K/(K-1));
        P=INPUT.P*INPUT.TPR;
        % 出口压力（压力平衡）
        Ps0=INPUT.Ps0;
        V_ext=V0/(1+FAR);
        K_ext=T/(T-V_ext^2/2/mc_pmsm_CPSH(T,FAR));
        M_ext_cr=((K_ext-1)*2/(K-1))^.5;
        M_ext=max(M_ext_cr,M_ext);
        P_lim=Ps0*(1+(K-1)/2*M_ext^2)^(K/(K-1));
        dP=P/P_lim-1;
        P=max(P,P_lim);
        OUTPUT.P=P;
        PR=P/Ps0;
        Ts=T*PR^-((K-1)/K);
        OUTPUT.Ts=Ts;
        mc_pmsm_VC=((1-Ts/T)*(K+1)/(K-1))^0.5;
        Ps=Ps0;
        %计算临界状态参数
        if(PR>PRcr)
            mc_pmsm_VC=1;
            Ps=mc_pmsm_AFP(mc_pmsm_VC,K)*P; 
        end        
        end
        OUTPUT.PR=PR;
        OUTPUT.dP=dP;
        OUTPUT.WCOR=W*T^0.5/INPUT.P;
        OUTPUT.V=mc_pmsm_VC*sqrt(2*K/(K+1)*mc_pmsm_GC(FAR,D)*T); 
        OUTPUT.AN=W*sqrt(T)/P/mc_pmsm_FC(mc_pmsm_VC,K,FAR,D);
        OUTPUT.THRUST=(W*OUTPUT.V+(Ps-Ps0)*OUTPUT.AN)/1000;
    case "offdesign"
        OUTPUT=INPUT;
        PR0=INPUT.PR0;
        AN=INPUT.AN;
        FAR=INPUT.FAR;
        WA=INPUT.WA;
        W=(1+FAR)*WA;
        V0=INPUT.V0;
        D=INPUT.D;
        T=INPUT.T;
        OUTPUT.WCOR=W*T^0.5/INPUT.P;
        DPR=1-INPUT.TPR;
        WCOR=INPUT.WCOR;
        TPR=1-DPR*(OUTPUT.WCOR/WCOR)^2;
        K=mc_pmsm_AE(T,FAR,D);
        PRcr=((K+1)/2)^(K/(K-1));
        P=INPUT.P*TPR;
        Ps0=INPUT.Ps0;
        OUTPUT.P=P;
        PR=P/Ps0;
        % 出口温度
        Ts=T*PR^-((K-1)/K);        
        OUTPUT.Ts=Ts;
        if PR>=1        
        mc_pmsm_VC=((1-Ts/T)*(K+1)/(K-1))^0.5;
        Ps=Ps0; 
        %计算临界状态参数
        if(PR>PRcr)
            mc_pmsm_VC=1;
            Ps=mc_pmsm_AFP(mc_pmsm_VC,K)*P;  
        end
        else
        mc_pmsm_VC=-((1-T/Ts)*(K+1)/(K-1))^0.5;
        Ps=Ps0;
        end
        W1=AN*P*mc_pmsm_FC(mc_pmsm_VC,K,FAR,D)/sqrt(T);
        OUTPUT.V=mc_pmsm_VC*sqrt(2*K/(K+1)*mc_pmsm_GC(FAR,D)*T); 
        OUTPUT.DW=W1/W-1;% 喷管流量平衡方程
        OUTPUT.THRUST=(W*OUTPUT.V+(Ps-Ps0)*AN)/1000;
        OUTPUT.dPR=PR/PR0-1;
        OUTPUT.PR=PR;
end
end
% function [O]=mc_pmsm_LAMBDA(K,I,mode)
% switch mode
%     case 1 %由M到LAMBDA
%     O=I*((K+1)/(2+(K-1)*I^2))^0.5;
%     case 2 %由LAMBDA到M
%     O=I*(2/((K+1)-(K-1)*I^2))^0.5;
% end
% end