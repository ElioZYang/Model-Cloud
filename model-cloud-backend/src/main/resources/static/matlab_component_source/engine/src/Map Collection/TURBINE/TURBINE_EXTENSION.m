clc
clear
close all
T=readtable("TURBINE.xlsx",Sheet="T");
row_numbers = (1:height(T))';
first_column_data = T{:,1};  % 或 C.(1) 如果列名未知
% 使用 table 存储（适用于混合类型）
result = table(row_numbers, first_column_data, ...
    'VariableNames', {'number', 'basic map'});
disp(result);
T=table2struct(T);
baseline=input("select baseline turbine map:\n");
T_in=T(baseline);
TURB=xlsread("TURBINE.xlsx",T_in.basicmap);
ncol=T_in.ncol;nrow=T_in.nrow;
maxeff=T_in.maxeff;n_design=T_in.n_design;
NCOR=TURB(1,2:1+ncol);
WCOR=TURB(2:1+nrow,2:1+ncol);
EFF=TURB(3+nrow:2+2*nrow,2:1+ncol);
PR=TURB(4+2*nrow:3*(1+nrow),2:1+ncol);
WCOR0=WCOR(maxeff,n_design);
PR0=PR(maxeff,n_design);
WCOR=WCOR/WCOR0;
NCOR=NCOR/NCOR(n_design);
% 输入关键拟合参数
Mref=0.5;% 参考叶尖马赫数
N_extra=2; %增加的转速线条数
k=1.4;k1=(k-1)/k;
EFF(1,:)=2*EFF(2,:)-EFF(3,:);
H_is0=(1-PR0.^-k1);
H_is=(1-PR.^-k1)/H_is0;
H=H_is.*EFF;
PSI=H./NCOR.^2;
PHI=WCOR./NCOR;
Q=H./NCOR;
nrow1=50;% 新MAP图每条等转速线的分段数
R1=[0:nrow1-1]';
R=R1(nrow1-nrow+1:nrow1);
PSI_is_beta0=-(k-1)/2*Mref^2/H_is0;
% 延伸至小流量
PR_beta0=(1-PSI_is_beta0*H_is0*NCOR.^2).^(-1/k1);% 流量=0的膨胀比
X=[PR_beta0;PR];
Y=[0*PR_beta0;WCOR];
PR1=linspace(0,1,nrow1-nrow+1)'.*(PR(1,:)-PR_beta0)+PR_beta0;% 小流量膨胀比
PR_extend2zeroflow=[PR1(1:end-1,:);PR];% 延伸至小流量后的膨胀比
for n=1:ncol
x=X(:,n);y=Y(:,n);
fitFunction = fittype('-a*exp(-b*x)+c', 'independent', 'x', 'dependent', 'y');
    Opt=fitoptions('Method', 'NonlinearLeastSquares', 'StartPoint', [y(end),1,y(end)]);
    [fitResult, gof] = fit(x, y, fitFunction,Opt);
    WCOR1(:,n)=fitResult(PR1(:,n));
end
WCOR1(1,:)=0;
PHI1=WCOR1./NCOR;% 小流量下的速度系数
WCOR_extend2zeroflow=[WCOR1(1:end-1,:);WCOR];% 延伸至小流量后的流量
PSI_is_extend2zeroflow=(1-PR_extend2zeroflow.^-k1)./NCOR.^2./H_is0;
PHI_extend2zeroflow=WCOR_extend2zeroflow./NCOR;
% 拟合效率-NCOR-R关系式
% 1. 生成网格坐标
% 生成二维网格
X_fit=PR(:);
Y_fit = (WCOR.*NCOR);
Y_fit = Y_fit(:);
Z_fit = EFF(:);                       % 确保 Z 与网格对齐
 
% 2. 定义三次多项式模型（总次数为3）
model = fittype('poly22');          % 对应公式: p00 + p10*x + p01*y + p20*x^2 + p11*x*y + p02*y^2 + p30*x^3 + p21*x^2*y + p12*x*y^2 + p03*y^3
 
% 3. 执行拟合
fit_result = fit([X_fit,Y_fit], Z_fit, model);
% ERR=EFF-fit_result(X_fit,NCOR);
% 插值得小流量效率
EFF1=fit_result(PR1,WCOR1.*NCOR);
EFF_extend2zeroflow=[EFF1(1:end-1,:);EFF];
PSI_extend2zeroflow=PSI_is_extend2zeroflow.*EFF_extend2zeroflow;
Q_extend2zeroflow=PSI_extend2zeroflow.*NCOR;
figure;
plot(WCOR_extend2zeroflow,Q_extend2zeroflow);
% 延伸至低转速
NCOR1=linspace(0,NCOR(1),N_extra+1);
NCOR1=NCOR1(1:end-1);
PR_beta1_lowspeed=1+(NCOR1/NCOR(1)).^2*(PR(end,1));
PR_beta0_lowspeed=(1-PSI_is_beta0*H_is0*NCOR1.^2).^(-1/k1);% 小转速，流量=0的膨胀比
PR2=(PR_beta1_lowspeed-PR_beta0_lowspeed).*( ...
    PR_extend2zeroflow(:,1)-PR_extend2zeroflow(1,1) ...
    )/(PR_extend2zeroflow(end,1)-PR_extend2zeroflow(1,1) ...
    )+PR_beta0_lowspeed;
