function Nu = mc_pmsm_Nu_cgv(Re, Pr)
    term1 =  (0.5 * Re * Pr)^3;
    term2 =  (0.664 * sqrt(Re) * Pr^0.33 * sqrt(1 + 3.65 / sqrt(Re)))^3;
    Nu = (1/term1 + 1/term2)^(-0.33);
end