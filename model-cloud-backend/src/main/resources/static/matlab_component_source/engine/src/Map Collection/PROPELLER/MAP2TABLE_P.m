clc
clear
close all
nrpm=10;
nbeta=20;
nrow=5;
nrow1=3;
ncol=5;
name='PROP01';
original_data=importdata(strcat(name,'.txt'));
beta=original_data(1:nrow,:);
beta=beta';
beta=beta(:);
beta(1)=[];
beta(isnan(beta))=[];
rpm=zeros(1,nrpm);
WCOR=zeros(nbeta,nrpm);
EFF=WCOR;
startrow=1+nrow;
%% 读取效率数据
for k=1:nrpm
    wcor=original_data(startrow:startrow+nrow-1,:);
    startrow=startrow+nrow;
    wcor=wcor';wcor=wcor(:)';
    rpm(k)=wcor(1);
    wcor(1)=[];
    wcor(isnan(wcor))=[];
    WCOR(:,k)=wcor;
end
%% 读取功率因子数据
startrow=startrow+nrow;
for k=1:nrpm
    wcor=original_data(startrow:startrow+nrow-1,:);
    startrow=startrow+nrow;
    wcor=wcor';wcor=wcor(:)';
    wcor(1)=[];
    wcor(isnan(wcor))=[];
    EFF(:,k)=wcor;
end
%% 读取Cf/Cpw数据
cpw=original_data(startrow:startrow+nrow1-1,:);
cfcpw=original_data(startrow+nrow1:startrow+2*nrow1-1,:);
cpw=cpw';cpw=cpw(:);cpw=cpw';cpw(isnan(cpw))=[];cpw(1)=[];
cfcpw=cfcpw';cfcpw=cfcpw(:);cfcpw=cfcpw';cfcpw(isnan(cfcpw))=[];cfcpw(1)=[];
datasum=[rpm;WCOR;rpm;EFF];
datasum=[["EFF";beta;"CPW";beta],datasum];
datasum=[datasum;["CPW",cpw;"CF/CPW",cfcpw]];
filename="PROPELLER.xlsx";
% [~,~,rawSheets] = xlsread(filename,'SheetList');
    % 生成一个新的不重复的sheet名
    newSheetName = name;
    
    % 将矩阵A写入新的sheet
    xlswrite(filename,datasum,newSheetName);