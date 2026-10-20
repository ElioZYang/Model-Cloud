function [geometry,magnet]=mc_pmsm_c_rotor(configuration,operatingPoint,geometry,slot)
c=configuration; Di=geometry.stator_ID/1000; L=geometry.core_length/1000; gap=geometry.air_gap/1000;
if operatingPoint.speed_rpm>5000, kind='SmCo'; else, kind='NdFeB'; end
Br=mc_pmsm_get_prop(c.material.data,kind,'B_r'); Hcj=mc_pmsm_get_prop(c.material.data,kind,'H_cj');
hmax=Di/2-1e-3;
h=mc_pmsm_calculate_pm_thickness(Di,L,gap,c.B_g/c.arc_factor,Br,Hcj,c.carter_factor,...
    c.pole_pairs,c.arc_factor,slot.opening_width/1000,slot.opening_height/1000);
if h>hmax, gap=gap*hmax/h; h=hmax; end
Dor=Di-2*gap; Dir=Dor*c.X_rotor;
geometry.air_gap=gap*1000; geometry.rotor_OD=Dor*1000; geometry.rotor_ID=Dir*1000;
magnet=struct('magnet_type',kind,'outer_diameter',1000*Dor,'pole_pairs',c.pole_pairs,...
    'volume',L*pi*((Dor/2)^2-(Dor/2-h)^2)*c.arc_factor,...
    'height',1000*h,'theta',c.arc_factor*360/2/c.pole_pairs,'segments',1);
end
