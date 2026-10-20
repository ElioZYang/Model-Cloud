function [ O ] = MAPPING(mode,MAP,X,Y,PRC0)
%UNTITLED3 此处显示有关此函数的摘要
%   此处显示详细说明
%   默认WCOR随R增加而增加
mode_interp=1;
if mode_interp==0
switch mode
    case "comp"
        surge=0;
        choke=0;
        overload=0;
        NCOR_REF=MAP.NCOR;
        N_cr=MAP.C_in.NC_min;
        R_REF=MAP.R;
        if Y<min(R_REF)
            choke=(min(R_REF)-Y)/abs(R_REF(1)-R_REF(end));
        end
        if Y>max(R_REF)
            surge=(Y-max(R_REF))/abs(R_REF(1)-R_REF(end));
        end
        WCOR_REF=MAP.WCOR;
        PR_REF=MAP.PR;
        EFF_REF=MAP.EFF;
        if (X>=N_cr&&X<=max(NCOR_REF))
        O.WAC=interp2(NCOR_REF,R_REF,WCOR_REF,X,Y,'linear');
        if isnan(O.WAC)
        O.WAC=interp2(NCOR_REF,R_REF,WCOR_REF,X,Y,'spline');
        O.PR=interp2(NCOR_REF,R_REF,PR_REF,X,Y,'spline');
        O.EFF=interp2(NCOR_REF,R_REF,EFF_REF,X,Y,'spline');
        else
        O.PR=interp2(NCOR_REF,R_REF,PR_REF,X,Y,'linear');
        O.EFF=interp2(NCOR_REF,R_REF,EFF_REF,X,Y,'linear');
        end
        elseif X>max(NCOR_REF)
        X=max(NCOR_REF);
        overload=X-max(NCOR_REF);
        O.WAC=interp1(R_REF,WCOR_REF(:,end),Y,'linear','extrap')*X/NCOR_REF(end);
        O.PR=interp1(R_REF,PR_REF(:,end),Y,'linear','extrap')*X/NCOR_REF(end);
        O.EFF=interp1(R_REF,EFF_REF(:,end),Y,'linear','extrap')*X/NCOR_REF(end);
        else % incompressible
        O.WAC=interp2(NCOR_REF.^2,R_REF,WCOR_REF,X^2,Y,'linear');
        if isnan(O.WAC)
        O.WAC=interp2(NCOR_REF.^2,R_REF,WCOR_REF,X^2,Y,'spline');
        O.PR=interp2(NCOR_REF.^2,R_REF,PR_REF,X^2,Y,'spline');
        O.EFF=interp2(NCOR_REF.^2,R_REF,EFF_REF,X^2,Y,'spline');
        else
        O.PR=interp2(NCOR_REF.^2,R_REF,PR_REF,X^2,Y,'linear');
        O.EFF=interp2(NCOR_REF.^2,R_REF,EFF_REF,X^2,Y,'linear');            
        end    
        end
        O.WAC=max(0,O.WAC);
        O.EFF=max(0.001,O.EFF);
        O.surge=surge;
        O.choke=choke;
        O.overload=overload;
    case "turb"
        overload=0;
        NCOR_REF=MAP.NCOR;
        R_REF=MAP.R;
        if X>max(NCOR_REF)
        overload=X-max(NCOR_REF);
        end
        O.overload=overload;
        X=max(X,min(NCOR_REF));
        X=min(X,max(NCOR_REF));        
        Y=max(Y,min(R_REF));
        Y=min(Y,max(R_REF));
        WCOR_REF=MAP.WCOR;
        PR_REF=MAP.PR;
        EFF_REF=MAP.EFF;
        O.WGC=interp2(NCOR_REF,R_REF,WCOR_REF,X,Y,'linear');
        if isnan(O.WGC)
        O.WGC=interp2(NCOR_REF,R_REF,WCOR_REF,X,Y,'spline');
        O.PR=interp2(NCOR_REF,R_REF,PR_REF,X,Y,'spline');
        O.EFF=interp2(NCOR_REF,R_REF,EFF_REF,X,Y,'spline');
        else
        O.PR=interp2(NCOR_REF,R_REF,PR_REF,X,Y,'linear');
        O.EFF=interp2(NCOR_REF,R_REF,EFF_REF,X,Y,'linear');
        end
        O.WGC=max(0,O.WGC);
        O.EFF=max(0.001,O.EFF);
    case "motor"
        % '电动机'模式下，WCOR默认为转矩的归一化值
        WCOR_REF=MAP.WCOR;
        NCOR_REF=MAP.NCOR;
        EFF_REF=MAP.EFFM;
        R_REF=MAP.R;
        fun=@(R) interp2(NCOR_REF,R_REF,WCOR_REF,X,R)-Y;
        R_final=fzero(fun,1);
        O=interp2(NCOR_REF,R_REF,EFF_REF,X,R_final,'spline');
        O=max(0.1,O);
