%单纯形法求解工作点
%稳态计算求解工作点
%设置求解结构体
global O
global D
global I
O.Point.objective=@SRF;
O.Point.solver='lsqnonlin';
O.Point.x0(1)=D.C.R('Fan');
O.Point.x0(2)=D.C.R('Fla');
O.Point.x0(3)=D.C.R('CDFS');
O.Point.x0(4)=D.C.R('HPC');
O.Point.x0(5)=D.T.R('HPT');
O.Point.x0(6)=D.T.R('LPT');
O.Point.x0(7)=D.R.N('H');
O.Point.x0(8)=D.R.N('L');
O.Point.x0(9)=D.B.T('C');
I.Point.B(1:2,1)=[1;D.C.Rs('Fan')];
I.Point.B(1:2,2)=[1;D.C.Rs('Fla')];
I.Point.B(1:2,3)=[1;D.C.Rs('CDFS')];
I.Point.B(1:2,4)=[1;D.C.Rs('HPC')];
I.Point.B(1:2,5)=[0.5;2];
I.Point.B(1:2,6)=[0.5;2];
I.Point.B(1:2,7)=[0.5;1.1];
I.Point.B(1:2,8)=[0.5;1.1];
I.Point.B(1:2,9)=[1000;2150];
O.Point.lb=I.Point.B(1,:);
O.Point.ub=I.Point.B(2,:);
O.Point.options=optimset('Display','iter','PlotFcns',@optimplotfval);
x = lsqnonlin(O.Point);

function stop = END(~, optimValues, ~)
%设置残差计算误差
stop = false;
if optimValues.residual < 0.001
    stop = true;
end
end        

