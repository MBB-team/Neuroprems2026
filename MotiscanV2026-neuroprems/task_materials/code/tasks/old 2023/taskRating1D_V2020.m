function [sub_data] = taskRating1D_V2020(sub_data,cfg,dimension)
% function [sub_data] = taskRatingE_V2(sub_data, cfg)
%
% taskRatingE - execute the effort rating task (from motiscan battery V2)
% Launch the task with this function for testing one subject.
% The subject has to provide a subjective estimate of item painfulness.
%
%   task specifications:
%       - structure: instructions -> training -> testing
%       - experimental conditions:  item subdomain (physical,
%       cognitive and social efforts)
%       - randomization:  between-subject random permutation of items, random permutation of item subdomain
%       - ntrial = 24
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

% fontsize
if isfield(cfg.ptb,mfilename)
        ftsz_iTask = cfg.ptb.fontsize.(mfilename);
else;   ftsz_iTask = cfg.ptb.fontsize.global;
end
ftsz_big    = ftsz_iTask.ftsz_big;
ftsz_mid    = ftsz_iTask.ftsz_mid;
ftsz_small  = ftsz_iTask.ftsz_small;
% maxCharPline_instruc = ftsz_iTask.maxCharPline_instruc;
maxCharPline_instruc = 75;

% Load stimuli
%-----------------------------------------------
task_name = ['Rating' dimension];
task_strctName = ['taskRating' dimension];

emojiNeutral_file = 'emoji_neutral.png';
text.answers  = {'Pas du tout','Enormément'};

switch dimension
    case 'E'        
        trainingList_file = 'efforts_training.xlsx';
        testingList_file  = 'efforts.xlsx';
        list_name = 'effortList';
        instruc_fill = {'différents EFFORTS présentés',                ...
            '"A quel point cela me serait-il pénible d''effectuer cet effort ?"'};

        emojiSpecific_file = 'emoji_effort.png';
        text.question = 'ça me déplaît :';
    case 'P'    
        trainingList_file = 'punishments_training.xlsx';
        testingList_file  = 'punishments.xlsx';
        list_name = 'punishList';
        moneyList = {'Perdre une pièce d''un centime EUR',                ...
            'perdre une pièce de 1 EUR',                                  ...
            'perdre un billet de 20 EUR'};
        instruc_fill = {'différentes PUNITIONS présentées',            ...
            '"A quel point cela me déplairaît-il de subir cette punition ?"'};

        emojiSpecific_file = 'emoji_punishment.png';
        text.question = 'ça me déplaît :';
    case 'R'
        trainingList_file = 'rewards_training.xlsx';
        testingList_file  = 'rewards.xlsx';
        list_name = 'rewardList';
        moneyList = {'recevoir une pièce d''un centime EUR',                   ...
            'recevoir une pièce de 1 EUR',                               ...
            'recevoir un billet de 20 EUR'};
        instruc_fill = {'différentes RECOMPENSES présentées',          ... 
            '"A quel point cela me plairaît-il d''obtenir cette récompense ?"'};
        emojiSpecific_file = 'emoji_reward.png';
        text.question = 'ça me plaît :';
end

cd(cfg.paths.task.images); % enter img dir

% informative icons
cross=Screen('MakeTexture',display.window,imread('Cross.bmp'));
rectcross=CenterRectOnPoint(Screen('Rect',cross),x,y);
yScale = y/2;
yemoji = y + yScale + 100 ;
xScaleLim = [x*1/5,x*9/5];
% neutral emoji
[img,map] = imread(emojiNeutral_file);
img = ind2rgb(img,map);img = img.*255;
emoji_neutral=Screen('MakeTexture',display.window,img);
rect_emoji_neutral=CenterRectOnPoint(Screen('Rect',emoji_neutral),xScaleLim(1),yemoji);
% specific (sad, happy, tired) emoji
switch dimension
    case 'E';   [img,map] = imread(emojiSpecific_file);
                img = ind2rgb(img,map);img = img.*255;
    otherwise; img = imread(emojiSpecific_file);
end
emoji_infinite = Screen('MakeTexture',display.window,img);
rect_emoji_infinite=CenterRectOnPoint(Screen('Rect',emoji_infinite),xScaleLim(2),yemoji);

% instructions images
instruction = struct('texture',{},'position',{});
for i=1:3
    instruction(i).texture = Screen('MakeTexture',display.window,imread(['instruction_R' task_name(2:end) '_' num2str(i) '.bmp']));
