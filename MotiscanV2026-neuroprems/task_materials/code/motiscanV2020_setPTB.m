function [cfg] = motiscanV2020_setPTB(cfg)
%[cfg] = motiscanV2020_setPTB(cfg)
% Sets the Psychtoolbox general configuration (display and key) as well as
% tracker (mouse or touch) functions.
%
%
% INPUTS:
%   -   cfg: configuration structure, with at least the instruction for to
%   display PTB fullscreen or not (cfg.ptb.fullscreen).
%
%
% OUTPUTS:
%   -   cfg: configuration structure, added with PTB display parameter 
%   (cfg.ptb.display) and key parameter (cfg.ptb.key) as well 
%   as tracker configuration (cfg.ptb.wait4release & .recordResponse).
%
%
% NEEDS:
%   -   psychtoolbox
%   -   tracker (mouse or touch) functions
%
%
% from motivational battery subfunctions
% by <teddy.landron@gmail.com> (feb. 2020)

%% Text loading
input_texts = cfg.input_texts.(mfilename);
if cfg.english
    inputText_iScript = input_texts(:,1);
else
    inputText_iScript = input_texts(:,2);
end

% police without accent character problem
Screen('Preference','TextEncodingLocale','UTF-8')

%% Psychtoolbox start & tracker (Mouse/Touchscreen) configuration
cfg.ptb.touch = logical(input_num(cfg,inputText_iScript{1},0:1)); %text:1

% Path & mouse/touchscreen
if cfg.ptb.touch
    addpath(genpath(cfg.paths.PTBtouch)); 
    cfg.ptb.mouse = false; 
else; cfg.ptb.mouse = true;
    addpath(genpath(cfg.paths.PTB));
end
% Moving the critical PsychBasic to Top
addpath(fileparts(which('Screen.mexw64')))

% Launching
if exist('PsychStartup','file'), PsychStartup, AssertOpenGL;
else, warning('PsychToolbox not installed'); end

%% Screen configuration
i_screen = max(Screen('Screens'));
[L, H] = Screen('WindowSize',i_screen);
x = L/2;
y = H/2;

Screen('Preference','SyncTestSettings', 0.004, 50, 0.1, 5);  % A bit less strict settings for the sync test
Screen('Preference','VisualDebugLevel', 0);  % supress PTB start screen
Screen('Preference','SkipSyncTests', 1);  % this can be turned off for debugging
% sst = 0;
% cfg.debug = true;
% if cfg.debug; sst = 1; warning('PTB: ''SkipSyncTests,1'', debug mode'); end
% Screen('Preference', 'SkipSyncTests', sst);%1); % or see 'help SyncTrouble'
Screen('Preference', 'ConserveVRAM', 4096);

display.i_screen = i_screen;
display.L        = L;
display.H        = H;
display.x        = x;
display.y        = y;
cfg.ptb.display = display;

IOPort('CloseAll');

%% Keyboard configuration
[~,~,keycode] = KbCheck;
DisableKeysForKbCheck(find(keycode==1));

KbName('UnifyKeyNames');
key.left    = KbName('LeftArrow');
key.right   = KbName('RightArrow');
key.up      = KbName('UpArrow');
key.down    = KbName('DownArrow');
key.space   = KbName('Space') ;
key.valid   = KbName('Space');
key.escape  = KbName('ESCAPE') ;
try
    key.clear = KbName('BackSpace') ;
catch
    key.clear = KbName('DELETE') ;
end

if exist('laptop','var')
    if laptop
        key.digit = 48:57;        
    else
        key.digit = 96:105;
    end
end

cfg.ptb.key = key;

