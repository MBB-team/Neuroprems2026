function [sub_data] = taskControlPerception_V2023_img(sub_data,cfg)
% function [sub_data] = taskControlPerception_V2023_img(sub_data, cfg)
%
% taskControlPerception - execute the 1D-2O choice task (from motiscan battery)
% Launch the task with this function for testing one subject.
% The subject has choose between 2 items the one with the most gray in the
% background.
%
%   task specifications:
%       - structure: instructions -> training -> testing
%       - experimental conditions: item value difference, item subdomain
%       (physical, cognitive and social efforts)
%       - randomization:
%           random permutation of value pairs (with 4 sequences,...
%               exploring the full value range and value difference range),
%           random balanced permutation of item subdomain
%       - iTrial = 48
%       - trial structure: display 2 options, choose one option
%       - training: exposure to several options (3 trials)
%
% Inputs: sub_data and cfg structures
%
% Outputs: updated sub_data with results = training_data and data tables
% with (trialNumber, isLeftChoice, choice_position, RT) for training and
% with (trialNumber, itemNumberLeft, GreyLevelLeft, itemNumberRight,
%       GreyLevelRight, isLeftChoice, choice_position, RT) for testing
%
% Author: Raphael Le Bouc, Nicolas Borderies
% email address: nico.borderies@gmail.com
% September 2013; Last revision: February 2017
%
% Updated March 2020 for V2020, P. CARRILLO
% Updated Septm 2020 for V2020, <teddy.landron@gmail.com>;
% Updated February 2023 for V2023, R.JOLY


%% Configuration
% -----------------------------------------------
cfg = motiscanV2020_setTask(cfg);

display         = cfg.ptb.display;
L               = display.L;
H               = display.H;
x               = display.x;
y               = display.y;
winL_coor       = [0 0 x H];
winR_coor       = [x 0 L H];
% winCenter_coor  = [0 0 L H];

rectImg1=[x/2-3*y/8, 5*y/8, x/2+3*y/8, 11*y/8];
rectImg2=[3*x/2-3*y/8, 5*y/8, 3*x/2+3*y/8, 11*y/8];

rectImgInstruction=[0 0 2*x 2*y];

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

ftsz_instruc = 80

% maxCharPline_instruc = ftsz_iTask.maxCharPline_instruc;
maxCharPline_instruc = 75;
% max_charPline = ftsz_iTask.maxCharPline_instruc;
max_charPline = 35;

% Load stimuli
%-----------------------------------------------
taskName = 'taskControlPerception';
taskChoice_strctName = 'taskControlPerception';
%taskRating_strctName = 'taskRatingN';

trainingList_file = 'SocialNormViolations_training.xlsx';
testingList_file  = 'SocialNormViolations.xlsx';
pairingList_file  = 'appariement_perception.xlsx';
appariement_testing = readtable(pairingList_file);
instruc_fill      = 'IMAGES présentées';

testing_greylevel = 'greylevel_socialnorms.xlsx'; 
training_greylevel = 'greylevel_socialnorms_training.xlsx';

imgItemN = struct('texture',{},'position',{});
for i=1:24
    imgItemN(i).texture = Screen('MakeTexture',display.window,imread(['img_SocialNormViolations_' num2str(i) '.bmp']));
end

imgTrainingN = struct('texture',{},'position',{});
for i=1:6
    imgTrainingN(i).texture = Screen('MakeTexture',display.window,imread(['img_SocialNormViolations_training_' num2str(i) '.bmp']));
end

        

% informative icons
cd(cfg.paths.task.images); % enter img dir

cross=Screen('MakeTexture',display.window,imread('Cross.bmp'));
rectcross=CenterRectOnPoint(Screen('Rect',cross),x,y);


% instructions images
% instruction = struct('texture',{},'position',{});
% for i=1:1
%     image = imread(['instruction_' taskName '.bmp']);
%     instruction(i).texture = Screen('MakeTexture',display.window,image);
% end

% training items
cd(cfg.paths.task.text) % extracting text
trainingList  = readstim(trainingList_file);
testingList   = readstim(testingList_file);
GreyLevel_testing    = readmatrix(testing_greylevel);
%GreyLevel_training   = readmatrix(training_greylevel);

