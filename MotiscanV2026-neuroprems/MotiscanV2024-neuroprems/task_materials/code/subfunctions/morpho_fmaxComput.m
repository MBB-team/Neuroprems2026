function [predictedForce] = morpho_fmaxComput(asf, psf, circ, length)
%[predictedForce] = morpho_fmaxComput(asf, psf, circ, length)
% Estimate maximal theoretical force based on muscular volume of the 
% forearm (i.e., morphometric measurements)
% 
%
% INPUTS:
%   -   asf: forearm anterior skinfold (mm)
%   -   psf: forearm posterior skinfold (mm)
%   -   circ:  forearm circumference (mm)
%   -   length: forearm length (mm)
%
%
% OUTPUT:
%     - predictedForce: maximal theoretical force (Newton)
%
%
% from motivational battery subfunctions
% updated by Ted Landron <teddy.landron@gmail.com> (feb. 2020)


% physiological cross sectional area: arm section area minus fat section 
% area minus bone section area  bone section 
% (from litterature, e.g. Hsu, et al., 1993 J.Biomechanics).
skinfold = asf + psf; 
pcsa = pi*(circ/(2*pi) - (skinfold)/40)^2 - (.82 + .98);
 
% force is proportional to pcsa + correction form arm length constants 
% (from Neu, et al., 2001, Am. J. Physiol. Endocrinol. Metab).
predictedForce = pcsa * (2.45 + .288*length);

end