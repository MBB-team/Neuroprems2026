function [cfg] = check_hand(iTask_name, cfg)
%[cfg] = check_hand(iTask_name, cfg)
% Asks the experimenter whether the hand to be used needs to be switched or
% not (usually, before the task 'taskConfidencePrecision'). If so and the
% other hand information being not available, asks for the hand morphology.
%
%
% INPUTS:
%   -   iTask_name: the task name (string array)
%
%   -   cfg: subject's data structure, with hand information 
%   (cfg.grip.hand_used, .dominant)
%
%
% OUTPUTS:
%   -   cfg: with cfg.grip.hand_used.to_use, the hand to be used
%
%
% NEEDS:
%   -   morpho_ask.m
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
hand_str  = inputText_iScript{1}; % text:1
iHand_str = cfg.grip.hand_used.dominant;
i_hand = find(contains_forOlder(hand_str, iHand_str));

coherent_resp = false;
while ~coherent_resp
cont = input(sprintf(inputText_iScript{2},iTask_name,hand_str{i_hand}),'s'); % text:2

if ~isempty(cont)
    confirm = input(sprintf(inputText_iScript{3},hand_str{3-i_hand},iTask_name),'s'); % text:3
end

if isempty(cont)
    coherent_resp = true;
elseif exist('confirm','var') && isempty(confirm)
    i_hand = 3-i_hand;
    iHand_str = hand_str{i_hand};
    if ~isfield(cfg.grip.hand_used,iHand_str)         ...
            || isempty(cfg.grip.hand_used.(iHand_str))
        cfg.grip.hand_used.(iHand_str).morpho = morpho_ask(cfg);
        if ~isfield(cfg.grip.hand_used.(iHand_str),'calibratedFmax')...
                || isempty(cfg.grip.hand_used.(iHand_str).calibratedFmax)
           cfg.grip.hand_used.(iHand_str).calibratedFmax = grip_calib(cfg);
        else
            input_text = sprintf(inputText_iScript{4},iHand_str); %hand_str{3-i_hand}) % text:4
            recalib = logical(input_num(cfg,input_text,[0,1]));
            if recalib
                cfg.grip.hand_used.(iHand_str).calibratedFmax =    ...
                    grip_calib(cfg);
            end
            
        end
        
    end
    coherent_resp = true;
end
end
cfg.grip.hand_used.to_use = iHand_str;

