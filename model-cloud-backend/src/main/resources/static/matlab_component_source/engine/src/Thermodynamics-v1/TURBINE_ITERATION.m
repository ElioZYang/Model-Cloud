%             if DP.PRT(NT)==0
%             Eff_turb=(DP.EM.*DP.E_motor)*SHAFT(:,k);%考虑机械效率和电机效率的能量转化效率
%             PWT_req=DP.PWG(NT)/Eff_turb+sum(PW,2)'*SHAFT(:,k);
%             CT_min=T0/TO(NB);
%             CT=(1-PWT_req*1000/cp/TO(NB)/O.WA/(1+O.FAR)/EFFT(NT));
%             if CT>CT_min
%             PRT_input=CT^(-1/gamma1);
%             err=1;
%             while abs(err)>=1e-6
%             disp("迭代求解涡轮膨胀比……")
%             I_turb.PR=PRT_input;
%             O=TURBINE(I_turb);
%             err=1+O.PWT/PWT_req;
%             PRT_input=PRT_input*(1+err*(1-PRT_input^gamma1))^(-1/gamma1);
%             end
%             else
%                 fprintf('涡轮功率不足，已增加设计点空气流量\n')
%                 fprintf('增加前%f kg/s\n',DP.WA)
%                 DP.WA=DP.WA*(1-CT)/(1-CT_min)*1.01;
%                 fprintf('增加后%f kg/s\n',DP.WA)
%                 break
%             end
%             DP.PRT(NT)=PRT_input;
%             else
%             I_turb.PR=DP.PRT(NT);
%             O=TURBINE(I_turb);    
%             end