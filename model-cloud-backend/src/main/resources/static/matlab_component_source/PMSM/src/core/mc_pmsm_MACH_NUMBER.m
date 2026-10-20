function[M,K,V]=mc_pmsm_MACH_NUMBER(A,W,T,P,FAR,D)
% 已知截面积、空气流量、总温、总压、油气比、湿度，求马赫数，气体比热比，气体速度
R=mc_pmsm_GC(FAR,D);
fun1=@(M,K) M-W/P/A*sqrt(R*T/K)*(1+(K-1)/2*M^2)^(-1/2+K/(K-1));
fun2=@(M,K) K-mc_pmsm_AE(T/(1+(K-1)/2*M^2),FAR,D);
err=1E3;
det=1E-6;
K0=mc_pmsm_AE(T,FAR,D);
fun0=@(M) fun1(M,K0);
M0=fzero(fun0,0.3);
A=[1+det,0;0,1];
B=[1,0;0,1+det];
X0=[M0;K0];
J=[1,0;0,1];
Y=[0,0,0;0,0,0];
Y0=Y(:,1);
while err>=1E-6
X0=X0-J\Y0;
X=[X0,A*X0,B*X0];
for k=1:3
Y(:,k)=[fun1(X(1,k),X(2,k));fun2(X(1,k),X(2,k))];
end
Y0=Y(:,1);
err=sqrt(Y0'*Y0/2);
J=[Y(:,2)-Y(:,1),Y(:,3)-Y(:,1)]/det;
end
M=X0(1);
K=X0(2);
V=mc_pmsm_SV(T/(1+(K-1)/2*M^2),FAR,D)*M;
end