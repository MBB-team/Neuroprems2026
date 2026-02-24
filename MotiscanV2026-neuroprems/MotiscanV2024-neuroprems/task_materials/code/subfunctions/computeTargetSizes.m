function [targetHalfSizeVector] = computeTargetSizes(mu, sigma, probaSuccessVector)

    pd = makedist('Normal', mu, sigma);
    
    Y = linspace(0, abs(mu-.5) + 2*sigma, 1000);
    
    for i = 1:length(Y)
     integralY(i) =   cdf('Normal', .5 + Y(i), mu, sigma) - cdf('Normal', .5 - Y(i), mu, sigma);
    end
    
    for j = 1:length(probaSuccessVector)
        [aga , indice] = min(abs(integralY-probaSuccessVector(j)));
        targetHalfSizeVector(j) = Y(indice);
    end


end