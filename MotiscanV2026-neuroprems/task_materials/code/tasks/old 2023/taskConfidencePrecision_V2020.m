function [sub_data] = taskConfidencePrecision_V2020(sub_data, cfg)
%function [sub_data] = taskConfidencePrecision_V2(sub_data, cfg)
%
%taskConfidencePrecision -
%   task specifications:
%       - structure: instructions -> training -> testing
%       - experimental conditions: between-trials incentive(0.01,0.20,0.50,1,5,20 euros),
%         valence(gain/loss)
%       - randomization: within-block random incentive, switching valence blocks
%       - ntrial = 120
%       - training: exposure to all between-trials condition levels (6 trials)
%
% Input : sub_data and cfg structures
%
% Output : modified sub_data with results
% 
% Author: Raphael Le Bouc, Nicolas Borderies
% email address: nico.borderies@gmail.com
% April 2014; Last revision: February 2017
%
% Modified for V2, march 2020, P.CARRILLO

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

Handle   = cfg.grip.Handle;
readGrip = cfg.grip.readGrip;

% fontsize
if isfield(cfg.ptb,mfilename)
        ftsz_iTask = cfg.ptb.fontsize.(mfilename);
else;   ftsz_iTask = cfg.ptb.fontsize.global;
end
ftsz_big    = ftsz_iTask.ftsz_big;
ftsz_mid    = ftsz_iTask.ftsz_mid;
ftsz_small  = ftsz_iTask.ftsz_small;

%% Experiment preparation
% ----------------------------------------------
% Loads images and creates positions
cd(cfg.paths.task.images); % enter img dir
% incentive icons
for i=1:6
    pic_inc{i,1}=Screen('MakeTexture',display.window,imread(['pic_inc_' num2str(i) '.bmp']));
    [wrect{i},hrect{i}] = RectSize(Screen('Rect',pic_inc{i}));
    rect_inc{i}=CenterRectOnPoint(Screen('Rect',pic_inc{i}),x-wrect{i}/2-300,y+hrect{i}/2-300);
    pic_inc{i,2}=Screen('MakeTexture',display.window,imread(['pic_inc_' num2str(i) 'neg.bmp']));
end

% feedback icons
[ img,~] = imread('thumb_positive.png');
stim_fb_positive =  Screen('MakeTexture',display.window,img);

[ img,~] = imread('thumb_negative.png');
stim_fb_negative =  Screen('MakeTexture',display.window,img);

stim_rect = Screen('Rect',stim_fb_positive);
% [wrect,hrect] = RectSize(stim_rect);
rect_fb = CenterRectOnPoint(stim_rect, x ,y*0.75 );

% instructions images
instruction = struct('texture',{},'position',{});
for i=1:7
    instruction(i).texture = Screen('MakeTexture',display.window,imread(['instruction_GripRP_' num2str(i) '.bmp']));
end

% rating scale images
yScale = y/2;
yemoji= y + yScale + 100 ;
xScaleLim = [x*1/5,x*9/5];
% -- emojis
[img,map] = imread('emoji_sad.png');
img = ind2rgb(img,map);img = img.*255;
emoji_neutral=Screen('MakeTexture',display.window,img);
rect_emoji_neutral=CenterRectOnPoint(Screen('Rect',emoji_neutral),xScaleLim(1),yemoji);
[img,map] = imread('emoji_happy.png');
img = ind2rgb(img,map);img = img.*255;
emoji_infinite=Screen('MakeTexture',display.window,img);
% emoji_infinite=Screen('MakeTexture',display.window,imread('emoji_effort.png'));
rect_emoji_infinite=CenterRectOnPoint(Screen('Rect',emoji_infinite),xScaleLim(2),yemoji);

rect_confidence_low = CenterRectOnPoint(stim_rect, xScaleLim(1),yemoji );
rect_confidence_high = CenterRectOnPoint(stim_rect, xScaleLim(2),yemoji );

cd(cfg.paths.task.code) % returning to code directory

% Experimental conditions
%-----------------------------------------------
% number of samples
nTrial = 60;
nTrialPerBlock = 12;
nBlock = nTrial/nTrialPerBlock;
nTrialPerCalibration = 3;
nTrainingPhase1 = 10;  % 10
nTrainingPhase2 = 10;  % 10
nTraining = nTrainingPhase1 + nTrainingPhase2;

