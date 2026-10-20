clc
clear
close all
nrpm=12;
nbeta=20;
nrow=5;
ncol=5;
name='MediumPqPCompr';
original_data=importdata(strcat(name,'.txt'));
beta=original_data(1:nrow,:);
beta=beta';
beta=beta(:);
beta(1)=[];
beta(isnan(beta))=[];
rpm=zeros(1,nrpm);
WCOR=zeros(nbeta,nrpm);
EFF=WCOR;
PR=WCOR;
startrow=nrow+1;
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
%% 读取压比数据
startrow=startrow+nrow;
for k=1:nrpm
    wcor=original_data(startrow:startrow+nrow-1,:);
    startrow=startrow+nrow;
    wcor=wcor';wcor=wcor(:)';
    wcor(1)=[];
    wcor(isnan(wcor))=[];
    PR(:,k)=wcor;
end
datasum=[rpm;WCOR;rpm;EFF;rpm;PR];
datasum=[["WCOR";beta;"EFF";beta;"PR";beta],datasum];
filename="COMPONENTMAP.xlsx";
% [~,~,rawSheets] = xlsread(filename,'SheetList');
    % 生成一个新的不重复的sheet名
    newSheetName = name;
    
    % 将矩阵A写入新的sheet
    xlswrite(filename,datasum,newSheetName);