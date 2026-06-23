function [sub_data] = taskWeightR2E2_V2024_img(sub_data,cfg)
% function [sub_data] = taskWeightR2E2_V2024_img(sub_data, cfg)
%
%taskWeightRE - execute the reward/effort 2-D choice task (from motiscan battery)
% Launch the task with this function for testing one subject.
% The subject has choose to accept or reject an offer, consituted of a
% benefit and a cost item
%
%   task specifications:
%       - structure: instructions -> training -> testing
%       - experimental conditions: option benefit value, option cost value
%       - randomization:
%           random permutation of benefit and cost values
%           (with the 2 sequences: one of positive & one of negative covariations between benefit and cost)
%       - ntrial = 48
%       - trial structure: display 1 option with a cost and a benefit component, choose one option
%       - training: exposure to several options (6 trials)
%
% Inputs: sub_data and cfg structures
%
% Outputs: updated sub_data with results = training_data and data tables
% with (trialNumber, isLeftChoice, choicePosition, isAccept, RT) for training and
% with (trialNumber, itemNumberBenefit, ratingBenefit, itemNumberCost, ratingCost, 
%       isLeftChoice, choicePosition, isAccept, 'RT') for testing
%
% Author: Raphael Le Bouc, Nicolas Borderies
% email address: nico.borderies@gmail.com
% September 2013; Last revision: June 2017
%
% Updated March 2020 for V2, P. CARRILLO
% Updated April 2023 for V2023, R.JOLY
% Updated March 2024 for V2024, A. PAPASAVVA

%% Configuration
cfg = motiscanV2020_setTask(cfg);

display  = cfg.ptb.display;
L        = display.L;
H        = display.H;
x        = display.x;
y        = display.y;
win_l = [0 0 x H];
win_r = [x 0 L H];

key = cfg.ptb.key;

wait4release   = cfg.ptb.wait4release;
recordResponse = cfg.ptb.recordResponse;

% fontsize
if isfield(cfg.ptb,mfilename)
        ftsz_iTask = cfg.ptb.fontsize.(mfilename);
else;   ftsz_iTask = cfg.ptb.fontsize.global;
end
ftsz_big    = ftsz_iTask.ftsz_big;
ftsz_mid    = ftsz_iTask.ftsz_mid;
ftsz_small  = ftsz_iTask.ftsz_small;

max_charPline = 60;

rectImgInstruction = [0 0 2*x 2*y];

% Load stimuli
%-----------------------------------------------
taskName = 'WeightR2E2';
taskChoice_strctName = 'taskWeightR2E2';

benefit_ratingTaskName = 'taskRatingR2';
cost_ratingTaskName    = 'taskRatingE2';

benefitTestingList_file = 'rewards2.xlsx';
costTestingList_file     = 'efforts2.xlsx';

appariementTestingList_file = 'appariementR2E2.xlsx';
 
cd(cfg.paths.task.images); % enter img dir

% informative icons
cross=Screen('MakeTexture',display.window,imread('Cross.bmp'));
rectcross=CenterRectOnPoint(Screen('Rect',cross),x,y);

% instructions images
instruction = struct('texture',{},'position',{});
for i=1:1
    instruction(i).texture = Screen('MakeTexture',display.window,imread(['instruction_' taskName '.bmp']));
end

cd(cfg.paths.task.text) % extracting text

% recurring textstring
text.instruc = 'Instructions';
text.appuyer = 'appuyer sur une touche pour continuer...';
text.pretDebut = 'Prêt à débuter ?';
text.accept = 'J''accepte de';
text.pour = 'pour';
text.oui = 'OUI';
text.non = 'NON';
text.timesUp = 'Temps écoulé !';
text.faster = 'Répondez plus rapidement svp.';


% Stimuli images
cd(cfg.paths.task.images); % enter img dir

    imgItemE2 = struct('texture',{},'position',{});
    imgItemR2 = struct('texture',{},'position',{});
for i=1:24
    imgItemE2(i).texture = Screen('MakeTexture',display.window,imread(['img_efforts2_' num2str(i) '.bmp']));
    imgItemR2(i).texture = Screen('MakeTexture',display.window,imread(['img_rewards2_' num2str(i) '.bmp']));
end

% items
benefit_testingList  = readstim(benefitTestingList_file)';
cost_testingList     = readstim(costTestingList_file)';
appariement_testing  = readtable(appariementTestingList_file);

% sample list adaptation
% Adaptation of reward and effort lists for the NeuroPrems study

% Experimental conditions
%-----------------------------------------------
nTrial      = 20;

% timing variables
blanktime           = 1;
fixation_duration   = 0.5;
maxResponseDuration = 10e3;

% Extract ratings
% Item numbers are a subset of 1..24 with gaps (removed items), so we index
% by itemNumber, not by row position. Slots for removed items stay NaN.