% factorial levels
incentiveList = [0.01 0.20 0.50 1 5 20];
nIncentive = numel(incentiveList);
feedbackBiasList = [ (mod(sub_data.sub_id,2)*2 - 1) , -(mod(sub_data.sub_id,2)*2 - 1) ]; % randomize order according to subject number
targetLevel = 0.25;
difficultyLevel = 0.50;
trainingRange = 0.30;
forceOutlierCriterion = 0.75;

% training vectors
training_online_fb = [ ones(1,nTrainingPhase1) , zeros(1,nTrainingPhase2) ];
training_offline_fb = ones(1,nTraining);

% test vectors
designMat = CombVec(repmat(incentiveList,1,2),feedbackBiasList);
designMat = repmat(designMat,1,2);
designMat = [designMat(:,1:24) , [designMat(1,1:12) ; zeros(1,12)] , designMat(:,25:end) ];
incentive = designMat(1,:);

feedbackBias = designMat(2,:);
% feedbackValidity = mod(ceil([1:nTask]/6),2);
feedbackValidity = zeros(1,nTrial);
frequentFalseFeedback = ones(1,nTrial);
rareFeedback_distributionPerIncentive = ceil(randperm(6)/3)-1 ;
for iBias = [ -1 , +1 ]
    for i = 1:nIncentive
        distrib = rareFeedback_distributionPerIncentive(i);
        index = find(incentive==incentiveList(i) & feedbackBias==iBias);
        index = index( (1:2) + 2*distrib );
        randindex = index(randi(nTrialPerBlock/6,1));
        frequentFalseFeedback(randindex) = 0;
    end
end
feedback = zeros(1,nTrial);
feedback(frequentFalseFeedback==1) = feedbackBias(frequentFalseFeedback==1);
feedback(frequentFalseFeedback==0) = -feedbackBias(frequentFalseFeedback==0);
feedback(feedbackBias==0) = ceil(randperm(12)/6)*2-3 ;


blockNumber = ceil((1:nTrial)/12);
% trials = 1:nTrials;
online_fb = zeros(1,nTrial);
offline_fb = ones(1,nTrial);

% neutral block
% neutral_index = 24+1:24+12;
% feedbackValidity(neutral_index) = ones(1,nTrialPerBlock);
% offline_fb(neutral_index) = zeros(1,nTrialPerBlock);

confidence_rating = mod(1:nTrial,2);
mood_rating = zeros(1,nTrial);
mood_rating( 1 + ((1:5)-1)*nTrialPerBlock )= 1;
mood_rating( (1:5)*nTrialPerBlock )= 1;
recalibration = zeros(1,nTrial);
recalibration( (1:5)*nTrialPerBlock )= 1;

% randomization
for iblock = 1:max(blockNumber)
    index = 1+(iblock-1)*nTrialPerBlock:nTrialPerBlock+(iblock-1)*nTrialPerBlock;
    randindex = randperm(nTrialPerBlock) + (iblock-1)*nTrialPerBlock;
    incentive(index) = incentive(randindex);
    feedbackValidity(index) = feedbackValidity(randindex);
    randindex = randperm(nTrialPerBlock) + (iblock-1)*nTrialPerBlock;
    confidence_rating(index) = confidence_rating(randindex);
end
[~,incentiveLevel] = ismember(incentive,incentiveList);

% durations parameters
responseduration=0.4;
feedbackduration=2;
% intertrialduration=0.5;
jitmin=1;
jitmax=2;

% criterions
forceOnsetCriterion = 0.1;

% Data preparation
%-----------------------------------------------
% nInstruct = 3;
% instructforce=nan(1,nInstruct);
% instructsumforce=nan(1,nInstruct);
% instructperf=nan(1,nInstruct);
% gripdatainstruct={};

[training_force,training_force_error,training_accuracy_force,trainingtime, trainingefforttime, trainingperf, traininggain,...
    trainingfeedbacktime,trainingfeedback,training_correct_force,training_correct_time] = deal(nan(1,nTraining));

