clc
clear
close all
T=readtable("TURBINE.xlsx",Sheet="T");
disp(T{:,1})
T=table2struct(T);
baseline=input("select baseline turbine map:\n");
T_in=T(baseline);
TURB=xlsread("TURBINE.xlsx",T_in.basicmap);
ncol=T_in.ncol;nrow=T_in.nrow;
beta=0:1:nrow-1;
maxeff=T_in.maxeff;n_design=T_in.n_design;
NCOR=TURB(1,2:1+ncol);
WCOR=TURB(2:1+nrow,2:1+ncol);
EFF=TURB(3+nrow:2+2*nrow,2:1+ncol);
PR=TURB(4+2*nrow:3*(1+nrow),2:1+ncol);
WCOR0=WCOR(maxeff,n_design);
PR0=PR(maxeff,n_design);
WCOR=WCOR/WCOR0;
NCOR=NCOR/NCOR(n_design);
figure;
plot(WCOR.*NCOR,PR)
Mref=0.5;
k=1.4;k1=(k-1)/k;
PR_beta0=(1+(k-1)/2*Mref^2*NCOR.^2).^(-1/k1);
WCOR_extended2zeroflow=[zeros(1,ncol);WCOR];
PR_extended2zeroflow=[PR_beta0;PR];
figure;
for nc=1:ncol
    x=PR_extended2zeroflow(:,nc);
    y=WCOR_extended2zeroflow(:,nc);
    fitFunction = fittype('-a*exp(-b*x)+c', 'independent', 'x', 'dependent', 'y');
    Opt=fitoptions('Method', 'NonlinearLeastSquares', 'StartPoint', [1,1,1]);
    [fitResult, gof] = fit(x, y, fitFunction,Opt);
    plot(x,WCOR_extended2zeroflow(:,nc).*NCOR(nc),'ro')
    hold on
    plot(x,NCOR(nc)*fitResult(x),LineWidth=1,Color='black')
    hold on
end
figure;
plot(beta,PR./PR(end,:))