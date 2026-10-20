% function [OUTPUT]=MOTOR(INPUT)
%         OUTPUT=INPUT;
% switch INPUT.mode
%     case 'design'
%         OUTPUT.NM0=INPUT.N;
%         OUTPUT.TORQUE0=INPUT.PWS/OUTPUT.NM0;
%         if OUTPUT.PWS>0 % generator mode
%         OUTPUT.PWG=OUTPUT.EFFM*OUTPUT.PWS;
%         else
%         OUTPUT.PWG=OUTPUT.EFFM\OUTPUT.PWS;
%         end
%         OUTPUT.PWH=abs(OUTPUT.PWS-OUTPUT.PWG);
%     case 'offdesign'
%         TORQUE=INPUT.PWS/INPUT.N_REF/INPUT.NM0;
%         OUTPUT.TORQUE=TORQUE;
%         OUTPUT.TORQUE_ref=TORQUE/INPUT.TORQUE0;
%         if strcmpi(INPUT.MAP.M_in.basicMAP,"NO")
%         OUTPUT.EFFM=INPUT.EFFM0;
%         else
%         OUTPUT.EFFM=INPUT.EFFM0*MAPPING('motor',INPUT.MAP,INPUT.N_REF,OUTPUT.TORQUE_ref);
%         end
%         if OUTPUT.PWS>0 % generator mode
%         OUTPUT.PWG=OUTPUT.EFFM*OUTPUT.PWS;
%         else
%         OUTPUT.PWG=OUTPUT.EFFM\OUTPUT.PWS;
%         end
%         OUTPUT.PWH=abs(OUTPUT.PWS-OUTPUT.PWG);
% end
% end
function[OUTPUT]=MOTOR(INPUT)
OUTPUT=INPUT;
EFF0=INPUT.EFFM;
mode=INPUT.mode;
% if strcmpi(MAP.M_in.basicmap,"NO")
% if PWS>=0
%     PWG=PWS*EFF0;
% else
%     PWG=PWS/EFF0;
% end
% PWH=abs(PWG-PWS);
% OUTPUT.PWG=PWG;
% OUTPUT.PWH=PWH;
% OUTPUT.WP=[1;1];
% else
switch mode
case "design"
    PWG=INPUT.PWG;% electric power at engine design point
    NM0=INPUT.NM;
    if abs(PWG)<=1E-3
    PWG=0; % no electric power output
    end
    if PWG>0
        PWS=PWG/EFF0; % generator mode
    else
        PWS=PWG*EFF0; % motor mode
    end
    PWH=abs(PWG-PWS);
    OUTPUT.PWH=PWH;% heat flow
case "offdesign"
    MAP=INPUT.MAP;
    PWG=INPUT.PWG;
    PWG0=INPUT.PWG_rated;
    N_ref=INPUT.N_ref;
    NM0=INPUT.NM;
    pw=PWG/PWG0;
    if strcmpi(MAP.M_in.basicmap,"NO")% 电机效率恒定
    torque_ref=pw/N_ref;
    eff=EFF0;
    else
    r0=MAP.R0;
    r=fzero(@(x) electric_machine_efficiency(MAP,N_ref,x*r0,EFF0)-pw,1);
    [pw,eff,torque_ref]=electric_machine_efficiency(MAP,N_ref,r*r0,EFF0);
    end
    PWG=pw*PWG0;
    PWS=PWG*eff^(-sign(PWG));
    PWH=abs(PWG-PWS);
    OUTPUT.PWS=PWS;
    OUTPUT.PWG=PWG;
    OUTPUT.PWH=PWH;
    OUTPUT.EFF=eff;
    OUTPUT.WP=[N_ref;torque_ref];
end
% end
end
% function[dpw]=motor_balance(MAP,n,r,pws,pwg0,eff0)
%     pw_ref=pws/pwg0;
%     [pw,eff]=electric_machine_efficiency(MAP,n,r,eff0);
%     dpw=pw_ref-pw*eff;
% end
% function[dpw]=generator_balance(MAP,n,r,pws,pwg0,eff0)
%     pw_ref=pws/pwg0;
%     [pw,eff]=electric_machine_efficiency(MAP,n,r,eff0);
%     dpw=pw_ref*eff-pw;
% end
function[pw,eff,torque_ref]=electric_machine_efficiency(MAP,n,r,eff0)
pw_array=MAP.PW_elec;
eff_array=MAP.EFFM;
torque_array=MAP.TORQUE_mech;
r_array=MAP.R;
n_array=MAP.NCOR;
kp=1;
switch MAP.M_in.component
    case "motor"
kp=sign(r);r=kp*r;
    case "generator"
kp=sign(-r);r=kp*r;
end
pw=kp*interpn(r_array,n_array,pw_array,r,n);% pwg/pwg_rated
eff=interpn(r_array,n_array,eff_array,r,n)*eff0;% power transfer efficiency
torque_ref=interpn(r_array,n_array,torque_array,r,n);
end