end

cd(cfg.paths.task.text) % extracting text

% text items
trainingList = readstim(trainingList_file);
testingList = readstim(testingList_file);
cd(cfg.paths.task.code) % returning to code directory

% recurring textstring
text.instruc = 'Instructions';
text.instrucText1 = sprintf(['Dans ce test, il vous est demandé de '    ...
    'donner des notes à %s sous forme de texte, comme si vous '         ...
    'répondiez à la question :\n%s'],instruc_fill{:});
text.instrucText2 = ['Pour répondre, veuillez toucher la case qui '     ...
    'correspond à votre ressenti, sur l''échelle allant de "Pas du '     ...
    'tout" à "Enormément", en prenant en compte les niveaux intermédiaires.'];
text.instrucText3 = ['Essayez d''utiliser toute l''échelle et de nuancer '...
    'les notes que vous donnez aux items proposés.\n\nPrenez le temps '...
    'qu''il vous faut pour répondre tout en étant le plus sincère possible.'];
text.training = 'Entrainement';
text.appuyer = 'appuyer sur une touche pour continuer...';
text.pretDebut = 'Prêt à débuter ?';
text.timesUp = 'Temps écoulé !';
text.faster = 'Répondez plus rapidement svp.';

% Experimental conditions
%-----------------------------------------------
nTrial = 24;
nTraining = 6;

% randomization
trialperm = randperm(nTrial);
switch dimension
    case {'P','R'}
        moneyIndex =  randperm(nTrial,2);
        for i = 1:2
            trialperm = insert_vector(trialperm,nTrial+i,moneyIndex(i));
        end
        trialperm = [ trialperm , nTrial+3 ];

        % sample list adaptation
        nTrial = nTrial + 3;
        testingList = [testingList , moneyList];
end

% timing variables
% timing variables
blanktime = 0.4;
ITI_duration = 0.5;
ITI_jitter=0.5;
waitAft_bigTtl = 0.2;
waitAft_instruc = 0.5;
waitAft_trial = 0.007;
maxResponseDuration=10e3;

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

DrawMyText(display.window,text.instruc,ftsz_big,[255 255 255],[x,y]);
DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(waitAft_bigTtl);
KbWait;

% % instruction: explanations
% for i=1:3
%     Screen('DrawTexture',display.window,instruction(i).texture);
%     Screen(display.window,'Flip');
%     WaitSecs(1);
%     KbWait;
% end
Screen('TextSize', display.window,ftsz_small);
DrawFormattedText(display.window,text.instrucText1,'center','center',   ...
    [255 255 255],maxCharPline_instruc, 0, 0, 2, 0, []);
Screen(display.window,'Flip');
WaitSecs(waitAft_instruc);
KbWait;

Screen('TextSize', display.window,ftsz_small);
DrawFormattedText(display.window,text.instrucText2,'center','center',   ...
    [255 255 255],maxCharPline_instruc, 0, 0, 2, 0, []);
Screen(display.window,'Flip');
WaitSecs(waitAft_instruc);
KbWait;

Screen('TextSize', display.window,ftsz_small);
DrawFormattedText(display.window,text.instrucText3,'center','center',   ...
    [255 255 255],maxCharPline_instruc, 0, 0, 2, 0, []);
Screen(display.window,'Flip');
WaitSecs(waitAft_instruc);
KbWait;

DrawMyText(display.window,text.training,ftsz_big,[255 255 255],[x,y]);
DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(waitAft_bigTtl);
KbWait;

% Trial structure
%-----------------------------------------------
interrupt_task = false;ntrial=0; repeat=0;
while ntrial<nTraining
    
    if repeat==0
        ntrial=ntrial+1;
    end
    
    if interrupt_task
        break
    end
    
    % fixation interval
    Screen('DrawTexture',display.window,cross,[],rectcross);
    KbReleaseWait;
    wait4release()
    Screen(display.window,'Flip');
    WaitSecs(ITI_duration + rand*ITI_jitter);
    
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
        draw_scale_instruction_2(display.window,x,y,text.question,text.answers,ftsz_small);
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
                exit=1;
                training_validation_responsetime(ntrial) = GetSecs - startime;
            elseif keycode(key.escape)==1
                exit=1;
                interrupt_task = true;
            else
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
        WaitSecs(waitAft_trial);
    end
    
    % record data
    training_rating(ntrial)=training_cursor{ntrial}(iCursor);
    DrawMyText(display.window,trainingList{ntrial},ftsz_small,[255 255 255],[x,y]);
    draw_scale_instruction_2(display.window,x,y,text.question,text.answers,ftsz_small);
    display_rating_likert(display.window,x,y,training_rating(ntrial)) ;
    Screen('DrawTexture',display.window,emoji_neutral,[],rect_emoji_neutral);
    Screen('DrawTexture',display.window,emoji_infinite,[],rect_emoji_infinite);
    Screen(display.window,'Flip');
    WaitSecs(blanktime);
    % WaitSecs(1);
