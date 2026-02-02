function [sub_data, cfg] = motiscanV2020_setHandGrip(sub_data, cfg)
%[sub_data, cfg] = motiscanV2020_setHandGrip(sub_data, cfg)
% Sets the grip configuration, asks for hand information and measures
% hand(s) fmax.
%
%
% INPUTS:
%   -   sub_data: subject's data structure, with hand information if
%   already existing.
%
%   -   cfg: configuration structure, with at least the session number 
%   (cfg.sessNber_str), the selected tasks (cfg.tasks.task_sel) and the
%   grip device (cfg.grip.gripdevice).
%
%
% OUTPUTS:
%   -   sub_data: subject's data structure, added with the grip device 
%   (cfg.grip.gripdevice), the hand(s) information 
%   (cfg.grip.hand_used, .dominant, .morpho, .fmax).
%
%   -   cfg: configuration structure, added with grip information & related
%   functions (cfg.grip.Handle, .readGrip).
%
%
% NEEDS:
%   -   grip files
%   -   morpho_ask.m
%   -   grip_calib.m
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

%% Grip Configuration
% configure device reader
switch cfg.grip.gripdevice
    case 'vernier'
        % add paths
        cfg.paths.task.grip = [cfg.paths.task.devices 'dynamometer' filesep];
        if ~exist(cfg.paths.task.grip,'file')
            error('path:dynamometer',                               ...
                'no toolbox folder for Vernier device!');
        end
        addpath(cfg.paths.task.grip);
        try % Sometimes dynamometer doesn't close properly (for exemple if crash during
            % a grip task. and i think mex function in background prevents
            % it from restarting, so clear functions solve this problem.
            cfg.grip.Handle     = dynamometer;
        catch
            clear functions
            cfg.grip.Handle     = dynamometer;
        end
        cfg.grip.readGrip       = @readVernier;
          
    case 'mie'
        % add paths
        cfg.paths.task.grip = [cfg.paths.task.devices 'newMatlabOscillo'];
        if ~exist(cfg.paths.task.grip,'file')
            error('path:dynamometer','no toolbox folder for Mie device!');
        end
        addpath(genpath(cfg.paths.task.grip));
        
    otherwise
        error('Please check grip info!')
end

%% Hand information (morpho & fmax)
i_hand    = input_num(cfg,inputText_iScript{1}, 1:2); % text:1
hand_str  = inputText_iScript{2};
iHand_str = hand_str{i_hand};

if ~isfield(cfg.grip,'hand_used')
    cfg.grip.hand_used = struct;
end
if ~isfield(cfg.grip.hand_used,iHand_str)         ...
        || isempty(fieldnames(cfg.grip.hand_used.(iHand_str)))
    cfg.grip.hand_used.dominant = iHand_str;
    cfg.grip.hand_used.(iHand_str).morpho = morpho_ask(cfg);
    % Estimated fmax
    if ~ismember('calibratedFmax',fieldnames(cfg.grip.hand_used.(iHand_str)))...
            || isempty(cfg.grip.hand_used.(iHand_str).calibratedFmax)
        cfg.grip.hand_used.(iHand_str).calibratedFmax = grip_calib(cfg);
        % to measure fmax
    end
elseif ~ismember('calibratedFmax', fieldnames(cfg.grip.hand_used.(iHand_str)))
    cfg.grip.hand_used.(iHand_str).calibratedFmax = grip_calib(cfg, 'Calibration');
    % to measure fmax
else
    input_text = sprintf(inputText_iScript{3},iHand_str); %hand_str{3-i_hand})
    recalib = logical(input_num(cfg,input_text,[0,1]));
    if recalib
        cfg.grip.hand_used.(iHand_str).calibratedFmax = grip_calib(cfg);
    end
end

if any(ismember('taskConfidencePrecision', cfg.task.task_sel))
    input_text = sprintf(inputText_iScript{4},hand_str{3-i_hand}); % text:2
    other_hand = input_num(cfg,input_text, 0:1);
    if other_hand == 1
        cfg.grip.hand_used.(hand_str{3-i_hand}).morpho =       ...
            morpho_ask(cfg);
        if ~isfield(cfg.grip.hand_used.(hand_str{3-i_hand}),'calibratedFmax')
            cfg.grip.hand_used.(hand_str{3-i_hand}).calibratedFmax =     ...
                grip_calib(cfg); % to measure fmax
        else
            input_text = sprintf(inputText_iScript{3},hand_str{3-i_hand});
            recalib = logical(input_num(cfg,input_text,[0,1]));
            if recalib 
                cfg.grip.hand_used.(hand_str{3-i_hand}).calibratedFmax = ...
                    grip_calib(cfg);
            end
        end
    end
end

end