function INPUT=mc_pmsm_offdesign_input(design,power_kw,speed_rpm)
INPUT=design;
INPUT.mode="offdesign"; INPUT.pmsm_input=design.pmsm_params;
INPUT.PWG=power_kw; INPUT.PWG_ref=1;
INPUT.NM=speed_rpm; INPUT.N_ref=1;
end
