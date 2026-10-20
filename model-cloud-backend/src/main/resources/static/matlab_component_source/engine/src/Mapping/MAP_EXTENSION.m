function[MAP]=MAP_EXTENSION(MAP)
% 对已有压气机MAP图进行扩展
% 输入MAP，beta线数，转速分界线，转子闭锁下的最小压比，转子闭锁下的效率
% 输入设计点在MAP图上的位置
% 从左到右，beta增加，W增加，压比减小
switch MAP.component
    case "compressor"
K=1.4;K1=(K-1)/K;
Pr0=MAP.PR_locked;
NCOR=MAP.NCOR;
N_cr=MAP.NC_min;
R=MAP.R;
NX=length(R);
WCOR=MAP.WCOR;
PR=MAP.PR*(MAP.PR0-1)+1;
EFF=MAP.EFF;
if N_cr<min(NCOR)
HS=PR.^K1-1;
K0=.5;
Wg0=K0*N_cr/min(NCOR)*WCOR(1,1);
Wg_locked=linspace(Wg0,0,NX)';
PR_locked=1+(Pr0-1)*(linspace(1,0,NX)').^2;
H0=PR_locked.^K1-1;
HS_cr=H0+(HS(:,1)-H0)*(N_cr/min(NCOR))^2;%分界转速处的焓增
Eff0=min(EFF,[],2);
for nx=1:NX
Wg_cr(nx,1)=interp1([0,NCOR.^2],[Wg_locked(nx,:),WCOR(nx,:)],N_cr.^2,"linear");
Eff_cr(nx,1)=interp1([0,NCOR.^2],[Eff0(nx,1),EFF(nx,:)],N_cr.^2,"linear");
end
NCOR=[0,N_cr,NCOR];
PR=[ones(NX,1),(HS_cr+1).^(1/K1),PR];
WCOR=[zeros(NX,1),Wg_cr,WCOR];
EFF=[Eff0,Eff_cr,EFF];
MAP.NCOR=NCOR;
MAP.PR=(PR-1)/(MAP.PR0-1);
MAP.WCOR=WCOR;
MAP.EFF=EFF;
else
NCOR=[0,NCOR];
PR=[ones(NX,1),PR];
WCOR=[zeros(NX,1),WCOR];
Eff0=min(EFF,[],2);
EFF=[Eff0,EFF];
MAP.NCOR=NCOR;
MAP.PR=(PR-1)/(MAP.PR0-1);
MAP.WCOR=WCOR;
MAP.EFF=EFF;
end
    case "turbine"
end