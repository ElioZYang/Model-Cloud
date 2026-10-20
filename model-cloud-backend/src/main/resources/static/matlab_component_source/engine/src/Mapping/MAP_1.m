% 生成第一类MAP图
OP.T_REQ=0;
WF_ARRAY=zeros(NV,NH,NP,NT);
NP0=find(P_array==1);
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
WF_ARRAY(nv,DH(nh),1,1)=OP.WF/DP.WF;
X_ini=X0;
% 开始遍历4个象限
% 第一象限
order1=1;
for nt=NT0:NT
    n_count=n_count+1;
    OP.TO(1)=T_array(nt)*DP.TO(1);
if order1==1
    DPWG=NP0+1:NP;
else
    DPWG=NP:-1:NP0+1;
end
for np=1:NP-NP0
    OP.PWG=P_array(DPWG(np))*DP.PWG;
    X_ini1=X0;
    [OP,X0]=BALANCE_FUNCTION_OFFDESIGN(DP,OP,MAP,X0+w*dX_pt);
    dX_pt=X0-X_ini1;
    WF_ARRAY(nv,DH(nh),DPWG(np),nt)=OP.WF/DP.WF;
end
order1=-order1;
end
% 第二象限
X0=X_ini;
order1=1;
for np=NP0:-1:1
    OP.PWG=P_array(np)*DP.PWG;
if order1==1
    DTO=NT0+1:NT;
else
    DTO=NT:-1:NT0+1;
end
for nt=1:NT-NT0
    OP.TO(1)=T_array(DTO(nt))*DP.TO(1);
    X_ini1=X0;
    [OP,X0]=BALANCE_FUNCTION_OFFDESIGN(DP,OP,MAP,X0+w*dX_pt);
    dX_pt=X0-X_ini1;
    WF_ARRAY(nv,DH(nh),np,DTO(nt))=OP.WF/DP.WF;
end
order1=-order1;
end
% 第三象限
X0=X_ini;
order1=-1;
for nt=NT0:-1:1
    OP.TO(1)=T_array(nt)*DP.TO(1);
if order1==1
    DPWG=1:NP0-1;
else
    DPWG=NP0-1:-1:1;
end
for np=1:NP0-1
    OP.PWG=P_array(DPWG(np))*DP.PWG;
    X_ini1=X0;
    [OP,X0]=BALANCE_FUNCTION_OFFDESIGN(DP,OP,MAP,X0+w*dX_pt);
    dX_pt=X0-X_ini1;
    WF_ARRAY(nv,DH(nh),DPWG(np),nt)=OP.WF/DP.WF;
end
order1=-order1;
end
% 第四象限
X0=X_ini;
order1=-1;
for np=NP0:NP
    OP.PWG=P_array(np)*DP.PWG;
if order1==1
    DTO=1:NT0-1;
else
    DTO=NT0-1:-1:1;
end
for nt=1:NT0-1
    OP.TO(1)=T_array(DTO(nt))*DP.TO(1);
    X_ini1=X0;
    [OP,X0]=BALANCE_FUNCTION_OFFDESIGN(DP,OP,MAP,X0+w*dX_pt);
    dX_pt=X0-X_ini1;
    WF_ARRAY(nv,DH(nh),np,DTO(nt))=OP.WF/DP.WF;
end
order1=-order1;
end
end
order=-order;
end