PR_extend2zerospeed=[PR2,PR_extend2zeroflow];
WCOR_extend2zerospeed=WCOR_extend2zeroflow;
NCOR_extend2zerospeed=[NCOR1,NCOR];
% 逐条增加转速线
for nn=1:N_extra
dW=(NCOR_extend2zerospeed(N_extra-nn+3)-NCOR_extend2zerospeed(N_extra-nn+2))/( ...
    NCOR_extend2zerospeed(N_extra-nn+2)-NCOR_extend2zerospeed(N_extra-nn+1));
WCOR2=WCOR_extend2zerospeed(:,1)-(WCOR_extend2zerospeed(:,2)-WCOR_extend2zerospeed(:,1))*dW;
WCOR_extend2zerospeed=[WCOR2,WCOR_extend2zerospeed];
end
EFF2=fit_result(PR2,WCOR2.*NCOR1);
EFF_extend2zerospeed=[EFF2,EFF_extend2zeroflow];
PHI_extend2zerospeed=WCOR_extend2zerospeed./NCOR_extend2zerospeed;
PSI_is_extend2zerospeed=(1-PR_extend2zerospeed.^-k1)/H_is0./NCOR_extend2zerospeed.^2;
PSI_extend2zerospeed=PSI_is_extend2zerospeed.*EFF_extend2zerospeed;
Q_extend2zerospeed=PSI_extend2zerospeed.*NCOR_extend2zerospeed;
% 压比&效率-转速&流量图（原）
figure;
[C,h]=contour(WCOR.*NCOR,PR,EFF);
clabel(C,h);
hold on
plot(WCOR.*NCOR,PR,'black')
xlabel("WCOR*N")
ylabel("\pi")
title("original")
% EFF-PHI图（更新）
figure;
plot(PHI_extend2zerospeed(2:end,:),EFF_extend2zerospeed(2:end,:))
xlabel("\Phi")
ylabel("\eta")
% PSI-PHI图（更新）
figure;
plot(PHI_extend2zerospeed(2:end,:),PSI_extend2zerospeed(2:end,:))
xlabel("\Phi")
ylabel("\Psi")
% PSI_is-PHI图（更新）
figure;
plot(PHI_extend2zerospeed(1:end,:),PSI_is_extend2zerospeed(1:end,:))
xlabel("\Phi")
ylabel("\Psi_{is}")
Q_beta0=PSI_is_beta0.*EFF_extend2zerospeed(1,:).*NCOR_extend2zerospeed;
% TORQUE-WCOR图（更新）
figure;
plot(WCOR_extend2zerospeed,Q_extend2zerospeed)
hold on
plot(0,Q_beta0,'-rx')
xlabel("WCOR")
ylabel("TORQUE")
name1=strcat(T_in.basicmap,' extended');

% outputfile=input("write extended map to table? (1-Y)\n");
% if outputfile==1
% 将新数据写入现有数据的下一行
% basicmap	
% component	
% flowtype	
% nrow	
% ncol	
% maxeff	
% n_design	
% extension	
% scaling	
% NC_min
% 读取现有表格
write=1;
if write==1
filename = 'TURBINE.xlsx';
data = readtable(filename,Sheet="T");
% 新数据行（假设是一个1xN的单元格数组或表格行）
newRow={name1,T_in.component,T_in.flowtype,nrow1,ncol+N_extra,maxeff+nrow1-nrow,n_design+N_extra,1,1,0,Mref};

% 检查新数据的第一个元素是否已经存在于表格的第一列中
existingIndex = find(strcmpi(data{:, 1},newRow{1}));
if isempty(existingIndex)
    % 如果不存在，则追加到表格末尾
    data = [data;newRow];
else
    % 如果存在，则覆盖对应行
    data(existingIndex,:) = newRow;
end

% 将更新后的表格写回文件
writetable(data, filename);
CC0=["WCOR";R1;"EFF";R1;"PR";R1];
CC1=[NCOR_extend2zerospeed;WCOR_extend2zerospeed
    NCOR_extend2zerospeed;EFF_extend2zerospeed
    NCOR_extend2zerospeed;PR_extend2zerospeed];
CC=[CC0,CC1];
xlswrite(filename,CC,name1)
end
% 压比&效率-转速&流量图（更新）
figure;
[C,h]=contour(NCOR_extend2zerospeed.*WCOR_extend2zerospeed, ...
    PR_extend2zerospeed,EFF_extend2zerospeed);
% clabel(C,h);
colormap('jet')
shading interp
colorbar
hold on
plot(WCOR_extend2zerospeed, ...
    PR_extend2zerospeed,LineWidth=1,Color='black')
hold on
text(NCOR_extend2zerospeed.*WCOR_extend2zerospeed(end,:), ...
    PR_extend2zerospeed(end,:),string(NCOR_extend2zerospeed), ...
    'VerticalAlignment', 'bottom', ...
    'HorizontalAlignment', 'right')
title(name1)
xlabel("wcor")
ylabel("\pi_t")
saveas(gcf,name1,'png')