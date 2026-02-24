function [sub_data] = taskRatingR_V2020(sub_data, cfg)
% function [sub_data] = taskRatingR_V2(sub_data, cfg)
%
% taskRatingR - execute the reward rating task (from motiscan battery V2)
% Launch the task with this function for testing one subject.
% The subject has to provide a subjective estimate of item likability.
%
%   task specifications: 
%       - structure: instructions -> training -> testing
%       - experimental conditions:  item subdomain (alimentary,
%       non-alimentary, social and money rewards)
%       - randomization:  between-subject random permutation of items, random permutation of item subdomain
%       - ntrial = 27
%       - trial structure: display 1 option with a scale , record the rating
%       - training: exposure to several options (6 trials)
%
% Inputs: sub_data and cfg structures
%
% Outputs: updated sub_data with results = training_data and data tables
% with (trialNumber, itemNumber, rating, press_RT, validation_RT) for training and
% with (trialNumber, itemNumber, rating, press_RT, validation_RT) for testing
%
% Author: Raphael Le Bouc, Nicolas Borderies
% email address: nico.borderies@gmail.com 
% September 2013; Last revision: June 2017
%
% Updated March 2020 for V2020, P. CARRILLO

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

taskName = 'RatingR';

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
yScale = y/2;
yemoji= y + yScale + 100 ;
xScaleLim = [x*1/5,x*9/5];
[img,map] = imread('emoji_neutral.png');
img = ind2rgb(img,map);img = img.*255;
emoji_neutral=Screen('MakeTexture',display.window,img);
rect_emoji_neutral=CenterRectOnPoint(Screen('Rect',emoji_neutral),xScaleLim(1),yemoji);
emoji_infinite=Screen('MakeTexture',display.window,imread('emoji_reward.png'));
rect_emoji_infinite=CenterRectOnPoint(Screen('Rect',emoji_infinite),xScaleLim(2),yemoji);

% instructions images
instruction = struct('texture',{},'position',{});
for i=1:3
    instruction(i).texture = Screen('MakeTexture',display.window,imread(['instruction_' taskName '_' num2str(i) '.bmp']));
end

cd(cfg.paths.task.text) % extracting text

% text items
rewardList = readstim('rewards.xlsx');
trainingList = readstim('rewards_training.xlsx');
moneyList = {'Recevoir 1 pièce de 1 centime','Recevoir 1 pièce de 1 euro','Recevoir 1 billet de 20 euros'};

cd(cfg.paths.task.code) % returning to code directory

% Experimental conditions
%-----------------------------------------------
nTrial   = 24 ;
nTraining = 6;

% randomization
trialperm = randperm(nTrial);

moneyIndex =  randperm(nTrial,2);
for i=1:2
    trialperm = insert_vector(trialperm,nTrial+i,moneyIndex(i));
end
trialperm = [ trialperm , nTrial+3 ];

% sample list adaptation
nTrial = nTrial + 3;
rewardList = [ rewardList , moneyList];

% timing variables
intertrial_duration=0.75;
intertrial_jitter=0.5;

% Data preparation
%-----------------------------------------------
% training
training_rating                  = nan(1,nTraining);
training_press_responsetime      = nan(1,nTraining);
training_validation_responsetime = nan(1,nTraining);
training_cursor                  = cell(1,nTraining);

