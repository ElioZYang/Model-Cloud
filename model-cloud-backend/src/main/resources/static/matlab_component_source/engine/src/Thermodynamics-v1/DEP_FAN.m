% 涵道风扇模块
function[OUTPUT]=DEP_FAN(INPUT)
mode=INPUT.mode;
T_REQ=INPUT.THRUST;
switch mode
    case "design"
        INPUT.WA=1;
        INPUT.TPR=-1;
        OUTPUT=DUCTED_FAN(INPUT);
        if T_REQ>=0 % 给定推力
        INPUT.WA=T_REQ/OUTPUT.THRUST;
        else % 给定功率
        INPUT.WA=INPUT.PWC/OUTPUT.PWC;
        end
        OUTPUT=DUCTED_FAN(INPUT); 
        OUTPUT.WAC0=OUTPUT.WAC;
        disp("----------------------")
        disp("涵道风扇设计点计算完成")
        disp("海拔(m)")
        disp(OUTPUT.H)
        disp("速度(m/s)")
        disp(OUTPUT.V)
        disp("风扇总推力(kN)")
        disp(OUTPUT.THRUST)
        disp("风扇功率(kW)")
        disp(OUTPUT.PWC)
        disp("转速(rpm)")
        disp(OUTPUT.N)
        disp("空气流量(kg/s)")
        disp(OUTPUT.WA)
        disp("推进效率")
        disp(OUTPUT.EFFP)
    case "offdesign"
        fun=@(x) FAN_BALANCE(x,INPUT);
        if INPUT.N<0
        n=fzero(fun,1);
        INPUT.N=n*INPUT.N;
        end
        OUTPUT=DUCTED_FAN(INPUT);
        disp("----------------------")
        disp("涵道风扇非设计点计算完成")
        disp("海拔(m)")
        disp(OUTPUT.H)
        disp("速度(m/s)")
        disp(OUTPUT.V)
        disp("风扇总推力(kN)")
        disp(OUTPUT.THRUST)
        disp("风扇功率(kW)")
        disp(OUTPUT.PWC)
        disp("转速(rpm)")
        disp(OUTPUT.N)
        disp("空气流量(kg/s)")
        disp(OUTPUT.WA)
        disp("推进效率")
        disp(OUTPUT.EFFP)
end
end
% 涵道风扇平衡方程
function dT=FAN_BALANCE(n,INPUT)
    INPUT1=INPUT;
    T_REQ=INPUT1.THRUST;
    INPUT1.N=INPUT.N*n;
    OUTPUT=DUCTED_FAN(INPUT1);
    if T_REQ>=0
    dT=OUTPUT.THRUST/T_REQ-1;
    else
    dT=OUTPUT.PWC/INPUT.PWC-1;
    end
end