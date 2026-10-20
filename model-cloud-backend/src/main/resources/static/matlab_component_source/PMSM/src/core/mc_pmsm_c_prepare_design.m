function [configuration,operatingPoint]=mc_pmsm_c_prepare_design(configuration,power_kw,speed_rpm,B_g_override)
mc_pmsm_validate_operating(power_kw,speed_rpm);
if nargin>3&&B_g_override>0, configuration.B_g=B_g_override; end
voltage=configuration.voltage_phase;
if voltage<0, voltage=configuration.voltage_line/(3^0.5); end
power_W=abs(power_kw)*1000;
operatingPoint=struct('power_kw',power_kw,'power_W',power_W,'speed_rpm',speed_rpm,...
    'electricMode',sign(power_kw),'voltage_phase',voltage,...
    'frequency_Hz',configuration.pole_pairs*speed_rpm/60,'omega',speed_rpm*pi/30,...
    'current_A',power_W/(configuration.N_phase*voltage*configuration.cos_phi));
end
