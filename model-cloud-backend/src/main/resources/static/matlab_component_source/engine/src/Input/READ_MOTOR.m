%% read motor map
for nm = 1:DP.NM
    motor_fieldname = ['motor' num2str(nm)];
    M_in = M((strcmpi(basic_motor_map, MAP_in.(motor_fieldname)))); 
    MAP.MOTOR(nm).M_in=M_in;
    basicmap=M_in.basicmap;
    if ~strcmpi(basicmap,"NO")
        maxeff=M_in.maxeff;
        n_design=M_in.n_design;
        nrow=M_in.nrow;
        ncol=M_in.ncol;
        component=M_in.component;
        MOTOR=readmatrix(".\Map Collection\MOTOR\MOTOR.xlsx", ...
            "Sheet", basicmap);
        NCOR=MOTOR(1,2:1+ncol);
        R=MOTOR(2:1+nrow,1);
        WCOR=MOTOR(2:1+nrow,2:1+ncol);
        TORQUE=WCOR;
        TORQUE=TORQUE/WCOR(maxeff,n_design);
        EFFM=MOTOR(3+nrow:2+2*nrow,2:1+ncol);
        switch component
            case "motor"
                WCOR=WCOR./EFFM;% electric torque(+ for motor,- for generator)
                PW=WCOR.*NCOR;
                PW_peak=max(max(PW));
                EFF_peak=EFFM(PW==PW_peak);
            case "generator"
                WCOR=WCOR.*EFFM;
                PW=WCOR.*NCOR;
                PW_peak=-max(max(abs(WCOR.*NCOR)));
                EFF_peak=EFFM(PW==PW_peak);
            case "motor+generator"
                n_cr=0.5*(nrow-1);
                WCOR1=WCOR(1:n_cr-1,:);EFFM1=EFFM(1:n_cr-1,:);
                WCOR1=WCOR1.*EFFM1;% generator
                WCOR2=WCOR(n_cr+1:end,:);EFFM2=EFFM(n_cr+1:end,:);
                WCOR2=WCOR2./EFFM2;% motor
                WCOR=[WCOR1;zeros(1,ncol);WCOR2];
                PW1=WCOR1.*EFFM1;
                PW2=WCOR2.*EFFM2;
                PW=[PW1;zeros(1,ncol);PW2];
                PW_peak1=-max(max(abs(WCOR1.*NCOR)));
                EFF_peak1=EFFM(PW1==PW_peak1);
                PW_peak2=-max(max(abs(WCOR2.*NCOR)));
                EFF_peak2=EFFM(PW2==PW_peak2);
                PW_peak=[PW_peak1,PW_peak2];
                EFF_peak=[EFF_peak1,EFF_peak2];
        end
        PW(EFFM==0)=0;
        EFF0=EFFM(maxeff,n_design);
        PW0=PW(maxeff,n_design);
        WCOR0=WCOR(maxeff,n_design);
        MAP.MOTOR(nm).R=R;
        MAP.MOTOR(nm).R0=R(maxeff);
        N0=NCOR(n_design);
        MAP.MOTOR(nm).NCOR=NCOR./N0;
        MAP.MOTOR(nm).EFF0=EFF0;
        MAP.MOTOR(nm).EFF_peak=EFF_peak/EFF0;
        MAP.MOTOR(nm).TORQUE_elec=WCOR./WCOR0;
        MAP.MOTOR(nm).TORQUE_mech=TORQUE;
        MAP.MOTOR(nm).PW_elec=PW./PW0;
        MAP.MOTOR(nm).PW_mech=TORQUE.*NCOR;
        MAP.MOTOR(nm).PW_peak=PW_peak/PW0;
        MAP.MOTOR(nm).EFFM=EFFM./EFF0;
    end
end
%% generator map setting
G_in=table2struct(readtable(".\Map Collection\TURBO GENERATOR\TURBO GENERATOR.xlsx"));
% G=xlsread("D:\HYBRID AIRCRAFT SOFTWARE\HYBRID AIRCRAFT-v4\INPUT\MAP.xlsx",'MOTOR_MAP');
MAP.TURBO_GENERATOR=G_in;