cd(cfg.paths.task.code) % returning to code directory

% recurring textstring
text.instruc = 'Instructions';

% instructions images
instruction = struct('texture',{},'position',{});
for i=1:1
    instruction(i).texture = Screen('MakeTexture',display.window,imread(['instruction_Perception_'  num2str(i) '.bmp']));
end

%text.instrucText = sprintf(['Dans ce test, il vous est demand de '     ...
    %'choisir entre deux %s.\n\n'                      ...
    %'Slectionnez simplement l''image avec le plus de gris en arrire-plan.'],                          ...
    %instruc_fill);
text.training = 'Entrainement';
text.appuyer = 'appuyer sur une touche pour continuer...';
text.quePref  = 'Quelle image a le plus de gris en arrière-plan ?';
text.pretDebut = 'Prêt à débuter ?';
text.timesUp = 'Temps écoulé !';
text.respFaster = 'Rpondez plus rapidement svp.';

% Experimental conditions
%-----------------------------------------------
nTrial=12;
nTraining=3;

% timing variables
ITI_duration = 0.5;
ITI_jitter = 0.5;
blanktime = 0.4;
waitAft_bigTtl = 0.2;
waitAft_instruc = 0.5;
waitAft_trial = 0.007;
maxResponseDuration = 10e3;

% Extract ratings
%rtg_import =                                                            ...
%    sub_data.(cfg.sessNber_str).tasks.(taskRating_strctName).results.data;
%temp        = sortrows(rtg_import, 'itemNumber', 'ascend');
%rtg         = temp.rating(1:24); 
%clear temp

% % OLD NON-FIXED PAIRING
% 
% training_options = [1 3 5 1 2 3 ; 
%     2 4 6 4 5 6]; %voir avec raphael pour voir si on randomise ou pas, et comment on dispose les tches entre elles
% training_options = training_options'
% 
% % sort ratings
% [~,index] = sort(rtg,'ascend');
% 
% % First series of choices : take pairs from either side of the median rating, from
% % the center to the periphery.
% choices1 = [index(12-(0:11))  index(13:24)]';
% % Second series of choices : Same principle, but do it for small ratings
% % and big ratings separately.
% choices2 = [index(1:6) index(13:18) ; index(12-(0:5)) index(24-(0:5))]';
% % Third series of choices : select pairs with a small value difference but
% % variable mean value (increasing)
% choices3 = [index(1:2:23)  index(2:2:24)]';
% % Fourth series of choices : select pairs with a big value difference but
% % variable mean value (increasing)
% choices4 = [index(1:12)  index(13:24) ]';
% 
% % Concatenate and permute ChoiceLists
% permutlist = randperm(48);
% temp_list = [choices1  choices2  choices3  choices4];
% temp_list = temp_list(:, permutlist);
% 
% % Alternate the side of the less valuable option
% list(:,2:2:48)= temp_list(:,2:2:48);
% list(1,1:2:48)= temp_list(2,1:2:48);
% list(2,1:2:48)= temp_list(1,1:2:48);

%% NEW FIXED PAIRING
list = readtable(pairingList_file);
list = table2array(list);
list = list(randperm(size(list, 1)), :); % random permutation of rows
list = list';

training_options = [1 2 4 ;
    5 3 6];
clear temp_list

% Data preparation
%-----------------------------------------------
% training
training_isLeftChoice           = nan(1,nTraining);
training_choice_position        = nan(1,nTraining);
training_rt                     = nan(1,nTraining);

% testing
isLeftChoice    = nan(1,nTrial);
choice_position = nan(1,nTrial);
rt              = nan(1,nTrial);

%% Training
%-----------------------------------------------
% display
DrawMyText(display.window,text.instruc,ftsz_big,[255 255 255],[x,y]);
DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(waitAft_bigTtl);
KbWait;

% instruction: explanations
for i=1:1
     Screen('DrawTexture',display.window,instruction(i).texture);
     Screen(display.window,'Flip');
     WaitSecs(1);
     KbWait;
