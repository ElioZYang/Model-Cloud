    maptype=MAP.TURBO_GENERATOR.type;
    mapname=strcat(DP.type," demo ",sprintf("map%d ",maptype),sprintf("%dkW ",round(DP.PWE)),' ',sprintf("%dkN",round(DP.THRUST)),".mat");
    file0=pwd;
    TURBO_GENERATOR=MAP.TURBO_GENERATOR;
    cd('..\ENGINE+GENERATOR\Map Collection\TURBO GENERATOR\')
    save(mapname,'TURBO_GENERATOR');
    cd(file0)