trainingjitter=rand(1,nTraining)*(jitmax-jitmin)+jitmin;             % incentive is displayed during the jitter : between 1 and 3 secondes
training_gripdata={};

[force,force_error,accuracy_force,correct_force,correct_time,confidence_response_time,confidence_confirmation_time,...
    confidence,correct,mood_response_time,mood_confirmation_time,mood,trialtime,gain] = deal(nan(1,nTrial));

jitter=rand(1,nTrial)*(jitmax-jitmin)+jitmin;                       % incentive is displayed during the jitter : between 1 and 3 secondes
gripdata={};

% Initialization
%-----------------------------------------------
% counters and calibration
total=0;

calibratedForce = sub_data.grip.hand_used.(sub_data.grip.hand_used.to_use).calibratedFmax*1.2;

if strcmp(sub_data.grip.gripdevice,'mie') % device reset
    textstring = 'Avant de débuter, appuyer sur ''N'' et ''zero'' sur le boitier du Grip';
    DrawMyText(display.window,textstring,ftsz_mid,[255 0 0],[x,y]);
    textstring = 'appuyer sur une touche pour continuer';
    DrawMyText(display.window,textstring,ftsz_mid,[255 0 0],[x,1.5*y]);
    Screen(display.window,'Flip');
    WaitSecs(1);
    KbWait;
elseif strcmp(sub_data.grip.gripdevice,'vernier')
    % Necessary step for in this version the grip tends to disconnect
    % between tasks
    try
        Handle.start();
    catch
        cfg.grip.Handle     = dynamometer;
        cfg.grip.readGrip   = @readVernier;
        Handle   = cfg.grip.Handle;
        readGrip = cfg.grip.readGrip;
        Handle.start();
    end
    textstring = 'Avant de débuter, relacher complètement la poignée pour l''étalonnage.';
    DrawMyText(display.window,textstring,ftsz_mid,[255 255 255],[x,y]);
    textstring = 'appuyer sur une touche pour continuer';
    DrawMyText(display.window,textstring,ftsz_mid,[100 100 100],[x,1.5*y]);
    Screen(display.window,'Flip');
    WaitSecs(1);
    signal = [];
    rec = 1;
    while rec == 1
        grip = readGrip(Handle);
        signal = [signal,grip];
        rec = ~(KbCheck);
    end
    offset = nanmin(signal);
    readGrip = @(Handle) readVernier(Handle,offset);
end

%% Training
%-----------------------------------------------

% Handgrip training
%-----------------------------------------------
% display
textstring = 'Entrainement au dynamomètre';
DrawMyText(display.window,textstring,ftsz_big,[255 255 255],[x,y]);
Screen(display.window,'Flip');
WaitSecs(1);
KbWait;

% instruction: explanations
% - slide 1
textstring = ['Dans ce test, une jauge orange vous indiquera la force que vous exercez sur une échelle graduée.',...
    ' Vous allez devoir serrer la poignée au moment où l''instruction « Serrez maintenant ! »  apparaît. ',...
    'Un cadre vert sera placé sur l''échelle graduée. Le but de cet entraînement est de vous apprendre à effectuer une impulsion de force dont l''intensité maximale (indiquée par la jauge orange) est située dans le cadre vert.',...
    ' La pression exercée doit être très brève.. '];
Screen('TextSize', display.window, ftsz_mid);
DrawFormattedText(display.window, textstring,'center','center',[255 255 255], 50, 0, 0, 2, 0, []);
Screen(display.window,'Flip');
WaitSecs(1);
KbWait;

% Display instruction
target_name={'Exercez 25% de votre force maximale!'};
textstring = target_name{1};
DrawMyText(display.window,textstring,ftsz_mid,[255 0 0],[x,y]);
Screen(display.window,'Flip');
WaitSecs(3);

