function [sub_data] = taskChoice_DelayR2_V2024(sub_data, cfg)
% load('data_tache.mat')

% function [sub_data] = taskChoice_DelayR2_V2024(sub_data, cfg)

% taskChoice_DelayR2 - execute the delay-reward choice task (from
% motiscan battery V2024)
% Launch the task with this function for testing one subject.
% The subject has to choose between 2 options his prefered one.
% Each option is formulated as a foodvfood or nonfoodvnonfood that they 
% will obtain in a certain delay.

% Big reward: image format

% Modified version of 2020 :
% 6 Fixed trianing trials.
% 24 Unfixed testing trials.
% Immediate reward vs reward in 8 timepoints in the future.

% Input : sub_data and cfg structures
%
% Output : modified sub_data with data and training data
%
% Modified March 2024, A. PAPASAVVA

%% Configuration
% _________________________________________________________________________
cfg = motiscanV2020_setTask(cfg);

display  = cfg.ptb.display;
L        = display.L;
H        = display.H;
x        = display.x;
y        = display.y;

winL = [0 0 x H];
winR = [x 0 L H];

rectImgL=[x/2-3*y/8, 5*y/8, x/2+3*y/8, 11*y/8];
rectImgR=[3*x/2-3*y/8, 5*y/8, 3*x/2+3*y/8, 11*y/8];

key = cfg.ptb.key;

wait4release   = cfg.ptb.wait4release;
recordResponse = cfg.ptb.recordResponse;

% fontsize
if isfield(cfg.ptb,mfilename)
        ftsz_iTask = cfg.ptb.fontsize.(mfilename);
else;   ftsz_iTask = cfg.ptb.fontsize.global;
end

ftsz_big    = ftsz_iTask.ftsz_big;
ftsz_small  = ftsz_iTask.ftsz_small;

max_charPline = 35;

rectImgInstruction = [0 0 2*x 2*y];

% Load Stimuli
%__________________________________________________________________________
taskName = 'ChoiceDelayR2'
taskChoice_strctName = 'taskChoiceDelayR2'
taskRating_strctName = 'taskRatingR2'

testingList_file  = 'rewards2.xlsx';

% Testing Stimuli Images
imgItemR2 = struct('texture', {});
for i = 1:24                                                                % 24 items
    imgItemR2(i).texture = Screen('MakeTexture', display.window, imread(['img_rewards2_' num2str(i) '.bmp']));
end

% Informative Icons
cd(cfg.paths.task.images)
cross=Screen('MakeTexture',display.window,imread('Cross.bmp'));
rectcross=CenterRectOnPoint(Screen('Rect',cross),x,y);
% instructions images
instruction = struct('texture',{},'position',{});
for i=1:1
    instruction(i).texture = Screen('MakeTexture',display.window,imread(['instruction_WTWR_1' '.bmp']));
end
cd(cfg.paths.task.code); % exit img dir

cd(cfg.paths.task.text) % extracting text

% Text.instrucText2 = ;
text.appuyer = 'appuyer sur une touche pour continuer...';
text.quePref  = 'Que préférez-vous ?';
text.pretDebut = 'Prêt à débuter ?';
text.timesUp = 'Temps écoulé !';
text.respFaster = 'Répondez plus rapidement svp.';

% Items Text
cd(cfg.paths.task.text)                                                     % extracting text
testingList   = readstim(testingList_file);
cd(cfg.paths.task.code)                                                     % returning to code directory

text.instruc = 'Instructions';
text.instrucText = ['Dans ce test, il vous est demandé de choisir '    ...
    'entre deux récompenses présentées: une que vous pouvez recevoir ' ...
    'maintenant et une que vous pouvez recevoir dans le futur.\n\n' ...
    'Sélectionnez simplement l''offre que vous préférez si on vous donnait ' ...
    'la choix entre les deux. Il n''y a pas de bonne ou mauvais réponse, ' ...
    'nous souhaitons simplement connaître votre préférence.'];

% Experimental Conditions
%__________________________________________________________________________
nTrial=20;

% Timing Variables
ITI_duration = 0.5;
blanktime = 0.4;
waitAft_bigTtl = 0.2;
waitAft_trial = 0.007;
maxResponseDuration = 10e3;

% sample list adaptation
% Adaptation of reward list for the NeuroPrems study

