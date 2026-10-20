function h = component_calculate_rectangular_duct_h( ...
    velocity,width,height,rho,mu,cp,k,Pr)
%COMPONENT_CALCULATE_RECTANGULAR_DUCT_H 标量端口适配入口。
fluid_props = struct('rho',rho,'mu',mu,'cp',cp,'k',k,'Pr',Pr);
h = calculate_rectangular_duct_h(velocity,width,height,fluid_props);
end
