function[pr_optimal]=COMP_OPT(T0,T4,KP)
k=1.4;kk=(k-1)/k;KP=KP^(-kk);
fun=@(x) (T4-x*T0)./(T4*(1-KP./x)*0.9-T0*(x-1)/0.8);
x_optimal=fminbnd(fun,1,T4/T0);
pr_optimal=x_optimal^(1/kk);
end