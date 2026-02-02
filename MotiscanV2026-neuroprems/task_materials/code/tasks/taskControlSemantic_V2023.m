function [sub_data] = taskControlSemantic_V2023(sub_data,cfg)
% function [sub_data] = taskControlSemantic_V2023(sub_data, cfg)
%
% taskControlSemantic_V2023 - execute the Control_Semantic choice task
% Launch the task with this function for testing one subject.
% The subject has to choose among two words the one that is semantically
% closest to the item
%
%   task specifications:
%       - structure: instructions -> training -> testing
%       - experimental conditions: Norm violation
%       - randomization:
%           pseudo-random permutation of norms violations
%       - ntrial = 24
%       - trial structure: display 1 option with a norm violation; choose one option (2 words)
%       - training: exposure to several options (6 trials)
%
% Inputs: sub_data and cfg structures
%
% Outputs: updated sub_data with results = training_data and data tables
% with (trialNumber, isLeftChoice, choicePosition, isCorrect, RT) for training and
% with (trialNumber, itemNumberNormViolation,isLefthoice, choicePosition, isCorrect, 'RT') for testing
%
% Author: Raphael Le Bouc, Nicolas Borderies
% email address: nico.borderies@gmail.com
% September 2013; Last revision: June 2017
%
% Updated March 2023 for V2023, R. JOLY



%%liste choice
appariementTestingList1_file ='appariement_Semantic_liste1.xlsx';
appariementTestingList2_file ='appariement_Semantic_liste2.xlsx';

response = input('Liste à utiliser (1/2):');


while response ~=1 && response ~=2
    disp('Réponse invalide. Veuillez répondre avec 1 ou 2:')
    response = input('Liste à utiliser (1/2):');
end

if response == 1
    %norm_testingList = readstim(normTestingList1_file)';
    appariement_testing = readtable(appariementTestingList1_file);

elseif response == 2
    %norm_testingList = readstim(normTestingList2_file)';
    appariement_testing = readtable(appariementTestingList2_file);
end

ListeNb = response;

%% Configuration
cfg = motiscanV2020_setTask(cfg);

display  = cfg.ptb.display;
L        = display.L;
H        = display.H;
x        = display.x;
y        = display.y;
win_l = [0 0 x H];
win_r = [x 0 L H];

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
maxCharPline_instruc = 75;
max_charPline = 60;

% Load stimuli
%-----------------------------------------------

norm_ratingTaskName = 'taskRatingN';

% items
trainingList = readstim('SocialNormViolations_training.xlsx');
testingList = readstim('SocialNormViolations.xlsx');

appariement_training = readtable('appariement_Semantic_training.xlsx');

%appariement_testing = readtable('appariement_Semantic.xlsx'); %maintenant
%listes pour 12 trials

cd(cfg.paths.task.images); % enter img dir

% informative icons
cross=Screen('MakeTexture',display.window,imread('Cross.bmp'));
rectcross=CenterRectOnPoint(Screen('Rect',cross),x,y);

% instructions images
instruction = struct('texture',{},'position',{});
for i=1:1
    instruction(i).texture = Screen('MakeTexture',display.window,imread(['instruction_Semantic_'  num2str(i) '.bmp']));
end

% Stimuli images
imgItemN = struct('texture',{},'position',{});
for i=1:24
    imgItemN(i).texture = Screen('MakeTexture',display.window,imread(['img_SocialNormViolations_' num2str(i) '.bmp']));
end

imgTrainingN = struct('texture',{},'position',{});
for i=1:6
    imgTrainingN(i).texture = Screen('MakeTexture',display.window,imread(['img_SocialNormViolations_training_' num2str(i) '.bmp']));
end

cd(cfg.paths.task.text) % extracting text

% recurring textstring
text.instruc = 'Instructions';
text.training = 'Entrainement';
text.appuyer = 'appuyer sur une touche pour continuer...';
text.pretDebut = 'Prêt à débuter ?';
text.question = 'Quel mot décrit le mieux le comportement?'; % text.accept = 'Il pourrait m''arriver de';
text.timesUp = 'Temps écoulé !';
text.faster = 'Répondez plus rapidement svp.';



