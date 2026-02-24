function [sub_data] = taskWeightRP_V2020(sub_data,cfg)
% function [sub_data] = taskWeightRP_V2(sub_data,cfg)
%
% taskWeightRP - execute the reward/punishment 2-D choice task (from motiscan battery V2)
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
%       - iTrial = 48
%       - trial structure: display 1 option with a cost and a benefit component, choose one option
%       - training: exposure to several options (3 trials)
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
% -----------------------------------------------
cfg = motiscanV2020_setTask(cfg);

display  = cfg.ptb.display;
H        = display.H;
x        = display.x;
y        = display.y;

key = cfg.ptb.key;

wait4release   = cfg.ptb.wait4release;
recordResponse = cfg.ptb.recordResponse;

taskName = 'WeightRP';

% fontsize
if isfield(cfg.ptb,mfilename)
        ftsz_iTask = cfg.ptb.fontsize.(mfilename);
else;   ftsz_iTask = cfg.ptb.fontsize.global;
end
ftsz_big    = ftsz_iTask.ftsz_big;
ftsz_mid    = ftsz_iTask.ftsz_mid;
ftsz_small  = ftsz_iTask.ftsz_small;

% Load stimuli
%-----------------------------------------------
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

% training items
benefit_traininglist = readstim('rewards_training.xlsx');
cost_traininglist    = readstim('punishments_training.xlsx');

% Experimental conditions
%-----------------------------------------------
nTrial=48;
nTraining=6;

% timing variables
blanktime=1;
fixation_duration=0.5;
maxResponseDuration=10e3;

% Extract ratings
tempR   = sortrows(sub_data.(cfg.sessNber_str).tasks.taskRatingR.results.data, 'itemNumber', 'ascend');
tempC   = sortrows(sub_data.(cfg.sessNber_str).tasks.taskRatingP.results.data, 'itemNumber', 'ascend');

ratingsBenefit = tempR.rating(1:24);
ratingsCost    = tempC.rating(1:24);
rewardList     = readstim('rewards.xlsx');
punishList     = readstim('punishments.xlsx');
clear temp*
cd(cfg.paths.task.code) % returning to code directory

%% OLD pairing, non-fixed
% % first series of choices (anticorrelated): the highest P is proposed with the lowest E,
% % the second highest P and the second lowest E, and so on...
% % Second series (correlated): the highest P is proposed with the highest E,
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
% stimP = stimC(randomtrial);

%% New fixed pairing
index = readtable('appariementRP.xlsx');
index = table2array(index);
index = index(randperm(size(index, 1)), :); % random permutation of rows
stimR = index(:,2);
stimP = index(:,1);

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
isLeftChoice      = nan(1,nTrial);
choice_position = nan(1,nTrial);
choicedo        = nan(1,nTrial);
rt              = nan(1,nTrial);
sideyes         = sidesub.*(ones(1,nTrial)); % 0=right, 1=left

%% Training
%-----------------------------------------------
% display
textstring = 'Instructions';
DrawMyText(display.window,textstring,ftsz_big,[255 255 255],[x,y]);
textstring = 'appuyer sur une touche pour continuer';
DrawMyText(display.window,textstring,ftsz_small,[100 100 100],[x,H*4/5]);
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

