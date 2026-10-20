% 生成第三类MAP图
OP.T_REQ=0;
WF_ARRAY=zeros(NV,NH,NT);
NT0=find(T_array==1);
X_ini=X0;
order=-1;
for nv=NV:-1:1
OP.V=(V_array(nv)^0.5)*DP.V_max;
if order==-1
DH=NH:-1:1;
else
DH=1:NH;
end
for nh=1:NH
OP.H=H_array(DH(nh))*DP.H_max;
[OP,X0]=BALANCE_FUNCTION_OFFDESIGN(DP,OP,MAP,X_ini+w*dX_hv);
dX_hv=X0-X_ini;
WF_ARRAY(nv,DH(nh),1)=OP.WF/DP.WF;
X_ini=X0;
for nt=NT0:NT
OP.TO(1)=T_array(nt)*DP.TO(1);
    X_ini1=X0;
    [OP,X0]=BALANCE_FUNCTION_OFFDESIGN(DP,OP,MAP,X0+w*dX_pt);
    dX_pt=X0-X_ini1;
WF_ARRAY(nv,DH(nh),nt)=OP.WF/DP.WF;
end
X0=X_ini;
for nt=NT0-1:-1:1
OP.TO(1)=T_array(nt)*DP.TO(1);
    X_ini1=X0;
    [OP,X0]=BALANCE_FUNCTION_OFFDESIGN(DP,OP,MAP,X0+w*dX_pt);
    dX_pt=X0-X_ini1;
WF_ARRAY(nv,DH(nh),nt)=OP.WF/DP.WF;
end
end
order=-order;
end