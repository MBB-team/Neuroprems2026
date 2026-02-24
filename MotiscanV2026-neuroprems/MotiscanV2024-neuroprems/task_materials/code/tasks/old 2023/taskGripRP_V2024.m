function [sub_data] = taskGripRP_V2024(sub_data, cfg)
% function [sub_data] = taskGripRP_V2(sub_data, cfg)
%
% taskGripRP - execute the motivational force task (from motiscan battery)
% Launch the task with this function for testing one subject.
% The subject has to squeeze a handgrip dynamometer in order to accumulate
% as much money as possible.
%
%   task specifications:
%       - structure: instructions -> training -> testing
%       - experimental conditions: between-trials incentive(0.01,0.20,0.50,1,5,20 euros),
%         valence(gain). Loss is an option that needs to be activated be
%         uncomenting the first few lines of the script
%       - randomization: within-block random incentive, switching valence blocks
%       - ntrial = 120
%       - trial structure:
%       - calibration: estimate maximal voluntary force (3 trials) -> adapt
%         subject rettribution rule to maximal force (Outcome = incentive*force/(calibratedforce*1.2))
%       - training: exposure to all between-trials condition levels (6 trials)
%
% Input : sub_data and cfg structures
%
% Ouput : sub_data updated with results
%
% Author: Raphael Le Bouc, Nicolas Borderies
% email address: nico.borderies@gmail.com
% April 2014; Last revision: February 2017
%
% Updated for V2 march 2020, P. CARRILLO
% Updated for V2024 April 2024, A PAPASAVVA (reduced trials to 30)


%% Valence configuration
valenceconfig = 'R';
% valenceconfig = 'P';
% valenceconfig = 'RP';

%% Configuration
% -----------------------------------------------
cfg = motiscanV2020_setTask(cfg);

display  = cfg.ptb.display;
H        = display.H;
x        = display.x;
y        = display.y;

wait4release   = cfg.ptb.wait4release;
% recordResponse = cfg.ptb.recordResponse;

gripdevice  = cfg.grip.gripdevice;
Handle   = cfg.grip.Handle;
readGrip = cfg.grip.readGrip;

% recurring textstring
text.instruc = 'Instructions';
text.instrucText1 = ['Dans ce test, il vous est demandé de choisir '    ...
    'entre deux offres. Chaque offre est composée d''une somme '        ...
    'd''argent et d''un effort à réaliser pour l''obtenir.'];
text.instrucText2 = ['Sélectionnez simplement l''offre que vous préférez.'];
text.instrucText3 = ['Attention : à la fin de vos choix, certains '     ...
    'seront tirés au sort et vous devrez réaliser la force associée.'];
text.instrucText4 = ['Les choix sont terminés.\nCertains d''entre eux ' ...
    'ont été tirés au sort : vous devez les réaliser.'];