end

training_rating(training_rating <5)   = 0;
training_rating(training_rating <95 & training_rating >=5) = ceil((training_rating(training_rating <95 & training_rating >=5)-4)/10);
training_rating(training_rating >=95) = 10;

%% Testing
%-----------------------------------------------
% instructions:  start
DrawMyText(display.window,text.pretDebut,ftsz_big,[255 255 255],[x,y]);
DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(waitAft_bigTtl);
KbWait;
wait4release()

% Trial structure
%-----------------------------------------------
interrupt_task = false;ntrial=0; repeat=0;
while ntrial<nTrial
    
    if repeat==0
        ntrial=ntrial+1;
    end
    
    if interrupt_task
        break
    end
    
    % int
    Screen('DrawTexture',display.window,cross,[],rectcross);
    KbReleaseWait;
    wait4release()
    Screen(display.window,'Flip');
    WaitSecs(ITI_duration + rand*ITI_jitter);
    
    %  Check Response
    exit=0;
    iCursor = 1;
    cursor{ntrial}(iCursor) = 50;
    buttons = 0;
    % Get trialtime
    startime=GetSecs;
    
    while exit==0
        % Write reward
        DrawMyText(display.window,testingList{trialperm(ntrial)},ftsz_small,[255 255 255],[x,y]);
        
        % Write instructions
        draw_scale_instruction_2(display.window,x,y,text.question,text.answers,ftsz_small);
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
                exit=1;
                interrupt_task = true;
            else
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
        WaitSecs(waitAft_trial);
    end
    
    % Update data to save
    rating(ntrial)=cursor{ntrial}(iCursor);
    
    DrawMyText(display.window,testingList{trialperm(ntrial)},ftsz_small,[255 255 255],[x,y]);
    draw_scale_instruction_2(display.window,x,y,text.question,text.answers,ftsz_small);
    display_rating_likert(display.window,x,y,rating(ntrial)) ;
    Screen('DrawTexture',display.window,emoji_neutral,[],rect_emoji_neutral);
    Screen('DrawTexture',display.window,emoji_infinite,[],rect_emoji_infinite);
    
    Screen(display.window,'Flip');
    WaitSecs(blanktime);
    % WaitSecs(1);
end

% Ratings transformation
rating(rating <5)   = 0;
rating(rating <95 & rating >=5) = ceil((rating(rating <95 & rating >=5)-4)/10);
rating(rating >=95) = 10;

% display end
Screen(display.window,'Flip');
sca;

%% Data saving
%-----------------------------------------------
% data creation
varNames = {'trialNumber', 'itemNumber', 'rating', 'press_RT', 'validation_RT'};
training_data = table((1:nTraining)',(1:nTraining)',training_rating',   ...
    training_press_responsetime',training_validation_responsetime',     ...
    'VariableNames', varNames);
varNames = {'trialNumber', 'itemNumber', 'rating', 'press_RT', 'validation_RT'};
data=table((1:nTrial)',trialperm',rating',press_responsetime',          ...
    validation_responsetime', 'VariableNames', varNames);

% saving
if interrupt_task
    sub_data.(cfg.sessNber_str).tasks.(task_strctName).completed...
        = false;
else; sub_data.(cfg.sessNber_str).tasks.(task_strctName).completed...
        = true;
end
sub_data.(cfg.sessNber_str).tasks.(task_strctName).results =                 ...
    struct('trainingData', training_data, 'data', data);
% Do we really need to save this ?
sub_data.(cfg.sessNber_str).tasks.(task_strctName).trainingList   ...
    = trainingList;
sub_data.(cfg.sessNber_str).tasks.(task_strctName).(list_name)    ...
    = testingList;

end

