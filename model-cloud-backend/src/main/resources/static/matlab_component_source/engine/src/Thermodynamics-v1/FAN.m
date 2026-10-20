function[OUTPUT]=FAN(INPUT)
% OUTPUT=INPUT;
% WA=INPUT.WA;
% FAR=INPUT.FAR;
% D=INPUT.D;
% V=INPUT.V;
% Ts=INPUT.Ts0;
% Ps=INPUT.Ps0;
% P=INPUT.P;
% K=CPSH(Ts,FAR);
% R=GC(FAR,D);
% KK=(K-1)/K;
% V_ext=(2*KK*R*Ts*((P/Ps)^KK-1))^0.5;
% OUTPUT.V=V_ext;
% OUTPUT.THRUST=WA*(1+FAR)*(V_ext-V)/1000;
        OUTPUT=INPUT;
        WA=INPUT.WA;
        FAR=INPUT.FAR;
        D=INPUT.D;
        T=INPUT.T;
        K=AE(T,FAR,D);
        PRcr=((K+1)/2)^(K/(K-1));
        P=INPUT.P*INPUT.TPR;
        % 出口压力（压力平衡）
        Ps0=INPUT.Ps0;
        OUTPUT.P=P;
        % 出口温度
        Ts=T*(Ps0/P)^((K-1)/K);
        OUTPUT.Ts=Ts;
        VC=sqrt(max((1-Ts/T),0)*(K+1)/(K-1));
        %计算超临界状态时参数
        PR=P/Ps0;
        Ps=Ps0;
%         PRcr=PR;
        if(PR>PRcr)
            VC=1;
            Ps=AFP(VC,K)*P;  
        end
        OUTPUT.AN=WA*sqrt(T)/P/FC(VC,K,FAR,D);
        OUTPUT.V=VC*sqrt(2*K/(K+1)*GC(FAR,D)*T); 
        OUTPUT.THRUST=(WA*OUTPUT.V+(Ps-Ps0)*OUTPUT.AN)/1000;
end