clc
clear
close all
nrpm=40;
nrow=9;
ncol=5;
name='EMG01';
original_data=importdata(strcat(name,'.txt'));
beta=original_data(1:nrow,:);
beta=beta';
beta=beta(:);
beta(1)=[];
beta(isnan(beta))=[];
nbeta=length(beta);
rpm=zeros(1,nrpm);
WCOR=zeros(nbeta,nrpm);
EFF=WCOR;
startrow=nrow+1;
%% 读取转矩数据
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
datasum=[rpm;WCOR;rpm;EFF];
datasum=[["WCOR";beta;"EFF";beta],datasum];
filename="MOTOR.xlsx";
% [~,~,rawSheets] = xlsread(filename,'SheetList');
    % 生成一个新的不重复的sheet名
    newSheetName = name;
    
    % 将矩阵A写入新的sheet
    xlswrite(filename,datasum,newSheetName);