clc
clear
close all
C=readtable("COMPRESSOR.xlsx",Sheet="C");
row_numbers = (1:height(C))';
first_column_data = C{:,1};  % 或 C.(1) 如果列名未知
% 使用 table 存储（适用于混合类型）
result = table(row_numbers, first_column_data, ...
    'VariableNames', {'number', 'basic map'});
disp(result);
C=table2struct(C);
% baseline=input("select baseline compressor map:\n");
baseline=11;
C_in=C(baseline);
COMP=xlsread("COMPRESSOR.xlsx",C_in.basicmap);
ncol=C_in.ncol;nrow=C_in.nrow;
maxeff=C_in.maxeff;n_design=C_in.n_design;
NCOR=COMP(1,2:1+ncol);
WCOR=COMP(2:1+nrow,2:1+ncol);
EFF=COMP(3+nrow:2+2*nrow,2:1+ncol);
PR=COMP(4+2*nrow:3*(1+nrow),2:1+ncol);
k=1.4;k1=(k-1)/k;
HS=PR.^k1-1;
H=HS./EFF;
WCOR0=WCOR(maxeff,n_design);
WCOR=WCOR/WCOR0;
NCOR=NCOR/NCOR(n_design);
PHI=WCOR./NCOR;
PSI_is=HS./NCOR.^2;
PSI=H./NCOR.^2;
Q=HS./EFF./NCOR;
% 输入关键拟合参数
PR_locked0=min(0.9,min(min(PR)-0.1));% 转子闭锁压比
an0=3;
W_locked0=((1-PR_locked0)/an0)^0.5;
W_locked=W_locked0*linspace(1,0,nrow)';
PR_locked=1-an0*W_locked.^2;
HS_locked=PR_locked.^k1-1;
N_cr=0.3;%分界转速
N_min=min(NCOR);
if N_cr>N_min
N_cr=N_min-0.01;
end
N_speed_below=1;
N_speed_above=1;
HS_cr=HS_locked+(HS(:,1)-HS_locked)*(N_cr/N_min)^2;
W_cr=W_locked+(WCOR(:,1)-W_locked)*(N_cr/N_min)^2;
PHI_cr=W_cr./N_cr;
PSI_is_cr=HS_cr./N_cr^2;
PR_cr=(HS_cr+1).^(1/k1);
figure;
plot(PHI,PSI,"k")
xlabel("\phi")
ylabel("\psi")
figure;
plot(PHI,PSI_is,"r")
hold on
plot(PHI_cr,PSI_is_cr,"b")
xlabel("\phi")
ylabel("\psi_{is}")
figure;
plot(PHI,EFF,"-ks")
xlabel("\phi")
ylabel("\eta")
figure;
plot(NCOR.^2,HS,"-s")
xlabel("N_{cor}^2")
ylabel("H_{is}")
figure;
plot(NCOR,WCOR,"-s")
xlabel("N_{cor}")
ylabel("flow")
figure;
plot(WCOR,Q,"k")
hold on
plot(W_cr,HS_cr./N_cr)
xlabel("flow")
ylabel("torque/flow")
figure;
plot(WCOR,PR,"k")
hold on
text(WCOR(1,:),PR(1,:),string(NCOR))
plot(WCOR',PR',"b")
hold on
plot(W_locked,PR_locked,"r")
hold on
plot(W_cr,PR_cr,"g")
xlabel("flow")
ylabel("\pi")

R=(1:nrow)';
NCOR_extra1=linspace(0,N_cr,N_speed_below+2);
NCOR_extra2=linspace(N_cr,min(NCOR),N_speed_above+2);
NCOR1=[NCOR_extra1,NCOR_extra2(2:end-1),NCOR];
Wg_cr=WCOR(:,1)*(N_cr/min(NCOR))^2;
ncol1=length(NCOR);
name1=strcat(C_in.basicmap,' extended');
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
write=0;
if write==1
filename = 'COMPRESSOR.xlsx';
data = readtable(filename,Sheet="C");
% 新数据行（假设是一个1xN的单元格数组或表格行）
newRow={name1,C_in.component,C_in.flowtype,nrow,ncol1,maxeff,n_design+ncol1-ncol,1,1,N_cr,PR_locked0};

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
CC0=["WCOR";R;"EFF";R;"PR";R];
CC1=[NCOR;WCOR
    NCOR;EFF
    NCOR;PR];
CC=[CC0,CC1];
xlswrite(filename,CC,name1)
figure;
[C,h]=contour(WCOR,PR,EFF);
% clabel(C,h);
colormap('jet')
shading interp
colorbar
hold on
plot(WCOR,PR,LineWidth=1,Color='black')
hold on
text(WCOR(end,:),PR(end,:),string(NCOR), ...
    'VerticalAlignment', 'bottom', ...
    'HorizontalAlignment', 'right')
title(name1)
xlabel("wcor")
ylabel("\pi_c")
saveas(gcf,name1,'png')
end
% end