outputfile=input("write extended map to table? (1-Yes)\n");
if outputfile
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
filename = 'TURBINE.xlsx';
data = readtable(filename,Sheet="T");
% 新数据行（假设是一个1xN的单元格数组或表格行）
newRow={name1,T_in.component,T_in.flowtype,nrow1,ncol+N_extra,T_in.maxeff+nrow1-nrow,T_in.n_design+N_extra,1,1,0};

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
R1=[1:nrow1]';
TT0=["WCOR";R1
    "EFF";R1
    "PR";R1];
TT1=[NCOR_extend2zerospeed;WCOR_extend2zerospeed
    NCOR_extend2zerospeed;EFF_extend2zerospeed
    NCOR_extend2zerospeed;PR_extend2zerospeed];
TT=[TT0,TT1];
xlswrite(filename,TT,name1)
end