% Benefit ratings
if isfield(sub_data.(cfg.sessNber_str).tasks, benefit_ratingTaskName) && ...
   isfield(sub_data.(cfg.sessNber_str).tasks.(benefit_ratingTaskName), 'results') && ...
   isfield(sub_data.(cfg.sessNber_str).tasks.(benefit_ratingTaskName).results, 'data')

    tempB = sub_data.(cfg.sessNber_str).tasks.(benefit_ratingTaskName).results.data;
    ratingsBenefit = nan(24,1);                          % full 1..24 range
    ratingsBenefit(tempB.itemNumber) = tempB.rating;     % place each rating at its item number
else
    fprintf('No reward rating task - ratingBenefit column will be NaN (expected).\n');
    ratingsBenefit = nan(24,1);
end

% Cost ratings
if isfield(sub_data.(cfg.sessNber_str).tasks, cost_ratingTaskName) && ...
   isfield(sub_data.(cfg.sessNber_str).tasks.(cost_ratingTaskName), 'results') && ...
   isfield(sub_data.(cfg.sessNber_str).tasks.(cost_ratingTaskName).results, 'data')

    tempC = sub_data.(cfg.sessNber_str).tasks.(cost_ratingTaskName).results.data;
    ratingsCost = nan(24,1);                             % full 1..24 range
    ratingsCost(tempC.itemNumber) = tempC.rating;        % place each rating at its item number
else
    fprintf('No effort rating task - ratingCost column will be NaN (expected).\n');
    ratingsCost = nan(24,1);
end

clear temp*
cd(cfg.paths.task.code) % returning to code directory

%% Create vectors of experimental factors
index = appariement_testing;
index = table2array(index);
index = index(randperm(size(index, 1)), :); % random permutation of rows
stimR2 = index(:,2);
stimE2 = index(:,1);

% Data preparation
%-----------------------------------------------
% Inter-subject side randomization
sidesub = mod(sub_data.sub_id,2);

% testing
isUpChoice      = nan(1,nTrial);
choice_position = nan(1,nTrial);
choicedo        = nan(1,nTrial);
rt              = nan(1,nTrial);
sideyes         = sidesub.*(ones(1,nTrial)); % 0=down, 1=up

%% Testing
%-----------------------------------------------
DrawMyText(display.window,text.instruc,ftsz_big,[255 255 255],[x,y]);
DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(0.2);
KbWait;

% instruction: explanations
for i=1:1
    Screen('DrawTexture',display.window,instruction(i).texture,[],rectImgInstruction);
    Screen(display.window,'Flip');
    WaitSecs(1);
    KbWait;
end

% instructions:  start
DrawMyText(display.window,text.pretDebut,ftsz_big,[255 255 255],[x,y]);
DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(1);
KbWait;
wait4release()

% Trial structure
%-----------------------------------------------
stoptask=0;iTrial=0; repeat=0;
while iTrial<nTrial
    
    if repeat==0
        iTrial=iTrial+1;
    end
    
    if stoptask
        break
    end
    
    % int
    Screen('DrawTexture',display.window,cross,[],rectcross);
    KbReleaseWait;
    Screen(display.window,'Flip');
    WaitSecs(fixation_duration);
    wait4release()

    text.E2 = cost_testingList{stimE2(iTrial)}; % Cost number
    text.R2 = benefit_testingList{stimR2(iTrial)}; % Reward number

    img.E2 = imgItemE2(stimE2(iTrial)).texture;
    img.R2 = imgItemR2(stimR2(iTrial)).texture;
    
    disp_trial(display,ftsz_small,max_charPline,text,img,win_l,win_r,sideyes(iTrial),sub_data)
    startime = Screen(display.window,'Flip');
    
    % Check Response
    exit=0;
    while exit==0
        % refresh screen
        disp_trial(display,ftsz_small,max_charPline,text,img,win_l,win_r,sideyes(iTrial),sub_data)
        Screen(display.window,'Flip');
        
        % Record Response
        [keyisdown, ~, keycode] = KbCheck;
        if keyisdown==1
            % monitor validation & exit
            if keycode(key.escape)==1
                exit=1;
                timedown=GetSecs;
                stoptask=1;
            else
                if  keycode(key.up)==1
                    exit=1;
                    timedown=GetSecs;
                    isUpChoice(iTrial)=1;                                              %-1=up
                    repeat=0;
                elseif keycode(key.down)==1
                    exit=1;
                    timedown=GetSecs;
                    isUpChoice(iTrial)=0;                                               %1=down
                    repeat=0;
                end
            end
        end

         [xMouse, yMouse, buttons] = recordResponse(display.window);
            if buttons(1) ~= 0 && yMouse > y/2
                if yMouse > 4*y/4 && yMouse < 5.9*y/4
                    isUpChoice(iTrial) = 1; % Up choice
                    choice_position(iTrial) = (yMouse - y)/y; 
                    timedown = GetSecs;
                    repeat = 0;
                    exit = 1;
                elseif buttons(1) ~= 0 &&  yMouse > 6.1*y/4 && yMouse < 8*y/4
                    isUpChoice(iTrial) = 0; % Down choice
                    choice_position(iTrial) = (yMouse - y)/y; 
                    timedown = GetSecs;
                    repeat = 0;
                    exit = 1;
                end
            end

        WaitSecs(0.007);
        
        if isUpChoice(iTrial) == sideyes(iTrial)
            choicedo(iTrial) = 1;
        else
            choicedo(iTrial) = 0;
        end
        
        % Monitor maximal response time
        timePassed = GetSecs-startime;
        if timePassed>maxResponseDuration
            exit=1;
            repeat=repeat+1;
        end
    end
    
    if repeat==0
        rt(iTrial)=timedown-startime;

        % Show Response
        switch choicedo(iTrial)
            case 0 % response = no
                yes_color = [255 255 255];
                no_color = [0 255 0];
            case 1 % response = yes
                no_color = [255 255 255];
                yes_color = [0 255 0];
        end

        disp_trial(display,ftsz_small,max_charPline,text,img,win_l,win_r,   ...
            sideyes(iTrial),sub_data,yes_color,no_color)
        Screen(display.window,'Flip');
        tresponse = GetSecs;
        while GetSecs <= tresponse + blanktime
            
        end
    else
        % instruction: speed-up warning
        DrawMyText(display.window,text.timesUp,ftsz_big,[255 255 255],[x,y]);
        DrawMyText(display.window,text.faster,ftsz_big,[255 255 255],[x,y*1.2]);
        Screen(display.window,'Flip');
        WaitSecs(blanktime+1);
    end