% testing
rating                  = nan(1,nTrial);
press_responsetime      = nan(1,nTrial);
validation_responsetime = nan(1,nTrial);
cursor                  = cell(1,nTrial);

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
for i=1:3
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
stoptask=0; ntrial=0; repeat=0;
while ntrial<nTraining
    
    if repeat == 0
        ntrial = ntrial+1;
    end
    
    if stoptask
        break
    end
    
    % int
    Screen('DrawTexture',display.window,cross,[],rectcross);
    KbReleaseWait;
    wait4release()
    Screen(display.window,'Flip');
    WaitSecs(intertrial_duration + rand*intertrial_jitter);
    
    %  Check Response
    exit=0;
    iCursor = 1;
    training_cursor{ntrial}(iCursor) = 50;
    startime=GetSecs;
    buttons = 0;
    while exit==0
        
        % Write reward
        DrawMyText(display.window,trainingList{ntrial},ftsz_small,[255 255 255],[x,y]);
        
        % Write instructions
        question_name = 'Ça me plaît :';
        answer_names = {'Pas du tout','Enormément'};
        draw_scale_instruction_2(display.window,x,y,question_name,answer_names,ftsz_small);
        Screen('DrawTexture',display.window,emoji_neutral,[],rect_emoji_neutral);
        Screen('DrawTexture',display.window,emoji_infinite,[],rect_emoji_infinite);
        
        % Display cursor and scale
        display_rating_likert(display.window,x,y,[]);
        Screen(display.window,'Flip');
        iCursor = iCursor + 1;
        training_cursor{ntrial}(iCursor) = training_cursor{ntrial}(iCursor-1);
        
        % Check keys
        [keyisdown, ~, keycode] = KbCheck;
        if keyisdown==1
            % monitor validation & exit
            if  keycode(key.space)==1
                exit = 1;
                training_validation_responsetime(ntrial) = GetSecs - startime;
            elseif keycode(key.escape)==1
                exit     = 1;
                stoptask = 1;
            else % keyboard arrows
                % monitor rating time
                if isnan(training_press_responsetime(ntrial))
                    training_press_responsetime(ntrial) = GetSecs - startime;
                end
                if  keycode(key.right)==1
                    training_cursor{ntrial}(iCursor)=min([training_cursor{ntrial}(iCursor)+1 100]);
                elseif keycode(key.left)==1
                    training_cursor{ntrial}(iCursor)=max([training_cursor{ntrial}(iCursor)-1 0]);
                end
            end
        end
        [xMouse,yMouse,buttons] = recordResponse(display.window);
        xcursor = (xMouse - xScaleLim(1))/diff(xScaleLim)*100;
        xcursor = round(max([min([xcursor,100]),0]));
        training_cursor{ntrial}(iCursor) = xcursor ;
        % monitor rating time
        if isnan(training_press_responsetime(ntrial)) && training_cursor{ntrial}(iCursor)~=training_cursor{ntrial}(1)
            training_press_responsetime(ntrial) = GetSecs - startime;
        end
        % monitor confirmation
        exit = any(buttons~=0) & (yMouse>=y);
        training_validation_responsetime(ntrial) = GetSecs - startime;
        
        WaitSecs(0.007);
    end
    
    % record data
    training_rating(ntrial) = training_cursor{ntrial}(iCursor);
    
    DrawMyText(display.window,trainingList{ntrial},ftsz_small,[255 255 255],[x,y]);
    draw_scale_instruction_2(display.window,x,y,question_name,answer_names,ftsz_small);
    display_rating_likert(display.window,x,y,training_rating(ntrial)) ;
    Screen('DrawTexture',display.window,emoji_neutral,[],rect_emoji_neutral);
    Screen('DrawTexture',display.window,emoji_infinite,[],rect_emoji_infinite);
    Screen(display.window,'Flip');
    
    WaitSecs(1);
end

