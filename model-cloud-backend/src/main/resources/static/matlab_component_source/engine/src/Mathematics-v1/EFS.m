function R=EFS(X)
%Equilibrium Functions Solver
%平衡方程求解器
%设置求解结构体
global O
global D
global I
O.C.VSV({'CDFS','HPC'})=X(1:2);
O.T.VAN('LPT')=X(3);
O.S.A('22')=X(4)*D.S.A('22');
O.S.A('52')=X(5)*D.S.A('52');
O.S.A('8')=X(6)*D.N.Anc('N');
I.Point.objective=@SRF;
I.Point.solver='lsqnonlin';
I.Point.x0(1)=O.C.R('Fan');
I.Point.x0(2)=O.C.R('Fla');
I.Point.x0(3)=O.C.R('CDFS');
I.Point.x0(4)=O.C.R('HPC');
I.Point.x0(5)=O.T.R('HPT')*5;
I.Point.x0(6)=O.T.R('LPT')*5;
I.Point.x0(7)=O.R.N('H')*10;
I.Point.x0(8)=O.R.N('L')*10;
I.Point.x0(9)=O.B.T('C')/1000;
I.Point.B(1:2,1)=[1;D.C.Rs('Fan')];
I.Point.B(1:2,2)=[1;D.C.Rs('Fla')];
I.Point.B(1:2,3)=[1;D.C.Rs('CDFS')];
I.Point.B(1:2,4)=[1;D.C.Rs('HPC')];
I.Point.B(1:2,5)=[0.5;2]*5;
I.Point.B(1:2,6)=[0.5;2]*5;
I.Point.B(1:2,7)=[0.5;1.1]*10;
I.Point.B(1:2,8)=[0.5;1.1]*10;
I.Point.B(1:2,9)=[1000;2150]/1000;
I.Point.lb=I.Point.B(1,:);
I.Point.ub=I.Point.B(2,:);
%I.Point.options=optimoptions('fsolve','Display','final','MaxFunctionEvaluations',200,'MaxIterations',100,'OptimalityTolerance',1e-3);
I.Point.options=optimset('Display','iter','PlotFcns',@optimplotfval);
lsqnonlin(I.Point);
%R(1)=O.C.R('Fan')-8;
%R(2)=O.C.R('CDFS')-5;
%R(3)=O.C.R('HPC')-4;
R=abs(O.C.R('Fan')-8)+abs(O.C.R('CDFS')-5)+abs(O.C.R('HPC')-4);
end