end

% display end
Screen(display.window,'Flip');
sca;

%% Data saving
%-----------------------------------------------
% data creation
varNames      = {'trialNumber', 'itemNumberBenefit', 'ratingBenefit', 'itemNumberCost', 'ratingCost', 'isUpChoice', 'choicePosition', 'isAccept', 'RT'};
ratingBenefit = ratingsBenefit(stimR2(:));
ratingCost    = ratingsCost(stimE2(:));
data          = table((1:nTrial)',stimR2,ratingBenefit,stimE2,ratingCost,isUpChoice',choice_position',choicedo',rt','VariableNames',varNames);

% saving
sub_data.(cfg.sessNber_str).tasks.(taskChoice_strctName).results = struct('data', data);
end

function [] = disp_trial(display,ftsz,max_charPline,text,img,win_l,win_r,   ...
    sideyes,sub_data,varargin)

H = display.H;
x = display.x;
y = display.y;

y20_acpt = 4;
y20_pour = 8;
y20_resp = 14;

rectImg1=[x/2-3*y/8, y/2-3*y/8 + y/4, x/2+3*y/8, y/2+3*y/8 + y/4];
rectImg2=[3*x/2-3*y/8, y/2-3*y/8 + y/4, 3*x/2+3*y/8, y/2+3*y/8 + y/4];

if nargin > 9; color_yes = varargin{1}; color_no = varargin{2}; 
else; color_yes = [255 255 255]; color_no = [255 255 255];
end

Screen('TextSize', display.window, ftsz);

% Draw accept text above the left image
DrawFormattedText(display.window,text.accept,'center',(y/2-4*y/8)-max_charPline + y/4,[100 100 100],max_charPline,0,0,2,0,win_l);
DrawFormattedText(display.window,text.E2,'center',(y/2-3*y/8)-max_charPline + y/4,[255 255 255],max_charPline, 0,0,2,0,win_l);
Screen('DrawTexture',display.window,img.E2,[],rectImg1);

% Draw pour text above the right image
DrawFormattedText(display.window,text.pour,'center',(y/2-4*y/8)-max_charPline + y/4,[100 100 100],max_charPline,0,0,2,0,win_r);
DrawFormattedText(display.window,text.R2,'center',(y/2-3*y/8)-max_charPline + y/4,[255 255 255],max_charPline,0,0,2,0,win_r);
Screen('DrawTexture',display.window,img.R2,[],rectImg2);

% Draw oui and non text below the images
if mod(sub_data.sub_id,2) == 0
    DrawFormattedText(display.window,text.oui,'center',7*y/4,color_yes,max_charPline,0,0,2,0); % oui down
    DrawFormattedText(display.window,text.non,'center',5*y/4,color_no,max_charPline,0,0,2,0); % non up
else
    DrawFormattedText(display.window,text.oui,'center',5*y/4,color_yes,max_charPline,0,0,2,0); % oui up
    DrawFormattedText(display.window,text.non,'center',7*y/4,color_no,max_charPline,0,0,2,0); % non down
end

Screen('LineStipple',display.window, 1, 2, mod(ceil((1:16)/8),2));
Screen('DrawLine', display.window, [255 255 255]*0.5,x/2,3*y/2,3*x/2,3*y/2, 3);

end
