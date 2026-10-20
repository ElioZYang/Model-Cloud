clc
clear
close all
nrow1=4;% 涡轮压比行数
nrow=11;% 每个转速下的流量行数
ncol=5;
nbeta=(nrow-1)*ncol;
name='HPT01';
original_data=importdata(strcat(name,'.txt'));
rpm=original_data(1:nrow1,:);
rpm=rpm';
rpm=rpm(:)';
rpm(isnan(rpm))=[];
rpm(1)=[];
nrpm=length(rpm);
prt_min=original_data(nrow1+1:2*nrow1,:)';
prt_max=original_data(3*nrow1+1:4*nrow1,:)';
prt_min=prt_min(:);
prt_min(isnan(prt_min))=[];
prt_min(1)=[];
prt_max=prt_max(:);
prt_max(isnan(prt_max))=[];
prt_max(1)=[];
for k=1:nrpm
prt(:,k)=linspace(prt_min(k),prt_max(k),nbeta)';
end
beta=original_data(4*nrow1+1:4*nrow1+nrow,:);
beta=beta';
beta=beta(:);
beta(1)=[];
beta(isnan(beta))=[];
WCOR=zeros(nbeta,nrpm);
EFF=WCOR;
PR=prt;
startrow=4*nrow1+nrow+1;
%% 读取流量数据
for k=1:nrpm
    wcor=original_data(startrow:startrow+nrow-1,:);
    startrow=startrow+nrow;
    wcor=wcor';wcor=wcor(:)';
    rpm(k)=wcor(1);
    wcor(1)=[];
    wcor(isnan(wcor))=[];
    WCOR(:,k)=wcor;
end
%% 读取效率数据
startrow=startrow+nrow;
for k=1:nrpm
    wcor=original_data(startrow:startrow+nrow-1,:);
    startrow=startrow+nrow;
    wcor=wcor';wcor=wcor(:)';
    wcor(1)=[];
    wcor(isnan(wcor))=[];
    EFF(:,k)=wcor;
end
datasum=[rpm;WCOR;rpm;EFF;rpm;PR];
datasum=[["WCOR";beta;"EFF";beta;"PR";beta],datasum];
filename="TURBINE.xlsx";
% [~,~,rawSheets] = xlsread(filename,'SheetList');
    % 生成一个新的不重复的sheet名
    newSheetName = name;
    
    % 将矩阵A写入新的sheet
    xlswrite(filename,datasum,newSheetName);