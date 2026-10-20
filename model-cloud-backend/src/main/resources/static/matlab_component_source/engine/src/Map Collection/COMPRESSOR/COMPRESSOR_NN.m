clc
clear
close all
C=readtable("COMPRESSOR.xlsx",Sheet="C");
disp(C{:,1})
C=table2struct(C);
baseline=input("select baseline compressor map:\n");
C_in=C(baseline);
COMP=xlsread("COMPRESSOR.xlsx",C_in.basicmap);
ncol=C_in.ncol;nrow=C_in.nrow;
maxeff=C_in.maxeff;n_design=C_in.n_design;
NCOR=COMP(1,2:1+ncol);
WCOR=COMP(2:1+nrow,2:1+ncol);
EFF=COMP(3+nrow:2+2*nrow,2:1+ncol);
PR=COMP(4+2*nrow:3*(1+nrow),2:1+ncol);
WCOR0=WCOR(maxeff,n_design);
PR0=PR(maxeff,n_design);
WCOR=WCOR/WCOR0;
NCOR=NCOR/NCOR(n_design);
figure;
plot(WCOR,PR)
figure;
for nc=1:ncol
    x=PR(:,nc);
    y=WCOR(:,nc);
    fitFunction = fittype('-a*exp(-b*x+c)+d', 'independent', 'x', 'dependent', 'y');
%     Opt=fitoptions('Method', 'NonlinearLeastSquares', 'StartPoint', [1,1,1,1]);
    [fitResult, gof] = fit(x, y, fitFunction);
    plot(WCOR(:,nc),x,'ro')
    hold on
    plot(fitResult(x),x,LineWidth=1,Color='black')
    hold on
end