textstring = 'Entrainement';
DrawMyText(display.window,textstring,ftsz_big,[255 255 255],[x,y]);
textstring = 'appuyer sur une touche pour continuer';
DrawMyText(display.window,textstring,ftsz_small,[100 100 100],[x,H*4/5]);
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
    
    % Write instructions & options
    yshift = -100;
    DrawMyText(display.window,'J''accepte de',ftsz_small,[100 100 100],[x,y+1.5*yshift]);
    DrawMyText(display.window,cost_traininglist{training_options(1,iTrial)},ftsz_small,[255 255 255],[x,y+1*yshift]);
    DrawMyText(display.window,'pour',ftsz_small,[100 100 100],[x,y-1*yshift]);
    DrawMyText(display.window,benefit_traininglist{training_options(2,iTrial)},ftsz_small,[255 255 255],[x,y-1.5*yshift]);
    % Display responses
    xshift = x/2;
    DrawMyText(display.window,'OUI',45,[255 255 0],[ x+xshift/2*((1-training_sideyes(iTrial))-training_sideyes(iTrial)) , y-4*yshift ]);
    DrawMyText(display.window,'NON',45,[255 255 0],[ x-xshift/2*((1-training_sideyes(iTrial))-training_sideyes(iTrial)) , y-4*yshift ]);
    Screen('LineStipple',display.window, 1, 2, mod(ceil((1:16)/8),2));
    Screen('DrawLine', display.window, [255 255 255]*0.5, x, y*7/5 ,  x, y*9/5, 3);
    startime = Screen(display.window,'Flip');
    
    % Check Response
    exit=0;
    while exit==0
        
        % refresh screen
        DrawMyText(display.window,'J''accepte de',ftsz_small,[100 100 100],[x,y+1.5*yshift]);
        DrawMyText(display.window,cost_traininglist{training_options(1,iTrial)},ftsz_small,[255 255 255],[x,y+1*yshift]);
        DrawMyText(display.window,'pour',ftsz_small,[100 100 100],[x,y-1*yshift]);
        DrawMyText(display.window,benefit_traininglist{training_options(2,iTrial)},ftsz_small,[255 255 255],[x,y-1.5*yshift]);
        DrawMyText(display.window,'OUI',45,[255 255 0],[ x+xshift/2*((1-training_sideyes(iTrial))-training_sideyes(iTrial)) , y-4*yshift ]);
        DrawMyText(display.window,'NON',45,[255 255 0],[ x-xshift/2*((1-training_sideyes(iTrial))-training_sideyes(iTrial)) , y-4*yshift ]);
        Screen('LineStipple',display.window, 1, 2, mod(ceil((1:16)/8),2));
        Screen('DrawLine', display.window, [255 255 255]*0.5, x, y*7/5 ,  x, y*9/5, 3);
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
                    training_isLeftChoice(iTrial)=1;
                    repeat=0;
                elseif keycode(key.right)==1
                    exit=1;
                    timedown=GetSecs;
                    training_isLeftChoice(iTrial)=0;
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
        
        training_choicedo(iTrial) = training_isLeftChoice(iTrial) == training_sideyes(iTrial);
        
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
        % -- Write instructions & options
        yshift = -100;
        DrawMyText(display.window,'J''accepte de',ftsz_small,[100 100 100],[x,y+1.5*yshift]);
        DrawMyText(display.window,cost_traininglist{training_options(1,iTrial)},ftsz_small,[255 255 255],[x,y+1*yshift]);
        DrawMyText(display.window,'pour',ftsz_small,[100 100 100],[x,y-1*yshift]);
        DrawMyText(display.window,benefit_traininglist{training_options(2,iTrial)},ftsz_small,[255 255 255],[x,y-1.5*yshift]);
        % -- Display responses
        xshift = x/2;
        yes_color = [255*(training_choicedo(iTrial)==0) 255 0];
        no_color  = [255*(training_choicedo(iTrial)==1) 255 0];
        DrawMyText(display.window,'OUI',45,yes_color,[ x+xshift/2*((1-training_sideyes(iTrial))-training_sideyes(iTrial)) , y-4*yshift ]);
        DrawMyText(display.window,'NON',45,no_color,[ x-xshift/2*((1-training_sideyes(iTrial))-training_sideyes(iTrial)) , y-4*yshift ]);
        Screen('LineStipple',display.window, 1, 2, mod(ceil((1:16)/8),2));
        Screen('DrawLine', display.window, [255 255 255]*0.5, x, y*7/5 ,  x, y*9/5, 3);
        Screen(display.window,'Flip');
        tresponse = GetSecs;
        while GetSecs <= tresponse + blanktime
            
        end
    else
        % instruction: speed-up warning
        textstring = 'Temps écoulé.';
        DrawMyText(display.window,textstring,ftsz_big,[255 255 255],[x,y]);
        textstring = 'Répondez plus rapidement.';
        DrawMyText(display.window,textstring,ftsz_big,[255 255 255],[x,y*1.2]);
        Screen(display.window,'Flip');
        WaitSecs(blanktime+1);
    end
end