end

%Screen('TextSize', display.window, ftsz_instruc);
%DrawFormattedText(display.window, instruction,'center','center',   ...
%    [255 255 255],maxCharPline_instruc, 0, 0, 1, 0, []);
%Screen(display.window,'Flip');
%WaitSecs(waitAft_instruc);
%KbWait;

DrawMyText(display.window,text.training,ftsz_big,[255 255 255],[x,y]);
DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(waitAft_bigTtl);
KbWait;

% Trial structure
%-----------------------------------------------

interrupt_task=0;iTrial=0; repeat=0;
while iTrial < nTraining
    
    if repeat==0
        iTrial=iTrial+1;
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
    


    % Write instructions & options
    DrawMyText(display.window,text.quePref,ftsz_small,[100 100 100],    ...
        [x,y*1/2]);
    Screen('TextSize', display.window,ftsz_small);
    text.l = trainingList{training_options(1,iTrial)};
    img.l = imgTrainingN(training_options(1,iTrial)).texture;
    text.r = trainingList{training_options(2,iTrial)};
    img.r = imgTrainingN(training_options(2,iTrial)).texture;
    
    Screen('LineStipple',display.window, 1, 2, mod(ceil((1:16)/8),2));
    Screen('DrawLine', display.window,[255 255 255]*0.5, x,y*1/2 ,  x,y*3/2, 3);
    Screen('DrawTexture',display.window,img.l,[],rectImg1);
    Screen('DrawTexture',display.window,img.r,[],rectImg2);

    startime = Screen(display.window,'Flip');
    
    % Check Response
    exit = 0;
    
    while exit == 0
        % refresh screen
        DrawMyText(display.window,text.quePref,ftsz_small,[100 100 100],...
            [x,1/2*y]);
        
        Screen('TextSize', display.window, ftsz_small);
        
        Screen('LineStipple',display.window, 1, 2, mod(ceil((1:16)/8),2));
        Screen('DrawLine', display.window, [255 255 255]*0.5, x,y*1/2 ,  x,y*3/2, 3);
        Screen('DrawTexture',display.window,img.l,[],rectImg1);
        Screen('DrawTexture',display.window,img.r,[],rectImg2);
        Screen(display.window,'Flip');
        
        % Record Response
        [keyisdown, ~, keycode] = KbCheck;
        if keyisdown==1
            % monitor validation & exit
            if keycode(key.escape)==1
                exit=1;
                timedown=GetSecs;
                interrupt_task = 1;
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
        WaitSecs(waitAft_trial);
        
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
        DrawMyText(display.window,text.quePref,ftsz_small,[100 100 100],[x,1/2*y]);
        Screen('TextSize', display.window, ftsz_small);
        left_color = [255*(training_isLeftChoice(iTrial)==0) 255 255*(training_isLeftChoice(iTrial)==0)];
        right_color = [255*(training_isLeftChoice(iTrial)==1) 255 255*(training_isLeftChoice(iTrial)==1)];
        
        Screen('LineStipple',display.window, 1, 2, mod(ceil((1:16)/8),2));
        Screen('DrawLine', display.window, [255 255 255]*0.5, x, y*1/2 ,  x, y*3/2, 3);
        Screen('DrawTexture',display.window,img.l,[],rectImg1);
        Screen('DrawTexture',display.window,img.r,[],rectImg2);

        Screen(display.window,'Flip');
        tresponse = GetSecs;
        while GetSecs <= tresponse + blanktime
            
        end
    else
        % instruction: speed-up warning
        % DrawMyText(display.window,textstring,ftsz_big,[255 255 255],[x,y]);
        Screen('TextSize', display.window, ftsz_small);
        DrawFormattedText(display.window,text.timesUp,'center','center',[255 255 255], 0, 0, 1, 0, []);
        DrawMyText(display.window,text.respFaster,ftsz_big,[255 255 255],[x,y*1.2]);
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
    
    text.l = testingList{list(1,iTrial)};
    text.r = testingList{list(2,iTrial)};
    img.l = imgItemN(list(1,iTrial)).texture;
    img.r = imgItemN(list(2,iTrial)).texture;
    
    % Write instructions & options
    DrawMyText(display.window,text.quePref,ftsz_small,[100 100 100],[x,1/2*y]);
    
    Screen('TextSize', display.window, ftsz_small);
    
    Screen('LineStipple',display.window, 1, 2, mod(ceil((1:16)/8),2));
    Screen('DrawLine', display.window, [255 255 255]*0.5, x, y*1/2 ,  x, y*3/2, 3);
    Screen('DrawTexture',display.window,img.l,[],rectImg1);
    Screen('DrawTexture',display.window,img.r,[],rectImg2);
    startime = Screen(display.window,'Flip');
    
    % Check Response
    exit=0;
    
    while exit==0
        % refresh screen
        DrawMyText(display.window,text.quePref,ftsz_small,[100 100 100],[x,1/2*y]);
        
        Screen('TextSize', display.window, ftsz_small);
        
        Screen('LineStipple',display.window, 1, 2, mod(ceil((1:16)/8),2));
        Screen('DrawLine', display.window, [255 255 255]*0.5, x, y*1/2 ,  x, y*3/2, 3);
        Screen('DrawTexture',display.window,img.l,[],rectImg1);
        Screen('DrawTexture',display.window,img.r,[],rectImg2);
        Screen(display.window,'Flip');
        
        % Record Response
        [keyisdown, ~, keycode] = KbCheck;
        if keyisdown==1
            % monitor validation & exit
            if keycode(key.escape)==1
                exit=1;
                timedown=GetSecs;
                interrupt_task=1;
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
        
        % Show Response
        DrawMyText(display.window,text.quePref,ftsz_small,[100 100 100],[x,1/2*y]);
        
        Screen('TextSize', display.window, ftsz_small);
        left_color = [255*(isLeftChoice(iTrial)==0) 255 255*(isLeftChoice(iTrial)==0)];
        right_color = [255*(isLeftChoice(iTrial)==1) 255 255*(isLeftChoice(iTrial)==1)];
        
        Screen('LineStipple',display.window, 1, 2, mod(ceil((1:16)/8),2));
        Screen('DrawLine', display.window, [255 255 255]*0.5, x, y*1/2 ,  x, y*3/2, 3);
        Screen('DrawTexture',display.window,img.l,[],rectImg1);
        Screen('DrawTexture',display.window,img.r,[],rectImg2);
        Screen(display.window,'Flip');
        tresponse = GetSecs;
        while GetSecs <= tresponse + blanktime
            
        end
    else
        % instruction: speed-up warning
        % DrawMyText(display.window,textstring,ftsz_big,[255 255 255],[x,y]);
        Screen('TextSize', display.window, ftsz_small);
        DrawFormattedText(display.window,text.timesUp,'center','center',[255 255 255], 0, 0, 1, 0, []);
        DrawMyText(display.window,text.respFaster,ftsz_big,[255 255 255],[x,y*1.2]);
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
varNames      = {'trialNumber', 'isLeftChoice', 'choice_position',  ...
    'RT'};


training_data = table((1:nTraining)',training_isLeftChoice',        ...
    training_choice_position',training_rt', 'VariableNames', varNames);

varNames      = {'trialNumber', 'itemNumberLeft','GreyLevelLeft',      ...
    'itemNumberRight','GreyLevelRight','isLeftChoice','choice_position', 'RT'};

GreyLevelLeft = GreyLevel_testing(list(1,:));
GreyLevelRight = GreyLevel_testing(list(2,:));


data          = table((1:nTrial)',list(1,:)',GreyLevelLeft,list(2,:)', ...
    GreyLevelRight,isLeftChoice',choice_position',rt','VariableNames',varNames);

% saving
if interrupt_task
    sub_data.(cfg.sessNber_str).tasks.(taskChoice_strctName).completed...
        = false;
else; sub_data.(cfg.sessNber_str).tasks.(taskChoice_strctName).completed...
        = true;
end
sub_data.(cfg.sessNber_str).tasks.(taskChoice_strctName).results =  ...
    struct('trainingData', training_data, 'data', data);

end
