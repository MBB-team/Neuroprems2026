function [cfg] = motiscanV2020_setTask(cfg)
%[cfg] = motiscanV2020_setTask(cfg)
% initializes the configuration of every motiscan tasks
%       - opening a window either fullscreen or 1/4th
%       - setting defaults font options and priority
%       - referencing user devices functions (either with mouse or
%       touchscreen)
%
% INPUT: cfg, configuration structure with at least the paths, psychtoolbox
% configuration (cfg.ptb) and grip configuration (cfg.grip).
%
% OUPUT: updated cfg
%
% Updated March 2020 for V2020, P. CARRILLO

%% Generator reset
%-----------------------------------------------
try rng('shuffle'); catch, rng('default'), rng('shuffle'); end

%% Open window
if cfg.ptb.fullscreen % full-screen window
    cfg.ptb.display.window = Screen('OpenWindow',cfg.ptb.display.i_screen,[0 0 0],[]);  
else % testing window 1/4th of the screen upper right corner
    cfg.ptb.display.window = Screen('OpenWindow',cfg.ptb.display.i_screen,[0 0 0],[0 0 cfg.ptb.display.x cfg.ptb.display.y]);
    % updating window measures
%     cfg.ptb.display.L = cfg.ptb.display.x;
%     cfg.ptb.display.H = cfg.ptb.display.y;
%     cfg.ptb.display.x = cfg.ptb.display.x/2;
%     cfg.ptb.display.y = cfg.ptb.display.y/2;
    cfg.ptb.display.L = cfg.ptb.display.L*3/4;
    cfg.ptb.display.H = cfg.ptb.display.H*3/4;
    cfg.ptb.display.x = cfg.ptb.display.L/2;
    cfg.ptb.display.y = cfg.ptb.display.H/2;
end

% setting default screen options
Screen('TextSize', cfg.ptb.display.window, 40);
Screen('TextFont', cfg.ptb.display.window, 'arial');
Priority(MaxPriority(cfg.ptb.display.window));

% referencing user devices functions
if cfg.ptb.mouse
    ShowCursor;
    cfg.ptb.wait4release   = @() MouseReleaseWait;
    cfg.ptb.recordResponse = @(window) GetMouse(window);
elseif cfg.ptb.touch
    HideCursor;
    cfg.ptb.wait4release   = @() TouchReleaseWait;
    cfg.ptb.recordResponse = @(window) GetMouseTransient(window,1);
end
