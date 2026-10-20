% 生成第四类MAP图
WF_ARRAY=zeros(NV,NH);
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
WF_ARRAY(nv,DH(nh))=OP.WF/DP.WF;
end
order=-order;
end