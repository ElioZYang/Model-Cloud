function[MAP]=MAP_RESET(MAP)
% 计算MAP对应的焓变
k=1.4;
kk=(k-1)/k;
for nc=1:DP.NC
DP.EFFC(nc)=MAP.COMPRESSOR(nc).EFF0;
MAP.COMPRESSOR(nc).PR0=DP.PRC(nc);
MAP.COMPRESSOR(nc).HS=(((DP.PRC(nc)-1)*MAP.COMPRESSOR(nc).PR+1).^kk-1)/(DP.PRC(nc)^kk-1);
end
for nt=1:DP.NT
PR=MAP.TURBINE(nt).PR*(MAP.TURBINE(nt).PR0-1)+1;
MAP.TURBINE(nt).HS=(PR.^-kk-1)/(MAP.TURBINE(nt).PR0.^-kk-1);
MAP.TURBINE(nt).EFF0=DP.EFFT(nt);
end
end