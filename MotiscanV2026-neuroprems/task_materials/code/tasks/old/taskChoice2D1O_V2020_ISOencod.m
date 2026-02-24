function [sub_data] = taskChoice2D1O_V2020(sub_data,cfg,dimension)
% function [sub_data] = taskWeightRE_V2(sub_data, cfg)
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

%% Configuration
cfg = motiscanV2020_setTask(cfg);

display  = cfg.ptb.display;
L        = display.L;
H        = display.H;
x        = display.x;
y        = display.y;
win_l = [0 0 x H];
win_r = [x 0 L H];
% winLup_coor = [0 0 x y];
% winLdo_coor = [0 y x H];
% winRup_coor = [x 0 L y];
% winRdo_coor = [x y L H];

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

% Load stimuli
%-----------------------------------------------
taskName = ['Weight' dimension];
taskChoice_strctName = ['taskWeight' dimension];
switch dimension
    case 'RE'
        benefit_ratingTaskName = 'taskRatingR';
        cost_ratingTaskName    = 'taskRatingE';
        
        benefitTrainingList_file = 'rewards_training.xlsx';
        costTrainingList_file    = 'efforts_training.xlsx';
        
        beneficeTestingList_file = 'rewards.xlsx';
        costTestingList_file     = 'efforts.xlsx';
        
        pairingList_file  = 'appariementRE.xlsx';
        

    case 'RP'
        benefit_ratingTaskName = 'taskRatingR';
        cost_ratingTaskName    = 'taskRatingP';
        
        benefitTrainingList_file = 'rewards_training.xlsx';
        costTrainingList_file    = 'punishments_training.xlsx';
        
        beneficeTestingList_file = 'rewards.xlsx';
        costTestingList_file     = 'punishments.xlsx';
        
        pairingList_file  = 'appariementRP.xlsx';

    case 'PE'
        benefit_ratingTaskName = 'taskRatingP';
        cost_ratingTaskName    = 'taskRatingE';
        
        benefitTrainingList_file = 'punishments_training.xlsx';
        costTrainingList_file    = 'efforts_training.xlsx';
        
        beneficeTestingList_file = 'punishments.xlsx';
        costTestingList_file     = 'efforts.xlsx';
        
        pairingList_file  = 'appariementPE.xlsx';
end

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
text.training = 'Entrainement';
text.appuyer = 'appuyer sur une touche pour continuer...';
text.pretDebut = 'Prêt à débuter ?';
text.accept = 'J''accepte de';
switch dimension;   case 'PE'; text.pour = 'pour éviter de';
                    otherwise; text.pour = 'pour';
end
text.oui = 'OUI';
text.non = 'NON';
text.timesUp = 'Temps écoulé !';
text.faster = 'Répondez plus rapidement svp.';

% training items
benefit_trainingList = readstim(benefitTrainingList_file);
cost_trainingList    = readstim(costTrainingList_file);

% Experimental conditions
%-----------------------------------------------
nTrial      = 48;
nTraining   = 6;

% timing variables
blanktime           = 1;
fixation_duration   = 0.5;
maxResponseDuration = 10e3;

% Extract ratings
tempB   = sortrows(sub_data.(cfg.sessNber_str).tasks.(benefit_ratingTaskName).results.data, 'itemNumber', 'ascend');
tempC   = sortrows(sub_data.(cfg.sessNber_str).tasks.(cost_ratingTaskName).results.data, 'itemNumber', 'ascend');

ratingsBenefit = tempB.rating(1:24);
ratingsCost    = tempC.rating(1:24);
benefice_testingList = readstim(beneficeTestingList_file);
cost_testingList     = readstim(costTestingList_file);
clear temp*
cd(cfg.paths.task.code) % returning to code directory

%% OLD pairing, non-fixed
% first series of choices (anticorrelated): the highest P is proposed with the lowest E,
% the second highest P and the second lowest E, and so on...
% Second series (correlated): the highest P is proposed with the highest E,
% % the second highest P and the second highest E, and so on...
% [~,iB] = sort(ratingsBenefit,'ascend');
% [~,iC] = sort(ratingsCost,'ascend');
% 
% stimB = iB([ 1:24    , 1:24 ]);
% stimC = iC([ 24:-1:1 , 1:24 ]);
% 
% randomtrial = randperm(48);
% 
% stimR = stimB(randomtrial);
% stimE = stimC(randomtrial);