% Extract Ratings
if isfield(sub_data.(cfg.sessNber_str).tasks, taskRating_strctName) && ...
   isfield(sub_data.(cfg.sessNber_str).tasks.(taskRating_strctName), 'results') && ...
   isfield(sub_data.(cfg.sessNber_str).tasks.(taskRating_strctName).results, 'data')

    rtg_import = sub_data.(cfg.sessNber_str).tasks.(taskRating_strctName).results.data;
    rtg = nan(24,1);                              % full 1..24 range
    rtg(rtg_import.itemNumber) = rtg_import.rating; % place each rating at its item number
    ratingRsummary = rtg;

else
    warning('Participant has not completed rating task - using mean control participant ratings from file');

    cd(cfg.paths.task.text)
    mean_ratings_data = readmatrix('mean_control_ratings_R2.xlsx');
    cd(cfg.paths.task.code)

    rtg = mean_ratings_data(1:24);
    ratingRsummary = rtg;
end

% Testing Delays
listShortDelayLabel = 'Aujourd''hui';
listLongDelayLabels2 = {'Demain', 'Dans trois jours','Dans une semaine', 'Dans deux semaines', ...
                       'Dans un mois', 'Dans trois mois', 'Dans six mois', 'Dans un an'};
listLongDelayLabels = string(listLongDelayLabels2);
baseDelays  = repmat(1:8, 1, 2);              % 16 trials: every delay x2
perm8       = randperm(8);                    % random ordering of 1..8
extraDelays = perm8(1:4);                     % 4 distinct delays, random per subject
delayIndex  = [baseDelays, extraDelays];      % 20 entries

delayIndex_permuted = delayIndex(randperm(numel(delayIndex)));

% % Data preparation
%__________________________________________________________________________
% testing
isLeftChoice    = nan(1,nTrial);
choice_position = nan(1,nTrial);
rt              = nan(1,nTrial);

smallstim=nan(1,length(nTrial));
smallrating=nan(1,length(nTrial));
bigstim=nan(1,length(nTrial));
bigrating=nan(1,length(nTrial));
bigdelay=nan(1,length(nTrial));

% Immediate option always on the left for even participants
if mod(sub_data.sub_id,2) == 0
    immIsLeft = 1;
    winImm = winL;
    winDel = winR;
    rectImm = rectImgL;
    rectDel = rectImgR;
else
    immIsLeft = 0;
    winImm = winR;
    winDel = winL;
    rectImm = rectImgR;
    rectDel = rectImgL;
end

testing_immIsLeft = zeros(1,nTrial);
testing_labels = cell(1,nTrial);

% Randomize Pairs of Items for Testing
subsample = [1 2 3 5 6 7 8 9 11 12 13 15 16 17 18 19 20 21 23 24];

category1 = subsample(subsample <= 12);   % food items     = [1 2 3 5 6 7 8 9 11 12]
category2 = subsample(subsample >= 13);   % non-food items = [13 15 16 17 18 19 20 21 23 24]
num_repetitions = 2;

food_choices = zeros(length(category1), num_repetitions);
non_food_choices = zeros(length(category2), num_repetitions);

% Check that the same item' won't appear twice in the same trial
% Reshuffle until: (a) no item is paired with itself within a trial, and
% (b) no unordered pair {a,b} repeats across trials, within each category.
keep_shuffling = true;
while keep_shuffling
    food_choices(:, 1)     = category1(randperm(length(category1)));
    food_choices(:, 2)     = category1(randperm(length(category1)));
    non_food_choices(:, 1) = category2(randperm(length(category2)));
    non_food_choices(:, 2) = category2(randperm(length(category2)));

    % (a) within-trial self-pairing
    selfPair = any(food_choices(:,1) == food_choices(:,2)) || ...
               any(non_food_choices(:,1) == non_food_choices(:,2));

    % (b) repeated unordered pairs within a category
    foodPairs    = sort(food_choices, 2);      % order-independent: {a,b}=={b,a}
    nonFoodPairs = sort(non_food_choices, 2);
    repeatedPair = size(unique(foodPairs,    'rows'), 1) < size(foodPairs,    1) || ...
                   size(unique(nonFoodPairs, 'rows'), 1) < size(nonFoodPairs, 1);

    keep_shuffling = selfPair || repeatedPair;
end

% Create table with items for each trial (food,non_food,food, etc.)
combined_choices = zeros(20, 2);
for i = 1:10
    food_pair = food_choices(i,:);
    non_food_pair = non_food_choices(i,:);
    combined_choices((i-1)*2+1, :) = food_pair;
    combined_choices((i-1)*2+2, :) = non_food_pair;
end

