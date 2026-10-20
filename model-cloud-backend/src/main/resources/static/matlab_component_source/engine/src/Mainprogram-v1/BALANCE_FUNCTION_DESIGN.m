function[DP,XD,diagnostics]=BALANCE_FUNCTION_DESIGN( ...
    DP,XD)
% 建立并求解非设计点的平衡方程
% 平衡方程的个数不一定为NC+NT+NS;
% 例如，如果对轴功率输出无严格要求，则方程个数为NC+NT，每个轴的转速为给定变量
% X0表示方程初始解
if dot(XD,XD)==0 %需要初始化
    % DP_pre=ENGINE_PREDESIGN(DP);
    DP_pre=ones(1+DP.NT,1);
    if DP.NH*DP.NM1 > 0
        XD=[DP_pre;DP.pmsm_input(1).temperature_limit*ones(DP.NH*DP.NM1,1)];
    else
        XD=DP_pre;
    end
end
diagnostics=struct('converged',true,'exitflag',1,'residual_norm',0, ...
    'fval',[],'message','设计点求解完成');
LM=[];
if min([DP.WA,DP.PRT])<=0
    if DP.WA<=0 %对推力有要求
        LM=[LM;1];
    end
    for nt=1:DP.NT
        if DP.PRT(nt)<=0 %涡轮膨胀比未知，需要求解平衡方程
            LM=[LM;nt+1];
            % X0=[X0;1];
        end
    end
    NH=DP.NH;
    NM1=DP.NM1;
    temp_pmsm_ref=DP.temp_pmsm_ref;
    fixed_value=DP.NT+1;
    for nm=1:NM1
        for nh=1:NH
            if temp_pmsm_ref(nh,nm)<0
                LM=[LM;fixed_value+(nm-1)*NH+nh];
            end
        end
    end
    % [YD]=DESIGN(XD(LM),DP);
    options = optimoptions('fsolve', 'Display', 'off');
    if ~isempty(LM)
        [XD(LM),fval,exitflag,output]=fsolve(@(x) DESIGN(x,DP),XD(LM),options);
        diagnostics.exitflag=exitflag;
        diagnostics.fval=fval;
        if isstruct(output) && isfield(output,'message')
            diagnostics.message=output.message;
        end
    end
end
% X=NIFS(fun,X0,1E-3,1000,1E-6);
[YD,DP]=DESIGN(XD(LM),DP);
DP.YD=YD;
if isempty(YD)
    diagnostics.residual_norm=0;
else
    residual=double(YD(:));
    diagnostics.residual_norm=norm(residual,inf);
end
finite_result=isempty(YD) || all(isfinite(double(YD(:)))) ...
    && isfinite(diagnostics.residual_norm);
diagnostics.converged=finite_result && (diagnostics.exitflag>0 ...
    || diagnostics.residual_norm<=1e-3);
dis=DP.display;
if dis==1
disp("--------------")
disp("设计点计算完成")
disp("发动机类型:")
disp(DP.type)
disp("空气流量(kg/s):")
disp(DP.WA)
disp("电功率输出(kW):")
disp(DP.PWG)
disp("总推力(kN):")
disp(DP.THRUST)
disp("换算功率(kW)")
disp(DP.PW_REF)
disp("换算推力(kN)")
disp(DP.THRUST_REF)
disp("效率")
disp(DP.EFF_turboelectric)
disp("燃油流量(kg/s):")
disp(DP.WF)
disp("计算误差")
disp(YD)
end
% Keep the adapter non-interactive.  The original demo printed a separator
% unconditionally even when display was disabled.
% disp(DP.pmsm_parameters.performance)
if dis == 1
    disp("--------------")
end
end