% Experimental conditions
%-----------------------------------------------
nTrial      = 12;
nTraining   = 6;

% timing variables
ITI_duration = 0.5;
blanktime = 0.4;
ITI_jitter = 0.5;
waitAft_bigTtl = 0.2;
waitAft_instruc = 0.5;
waitAft_trial = 0.007;
maxResponseDuration = 10e3;

clear temp*
cd(cfg.paths.task.code) % returning to code directory

%% Create vectors of experimental factors
stimN = [1:12];
index = randperm(12);
stimN = stimN(index);

training_options = [1 2 3 4 5 6 ]; % norm number

training_isCorrectAnswerLeft = [0 1 1 0 0 1 ];

isCorrectAnswerLeft = [zeros(1,6) ones(1,6)];%%jsp
isCorrectAnswerLeft = isCorrectAnswerLeft(index);%%jsp

% Data preparation
%-----------------------------------------------
training_isLeftChoice    = nan(1,nTraining);
training_choice_position = nan(1,nTraining);
training_choiceCorrect   = nan(1,nTraining);
training_rt              = nan(1,nTraining);

% testing
isLeftChoice    = nan(1,nTrial);
choice_position = nan(1,nTrial);
choiceCorrect   = nan(1,nTrial);
rt              = nan(1,nTrial);


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
     Screen('DrawTexture',display.window,instruction(i).texture,[],rectImgInstruction);
    Screen(display.window,'Flip');
    WaitSecs(1);
    KbWait;
end

DrawMyText(display.window,text.training,ftsz_big,[255 255 255],[x,y]);
DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(waitAft_bigTtl);
KbWait;

% Trial structure
%-----------------------------------------------
interrupt_task=0;iTrial=0; repeat=0;
while iTrial<nTraining
    
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
    
    text.N = trainingList{training_options(iTrial)}; % Norm number

    img.N = imgTrainingN(training_options(iTrial)).texture;

    
    text.correct = char(appariement_training{training_options(iTrial),1});
    text.uncorrect = char(appariement_training{training_options(iTrial),2});

    % Write instructions & option
    disp_trial(display,ftsz_small,max_charPline,text,img,win_l,win_r,training_isCorrectAnswerLeft(iTrial),0);
    startime = Screen(display.window,'Flip');



    % Check Response
    exit=0;
    while exit==0
        % refresh screen
        disp_trial(display,ftsz_small,max_charPline,text,img,win_l,win_r,training_isCorrectAnswerLeft(iTrial),1)
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
        
        if training_isLeftChoice(iTrial) == training_isCorrectAnswerLeft(iTrial)
            training_choiceCorrect(iTrial) = 1;
        else
            training_choiceCorrect(iTrial) = 0;
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
        [yes_color,no_color] = color_yesno(training_choiceCorrect(iTrial));
        disp_trial(display,ftsz_small,max_charPline,text,img,win_l,win_r,   ...
            training_isCorrectAnswerLeft(iTrial),1,yes_color,no_color)
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
WaitSecs(waitAft_bigTtl);
KbWait;
wait4release()

% Trial structure
%-----------------------------------------------
interrupt_task=0;iTrial=0; repeat=0;
while iTrial<nTrial
    
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
    
    %text.N = testingList{stimN(iTrial)}; % Norm number
    text.N = testingList{appariement_testing{stimN(iTrial),1}}; %maintenant avec les listes
        
    %img.N = imgItemN(stimN(iTrial)).texture;
    img.N = imgItemN(appariement_testing{stimN(iTrial),1}).texture;

    text.correct = char(appariement_testing{stimN(iTrial),2});
    text.uncorrect = char(appariement_testing{stimN(iTrial),3});

    % Write instructions & option
    disp_trial(display,ftsz_small,max_charPline,text,img,win_l,win_r,isCorrectAnswerLeft(iTrial),0);
    startime = Screen(display.window,'Flip');
    

    % Check Response
    exit=0;
    while exit==0
        % refresh screen
        disp_trial(display,ftsz_small,max_charPline,text,img,win_l,win_r,isCorrectAnswerLeft(iTrial),1)
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
        
        if isLeftChoice(iTrial) == isCorrectAnswerLeft(iTrial)
            choiceCorrect(iTrial) = 1;
        else
            choiceCorrect(iTrial) = 0;
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
        [yes_color,no_color] = color_yesno(choiceCorrect(iTrial));
        disp_trial(display,ftsz_small,max_charPline,text,img,win_l,win_r,   ...
            isCorrectAnswerLeft(iTrial),1,yes_color,no_color)

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
varNames = {'trialNumber', 'isCorrectAnswerLeft','itemNumberNorm','isLeftChoice', 'choicePosition', 'isCorrect', 'RT'};
training_data = table((1:nTraining)',training_isCorrectAnswerLeft',training_options',...
                      training_isLeftChoice',training_choice_position',training_choiceCorrect',training_rt', 'VariableNames', varNames);