%% Testing
%__________________________________________________________________________
% Display
DrawMyText(display.window,text.instruc,ftsz_big,[255 255 255],[x,y]);
DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(0.2);
KbWait;
Screen('TextSize', display.window, ftsz_small);

% Instruction: Explanations
for i=1:1
    Screen('DrawTexture',display.window,instruction(i).texture,[],rectImgInstruction);
    Screen(display.window,'Flip');
    WaitSecs(1);
    KbWait;
end

% Instructions:  Start
DrawMyText(display.window,text.pretDebut,ftsz_big,[255 255 255],[x,y]);
DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(waitAft_bigTtl);
KbWait;
wait4release()

% Trial structure
%-----------------------------------------------
interrupt_task = 0; iTrial = 0; repeat=0;
while iTrial<nTrial
    
    if repeat == 0
        iTrial = iTrial + 1;
    end
    
    if interrupt_task
        break
    end
    
    % int
    Screen('DrawTexture',display.window,cross,[],rectcross);
    KbReleaseWait;
    Screen(display.window,'Flip');
    WaitSecs(ITI_duration);
    wait4release()
    
    stim1 = combined_choices(iTrial,1);
    stim2 = combined_choices(iTrial,2);

    if ratingRsummary(stim1)>=ratingRsummary(stim2)
        bigstim(iTrial)=stim1;
        bigrating(iTrial)=ratingRsummary(stim1);
        smallstim(iTrial)=stim2;
        smallrating(iTrial)=ratingRsummary(stim2);
    else
        bigstim(iTrial)=stim2;
        bigrating(iTrial)=ratingRsummary(stim2);
        smallstim(iTrial)=stim1;
        smallrating(iTrial)=ratingRsummary(stim1);
    end

    text.imm = testingList{smallstim(1,iTrial)};
    img.imm = imgItemR2(smallstim(1,iTrial)).texture;
    text.del = testingList{bigstim(1,iTrial)};
    img.del = imgItemR2(bigstim(1,iTrial)).texture;
    startime = Screen(display.window,'Flip');

    % This is the generation of the delay label/text for the delay item
    for i = iTrial
        index = delayIndex_permuted(i);
        delay_label = listLongDelayLabels{index};
    end
    
    testing_labels{iTrial} = delay_label;

    % Check Response
    exit = 0;
    
    while exit == 0
        % Refresh Screen
       DrawMyText(display.window, text.quePref, ftsz_small, [100 100 100], ...
            [x, (2*y/8 - 50)], max_charPline);

        DrawFormattedText(display.window,listShortDelayLabel,'center',(y/2-3*y/8)-max_charPline + y/4, [255 255 255],max_charPline, 0, 0, 1, 0, winImm);
        DrawFormattedText(display.window,text.imm,'center',13*y/8,[255 255 255],max_charPline, 0,0,2,0,winImm);

        text.del = testingList{bigstim(1,iTrial)};
        img.del = imgItemR2(bigstim(1,iTrial)).texture;

        DrawFormattedText(display.window,delay_label,'center',(y/2-3*y/8)-max_charPline + y/4,[255 255 255],max_charPline, 0, 0, 1, 0, winDel); 
        DrawFormattedText(display.window,text.del,'center',13*y/8,[255 255 255],max_charPline,0,0,2,0,winDel);
            
        Screen('DrawTexture',display.window,img.imm,[],rectImm);
        Screen('DrawTexture',display.window,img.del,[],rectDel);
        Screen('LineStipple',display.window, 1, 2, mod(ceil((1:16)/8),2));
        Screen('DrawLine', display.window, [255 255 255]*0.5, x,3*y/8 - 35 ,  x,y*7/4, 3);
        Screen(display.window,'Flip');
        
    % Record Response
        [keyisdown, ~, keycode] = KbCheck;
        if keyisdown==1
            % Monitor validation & exit
            if keycode(key.escape)==1
                exit=1;
                timedown=GetSecs;
                interrupt_task = 1;
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
        WaitSecs(waitAft_trial);
        
        % Monitor maximal response time
        timePassed = GetSecs-startime;
        if timePassed>maxResponseDuration
            exit=1;
            repeat=repeat+1;
        end
    end
    if repeat==0
        rt(iTrial)=timedown-startime;
        if immIsLeft == 0
            testing_immIsLeft(iTrial) = 0;
        else 
            testing_immIsLeft(iTrial) = 1;
        end
        % Show Response
        DrawMyText(display.window, text.quePref, ftsz_small, [100 100 100], ...
            [x, (2*y/8 - 50)], max_charPline);
        Screen('TextSize', display.window, ftsz_small);
        if mod(sub_data.sub_id,2) == 0
            left_color = [255*(isLeftChoice(iTrial)==0) 255 255*(isLeftChoice(iTrial)==0)];
            DrawFormattedText(display.window,listShortDelayLabel,'center',(y/2-3*y/8)-max_charPline + y/4,left_color,max_charPline, 0, 0, 1, 0, winL);
            DrawFormattedText(display.window,text.imm,'center',13*y/8,left_color,max_charPline, 0,0,2,0,winL);

            right_color = [255*(isLeftChoice(iTrial)==1) 255 255*(isLeftChoice(iTrial)==1)];
            DrawFormattedText(display.window,delay_label,'center',(y/2-3*y/8)-max_charPline + y/4,right_color,max_charPline, 0, 0, 1, 0, winR);
            DrawFormattedText(display.window,text.del,'center',13*y/8,right_color,max_charPline, 0,0,2,0,winR);

            Screen('DrawTexture',display.window,img.imm,[],rectImgL);
            Screen('DrawTexture',display.window,img.del,[],rectImgR);
        else
            left_color = [255*(isLeftChoice(iTrial)==0) 255 255*(isLeftChoice(iTrial)==0)];
            DrawFormattedText(display.window,delay_label,'center',(y/2-3*y/8)-max_charPline + y/4,left_color,max_charPline, 0, 0, 1, 0, winL);
            DrawFormattedText(display.window,text.del,'center',13*y/8,left_color,max_charPline, 0,0,2,0,winL);

            right_color = [255*(isLeftChoice(iTrial)==1) 255 255*(isLeftChoice(iTrial)==1)];
            DrawFormattedText(display.window,listShortDelayLabel,'center',(y/2-3*y/8)-max_charPline + y/4,right_color,max_charPline, 0, 0, 1, 0, winR);
            DrawFormattedText(display.window,text.imm,'center',13*y/8,right_color,max_charPline, 0,0,2,0,winR);

            Screen('DrawTexture',display.window,img.del,[],rectImgL);
            Screen('DrawTexture',display.window,img.imm,[],rectImgR);
        end

            Screen('LineStipple',display.window, 1, 2, mod(ceil((1:16)/8),2));
            Screen('DrawLine', display.window, [255 255 255]*0.5, x,3*y/8 - 35 ,  x,y*7/4, 3);

        Screen(display.window,'Flip');
        tresponse = GetSecs;
        while GetSecs <= tresponse + blanktime
            
        end
    else
        % Instruction: Speed-up warning
        Screen('TextSize', display.window, ftsz_small);
        DrawFormattedText(display.window,text.timesUp,'center','center',[255 255 255],max_charPline, 0, 0, 2, 0, []);
        DrawMyText(display.window,text.respFaster,ftsz_big,[255 255 255],[x,y*1.2]);
        Screen(display.window,'Flip');
        WaitSecs(blanktime+1);
    end
    
