function[OUTPUT]=mc_pmsm_FAN(INPUT)
% OUTPUT=INPUT;
% WA=INPUT.WA;
% FAR=INPUT.FAR;
% D=INPUT.D;
% V=INPUT.V;
% Ts=INPUT.Ts0;
% Ps=INPUT.Ps0;
% P=INPUT.P;
% K=mc_pmsm_CPSH(Ts,FAR);
% R=mc_pmsm_GC(FAR,D);
% KK=(K-1)/K;
% V_ext=(2*KK*R*Ts*((P/Ps)^KK-1))^0.5;
% OUTPUT.V=V_ext;
% OUTPUT.THRUST=WA*(1+FAR)*(V_ext-V)/1000;
        OUTPUT=INPUT;
        WA=INPUT.WA;
        FAR=INPUT.FAR;
        D=INPUT.D;
        T=INPUT.T;
        K=mc_pmsm_AE(T,FAR,D);
        PRcr=((K+1)/2)^(K/(K-1));
        P=INPUT.P*INPUT.TPR;
        % 出口压力（压力平衡）
        Ps0=INPUT.Ps0;
        OUTPUT.P=P;
        % 出口温度
        Ts=T*(Ps0/P)^((K-1)/K);
        OUTPUT.Ts=Ts;
        mc_pmsm_VC=sqrt(max((1-Ts/T),0)*(K+1)/(K-1));
        %计算超临界状态时参数
        PR=P/Ps0;
        Ps=Ps0;
%         PRcr=PR;
        if(PR>PRcr)
            mc_pmsm_VC=1;
            Ps=mc_pmsm_AFP(mc_pmsm_VC,K)*P;  
        end
        OUTPUT.AN=WA*sqrt(T)/P/mc_pmsm_FC(mc_pmsm_VC,K,FAR,D);
        OUTPUT.V=mc_pmsm_VC*sqrt(2*K/(K+1)*mc_pmsm_GC(FAR,D)*T); 
        OUTPUT.THRUST=(WA*OUTPUT.V+(Ps-Ps0)*OUTPUT.AN)/1000;
end