text.calibText1 = ['Avant de débuter, appuyer sur ''N'' et '...
    '''zero'' sur le boitier du grip'];
text.calibText2 = ['Avant de débuter, relacher complètement'...
    ' la poignée pour l''étalonnage.'];
text.calib = 'étalonnage...';

text.gripTraining = 'Entrainement au dynamomètre';
text.instrucTraining = ['Serrez pour dépasser l''objectif (barre '      ...
    'rouge) puis relachez.'];
text.choiceTraining = 'Entrainement aux choix';

text.doChoice1 = ['Les choix sont terminés.\nCertains d''entre eux ' ...
    'ont été tirés au sort : vous devez les réaliser.'];
text.doChoice2 = 'Réalisation de vos choix';
text.doChoice3 = 'Réalisation de l''effort, rappel : niveau choisi = %d %% \n';

text.appuyer = 'appuyer sur une touche pour continuer...';
text.quePref  = 'Que préférez-vous ?';
text.pretDebut = 'Prêt à débuter ?';
text.timesUp = 'Temps écoulé !';
text.faster = 'Répondez plus rapidement svp.';


% fontsize
if isfield(cfg.ptb,mfilename)
        ftsz_iTask = cfg.ptb.fontsize.(mfilename);
else;   ftsz_iTask = cfg.ptb.fontsize.global;
end
ftsz_big    = ftsz_iTask.ftsz_big;
ftsz_mid    = ftsz_iTask.ftsz_mid;
ftsz_small  = ftsz_iTask.ftsz_small;

max_charPline = 50;

%% Experiment preparation
% ----------------------------------------------
% Loads images and creates positions
%-----------------------------------------------
cd(cfg.paths.task.images); % enter img dir
% incentive icons
for i=1:6
    pic_inc{i,1}=Screen('MakeTexture',display.window,imread(['pic_inc_' num2str(i) '.bmp']));
    [wrect{i},hrect{i}] = RectSize(Screen('Rect',pic_inc{i}));
    rect_inc{i}=CenterRectOnPoint(Screen('Rect',pic_inc{i}),x-wrect{i}/2-300,y+hrect{i}/2-300);
    pic_inc{i,2}=Screen('MakeTexture',display.window,imread(['pic_inc_' num2str(i) 'neg.bmp']));
end

% instructions images
instruction = struct('texture',{},'position',{});
for i=1:7
    instruction(i).texture = Screen('MakeTexture',display.window,imread(['instruction_GripRP_' num2str(i) '.bmp']));
end

cd(cfg.paths.task.code) % returning to code

% Experimental conditions
%-----------------------------------------------
% Incentives

reward=[0.01 0.2 0.5 1 5 20];

% Trial vectors
nTraining       = 6;
training_inc    = randperm(6); % 1cents=1, 20cents=2, 50cents=3, 1euro=4, 5euros=5, 20euros=6
nTrialPerBlock = 6;

if strcmp(sub_data.study_name, 'motistroke')
    blocks      = 1:3;
    trialNumber = 1:numel(blocks)*nTrialPerBlock;
    valence     = ones(size(trialNumber)) ;
else
    blocks      = 1:4;
    trialNumber = 1:numel(blocks)*nTrialPerBlock;
    valence     = ones(size(trialNumber)) ;
end

task_inc=[];
for nblock = blocks
    cond=[];
    for i = 1:nTrialPerBlock/numel(reward)
        cond = [cond randperm(6)];
    end
    task_inc = [task_inc mod(cond-1,6)+1];   % 1cents=1, 20cents=2, 50cents=3, 1euro=4, 5euros=5, 20euros=6
end

responseduration   = 3;
feedbackduration   = 3.5;
jitmin             = 2;
jitmax             = 4;
% time variables
% ITI_duration = 0.5;
% forceDuration = 0.1; % duration of force exertion (seconds)
% targetStopCriterion = 2/3; % threshold to cross to stop trial (in% of target force level)
% blanktime = 0.5;
% ITI_jitter = 0.5;
% waitAft_bigTtl = 0.2;
waitAft_instruc = 0.5;
% waitAft_choice2do = 1;
% waitAft_trial = 0.007;
% maxResponseDuration = 10e3;

% Data preparation
%-----------------------------------------------
nInstruct        = 3;
instructforce    = nan(1,nInstruct);
instructsumforce = nan(1,nInstruct);
instructperf     = nan(1,nInstruct);
gripdatainstruct = {};

trainingtime         = nan(1,nTraining);
trainingefforttime   = nan(1,nTraining);
trainingforce        = nan(1,nTraining);
trainingsumforce     = nan(1,nTraining);
trainingperf         = nan(1,nTraining);
traininggain         = nan(1,nTraining);
trainingfeedbacktime = nan(1,nTraining);
trainingfeedback     = nan(1,nTraining);
trainingjitter       = rand(1,nTraining)*(jitmax-jitmin)+jitmin;             % incentive is displayed during the jitter : between 1 and 3 secondes
gripdatatraining     = {};

nTrial        = length(trialNumber);
disp(trialNumber)
trialtime    = nan(1,nTrial);
efforttime   = nan(1,nTrial);
force        = nan(1,nTrial);
sumforce     = nan(1,nTrial);
perf         = nan(1,nTrial);
gain         = nan(1,nTrial);
feedbacktime = nan(1,nTrial);
feedback     = nan(1,nTrial);
jitter       = rand(1,nTrial)*(jitmax-jitmin)+jitmin;                       % incentive is displayed during the jitter : between 1 and 3 secondes
gripdata     = {};

% Initialization
%-----------------------------------------------
% counters
total = 0;

%% Calibration
% ----------------------------------------------
calibratedForce = cfg.grip.hand_used.(cfg.grip.hand_used.to_use).calibratedFmax * 1.2;

% [readGrip] = grip_tare(cfg,1);
switch gripdevice
    case 'mie' % device reset
        % textstring = inputText_iScript{2}; % text:2
        DrawMyText(display.window,text.calibText1,ftsz_mid,[255 0 0],[x,y]);
        % textstring = inputText_iScript{1}; % text:1
        DrawMyText(display.window,text.appuyer,ftsz_small,[255 0 0],[x,1.5*y]);
        Screen(display.window,'Flip');
        WaitSecs(waitAft_instruc);
        KbWait;
        
    case 'vernier'
        try Handle.start();
        catch
            cfg.grip.Handle     = dynamometer;
            cfg.grip.readGrip   = @readVernier;
            Handle   = cfg.grip.Handle;
            readGrip = cfg.grip.readGrip;
            Handle.start();
        end
        % textstring = inputText_iScript{3}; % text:3
        % DrawMyText(display.window,textstring,ftsz_mid,[255 255 255],[2*x,y*1/2],40);
        Screen('TextSize', display.window, ftsz_mid);
        DrawFormattedText(display.window,text.calibText2,'center',      ...
            'center',[255 255 255],max_charPline, 0, 0, 2, 0, []);
        % textstring = inputText_iScript{1};  % text:1
        DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,1.5*y]);
        Screen(display.window,'Flip');
        WaitSecs(waitAft_instruc);
        KbWait;
        
        Screen('TextSize', display.window, ftsz_mid);
        DrawFormattedText(display.window,text.calib,'center','center',  ...
            [255 255 255],max_charPline, 0, 0, 2, 0, []);
        DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],...
            [x,1.5*y]);
        Screen(display.window,'Flip');
        WaitSecs(waitAft_instruc);
        KbWait;
        
        % calib on
        signal = [];
        rec = 1;
        while rec == 1
            grip = readGrip(Handle);
            signal = [signal,grip];
            rec = ~(KbCheck);
        end
        offset = nanmin(signal);
        readGrip = @(Handle) readVernier(Handle,offset);
        % calib done
end
%% Training
%-----------------------------------------------
% Handgrip training
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
i=3;
Screen('DrawTexture',display.window,instruction(i).texture);
Screen(display.window,'Flip');
WaitSecs(1);
KbWait;

target_name={'Exercez votre force maximale';'Exercez la moitié de votre force';'Exercez 10% de votre force'};

% Trial structure
%-----------------------------------------------
for example=1:3
    
    % Display instruction
    textstring = target_name{example};
    DrawMyText(display.window,textstring,ftsz_mid,[255 0 0],[x,y]);
    Screen(display.window,'Flip');
    WaitSecs(3);
    
    % Display Effort scale
    i=0;
    exampletime=GetSecs;
    while GetSecs<(exampletime+responseduration)
        i=i+1;
        [grip,Tgrip]=readGrip(Handle);
        gripdatainstruct.grip{example}(i)=grip;
        gripdatainstruct.time{example}(i)=Tgrip;
        level=max(0,grip/calibratedForce*100);
        display_Effort(display.window,x,y,level);
        Screen(display.window,'Flip');
    end
    % Data to save
    instructforce(example)=max(gripdatainstruct.grip{example});
    instructsumforce(example)=sum(gripdatainstruct.grip{example});
    instructperf(example)=instructforce(example)/calibratedForce*100;    
end

% Task training
%-----------------------------------------------
% display
textstring = 'Entrainement aux exercices';
DrawMyText(display.window,textstring,ftsz_big,[255 255 255],[x,y]);
textstring = 'appuyer sur une touche pour continuer';
DrawMyText(display.window,textstring,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(0.2);
KbWait;

% instruction: explanations
switch valenceconfig
    case 'RP'
        islides = 4:7;
    case 'R'
        islides = [4 5 7];
    case 'P'
        islides = [4 6 7];
end

for i = islides
    Screen('DrawTexture',display.window,instruction(i).texture);
    Screen(display.window,'Flip');
    WaitSecs(1);
    KbWait;
end

% Trial structure
%-----------------------------------------------
for ntrial=1:nTraining
    % display condition
    %% block change detection
    switch valenceconfig
        case 'RP'
            if mod(ntrial,3)==1
                blockcond=mod(ceil(ntrial/3),2)*2-1; %1=gain,-1=loss
                switch blockcond
                    case 1
                        blockstr='GAIN';
                    case -1
                        blockstr='PERTE';
                end
                Screen('TextSize', display.window, ftsz_big);
                [widthPret,hightPret]=RectSize(Screen('TextBounds',display.window,blockstr));
                Screen('DrawText',display.window,blockstr,x-widthPret/2,y-hightPret/2,[255 255 255]);
                Screen(display.window,'Flip');
                WaitSecs(5);
            end
        case 'R'
            blockcond = +1;
        case 'P'
            blockcond = -1;
    end
    
    %%% Display incentive
    Screen('DrawTexture',display.window,pic_inc{training_inc(ntrial), 3-(blockcond+3)/2},[],rect_inc{training_inc(ntrial)});
    trainingtime(ntrial)=Screen(display.window,'Flip');
    
    %%% waiting period
    WaitSecs(trainingjitter(ntrial));
    
    % start display
    i=0;
    trainingefforttime(ntrial)=GetSecs;
    
    % Monitor response
    while GetSecs<(trainingtime(ntrial)+trainingjitter(ntrial)+responseduration)
        i=i+1;
        [grip,Tgrip]=readGrip(Handle);
        gripdatatraining.grip{ntrial}(i)=grip;
        gripdatatraining.time{ntrial}(i)=Tgrip;
        level=max(0,grip/calibratedForce*100);
        Screen('DrawTexture',display.window,pic_inc{training_inc(ntrial), 3-(blockcond+3)/2},[],rect_inc{training_inc(ntrial)});
        display_Effort(display.window,x,y,level,reward(training_inc(ntrial)));
        Screen(display.window,'Flip');
    end
    
    % Data to save
    trainingforce(ntrial)=max(gripdatatraining.grip{ntrial});
    trainingsumforce(ntrial)=sum(gripdatatraining.grip{ntrial});
    trainingperf(ntrial)=trainingforce(ntrial)/calibratedForce*100;
    switch blockcond
        case 1
            traininggain(ntrial)=trainingperf(ntrial)/100*reward(training_inc(ntrial));
        case -1
            traininggain(ntrial)=(100-trainingperf(ntrial))/100*-reward(training_inc(ntrial));
            traininggain(ntrial)=traininggain(ntrial)*(traininggain(ntrial)<0);                    % in the loss condition, the best outcom is zero.
    end
    previoustotal=total;
    total=total+traininggain(ntrial);
    trainingfeedback(ntrial)=round(1000*total)/1000;
    
    % Display Feedback
    trainingfeedbacktime(ntrial)=GetSecs;
    display_FeedbackRP( display.window,blockcond, previoustotal, total, x, y )
    
    % waiting period
    WaitSecs(feedbackduration);
end

%% Testing
%-----------------------------------------------
total = 0;

% instructions:  start
textstring = 'Prêt à débuter ?';
DrawMyText(display.window,textstring,ftsz_big,[255 255 255],[x,y]);
textstring = 'appuyer sur une touche pour continuer';
DrawMyText(display.window,textstring,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(0.2);
KbWait;
wait4release()

% Trial structure
%-----------------------------------------------
for ntrial=1:nTrial
    
    % display condition
    %% block change detection
    switch valenceconfig
        case 'RP'
            if mod(ntrial,12)==1
                blockcond=mod(ceil(ntrial/12),2)*2-1; %1=gain,-1=loss
                switch blockcond
                    case 1
                        blockstr='GAIN';
                    case -1
                        blockstr='PERTE';
                end
                Screen('TextSize', display.window, ftsz_big);
                [widthPret,hightPret]=RectSize(Screen('TextBounds',display.window,blockstr));
                Screen('DrawText',display.window,blockstr,x-widthPret/2,y-hightPret/2,[255 255 255]);
                Screen(display.window,'Flip');
                WaitSecs(5);
            end
        case 'R'
            blockcond = +1;
        case 'P'
            blockcond = -1;
    end
    
    % Display incentive
    Screen('DrawTexture',display.window,pic_inc{task_inc(ntrial), 3-(blockcond+3)/2},[],rect_inc{task_inc(ntrial)});
    trialtime(ntrial)=Screen(display.window,'Flip');
    
    %%% waiting period
    WaitSecs(jitter(ntrial));
    
    % start display
    i=0;
    efforttime(ntrial)=GetSecs;
    
    % Monitor response
    while GetSecs<(trialtime(ntrial)+jitter(ntrial)+responseduration)
        i=i+1;
        [grip,Tgrip]=readGrip(Handle);
        gripdata.grip{ntrial}(i)=grip;
        gripdata.time{ntrial}(i)=Tgrip;
        level=max(0,grip/calibratedForce*100);
        Screen('DrawTexture',display.window,pic_inc{task_inc(ntrial), 3-(blockcond+3)/2},[],rect_inc{task_inc(ntrial)});
        display_Effort(display.window,x,y,level,reward(task_inc(ntrial)));
        Screen(display.window,'Flip');
    end
    
    % Data to save
    force(ntrial)=nanmax(gripdata.grip{ntrial});
    sumforce(ntrial)=sum(gripdata.grip{ntrial});
    perf(ntrial)=force(ntrial)/calibratedForce*100;
    switch blockcond
        case 1
            gain(ntrial)=perf(ntrial)/100*reward(task_inc(ntrial));
        case -1
            gain(ntrial)=(100-perf(ntrial))/100*-reward(task_inc(ntrial));
            gain(ntrial)=gain(ntrial)*(gain(ntrial)<0);                    % in the loss condition, the best outcom is zero.
    end
    previoustotal=total;
    total=total+gain(ntrial);
    feedback(ntrial)=round(1000*total)/1000;
    
    % Display Feedback
    feedbacktime(ntrial)=GetSecs;
    display_FeedbackRP( display.window, blockcond, previoustotal, total, x, y )
    
    % waiting period
    WaitSecs(feedbackduration);
end

%% Complementary testing: grip rating
%-----------------------------------------------
% display end
Screen(display.window,'Flip');
sca;
%[readGrip] = grip_tare(cfg,0);

%grip_onoff(cfg,2);
switch gripdevice
    case 'vernier'
        Handle.stop();
    case 'mie'
        CloseGripDevice('MIE',Handle);
end

%% Data saving
%-----------------------------------------------
varNames      = {'trialNumber', 'incentiveLevel', 'forcePeak', 'sumForce', 'calibratedForce', 'forcePercentage', 'gain', 'totalGain', 'incentiveTime', 'effortTime', 'feedbackTime', 'jitter'};
training_data = table((1:nTraining)',training_inc',trainingforce',trainingsumforce',repmat(calibratedForce,nTraining,1),trainingperf',traininggain',trainingfeedback',trainingtime',trainingefforttime',trainingfeedbacktime',trainingjitter', 'VariableNames', varNames);
varNames      = {'trialNumber', 'incentiveLevel', 'forcePeak', 'sumForce', 'calibratedForce', 'forcePercentage', 'gain', 'totalGain', 'incentiveTime', 'effortTime', 'feedbackTime', 'jitter'};
data          = table((1:nTrial)',(task_inc.*valence)',force',sumforce',repmat(calibratedForce,nTrial,1),perf',gain',feedback',trialtime',efforttime',feedbacktime',jitter', 'VariableNames', varNames);



% saving
sub_data.(cfg.sessNber_str).tasks.taskGripRP.results = struct('tableTrialTraining', training_data, 'data', data);
%[readGrip] = grip_tare(cfg,0);

end