training_rating(training_rating <5)   = 0;
training_rating(training_rating <95 & training_rating >=5) = ceil((training_rating(training_rating <95 & training_rating >=5)-4)/10);
training_rating(training_rating >=95) = 10;

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
stoptask=0;ntrial=0; repeat=0;
while ntrial<nTrial
    
    if repeat==0
        ntrial=ntrial+1;
    end
    
    if stoptask
        break
    end
    
    % int
    Screen('DrawTexture',display.window,cross,[],rectcross);
    KbReleaseWait;
    wait4release()
    Screen(display.window,'Flip');
    WaitSecs( intertrial_duration + rand*intertrial_jitter );
    
    %  Check Response
    exit=0;
    iCursor = 1;
    cursor{ntrial}(iCursor) = 50;
    buttons = 0;
    
    % Get trialtime
    startime=GetSecs;
    
    while exit==0
        % Write reward
        DrawMyText(display.window,rewardList{trialperm(ntrial)},ftsz_small,[255 255 255],[x,y]);
        
        % Write instructions
        question_name = 'Ça me plaît :';
        answer_names = {'Pas du tout','Enormément'};
        draw_scale_instruction_2(display.window,x,y,question_name,answer_names,ftsz_small);
        Screen('DrawTexture',display.window,emoji_neutral,[],rect_emoji_neutral);
        Screen('DrawTexture',display.window,emoji_infinite,[],rect_emoji_infinite);
        
        % Display cursor and scale
        display_rating_likert(display.window,x,y,[]);
        Screen(display.window,'Flip');
        iCursor = iCursor + 1;
        cursor{ntrial}(iCursor) = cursor{ntrial}(iCursor-1);
        
        % Check keys
        [keyisdown, ~, keycode] = KbCheck;
        if keyisdown==1
            % monitor validation & exit
            if  keycode(key.space)==1
                exit=1;
                validation_responsetime(ntrial) = GetSecs - startime;
            elseif keycode(key.escape)==1
                exit     = 1;
                stoptask = 1;
            else % keyboard arrows
                % monitor rating time
                if isnan(press_responsetime(ntrial))
                    press_responsetime(ntrial) = GetSecs - startime;
                end
                if  keycode(key.right)==1
                    cursor{ntrial}(iCursor)=min([cursor{ntrial}(iCursor)+1 100]);
                elseif keycode(key.left)==1
                    cursor{ntrial}(iCursor)=max([cursor{ntrial}(iCursor)-1 0]);
                end
            end
        end
        
        [xMouse,yMouse,buttons] = recordResponse(display.window);
        xcursor = (xMouse - xScaleLim(1))/diff(xScaleLim)*100;
        xcursor = round(max([min([xcursor,100]),0]));
        cursor{ntrial}(iCursor) = xcursor ;
        % monitor rating time
        if isnan(press_responsetime(ntrial)) && cursor{ntrial}(iCursor)~=cursor{ntrial}(1)
            press_responsetime(ntrial) = GetSecs - startime;
        end
        % monitor confirmation
        exit = any(buttons~=0) & (yMouse>=y);
        validation_responsetime(ntrial) = GetSecs - startime;
        WaitSecs(0.007);
    end
    
    % Update data to save
    rating(ntrial)=cursor{ntrial}(iCursor);
    
    DrawMyText(display.window,rewardList{trialperm(ntrial)},ftsz_small,[255 255 255],[x,y]);
    draw_scale_instruction_2(display.window,x,y,question_name,answer_names,ftsz_small);
    display_rating_likert(display.window,x,y,rating(ntrial)) ;
    Screen('DrawTexture',display.window,emoji_neutral,[],rect_emoji_neutral);
    Screen('DrawTexture',display.window,emoji_infinite,[],rect_emoji_infinite);
    
    Screen(display.window,'Flip');
    WaitSecs(1);
end

% Ratings transformation (from 0->100 to 0->10)
rating(rating <5)   = 0;
rating(rating <95 & rating >=5) = ceil((rating(rating <95 & rating >=5)-4)/10);
rating(rating >=95) = 10;

% display end
Screen(display.window,'Flip');
Screen('CloseAll');

%% Data saving
%-----------------------------------------------
% data creation
varNames      = {'trialNumber', 'itemNumber', 'rating', 'press_RT', 'validation_RT'};
training_data = table((1:nTraining)',(1:nTraining)',training_rating',training_press_responsetime',training_validation_responsetime', 'VariableNames', varNames);
varNames      = {'trialNumber', 'itemNumber', 'rating', 'press_RT', 'validation_RT'};
data          = table((1:nTrial)',trialperm',rating',press_responsetime',validation_responsetime', 'VariableNames', varNames);

% saving
sub_data.(cfg.sessNber_str).tasks.taskRatingR.results      = struct('trainingData', training_data, 'data', data);
% Do we really need this ?
sub_data.(cfg.sessNber_str).tasks.taskRatingR.trainingList = trainingList;
sub_data.(cfg.sessNber_str).tasks.taskRatingR.rewardList   = rewardList;

end

