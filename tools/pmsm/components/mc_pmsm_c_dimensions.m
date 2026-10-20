function [configuration,geometry]=mc_pmsm_c_dimensions(configuration,operatingPoint)
c=configuration; op=operatingPoint;
P=op.power_W; n=op.speed_rpm; I=op.current_A; Q=c.N_slot; N=c.N_cs;
a=c.a; Xlen=c.X_length; pitch=c.slot_pitch/1000;
C=(pi^2/60*c.K_w*c.B_g*n); Amax=48000/c.B_g;
if N<0
    A=min(Amax,c.A_s);
    k=(a*pi/(I*Q))*(P/(C*Xlen))^(1/3);
    Ninteger=max(floor(k*A^(2/3)),1);
    A=(Ninteger/k)^(3/2);
    D2L=P/(C*A); Di=(D2L/Xlen).^(1/3);
    if Q<0, Q=max(round(pi*Di/pitch),2); end
    N=round(a*(A*pi*Di/I/Q));
else
    if Q<0
        D2L=max(P/C*pi*a*pitch/N/I,P/C/Amax);
        Di=(D2L/Xlen).^(1/3); Q=max(round(pi*Di/pitch),2);
    end
    N=min(N,round(pi*a*Amax^(2/3)*P^(1/3)/(C^(1/3)*I*Q*Xlen^(1/3))));
    DL=P/C*pi*a/N/I/Q; Di=(DL/Xlen).^.5;
    A=N*I/a*Q/pi/Di;
end
configuration.N_cs=N; configuration.A_s=A;
geometry=struct('stator_OD',Di/c.X_stator*1000,'stator_ID',Di*1000,...
    'core_length',Xlen*Di*1000,'air_gap',c.h_airgap,'slot_number',Q,'pole_pairs',c.pole_pairs);
end