% Trial structure
%-----------------------------------------------
for iTrial=1:nTraining
    
    % inter-trial phase
    Screen(display.window,'Flip');
    WaitSecs(1);
    
    % instructions
    if iTrial==1
        textstring = 'Entrainement avec retour visuel';
        DrawMyText(display.window,textstring,50,[255 255 255],[x,y]);
        Screen(display.window,'Flip');
        WaitSecs(1);
    elseif iTrial == nTrainingPhase1+1
        textstring = 'Entrainement à l''aveugle';
        DrawMyText(display.window,textstring,50,[255 255 255],[x,y]);
        Screen(display.window,'Flip');
        WaitSecs(1);
    end
    
    % Display Effort scale
    i=0; peak = 0; stop = 0; tForce = [];dtForce=0; correctTime = 1;
    tstart=GetSecs;
    
    while stop == 0
        % record force
        i=i+1;
        [grip,Tgrip]=readGrip(Handle);
        training_gripdata.grip{iTrial}(i)=grip;
        training_gripdata.time{iTrial}(i)=Tgrip;
        level=max(0,grip/calibratedForce*100);
        peak = nanmax([peak,level]);
        
        % display online force feedback
        textstring = 'Serrez maintenant!';
        DrawMyText(display.window,textstring,50,[255 255 255],[x,y*1/5]);
        if training_online_fb(iTrial)
            display_effortTarget_precision(display.window,x,y,level,targetLevel,trainingRange);
        end
        Screen(display.window,'Flip');
        
        % stop criterion
        if peak>forceOnsetCriterion*100
            tForce = [ tForce , GetSecs];
            dtForce = tForce(end) - tForce(1);
        end
        if dtForce > responseduration
            stop = 1;
            if level>forceOnsetCriterion*100
                correctTime = 0;
            end
        end
    end
    
    % Data to save
    training_force(iTrial) = nanmax(training_gripdata.grip{iTrial});
    training_force_error(iTrial) = (training_force(iTrial)/calibratedForce) - targetLevel;
    training_accuracy_force(iTrial) = abs(training_force_error(iTrial));
    training_correct_force(iTrial) = 1 - double(training_accuracy_force(iTrial)>trainingRange/2);
    training_correct_time(iTrial)=correctTime;
    
    % offline feedback
    if training_offline_fb(iTrial)
        fontsize = 50;
        if training_correct_time(iTrial)==0
            textstring = 'Vitesse: trop lent!';
            DrawMyText(display.window,textstring,fontsize,[255 0 0],[x*3/2,y - y*0.1]);
        end
        if training_correct_force(iTrial)==1
            textstring = 'Force: réussite!';
            DrawMyText(display.window,textstring,fontsize,[0 255 0],[x*3/2,y + y*0.1]);
        else
            textstring = 'Force: échec';
            if training_force_error(iTrial)>0
                textstring = [ textstring , ' trop fort...' ];
            else
                textstring = [ textstring , ' trop faible...' ];
            end
            DrawMyText(display.window,textstring,fontsize,[255 0 0],[x*3/2,y + y*0.1]);
        end
        display_effortTarget_precision(display.window,x,y,peak,targetLevel,trainingRange);
    end
    Screen(display.window,'Flip');
    WaitSecs(feedbackduration+1);
end

% force target range adaptation
% mu = .5 + mean(training_force_error);
% sigma = std(training_force_error);
%target_range_level = 2*computeTargetSizes(mu, sigma, difficultyLevel);

% Before v2020 target range was auto-adapted but this feature was never
% explained to the participants which disturbed them, so we fixed it to .3
target_range_level = 0.3;
target_range = repmat(target_range_level,1,nTrial);