end
else
    % 简单插值
switch mode
    case "comp"
        NCOR_REF=MAP.NCOR;
        R_REF=MAP.R;        
        WCOR_REF=MAP.WCOR;
        PR_REF=MAP.PR;
        EFF_REF=MAP.EFF;
        choke=1;
        surge=1;
        lowspeed=1;
        overload=1;
        if X<min(NCOR_REF)           
            lowspeed=X/min(NCOR_REF);X=min(NCOR_REF);
        end
        if X>max(NCOR_REF)          
            overload=X/max(NCOR_REF);X=max(NCOR_REF);
        end
        if Y<min(R_REF)            
            surge=Y/min(R_REF);Y=min(R_REF);
        end
        if Y>max(R_REF)            
            choke=Y/max(R_REF);Y=max(R_REF);
        end
        WAC=interp2(NCOR_REF,R_REF,WCOR_REF,X,Y,'linear')*lowspeed*overload;
        PR=interp2(NCOR_REF,R_REF,PR_REF,X,Y,'linear')*lowspeed*overload;
        EFF=interp2(NCOR_REF,R_REF,EFF_REF,X,Y,'linear');
        if choke>1
            PR=(PR+1/(PRC0-1))*(exp(1-choke))-1/(PRC0-1);
        end
        if surge<1
            WAC=WAC*surge;
            PR=PR*(exp(surge-1));
        end
        O.WAC=WAC;
        O.PR=PR;
        O.EFF=EFF;
        O.surge=surge;
        O.choke=choke;
        O.overload=overload;
    case "turb"
        NCOR_REF=MAP.NCOR;
        R_REF=MAP.R;        
        WCOR_REF=MAP.WCOR;
        PR_REF=MAP.PR;
        EFF_REF=MAP.EFF;
        choke=1;
        surge=1;
        lowspeed=1;
        overload=1;
        if X<min(NCOR_REF)        
            lowspeed=X/min(NCOR_REF);X=min(NCOR_REF);
        end
        if X>max(NCOR_REF)
            overload=X/max(NCOR_REF);X=max(NCOR_REF);
        end
        if Y<min(R_REF)
            surge=Y/min(R_REF);Y=min(R_REF);
        end
        if Y>max(R_REF)
            choke=Y/max(R_REF);Y=max(R_REF);
        end
        WAC=interp2(NCOR_REF,R_REF,WCOR_REF,X,Y,'linear');
        PR=interp2(NCOR_REF,R_REF,PR_REF,X,Y,'linear');
        EFF=interp2(NCOR_REF,R_REF,EFF_REF,X,Y,'linear');
        if choke>1
            PR=PR*choke;
        end
        if surge<1
            WAC=WAC*surge;
            PR=PR*(exp(surge-1));
        end
        O.WGC=WAC;
        O.PR=PR;
        O.EFF=EFF;
        O.surge=surge;
        O.choke=choke;
        O.overload=overload;
    case "motor"
        % '电动机'模式下，WCOR默认为转矩的归一化值
        WCOR_REF=MAP.WCOR;
        NCOR_REF=MAP.NCOR;
        EFF_REF=MAP.EFFM;
        R_REF=MAP.R;
        fun=@(R) interp2(NCOR_REF,R_REF,WCOR_REF,X,R)-Y;
        R_final=fzero(fun,1);
        O=interp2(NCOR_REF,R_REF,EFF_REF,X,R_final,'spline');
        O=max(0.1,O);
end
end

