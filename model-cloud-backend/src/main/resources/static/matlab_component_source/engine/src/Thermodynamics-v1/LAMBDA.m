function [O]=LAMBDA(I,K,mode)
switch mode
    case 1 %由M到LAMBDA
    O=I*((K+1)/(2+(K-1)*I^2))^0.5;
    case 2 %由LAMBDA到M
    O=I*(2/((K+1)-(K-1)*I^2))^0.5;
end
end