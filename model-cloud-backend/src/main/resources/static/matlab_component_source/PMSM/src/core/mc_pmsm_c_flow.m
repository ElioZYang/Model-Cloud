function flowState=mc_pmsm_c_flow(thermalGeometry,thermalBoundary)
g=thermalGeometry; b=thermalBoundary;
T=b.T; P=b.P; WA=b.WA; FAR=b.FAR; D=b.D; W=WA*(1+FAR);
if ~isreal([T,P,WA])||any(~isfinite([T,P,WA]))||T<=0||P<=0||WA<=0
    error('PMSM:InvalidFlow','Positive finite inlet temperature, pressure and flow are required.');
end
K=mc_pmsm_AE(T,FAR,D); WCOR=W*sqrt(T)/P;
M0=W*(mc_pmsm_GC(FAR,D)*T/K)^.5/g.Area/P;
fun=@(M) g.Area*M*mc_pmsm_SV(T/(1+(K-1)/2*M^2),FAR,D)*...
    (P/T/mc_pmsm_GC(FAR,D))*(1+(K-1)/2*M^2)^(1-K/(K-1))/W-1;
choke=fun(1);
if choke<0, M=1; W=W*(choke+1); WA=WA*(choke+1); else, M=fzero(fun,M0); end
Ts=T/(1+(K-1)/2*M^2); Ps=P/(1+(K-1)/2*M^2)^(K/(K-1));
flowState=struct('W',W,'WA',WA,'K',K,'WCOR',WCOR,'M_in',M,...
    'Ts_amb',Ts,'Ps_amb',Ps,'Vel',M*mc_pmsm_SV(Ts,FAR,D),'rhos',Ps/mc_pmsm_GC(FAR,D)/Ts,'choked',choke<0);
end