%% Fontsizes
% .global the tasks uses common fontsize
% add .(iTask_name) if not
switch cfg.system_id
    case {'MOTIstroke_tablet'}
        fontsize.global.ftsz_big     = 200; 
        fontsize.global.ftsz_mid     = 130; 
        fontsize.global.ftsz_small   = 90;

        % training
        [fontsize.trainingMouse_V2020.ftsz_big,                           ...
            fontsize.trainingTouch_V2020.ftsz_big] = deal(fontsize.global.ftsz_big);
        [fontsize.trainingMouse_V2020.ftsz_mid,                           ...
            fontsize.trainingTouch_V2020.ftsz_mid] = deal(70); 
        [fontsize.trainingMouse_V2020.ftsz_small,                           ...
            fontsize.trainingTouch_V2020.ftsz_small] = deal(fontsize.global.ftsz_small);
        
        % Ratings
        [fontsize.taskRatingR_V2020.ftsz_big,                           ...
            fontsize.taskRatingE_V2020.ftsz_big,                        ...
            fontsize.taskRatingP_V2020.ftsz_big] = deal(fontsize.global.ftsz_big);
        [fontsize.taskRatingR_V2020.ftsz_mid,                           ...
            fontsize.taskRatingE_V2020.ftsz_mid,                        ...
            fontsize.taskRatingP_V2020.ftsz_mid] = deal(fontsize.global.ftsz_mid);
        [fontsize.taskRatingR_V2020.ftsz_small,                         ...
            fontsize.taskRatingE_V2020.ftsz_small,                      ...
            fontsize.taskRatingP_V2020.ftsz_small] = deal(fontsize.global.ftsz_small);
        
        % Choices & taskRating_gripExerted
        [fontsize.taskChoiceR_V2020.ftsz_big,                           ...
            fontsize.taskChoiceE_V2020.ftsz_big,                        ...
            fontsize.taskChoiceP_V2020.ftsz_big,                        ...
            fontsize.taskChoice_GripEffort_V2020.ftsz_big,              ...
            fontsize.taskChoice_MoneyDelay.ftsz_big,                    ...
            fontsize.taskChoice_MoneyRisk.ftsz_big,                     ...
            fontsize.taskRating_gripExerted_V2020.ftsz_big] = deal(150);
        [fontsize.taskChoiceR_V2020.ftsz_mid,                           ...
            fontsize.taskChoiceE_V2020.ftsz_mid,                        ...
            fontsize.taskChoiceP_V2020.ftsz_mid,                        ...
            fontsize.taskChoice_GripEffort_V2020.ftsz_mid,              ...
            fontsize.taskChoice_MoneyDelay.ftsz_mid,                    ...
            fontsize.taskChoice_MoneyRisk.ftsz_mid,                     ...
            fontsize.taskRating_gripExerted_V2020.ftsz_mid] = deal(90);
        [fontsize.taskChoiceR_V2020.ftsz_small,                           ...
            fontsize.taskChoiceE_V2020.ftsz_small,                        ...
            fontsize.taskChoiceP_V2020.ftsz_small,                        ...
            fontsize.taskChoice_GripEffort_V2020.ftsz_small,              ...
            fontsize.taskChoice_MoneyDelay.ftsz_small,                    ...
            fontsize.taskChoice_MoneyRisk.ftsz_small,                     ...
            fontsize.taskRating_gripExerted_V2020.ftsz_small] = deal(50);
        
 case {'FTDISI_tablet'}
        fontsize.global.ftsz_big     = 150; 
        fontsize.global.ftsz_mid     = 100; 
        fontsize.global.ftsz_small   = 50;

  case {'Motineuro_tablet'}
        fontsize.global.ftsz_big     = 150; 
        fontsize.global.ftsz_mid     = 100; 
        fontsize.global.ftsz_small   = 50;
 % 
 %        % training
 %        [fontsize.trainingMouse_V2020.ftsz_big,                           ...
 %            fontsize.trainingTouch_V2020.ftsz_big] = deal(30);
 %        [fontsize.trainingMouse_V2020.ftsz_mid,                           ...
 %            fontsize.trainingTouch_V2020.ftsz_mid] = deal(30); 
 %        [fontsize.trainingMouse_V2020.ftsz_small,                           ...
 %            fontsize.trainingTouch_V2020.ftsz_small] = deal(30);
 % 
 %        % Ratings
 %        [fontsize.taskRatingR_V2020.ftsz_big,                           ...
 %            fontsize.taskRatingE_V2020.ftsz_big,                        ...
 %            fontsize.taskRatingP_V2020.ftsz_big] = deal(fontsize.global.ftsz_big);
 %        [fontsize.taskRatingR_V2020.ftsz_mid,                           ...
 %            fontsize.taskRatingE_V2020.ftsz_mid,                        ...
 %            fontsize.taskRatingP_V2020.ftsz_mid] = deal(fontsize.global.ftsz_mid);
 %        [fontsize.taskRatingR_V2020.ftsz_small,                         ...
 %            fontsize.taskRatingE_V2020.ftsz_small,                      ...
 %            fontsize.taskRatingP_V2020.ftsz_small] = deal(fontsize.global.ftsz_small);
 % 
 %        % Choices & taskRating_gripExerted
 %        [fontsize.taskChoiceR_V2020.ftsz_big,                           ...
 %            fontsize.taskChoiceE_V2020.ftsz_big,                        ...
 %            fontsize.taskChoiceP_V2020.ftsz_big,                        ...
 %            fontsize.taskChoice_GripEffort_V2020.ftsz_big,              ...
 %            fontsize.taskChoice_MoneyDelay.ftsz_big,                    ...
 %            fontsize.taskChoice_MoneyRisk.ftsz_big,                     ...
 %            fontsize.taskRating_gripExerted_V2020.ftsz_big] = deal(150);
 %        [fontsize.taskChoiceR_V2020.ftsz_mid,                           ...
 %            fontsize.taskChoiceE_V2020.ftsz_mid,                        ...
 %            fontsize.taskChoiceP_V2020.ftsz_mid,                        ...
 %            fontsize.taskChoice_GripEffort_V2020.ftsz_mid,              ...
 %            fontsize.taskChoice_MoneyDelay.ftsz_mid,                    ...
 %            fontsize.taskChoice_MoneyRisk.ftsz_mid,                     ...
 %            fontsize.taskRating_gripExerted_V2020.ftsz_mid] = deal(90);
 %        [fontsize.taskChoiceR_V2020.ftsz_small,                           ...
 %            fontsize.taskChoiceE_V2020.ftsz_small,                        ...
 %            fontsize.taskChoiceP_V2020.ftsz_small,                        ...
 %            fontsize.taskChoice_GripEffort_V2020.ftsz_small,              ...
 %            fontsize.taskChoice_MoneyDelay.ftsz_small,                    ...
 %            fontsize.taskChoice_MoneyRisk.ftsz_small,                     ...
 %            fontsize.taskRating_gripExerted_V2020.ftsz_small] = deal(50);
 % 
 % 
 %        % Grip calib
 %        fontsize.grip_calib.ftsz_big = 140;
 %        fontsize.grip_calib.ftsz_mid = 100;
 %        fontsize.grip_calib.ftsz_small = 60;
        
    otherwise
        
        fontsize.global.ftsz_big     = 60; 
        fontsize.global.ftsz_mid     = 40; 
        fontsize.global.ftsz_small   = 30;
end
cfg.ptb.fontsize = fontsize;

%% Disp step
fprintf(inputText_iScript{2})

end