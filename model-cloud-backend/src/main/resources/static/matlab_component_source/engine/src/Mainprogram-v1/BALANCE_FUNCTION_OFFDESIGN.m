function[OP,X,DX,diagnostics]=BALANCE_FUNCTION_OFFDESIGN(DP,OP,X0)
% 建立并求解非设计点的平衡方程
% 平衡方程的个数不一定为NC+NT+NS;
% 例如，如果对轴功率输出无严格要求，则方程个数为NC+NT，每个轴的转速为给定变量
% X0表示方程初始解
fun=@(x) OFFDESIGN(x,DP,OP);
NC=DP.NC;
NT=DP.NT;
NS=DP.NS;
NBY=DP.NBY;
NM=DP.NM;% 电机数量
NM1=DP.NM1;% 热管导叶电机数量
NH=DP.NH;% 每个热管导叶电机的温度节点数
temp_pmsm_ref=OP.temp_pmsm_ref;
N_ref=OP.N_ref;
fixed_value=NBY+NC+NT;
max_value=NBY+NC+NT+NS+NH*NM1+1;% 若每根转轴都接一个电机
LM=(1:fixed_value)';
if dot(X0,X0)==0 %需要初始化
X0=ones(max_value,1);% 待求的根数量介于NB+NC+NT+1、NB+NC+NT+NS+2之间
% W*sqrt(T0)/P0=W_d*sqrt(T0_d)/P0_d
[Ps0,Ts0,P0,T0]=STAGNATION_CAL(DP.H,DP.V,DP.M,DP.DT,DP.QP);
[Ps,Ts,P,T]=STAGNATION_CAL(OP.H,OP.V,OP.M,OP.DT,OP.QP);
for n=1:NS
if N_ref(n)<0 %转速未知，需要求解平衡方程
LM=[LM;fixed_value+n];
X0(fixed_value+n)=(T/T0)^0.5;
end
end
for nm=1:NM1
for nh=1:NH
    if temp_pmsm_ref(nh,nm)<0
        LM=[LM;fixed_value+NS+(nm-1)*NH+nh];
    end
end
end
if OP.T_REQ>0
LM=[LM;max_value];
end
else
for n=1:NS
if N_ref(n)<0 %转速未知，需要求解平衡方程
LM=[LM;fixed_value+n];
end
end
for nm=1:NM1
for nh=1:NH
    if temp_pmsm_ref(nh,nm)<0
        LM=[LM;fixed_value+NS+(nm-1)*NH+nh];
    end
end
end
if OP.T_REQ>0
LM=[LM;max_value];
end
end
X=X0;
options = optimoptions('fsolve', 'Display', 'off');
% Y=OFFDESIGN(X(LM),DP,OP);
if isempty(LM)
    fval=[];
    exitflag=1;
    output=struct('message','无非设计点未知量');
else
    [X(LM),fval,exitflag,output]=fsolve(fun,X(LM),options);
end
X=real(X);
DX=X-X0;
[YOFF,OP]=OFFDESIGN(X(LM),DP,OP);
OP.XO=X;OP.LM=LM;
if isempty(YOFF)
    residual_norm=0;
else
    residual_norm=norm(double(YOFF(:)),inf);
end
finite_result=all(isfinite(double(X(:)))) && (isempty(YOFF) ...
    || all(isfinite(double(YOFF(:))))) && isfinite(residual_norm);
diagnostics=struct('converged',finite_result && (exitflag>0 ...
    || residual_norm<=1e-3),'exitflag',exitflag, ...
    'residual_norm',residual_norm,'fval',fval,'message','');
if isstruct(output) && isfield(output,'message'), diagnostics.message=output.message; end
if DP.NM1>0
    diagnostics=component_engine_pmsm_diagnostics(DP,OP,diagnostics,'offdesign');
    OP.pmsmSolverDiagnostics=diagnostics;
end
dis=OP.display;
if dis==1
SOLUTION_VISUALIZE(OP);
end
end
