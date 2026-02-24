function morpho = morpho_ask(cfg)
%[morpho] = morpho_ask(cfg)
% Asks morphological information and estimates fmax. 
%
%
% INPUTS:
%   -   cfg 
%
%
% OUTPUTS:
%   -   morpho: subject's hand morphology information, structure with 
%  forearm anterior & posterior skinfold, circumference and length (all in 
%   mm!).
%
%
% NEEDS:
%   -   morpho_fmaxComput.m
%
%
% by <teddy.landron@gmail.com> (feb. 2020)


%% Text loading
input_texts = cfg.input_texts.(mfilename);
if cfg.english
    inputText_iScript = input_texts(:,1);
else
    inputText_iScript = input_texts(:,2);
end

%% Main
fprintf(inputText_iScript{1}); % text:1

morpho          = struct;
morpho.asf      = input_num(cfg,inputText_iScript{2},0:100); % text:2
morpho.psf      = input_num(cfg,inputText_iScript{3},0:100); % text:3
morpho.circ     = input_num(cfg,inputText_iScript{4},0:999); % text:4
morpho.len      = input_num(cfg,inputText_iScript{5},0:999); % text:5

if ~ismember(0,[morpho.asf morpho.psf morpho.circ morpho.len])
    morpho.fmax_est = round(morpho_fmaxComput(morpho.asf,morpho.psf,morpho.circ,morpho.len));
else
    morpho  = [];
end

