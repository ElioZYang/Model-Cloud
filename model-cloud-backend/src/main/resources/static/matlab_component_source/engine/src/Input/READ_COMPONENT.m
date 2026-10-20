% k=1.4;k1=(k-1)/k;
O_in=readtable(".\Input\Component Map Input.xlsx",Sheet="Component Maps");
% 初始化一个空的结构体
MAP_in = struct();
% 遍历表格的每一行
for i = 1:height(O_in)
    % 获取变量名和变量值
    varName = cell2mat(O_in{i, 1}); % 第一列是变量名
    if ~strcmpi(varName,'')
        varValue = cell2mat(O_in{i, 2}); % 第二列是变量值
        MAP_in.(varName) = varValue;
    end
end
C=readtable(".\Map Collection\COMPRESSOR\COMPRESSOR.xlsx",Sheet="C");
baseline_compressor_map=C.basicmap;
T=readtable(".\Map Collection\TURBINE\TURBINE.xlsx",Sheet="T");
baseline_turbine_map=T.basicmap;
M=readtable(".\Map Collection\MOTOR\MOTOR.xlsx",Sheet="M");
basic_motor_map=M.basicmap;
C=table2struct(C);
T=table2struct(T);
M=table2struct(M);
nc=0;
nt=0;
for nf=1:DP.NF
%% read compressor map
    if strcmpi(DP.F(nf),"fan")||strcmpi(DP.F(nf),"lpc")||strcmpi(DP.F(nf),"hpc")||strcmpi(DP.F(nf),"ipc")
        nc=nc+1;
        fieldName = lower(DP.F(nf));
        if isfield(MAP_in, fieldName)
            C_in = C(strcmpi(baseline_compressor_map, MAP_in.(fieldName)));
            if C_in.extension==1
            C_in = C(strcmpi(baseline_compressor_map, strcat(MAP_in.(fieldName)," extended")));       
            end
        else
            error('Invalid field name: %s', fieldName);
        end
        basicmap=C_in.basicmap;
        C_in.component=DP.F(nf);
        COMP=readmatrix(".\Map Collection\COMPRESSOR\COMPRESSOR.xlsx", ...
            "Sheet", basicmap);
        MAP.COMPRESSOR(nc).C_in=C_in;
        ncol=C_in.ncol;nrow=C_in.nrow;
        maxeff=C_in.maxeff;n_design=C_in.n_design;
        NCOR=COMP(1,2:1+ncol);
        WCOR=COMP(2:1+nrow,2:1+ncol);
        EFF=COMP(3+nrow:2+2*nrow,2:1+ncol);
        PR=COMP(4+2*nrow:3*(1+nrow),2:1+ncol);
        if WCOR(end,n_design)<WCOR(1,n_design)
            WCOR=flip(WCOR,1);
            PR=flip(PR,1);
            EFF=flip(EFF,1);
            maxeff=nrow-maxeff;
        end
        WCOR0=WCOR(maxeff,n_design);
        EFF0=EFF(maxeff,n_design);
        PR0=PR(maxeff,n_design);
        % MAP.COMPRESSOR(nc).maxeff=maxeff;
        % MAP.COMPRESSOR(nc).n_design=n_design;
        MAP.COMPRESSOR(nc).WCOR0=WCOR0;
        MAP.COMPRESSOR(nc).EFF0=EFF0;
        MAP.COMPRESSOR(nc).PR0=PR0;
        MAP.COMPRESSOR(nc).WCOR=WCOR/WCOR0;
        MAP.COMPRESSOR(nc).EFF=EFF/EFF0;
        MAP.COMPRESSOR(nc).PR=(PR-1)/(PR0-1);
        MAP.COMPRESSOR(nc).NCOR=NCOR/NCOR(n_design);
        R=(1:nrow)';
        MAP.COMPRESSOR(nc).R=R/R(maxeff);
        MAP.COMPRESSOR(nc).WCOR=max(MAP.COMPRESSOR(nc).WCOR,0);
    end
%% read turbine map
    if strcmpi(DP.F(nf),"lpt")||strcmpi(DP.F(nf),"hpt")||strcmpi(DP.F(nf),"ipt")
        nt=nt+1;
        fieldName = lower(DP.F(nf));
        if isfield(MAP_in, fieldName)
            T_in = T(strcmpi(baseline_turbine_map, MAP_in.(fieldName)));
            if T_in.extension==1
            T_in = T(strcmpi(baseline_turbine_map, strcat(MAP_in.(fieldName)," extended")));       
            end
        else
            error('Invalid field name: %s', fieldName);
        end
        basicmap=T_in.basicmap;
        T_in.component=DP.F(nf);
        TURB=readmatrix(".\Map Collection\TURBINE\TURBINE.xlsx", ...
            "Sheet", basicmap);
        MAP.TURBINE(nt).T_in=T_in;
        ncol=T_in.ncol;nrow=T_in.nrow;
        maxeff=T_in.maxeff;n_design=T_in.n_design;
        NCOR=TURB(1,2:1+ncol);
        WCOR=TURB(2:1+nrow,2:1+ncol);
        EFF=TURB(3+nrow:2+2*nrow,2:1+ncol);
        PR=TURB(4+2*nrow:3*(1+nrow),2:1+ncol);
        if WCOR(end,n_design)<WCOR(1,n_design)
            WCOR=flip(WCOR,1);
            PR=flip(PR,1);
            EFF=flip(EFF,1);
            maxeff=nrow-maxeff;
        end
        WCOR0=WCOR(maxeff,n_design);
        EFF0=EFF(maxeff,n_design);
        PR0=PR(maxeff,n_design);
        MAP.TURBINE(nt).WCOR0=WCOR0;
        MAP.TURBINE(nt).EFF0=EFF0;
        MAP.TURBINE(nt).PR0=PR0;
        MAP.TURBINE(nt).WCOR=WCOR/WCOR0;
        MAP.TURBINE(nt).EFF=EFF/EFF0;
        MAP.TURBINE(nt).PR=(PR-1)/(PR0-1);
        MAP.TURBINE(nt).NCOR=NCOR/NCOR(n_design);
        R=(1:nrow)';
        MAP.TURBINE(nt).R=R/R(maxeff);
    end
%% read propeller map
end