%% Testing
%-----------------------------------------------
textstring = 'Instructions de la tâche';
DrawMyText(display.window,textstring,ftsz_big,[255 255 255],[x,y]);
textstring = 'appuyer sur une touche pour continuer';
DrawMyText(display.window,textstring,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(0.2);
KbWait;
% instruction: explanations
% - slide 1
islide=4;
Screen('DrawTexture',display.window,instruction(islide).texture);
Screen(display.window,'Flip');
WaitSecs(1);
KbWait;
% - slide 2
textstring = ['Votre rémunération dépendra de votre succès dans la réalisation de l''impulsion. ',...
    'Si l''impulsion de force a une intensité correcte, vous remportez l''intégralité du montant en jeu, sinon vous ne remportez rien du tout.'];
Screen('TextSize', display.window, ftsz_mid);
DrawFormattedText(display.window, textstring,'center','center',[255 255 255], 50, 0, 0, 2, 0, []);
Screen(display.window,'Flip');
WaitSecs(1);
KbWait;
% - slide 3
textstring = ['Le but du test est d''accumuler le plus d''argent possible. A vous de contrôler votre force pour parvenir à ce but.',...
    'Bon courage!'];
Screen('TextSize', display.window, ftsz_mid);
DrawFormattedText(display.window, textstring,'center','center',[255 255 255], 50, 0, 0, 2, 0, []);
Screen(display.window,'Flip');
WaitSecs(1);
KbWait;

% instructions:  start
textstring = 'Prêt à débuter ?';
DrawMyText(display.window,textstring,ftsz_big,[255 255 255],[x,y]);
textstring = 'appuyer sur une touche pour continuer';
DrawMyText(display.window,textstring,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(1);
KbWait;

% Trial structure
%-----------------------------------------------
for iTrial=1:nTrial
    
    % inter-trial phase
    Screen(display.window,'Flip');
    WaitSecs(1);
    
    % instructions
    if mod(iTrial-1,nTrialPerBlock)==0
        nCurrentBlock = ceil(iTrial/12);
        textstring = ['Bloc: ' num2str(nCurrentBlock) '/' num2str(nBlock) ] ;
        DrawMyText(display.window,textstring,50,[255 255 255],[x,y]);
        Screen(display.window,'Flip');
        WaitSecs(1);
    end
    
    % Display incentive
    Screen('DrawTexture',display.window,pic_inc{incentiveLevel(iTrial),1},[],rect_inc{incentiveLevel(iTrial)});
    trialtime(iTrial)=Screen(display.window,'Flip');
    wait4release()
    WaitSecs(jitter(iTrial));
    
    % confidence rating
    if confidence_rating(iTrial)
        %  Check Response
        exit=0;onset=0;iCursor = 1;
        cursor{iTrial}(iCursor) = 50;
        startime=GetSecs;
        
        while exit==0
            Screen('DrawTexture',display.window,pic_inc{incentiveLevel(iTrial),1},[],rect_inc{incentiveLevel(iTrial)});
            
            % Write instructions
            question_name = 'Quelles sont mes chances de réussite?';
            answer_names = {'0%','100%'};
            draw_scale_instruction_2(display.window,x,y,question_name,answer_names);
            Screen('DrawTexture',display.window,stim_fb_negative,[],rect_confidence_low);
            Screen('DrawTexture',display.window,stim_fb_positive,[],rect_confidence_high);
            
            % Display cursor and scale
            display_rating_likert(display.window,x,y,[]);
            Screen(display.window,'Flip');
            iCursor = iCursor + 1;
            cursor{iTrial}(iCursor) = cursor{iTrial}(iCursor-1);
            % Check keys
            [keyisdown, ~, keycode] = KbCheck;
            if keyisdown==1
                % monitor validation & exit
                if  keycode(key.space)==1
                    exit=1;
                    confidence_confirmation_time(iTrial) = GetSecs - startime;
                elseif keycode(key.escape)==1
                    exit=1;
                    interrupt_task=1;
                else
                    % monitor rating time
                    if isnan(confidence_response_time(iTrial))
                        confidence_response_time(iTrial) = GetSecs - startime;
                    end
                    if  keycode(key.right)==1
                        cursor{iTrial}(iCursor)=min([cursor{iTrial}(iCursor)+1 100]);
                    elseif keycode(key.left)==1
                        cursor{iTrial}(iCursor)=max([cursor{iTrial}(iCursor)-1 0]);
                    end
                end
            end
            
            [xMouse,yMouse,buttons] = recordResponse(display.window);
            xcursor = (xMouse - xScaleLim(1))/diff(xScaleLim)*100;
            xcursor = round(max([min([xcursor,100]),0]));
            cursor{iTrial}(iCursor) = xcursor ;
            % monitor rating time
            if isnan(confidence_response_time(iTrial)) && cursor{iTrial}(iCursor)~=cursor{iTrial}(1)
                confidence_response_time(iTrial) = GetSecs - startime;
            end
            % monitor confirmation
            exit = any(buttons~=0) & (yMouse>=y);
            confidence_confirmation_time(iTrial) = GetSecs - startime;
            WaitSecs(0.007);
        end
        
        % Update data to save
        confidence(iTrial)=cursor{iTrial}(iCursor);
        Screen('DrawTexture',display.window,pic_inc{incentiveLevel(iTrial),1},[],rect_inc{incentiveLevel(iTrial)});
        draw_scale_instruction_2(display.window,x,y,question_name,answer_names);
        display_rating_likert(display.window,x,y,confidence(iTrial)) ;
        Screen('DrawTexture',display.window,stim_fb_negative,[],rect_confidence_low);
        Screen('DrawTexture',display.window,stim_fb_positive,[],rect_confidence_high);
        Screen(display.window,'Flip');
        WaitSecs(1);
    end
    
    % Display Effort scale
    i=0; peak = 0; stop = 0; tForce = [];dtForce=0; correctTime = 1;
    tstart=GetSecs;
    while stop == 0
        
        % record force
        i=i+1;
        [grip,Tgrip]=readGrip(Handle);
        gripdata.grip{iTrial}(i)=grip;
        gripdata.time{iTrial}(i)=Tgrip;
        level=max(0,grip/calibratedForce*100);
        peak = nanmax([peak,level]);
        
        % display online force feedback
        Screen('DrawTexture',display.window,pic_inc{incentiveLevel(iTrial),1},[],rect_inc{incentiveLevel(iTrial)});
        textstring = 'Serrez maintenant!';
        DrawMyText(display.window,textstring,50,[255 255 255],[x,y*1/5]);
        if online_fb(iTrial)
            display_effortTarget_precision(display.window,x,y,level,targetLevel,target_range(iTrial));
        end
        Screen(display.window,'Flip');
        
        % stop criterion
        if peak>forceOnsetCriterion*100
            tForce = [ tForce , GetSecs];
            dtForce = tForce(end) - tForce(1);
        end
        if dtForce > responseduration
            stop = 1;
            if level>forceOnsetCriterion*100
                correctTime = 0;
            end
        end
    end
    
    % refresh screen
    Screen(display.window,'Flip');
    WaitSecs(0.6);
    
    % Data to save
    force(iTrial) = nanmax(gripdata.grip{iTrial});
    force_error(iTrial) = (force(iTrial)/calibratedForce) - targetLevel;
    accuracy_force(iTrial) = abs(force_error(iTrial));
    correct_force(iTrial) = 1 - double( accuracy_force(iTrial)> (target_range(iTrial)/2) );
    correct_time(iTrial)=correctTime;
    %              correct(ntrial) = double(correct_force(ntrial) & correct_time(ntrial));
    correct(iTrial) = double(correct_force(iTrial));
    gain(iTrial) = correct(iTrial)*incentive(iTrial);
    previoustotal=total;
    total=total+gain(iTrial);
    
    % offline feedback
    if offline_fb(iTrial)
        fontsize = 50;
        if force_error(iTrial) >= ( forceOutlierCriterion - targetLevel )
            feedbackValidity(iTrial) = 1;
            feedback(iTrial) = -1;
            textstring = 'Dommage, Echec!';
            DrawMyText(display.window,textstring,fontsize,[255 0 0],[x,y]);
            textstring = double([ ' Gains: 0 €'  ]);
            DrawMyText(display.window,textstring,fontsize,[255 0 0],[x,y*1.2]);
            Screen('DrawTexture',display.window,stim_fb_negative,[],rect_fb);
            
        else
            if feedback(iTrial) == +1
                textstring = 'Bravo, Réussite!';
                DrawMyText(display.window,textstring,fontsize,[0 255 0],[x,y]);
                textstring = double([ ' Gains: ' num2str(incentive(iTrial)) ' €'  ]);
                DrawMyText(display.window,textstring,fontsize,[0 255 0],[x,y*1.2]);
                Screen('DrawTexture',display.window,stim_fb_positive,[],rect_fb);
            else
                textstring = 'Dommage, Echec!';
                DrawMyText(display.window,textstring,fontsize,[255 0 0],[x,y]);
                textstring = double([ ' Gains: 0 €'  ]);
                DrawMyText(display.window,textstring,fontsize,[255 0 0],[x,y*1.2]);
                Screen('DrawTexture',display.window,stim_fb_negative,[],rect_fb);
            end
        end
        
        
        %                  display_effortTarget_precision(display.window,x,y,peak,targetLevel,trainingRange);
    end
    Screen(display.window,'Flip');
    WaitSecs(feedbackduration);
    
    % confidence rating
    if mood_rating(iTrial)
        
        %  Check Response
        wait4release()
        exit=0;onset=0;iCursor = 1;
        cursor{iTrial}(iCursor) = 50;
        startime=GetSecs;
        while exit==0
            
            % Write instructions
            question_name = 'Comment je me sens?';
            answer_names = {'mauvaise humeur','bonne humeur'};
            draw_scale_instruction_2(display.window,x,y,question_name,answer_names);
            Screen('DrawTexture',display.window,emoji_neutral,[],rect_emoji_neutral);
            Screen('DrawTexture',display.window,emoji_infinite,[],rect_emoji_infinite);
            
            % Display cursor and scale
            display_rating_likert(display.window,x,y,[]);
            Screen(display.window,'Flip');
            iCursor = iCursor + 1;
            cursor{iTrial}(iCursor) = cursor{iTrial}(iCursor-1);
            % Check keys
            [keyisdown, ~, keycode] = KbCheck;
            if keyisdown==1
                % monitor validation & exit
                if  keycode(key.space)==1
                    exit=1;
                    mood_confirmation_time(iTrial) = GetSecs - startime;
                elseif keycode(key.escape)==1
                    exit=1;
                    interrupt_task=1;
                else
                    % monitor rating time
                    if isnan(mood_response_time(iTrial))
                        mood_response_time(iTrial) = GetSecs - startime;
                    end
                    if  keycode(key.right)==1
                        cursor{iTrial}(iCursor)=min([cursor{iTrial}(iCursor)+1 100]);
                    elseif keycode(key.left)==1
                        cursor{iTrial}(iCursor)=max([cursor{iTrial}(iCursor)-1 0]);
                    end
                end
            end
            [xMouse,yMouse,buttons] = recordResponse(display.window);
            xcursor = (xMouse - xScaleLim(1))/diff(xScaleLim)*100;
            xcursor = round(max([min([xcursor,100]),0]));
            cursor{iTrial}(iCursor) = xcursor ;
            % monitor rating time
            if isnan(mood_response_time(iTrial)) && cursor{iTrial}(iCursor)~=cursor{iTrial}(1)
                mood_response_time(iTrial) = GetSecs - startime;
            end
            % monitor confirmation
            exit = any(buttons~=0) & (yMouse>=y);
            mood_confirmation_time(iTrial) = GetSecs - startime;
            WaitSecs(0.007);
        end
        
        % Update data to save
        mood(iTrial)=cursor{iTrial}(iCursor);
            draw_scale_instruction_2(display.window,x,y,question_name,answer_names);
            display_rating_likert(display.window,x,y,mood(iTrial)) ;
            Screen('DrawTexture',display.window,emoji_neutral,[],rect_emoji_neutral);
            Screen('DrawTexture',display.window,emoji_infinite,[],rect_emoji_infinite);
        Screen(display.window,'Flip');
        WaitSecs(1);
    end
    
    if recalibration(iTrial)
        
        % instructions
        textstring = 'Entraînement' ;
        DrawMyText(display.window,textstring,50,[255 255 255],[x,y]);
        Screen(display.window,'Flip');
        WaitSecs(1);
        
        clear calibration_gripdata
        
        for iCalibration =1:nTrialPerCalibration
            % inter-trial phase
            Screen(display.window,'Flip');
            WaitSecs(1);
            
            % Display Effort scale
            i=0; peak = 0; stop = 0; tForce = [];dtForce=0; correctTime = 1;
%             tstart=GetSecs;
            while stop == 0
                
                % record force
                i=i+1;
                [grip,Tgrip]=readGrip(Handle);
                calibration_gripdata.grip{iCalibration}(i)=grip;
                calibration_gripdata.time{iCalibration}(i)=Tgrip;
                level=max(0,grip/calibratedForce*100);
                peak = nanmax([peak,level]);
                
                % display online force feedback
                textstring = 'Serrez maintenant!';
                DrawMyText(display.window,textstring,50,[255 255 255],[x,y*1/5]);
                Screen(display.window,'Flip');
                
                % stop criterion
                if peak>forceOnsetCriterion*100
                    tForce = [ tForce , GetSecs];
                    dtForce = tForce(end) - tForce(1);
                end
                if dtForce > responseduration
                    stop = 1;
                    if level>forceOnsetCriterion*100
                        correctTime = 0;
                    end
                end
                
                
            end
            
            % refresh screen
            Screen(display.window,'Flip');
            WaitSecs(0.6);
            
            % Data to save
            calibration_force(iCalibration) = nanmax(calibration_gripdata.grip{iCalibration});
            calibration_force_error(iCalibration) = (calibration_force(iCalibration)/calibratedForce) - targetLevel;
            calibration_accuracy_force(iCalibration) = abs(calibration_force_error(iCalibration));
            calibration_correct_force(iCalibration) = 1 - double( calibration_accuracy_force(iCalibration) > (target_range(1)/2) );
            calibration_correct_time(iCalibration)=correctTime;
            %                      calibration_correct(ntrial) = double(calibration_correct_force(ntrial) & calibration_correct_time(ntrial));
            calibration_correct(iCalibration) = double(calibration_correct_force(iCalibration)); % only amplitude-criterion for accuracy
            
            
            % offline feedback
            fontsize = 50;
            if calibration_correct(iCalibration)
                textstring = 'Réussite!';
                DrawMyText(display.window,textstring,fontsize,[0 255 0],[x*3/2,y]);
            else
                textstring = 'Echec!';
                if calibration_force_error(iCalibration)>0
                    textstring = [ textstring , ' trop fort...' ];
                else
                    textstring = [ textstring , ' trop faible...' ];
                end
                DrawMyText(display.window,textstring,fontsize,[255 0 0],[x*3/2,y]);
            end
            display_effortTarget_precision(display.window,x,y,peak,targetLevel,target_range(1));
            Screen(display.window,'Flip');
            WaitSecs(feedbackduration);
            
            
        end
    end
    
end

% display end
Screen(display.window,'Flip');
Screen('CloseAll');

% terminate all recording
Screen('CloseAll');
switch sub_data.grip.gripdevice
    case 'vernier'
        Handle.stop();
    case 'mie'
        CloseGripDevice('MIE',Handle);
end

%% Data saving
%-----------------------------------------------
varNames      = {'trialNumber', 'perf', 'gain', 'feedback', 'time', 'effortTime', 'feedbackTime',...
    'jitter','force','forceError','accuracyForce','correctForce','correctTime'};
training_data          = table((1:nTraining)',trainingperf',traininggain',trainingfeedback',trainingtime',trainingefforttime',trainingfeedbacktime',trainingjitter',...
        training_force',training_force_error',training_accuracy_force',training_correct_force',training_correct_time', 'VariableNames', varNames);
    
varNames      = {'trialNumber', 'blockNumber', 'incentive', 'feedbackBias', 'feedbackValidity', 'feedback', 'force', 'forceError',...
    'accuracyForce', 'correctForce', 'correctTime', 'correct', 'gain', 'confidence', 'confidenceRT', 'confidenceConfirmationTime',...
    'mood', 'moodRT', 'moodConfirmationTime', 'jitter'};
data          = table((1:nTrial)',blockNumber',incentive',feedbackBias',feedbackValidity',feedback',force',force_error',...
        accuracy_force',correct_force',correct_time',correct',gain',...
        confidence',confidence_response_time',confidence_confirmation_time',...
        mood',mood_response_time',mood_confirmation_time',jitter', 'VariableNames', varNames);
    
varNames  = {'grip', 'time'};
tableSupp = table(gripdata.grip', gripdata.time', 'VariableNames', varNames);

% saving
sub_data.(cfg.sessNber_str).tasks.taskConfidencePrecision.results = struct('tableTrialTraining',training_data ,'data', data, 'suppResults', tableSupp);

end