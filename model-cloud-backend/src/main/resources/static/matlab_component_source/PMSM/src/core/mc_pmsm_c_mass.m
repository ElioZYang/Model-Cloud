function [geometry,mass]=mc_pmsm_c_mass(configuration,operatingPoint,geometry,slot,winding,magnet)
c=configuration; mat=c.material.data;
sd=mc_pmsm_get_prop(mat,'steel','density'); rd=mc_pmsm_get_prop(mat,'steel_shaft','density');
cd=mc_pmsm_get_prop(mat,'copper','density'); vd=mc_pmsm_get_prop(mat,'cavity','density');
md=mc_pmsm_get_prop(mat,magnet.magnet_type,'density'); ad=mc_pmsm_get_prop(mat,'aluminum','density');
Do=geometry.stator_OD/1000; Di=geometry.stator_ID/1000; L=geometry.core_length/1000;
Dor=geometry.rotor_OD/1000; Dir=geometry.rotor_ID/1000; Q=geometry.slot_number;
hy=slot.yoke_height/1000;
Vy=(pi/4*(Do^2-(Do-2*hy)^2))*L;
Vt=(pi/4*(Do^2-Di^2)*L-slot.area/1e6*Q*L)-Vy;
mt=Vt*sd; my=Vy*sd; mstator=mt+my;
mr=rd*(pi/4*Dor^2*L-magnet.volume);
Aw=slot.area_body*c.slot_fill/c.N_cs/1e6;
mc=cd*3*winding.conductor_length_per_phase*Aw;
mv=vd*slot.area/1e6*L*Q*(1-c.slot_fill); mm=md*magnet.volume;
th=.1*Do; Doh=Do+2*th;
mh=ad*(pi/4*(Doh^2-Do^2)*(L+.05)+pi/4*Doh^2*2*th);
H=.5*c.XH_cgv*Doh; C=c.XC_cgv*L; mhex=0; mcgv=0;
switch c.cooling
case {1,2}, mcgv=Q*H*C*.06*C*ad;
case 3, mhex=15*operatingPoint.power_W/1E5;
otherwise, error('PMSM:InvalidCooling','Unsupported cooling mode');
end
ms=rd*pi*(Dir/2)^2*(2*.05);
total=mstator+mr+mc+mv+mm+mh+ms+mcgv+mhex;
geometry.cgv_height=H*1000; geometry.cgv_length=C*1000; geometry.housing_OD=Doh*1000;
mass=struct('stator_tooth',mt,'stator_yoke',my,'rotor_core',mr,'copper',mc,'cavity',mv,...
    'magnets',mm,'housing',mh,'shaft',ms,'cgv',mcgv,'heat_exchanger',mhex,'total',total);
end