%% New fixed pairing
index = readtable(pairingList_file);
index = table2array(index);
index = index(randperm(size(index, 1)), :); % random permutation of rows
stimB = index(:,2);
stimC = index(:,1);

training_options = [ 1 2 3 4 5 6 ;
    1 2 3 4 5 6];

% Data preparation
%-----------------------------------------------
% Inter-subject side randomization
sidesub = mod(sub_data.sub_id,2);

% training
training_sideyes         = sidesub.*(ones(1,nTraining)); % 0=right, 1=left
training_isLeftChoice    = nan(1,nTraining);
training_choice_position = nan(1,nTraining);
training_choicedo        = nan(1,nTraining);
training_rt              = nan(1,nTraining);

% testing
isLeftChoice    = nan(1,nTrial);
choice_position = nan(1,nTrial);
choicedo        = nan(1,nTrial);
rt              = nan(1,nTrial);
sideyes         = sidesub.*(ones(1,nTrial)); % 0=right, 1=left

%% Training
%-----------------------------------------------
% display
DrawMyText(display.window,text.instruc,ftsz_big,[255 255 255],[x,y]);
DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(0.2);
KbWait;

% instruction: explanations
for i=1:1
    Screen('DrawTexture',display.window,instruction(i).texture);
    Screen(display.window,'Flip');
    WaitSecs(1);
    KbWait;
end

DrawMyText(display.window,text.training,ftsz_big,[255 255 255],[x,y]);
DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(0.2);
KbWait;

% Trial structure
%-----------------------------------------------
stoptask=0;iTrial=0; repeat=0;
while iTrial<nTraining
    
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
    
    text.C = cost_trainingList{training_options(1,iTrial)};
    text.B = benefit_trainingList{training_options(2,iTrial)};
    
    % Write instructions & options
    disp_trial(display,ftsz_small,max_charPline,text,win_l,win_r,training_sideyes(iTrial))
    startime = Screen(display.window,'Flip');

    % Check Response
    exit=0;
    while exit==0
        % refresh screen
        disp_trial(display,ftsz_small,max_charPline,text,win_l,win_r,training_sideyes(iTrial))
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
                if  keycode(key.left)==1
                    exit=1;
                    timedown=GetSecs;
                    training_isLeftChoice(iTrial)=1;                                              %-1=left
                    repeat=0;
                elseif keycode(key.right)==1
                    exit=1;
                    timedown=GetSecs;
                    training_isLeftChoice(iTrial)=0;                                               %1=right
                    repeat=0;
                end
            end
        end
        [xMouse,~,buttons] = recordResponse(display.window);
        if buttons(1)~=0
            training_isLeftChoice(iTrial) = sign(x-xMouse);
            if training_isLeftChoice(iTrial) == -1; training_isLeftChoice(iTrial) = 0; end
            training_choice_position(iTrial) = (xMouse-x)/x;
            timedown=GetSecs;
            repeat=0;
            exit=1;
            
        end
        WaitSecs(0.007);
        
        if training_isLeftChoice(iTrial) == training_sideyes(iTrial)
            training_choicedo(iTrial) = 1;
        else
            training_choicedo(iTrial) = 0;
        end
        
        % Monitor maximal response time
        timePassed = GetSecs-startime;
        if timePassed>maxResponseDuration
            exit=1;
            repeat=repeat+1;
        end
    end
    
    if repeat==0
        training_rt(iTrial)=timedown-startime;
        
        % Show Response
        yes_color = [255*(training_choicedo(iTrial)==0) 255 0];
        no_color = [255*(training_choicedo(iTrial)==1) 255 0];
        disp_trial(display,ftsz_small,max_charPline,text,win_l,win_r,   ...
            training_sideyes(iTrial),yes_color,no_color)
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