end
    
% Display End
Screen(display.window,'Flip');
sca;

%% Data saving
%__________________________________________________________________________
immediateItem   = smallstim(:);
immediateRating = smallrating(:);
delayedItem     = bigstim(:);
delayedRating   = bigrating(:);

% choseImmediate: 1 = chose the immediate option, 0 = chose the delayed one.
% isLeftChoice is 1=left, 0=right; immIsLeft says whether immediate was on the
% left. The subject chose immediate exactly when those two agree.

immIsLeftCol   = repmat(immIsLeft, nTrial, 1);
choseImmediate = double(isLeftChoice(:) == immIsLeft);
choseImmediate(isnan(isLeftChoice(:))) = NaN;

varNames = {'trialNumber','immediateItem','immediateRating', ...
            'delayedItem','delayedRating','delayLabel', ...
            'choseImmediate','RT','immIsLeft'};

data = table((1:nTrial)', immediateItem, immediateRating, ...
             delayedItem, delayedRating, testing_labels(:), ...
             choseImmediate, rt(:), immIsLeftCol, ...
             'VariableNames', varNames);

% saving
if interrupt_task
    sub_data.(cfg.sessNber_str).tasks.(taskChoice_strctName).completed = false;
else; sub_data.(cfg.sessNber_str).tasks.(taskChoice_strctName).completed = true;
end

sub_data.(cfg.sessNber_str).tasks.(taskChoice_strctName).results = struct('data', data);
end
