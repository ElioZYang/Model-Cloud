% 生成第二类MAP图
OP.T_REQ=1;
OP.THRUST=0;
WF_ARRAY=zeros(NV,NH,NP);
NP0=find(P_array==1);
X_ini=X0;
order=-1;
for nv=NV:-1:1
    disp(nv)
OP.V=(V_array(nv)^0.5)*DP.V_max;
if order==-1
DH=NH:-1:1;
else
DH=1:NH;
end
for nh=1:NH
    disp(nh)
OP.H=H_array(DH(nh))*DP.H_max;
[OP,X0]=BALANCE_FUNCTION_OFFDESIGN(DP,OP,MAP,X_ini+w*dX_hv);
dX_hv=X0-X_ini;
WF_ARRAY(nv,DH(nh),1)=OP.WF/DP.WF;
X_ini=X0;
for np=NP0:NP
    disp(np)
OP.PWG=P_array(np)*DP.PWG;
    X_ini1=X0;
    [OP,X0]=BALANCE_FUNCTION_OFFDESIGN(DP,OP,MAP,X0+w*dX_pt);
    dX_pt=X0-X_ini1;
WF_ARRAY(nv,DH(nh),np)=OP.WF/DP.WF;
end
X0=X_ini;
for np=NP0-1:-1:1
    disp(np)
OP.PWG=P_array(np)*DP.PWG;
    X_ini1=X0;
    [OP,X0]=BALANCE_FUNCTION_OFFDESIGN(DP,OP,MAP,X0+w*dX_pt);
    dX_pt=X0-X_ini1;
WF_ARRAY(nv,DH(nh),np)=OP.WF/DP.WF;
end
end
order=-order;
end