%% Testing
%-----------------------------------------------
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
    
    text.C = cost_testingList{stimC(iTrial)};
    text.B = benefice_testingList{stimB(iTrial)};
    
    disp_trial(display,ftsz_small,max_charPline,text,win_l,win_r,sideyes(iTrial))
    startime = Screen(display.window,'Flip');
    
    % Check Response
    exit=0;
    while exit==0
        % refresh screen
        disp_trial(display,ftsz_small,max_charPline,text,win_l,win_r,sideyes(iTrial))
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
                if  keycode(key.left)==1
                    exit=1;
                    timedown=GetSecs;
                    isLeftChoice(iTrial)=1;                                              %-1=left
                    repeat=0;
                elseif keycode(key.right)==1
                    exit=1;
                    timedown=GetSecs;
                    isLeftChoice(iTrial)=0;                                               %1=right
                    repeat=0;
                end
            end
        end
        [xMouse,~,buttons] = recordResponse(display.window);
        if buttons(1)~=0
            isLeftChoice(iTrial) = sign(x-xMouse);
            if isLeftChoice(iTrial) == -1; isLeftChoice(iTrial) = 0; end
            choice_position(iTrial) = (xMouse-x)/x;
            timedown=GetSecs;
            repeat=0;
            exit=1;
        end
        WaitSecs(0.007);
        
        if isLeftChoice(iTrial) == sideyes(iTrial)
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
        yes_color = [255*(choicedo(iTrial)==0) 255 0];
        no_color = [255*(choicedo(iTrial)==1) 255 0];
        disp_trial(display,ftsz_small,max_charPline,text,win_l,win_r,   ...
            sideyes(iTrial),yes_color,no_color)
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
varNames      = {'trialNumber', 'isLeftChoice', 'choicePosition', 'isAccept', 'RT'};
training_data = table((1:nTraining)',training_isLeftChoice',training_choice_position',training_choicedo',training_rt', 'VariableNames', varNames);
varNames      = {'trialNumber', 'itemNumberBenefit', 'ratingBenefit', 'itemNumberCost', 'ratingCost', 'isLeftChoice', 'choicePosition', 'isAccept', 'RT'};
ratingBenefit = ratingsBenefit(stimB(:));
ratingCost    = ratingsCost(stimC(:));
data          = table((1:nTrial)',stimB,ratingBenefit,stimC,ratingCost,isLeftChoice',choice_position',choicedo',rt','VariableNames',varNames);

% saving
sub_data.(cfg.sessNber_str).tasks.(taskChoice_strctName).results = struct('trainingData', training_data, 'data', data);
end

function [] = disp_trial(display,ftsz,max_charPline,text,win_l,win_r,   ...
    side_oui,varargin)

H = display.H;
x = display.x;
y = display.y;

y20_acpt = 4;
y20_pour = 8;
y20_resp = 14;

if nargin > 7; color_yes = varargin{1}; color_no = varargin{2};
else; color_yes = [255 255 255]; color_no = [255 255 255];
end

Screen('TextSize', display.window, ftsz);
DrawFormattedText(display.window,text.accept,'center',H*y20_acpt/20,[100 100 100],max_charPline,0,0,2,0);
DrawFormattedText(display.window,text.C,'center',H*(y20_acpt+1)/20,[255 255 255],max_charPline, 0,0,2,0);
DrawFormattedText(display.window,text.pour,'center',H*y20_pour/20,[100 100 100],max_charPline,0,0,2,0);
DrawFormattedText(display.window,text.B,'center',H*(y20_pour+1)/20,[255 255 255],max_charPline,0,0,2,0);
if logical(side_oui) % accept (oui) : right = 0, left = 1
    win_oui = win_l; win_non = win_r;
else; win_oui = win_r; win_non = win_l;
end
DrawFormattedText(display.window,text.oui,'center',H*y20_resp/20,color_yes,max_charPline,0,0,2,0,win_oui);
DrawFormattedText(display.window,text.non,'center',H*y20_resp/20,color_no,max_charPline,0,0,2,0,win_non);
Screen('LineStipple',display.window, 1, 2, mod(ceil((1:16)/8),2));
Screen('DrawLine', display.window, [255 255 255]*0.5, x,H*(y20_resp-3)/20, x,H*(y20_resp+3)/20, 3);
%         Screen('LineStipple',display.window, 1, 2, mod(ceil((1:16)/8),2));
%         Screen('DrawLine', display.window, [255 255 255]*0.5, x, y*7/5 ,  x, y*9/5, 3);

end