varNames      = {'trialNumber','ListNumber','isCorrectAnswerLeft','itemNumberNorm', 'isLeftChoice', 'choicePosition', 'isCorrect', 'RT'};
% ratingNorm    = ratingsNorm(stimN(:));
% count=0;
% for j=stimR+1
%     count=count+1;
%     stimR_Nbr(count) = appariement_testing{stimN(count),j};
% end
itemNumberNorm = appariement_testing{stimN,1};

ListNbUsed = repmat (ListeNb, 1, nTrial);

data          = table((1:nTrial)',ListNbUsed', isCorrectAnswerLeft',itemNumberNorm,isLeftChoice',choice_position',choiceCorrect',rt','VariableNames',varNames);

% saving
if interrupt_task
    sub_data.(cfg.sessNber_str).tasks.taskControlSemantic.completed...
        = false;
else; sub_data.(cfg.sessNber_str).tasks.taskControlSemantic.completed...
        = true;
end
sub_data.(cfg.sessNber_str).tasks.taskControlSemantic.results =      ...
    struct('trainingData', training_data, 'data', data);
end

function [] = disp_trial(display,ftsz,max_charPline,text,img,win_l,win_r,   ...
    side_correct,show_response,varargin)

H = display.H;
x = display.x;
y = display.y;

% rectImg1=[x/3-3*y/8, y/8, x/3+3*y/8, 7*y/8];
rectImg2=[x-3*y/8, y/8, x+3*y/8, 7*y/8];
% rectImg3=[5*x/3-3*y/8, y/8, 5*x/3+3*y/8, 7*y/8];

% y20_acpt = 4;
% y20_pour = 8;
y20_resp = 14;

txt_accept_size = Screen('TextSize', display.window);

if nargin > 10; color_yes = varargin{1}; color_no = varargin{2};
else; color_yes = [255 255 255]; color_no = [255 255 255];
end

Screen('TextSize', display.window, ftsz);

 
DrawFormattedText(display.window,text.question,'center',9*y/8,[100 100 100],max_charPline,0,0,1,0);
DrawFormattedText(display.window,text.N,'center','center',[255 255 255],max_charPline, 0,0,1,0);
Screen('DrawTexture',display.window,img.N,[],rectImg2);


if show_response
    if logical(side_correct) % corect answer : right = 0, left = 1
        win_oui = win_l; win_non = win_r;
    else; win_oui = win_r; win_non = win_l;
    end
    DrawFormattedText(display.window,text.correct,'center',H*y20_resp/20,color_yes,max_charPline,0,0,1,0,win_oui);
    DrawFormattedText(display.window,text.uncorrect,'center',H*y20_resp/20,color_no,max_charPline,0,0,1,0,win_non);
    Screen('LineStipple',display.window, 1, 2, mod(ceil((1:16)/8),2));
    Screen('DrawLine', display.window, [255 255 255]*0.5, x,H*(y20_resp-2)/20, x,H*(y20_resp+3)/20, 3);
    %         Screen('LineStipple',display.window, 1, 2, mod(ceil((1:16)/8),2));
    %         Screen('DrawLine', display.window, [255 255 255]*0.5, x, y*7/5 ,  x, y*9/5, 3);
end

end

function [color_yes,color_no] = color_yesno(choice)
color_yes = [255*(choice==0) 255 255*(choice==0)];
color_no  = [255*(choice==1) 255 255*(choice==1)];
end