%% Testing
%-----------------------------------------------
% instructions:  start
textstring = 'Prêt à débuter ?';
DrawMyText(display.window,textstring,ftsz_big,[255 255 255],[x,y]);
textstring = 'appuyer sur une touche pour continuer';
DrawMyText(display.window,textstring,ftsz_small,[100 100 100],[x,H*4/5]);
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
    
    % Write instructions & options
    yshift = -100;
    DrawMyText(display.window,'J''accepte de',ftsz_small,[100 100 100],[x,y+1.5*yshift]);
    DrawMyText(display.window,punishList{stimP(iTrial)},ftsz_small,[255 255 255],[x,y+1*yshift]);
    DrawMyText(display.window,'pour',ftsz_small,[100 100 100],[x,y-1*yshift]);
    DrawMyText(display.window,rewardList{stimR(iTrial)},ftsz_small,[255 255 255],[x,y-1.5*yshift]);
    % Display responses
    xshift = x/2;
    DrawMyText(display.window,'OUI',45,[255 255 0],[ x+xshift/2*((1-sideyes(iTrial))-sideyes(iTrial)) , y-4*yshift ]);
    DrawMyText(display.window,'NON',45,[255 255 0],[ x-xshift/2*((1-sideyes(iTrial))-sideyes(iTrial)) , y-4*yshift ]);
    Screen('LineStipple',display.window, 1, 2, mod(ceil((1:16)/8),2));
    Screen('DrawLine', display.window, [255 255 255]*0.5, x, y*7/5 ,  x, y*9/5, 3);
    startime = Screen(display.window,'Flip');
    % Check Response
    exit=0;
    while exit==0
        
        % refresh screen
        DrawMyText(display.window,'J''accepte de',ftsz_small,[100 100 100],[x,y+1.5*yshift]);
        DrawMyText(display.window,punishList{stimP(iTrial)},ftsz_small,[255 255 255],[x,y+1*yshift]);
        DrawMyText(display.window,'pour',ftsz_small,[100 100 100],[x,y-1*yshift]);
        DrawMyText(display.window,rewardList{stimR(iTrial)},ftsz_small,[255 255 255],[x,y-1.5*yshift]);
        DrawMyText(display.window,'OUI',45,[255 255 0],[ x+xshift/2*((1-sideyes(iTrial))-sideyes(iTrial)) , y-4*yshift ]);
        DrawMyText(display.window,'NON',45,[255 255 0],[ x-xshift/2*((1-sideyes(iTrial))-sideyes(iTrial)) , y-4*yshift ]);
        Screen('LineStipple',display.window, 1, 2, mod(ceil((1:16)/8),2));
        Screen('DrawLine', display.window, [255 255 255]*0.5, x, y*7/5 ,  x, y*9/5, 3);
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
                    isLeftChoice(iTrial)=1;
                    repeat=0;
                elseif keycode(key.right)==1
                    exit=1;
                    timedown=GetSecs;
                    isLeftChoice(iTrial)=0;
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
        
        choicedo(iTrial) = isLeftChoice(iTrial) == sideyes(iTrial);
        
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
        % -- Write instructions & options
        yshift = -100;
        DrawMyText(display.window,'J''accepte de',ftsz_small,[100 100 100],[x,y+1.5*yshift]);
        DrawMyText(display.window,punishList{stimP(iTrial)},ftsz_small,[255 255 255],[x,y+1*yshift]);
        DrawMyText(display.window,'pour',ftsz_small,[100 100 100],[x,y-1*yshift]);
        DrawMyText(display.window,rewardList{stimR(iTrial)},ftsz_small,[255 255 255],[x,y-1.5*yshift]);
        % -- Display responses
        xshift = x/2;
        yes_color = [255*(choicedo(iTrial)==0) 255 0];
        no_color = [255*(choicedo(iTrial)==1) 255 0];
        DrawMyText(display.window,'OUI',45,yes_color,[ x+xshift/2*((1-sideyes(iTrial))-sideyes(iTrial)) , y-4*yshift ]);
        DrawMyText(display.window,'NON',45,no_color,[ x-xshift/2*((1-sideyes(iTrial))-sideyes(iTrial)) , y-4*yshift ]);
        Screen('LineStipple',display.window, 1, 2, mod(ceil((1:16)/8),2));
        Screen('DrawLine', display.window, [255 255 255]*0.5, x, y*7/5 ,  x, y*9/5, 3);
        Screen(display.window,'Flip');
        tresponse = GetSecs;
        while GetSecs <= tresponse + blanktime
            
        end
    else
        % instruction: speed-up warning
        textstring = 'Temps écoulé.';
        DrawMyText(display.window,textstring,ftsz_big,[255 255 255],[x,y]);
        textstring = 'Répondez plus rapidement.';
        DrawMyText(display.window,textstring,ftsz_big,[255 255 255],[x,y*1.2]);
        Screen(display.window,'Flip');
        WaitSecs(blanktime+1);
    end
end

% display end
Screen(display.window,'Flip');
Screen('CloseAll');

%% Data saving
%-----------------------------------------------
% data creation
varNames      = {'trialNumber', 'isLeftChoice', 'choicePosition', 'isAccept', 'RT'};
training_data = table((1:nTraining)',training_isLeftChoice',training_choice_position',training_choicedo',training_rt', 'VariableNames', varNames);
varNames      = {'trialNumber', 'itemNumberBenefit', 'ratingBenefit', 'itemNumberCost', 'ratingCost', 'isLeftChoice', 'choicePosition', 'isAccept', 'RT'};
ratingBenefit = ratingsBenefit(stimR(:));
ratingCost    = ratingsCost(stimP(:));
data          = table((1:nTrial)',stimR,ratingBenefit,stimP,ratingCost,isLeftChoice',choice_position',choicedo',rt','VariableNames',varNames);

% saving
sub_data.(cfg.sessNber_str).tasks.taskWeightRP.results = struct('trainingData', training_data, 'data', data);
end

