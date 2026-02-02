function [sub_data] = taskChoice_GripEffort_V2020(sub_data, cfg)
% function [sub_data] = taskChoice_GripEffort_V2(sub_data, cfg)
%
% taskChoice_GripEffort - execute the effort-money choice task (from
% motiscan battery)
% Launch the task with this function for testing one subject.
% The subject has to choose between 2 options his prefered one.
% Each option is formulated as a monetary gain to obtain if the subject
% executes a certain force
%
% Modified version of 2020 :
% Grid from 1 to 19.9 euros for a small force (5% FME)
% versus 50 euros (always) for a big force (30, 45, 60, 75% FME)
%
% In this version, the subject has to execute some of the choices
%
% Modified for V2, march 2020, C. JAFFRE and P. CARRILLO

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

gripdevice  = cfg.grip.gripdevice;
Handle      = cfg.grip.Handle;
readGrip    = cfg.grip.readGrip;

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

%% Experiment preparation
% ----------------------------------------------
% fontsize
if isfield(cfg.ptb,mfilename)
    ftsz_iTask = cfg.ptb.fontsize.(mfilename);
else;   ftsz_iTask = cfg.ptb.fontsize.global;
end
ftsz_big    = ftsz_iTask.ftsz_big;
ftsz_mid    = ftsz_iTask.ftsz_mid;
ftsz_small  = ftsz_iTask.ftsz_small;
% maxCharPline_instruc = ftsz_iTask.maxCharPline_instruc;
maxCharPline_instruc = 70;
% max_charPline = ftsz_iTask.max_charPline;
max_charPline = 50;

cd(cfg.paths.task.images); % enter img dir

cross=Screen('MakeTexture',display.window,imread('Cross.bmp'));
rectcross=CenterRectOnPoint(Screen('Rect',cross),x,y);

for i=1:6
    pic_inc{i}=Screen('MakeTexture',display.window,imread(['pic_inc_' num2str(i) '.bmp']));
    [wrect{i},hrect{i}] = RectSize(Screen('Rect',pic_inc{i}));
    rectL_inc{i}=CenterRectOnPoint(Screen('Rect',pic_inc{i}),x-300,y-250);
    rectR_inc{i}=CenterRectOnPoint(Screen('Rect',pic_inc{i}),x+300,y-250);
end

% instructions images
% instruction = struct('texture',{},'position',{});
% for i=1:2
%     instruction(i).texture = Screen('MakeTexture',display.window,imread(['instruction_GripRP_' num2str(i) '.bmp']));
% end

cd(cfg.paths.task.code) % returning to code

% Experimental conditions
% __________________________________________________________________________
nRealPerf           = 2; % number of real performance trials
listSmallForce      = 5; % always 5%
listSmallForceLabel = {'5%'};
listHighForce       = [30, 45, 60, 75]; % In percentage
listHighForceLabel  = {'30%', '45%', '60%', '75%'};
nHighForce          = length(listHighForce);

listSmallForceAmount = [0.1 1 3 6 10 13 16 17 18 19 19.5 19.9];  % in euros
listHighForceAmount  = 20; % in euros
nSmallForceAmount    = length(listSmallForceAmount);

% Define trial table
temp = CombVec(1:nSmallForceAmount, 1:nHighForce)';
nTrial = length(temp);
crit = Inf;
while crit > 3.1 % Shuffle such that there is no correlation between time and conditions
    temp(:, 3) = Shuffle(1:nTrial);
    crit = sum(sum(abs(corr(temp))));
end
temp(:, 4) = 1:nTrial;
temp = sortrows(temp, 3);

% Make table
iTrial = (1:nTrial)';
tableTrial = table(iTrial);
tableTrial.orderTrial(:, 1) = temp(:, 4);
tableTrial.smallForceLevel = ones(nTrial, 1);
tableTrial.highForceLevel = temp(:, 2);
tableTrial.smallForceAmountLevel = temp(:, 1);
tableTrial.highForceAmountLevel = ones(nTrial, 1);
tableTrial.smallForce =  listSmallForce(tableTrial.smallForceLevel);
tableTrial.highForce =  listHighForce(tableTrial.highForceLevel)';
tableTrial.smallForceAmount =  listSmallForceAmount(tableTrial.smallForceAmountLevel)';
tableTrial.highForceAmount  =  listHighForceAmount(tableTrial.highForceAmountLevel);
tableTrial.smallForceLabel =  listSmallForceLabel(tableTrial.smallForceLevel);
tableTrial.highForceLabel  =  listHighForceLabel(tableTrial.highForceLevel)';
tableTrial.sideHighForce = zeros(nTrial, 1); % 1 = left ; 0 = right
% Random assignment of nRealPerf performance trials
perfTrial = datasample(1:1:48, nRealPerf, 'Replace', false);
tableTrial.doPerf = ismember(tableTrial.iTrial, perfTrial);

%Define trial table for training choices
tableTrialTrainingChoice = tableTrial(1:2, :);
tableTrialTrainingChoice.orderTrial = (1:2)';
tableTrialTrainingChoice.highForceLevel = [1 max(tableTrial.highForceLevel)]';
tableTrialTrainingChoice.smallForceAmountLevel = [1 max(tableTrial.smallForceAmountLevel)]';
tableTrialTrainingChoice.smallForce =  listSmallForce(tableTrialTrainingChoice.smallForceLevel);
tableTrialTrainingChoice.highForce  =  listHighForce(tableTrialTrainingChoice.highForceLevel)';
tableTrialTrainingChoice.smallForceAmount =  listSmallForceAmount(tableTrialTrainingChoice.smallForceAmountLevel)';
tableTrialTrainingChoice.highForceAmount  =  listHighForceAmount(tableTrialTrainingChoice.highForceAmountLevel);
tableTrialTrainingChoice.smallForceLabel =  listSmallForceLabel(tableTrialTrainingChoice.smallForceLevel);
tableTrialTrainingChoice.highForceLabel  =  listHighForceLabel (tableTrialTrainingChoice.highForceLevel)';
tableTrialTrainingChoice.sideHighForce = zeros(height(tableTrialTrainingChoice), 1); % 1 = left ; 0 = right
nTrainingChoices = height(tableTrialTrainingChoice);

%Define trial table for training performance
iTrial = (1:4)';
tableTrialTrainingPerf = table(iTrial);
tableTrialTrainingPerf.highForceLevel = unique(tableTrial.highForceLevel);
tableTrialTrainingPerf.highForce  =  unique(tableTrial.highForce);
tableTrialTrainingPerf = repmat(tableTrialTrainingPerf,2,1);
nTrainingPerf = height(tableTrialTrainingPerf);

% Supplementary results
choicePositions   = cell(nTrial, 1);
tableSupp = table(choicePositions);

% time variables
ITI_duration = 0.5;
forceDuration = 0.1; % duration of force exertion (seconds)
targetStopCriterion = 2/3; % threshold to cross to stop trial (in% of target force level)
blanktime = 0.5;
ITI_jitter = 0.5;
waitAft_bigTtl = 0.2;
waitAft_instruc = 0.5;
waitAft_choice2do = 1;
waitAft_trial = 0.007;
maxResponseDuration = 10e3;

% Starting parameters
calibratedForce = cfg.grip.hand_used.(cfg.grip.hand_used.to_use).calibratedFmax * 1.2;

%% Calibration
% ----------------------------------------------
% device calibration
%[readGrip] = grip_tare(cfg);
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

%% Training Handgrip Performance
%-----------------------------------------------
% Handgrip training
%-----------------------------------------------
% display
DrawMyText(display.window,text.gripTraining,ftsz_big,[255 255 255],[x,y]);
DrawMyText(display.window,text.instrucTraining,ftsz_small,[255 255 255],[x,H*3/5],maxCharPline_instruc);
DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(waitAft_bigTtl);
KbWait;

% Trial structure
%-----------------------------------------------
for iTrial = 1:nTrainingPerf
    %% Execution Phase
    % Display choosen effort
    i=0;
    stop = 0;
    onset = 0; offset = 0;
    iTimeCounter=0;
    
    while offset == 0
        % monitor grip
        i=i+1;
        [actualForce,Tgrip]=readGrip(Handle);
        tempStruct.forces{iTrial}(i)=actualForce;
        tempStruct.times{iTrial}(i)=Tgrip;
        level = max(0,actualForce/calibratedForce*100);
        
        % display  option
        display_ED(display.window,x,y,tableTrialTrainingPerf.highForce(iTrial),level);
        
        % onset criterion
        if stop==0 && level>=tableTrialTrainingPerf.highForce(iTrial)
            % detect & count time
            onset = 1;
            if iTimeCounter==0
                tableTrialTrainingPerf.effortTime(iTrial)=GetSecs;
            end
            iTimeCounter = iTimeCounter + (GetSecs-forceTime);
        end
        forceTime = GetSecs;
        
        % offset criterion
        if onset == 1
            if iTimeCounter >= forceDuration
                stop = 1;
                textstring = 'OK !';
                DrawMyText(display.window,textstring,ftsz_mid,[0 255 0],[x,y*2/5]);
            end
            
            if stop && level<targetStopCriterion*tableTrialTrainingPerf.highForce(iTrial) % force onset & offset criterion
                offset = 1;
            end
        end
        % refresh screen
        Screen(display.window,'Flip');
    end
    
    
    %% Data to save
    tableTrialTrainingPerf.maxForce(iTrial)=max(tempStruct.forces{iTrial});
    tableTrialTrainingPerf.sumForce(iTrial)=sum(tempStruct.forces{iTrial});
    WaitSecs(ITI_duration);
    
end

%% Choice phase
% -----------------------------------------------
% Training choice
% -----------------------------------------------
DrawMyText(display.window,text.instruc,ftsz_big,[255 255 255],[x,y]);
DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(waitAft_instruc);
KbWait;

% instruction: explanations
% - slide 1
Screen('TextSize', display.window, ftsz_small);
DrawFormattedText(display.window,text.instrucText1,'center','center',[255 255 255],maxCharPline_instruc, 0, 0, 2, 0, []);
Screen(display.window,'Flip');
WaitSecs(waitAft_instruc);
KbWait;
% - slide 2
Screen('TextSize', display.window, ftsz_small);
DrawFormattedText(display.window,text.instrucText2,'center','center',   ...
    [255 255 255],maxCharPline_instruc, 0, 0, 2, 0, []);
Screen(display.window,'Flip');
WaitSecs(waitAft_instruc);
KbWait;
% - slide 3
Screen('TextSize', display.window, ftsz_small);
DrawFormattedText(display.window,text.instrucText3,'center','center',   ...
    [255 255 255],maxCharPline_instruc, 0, 0, 2, 0, []);
Screen(display.window,'Flip');
WaitSecs(waitAft_instruc);
KbWait;
% display
DrawMyText(display.window,text.choiceTraining,ftsz_big,[255 255 255],   ...
    [x,y],maxCharPline_instruc);
%textstring = 'Vous allez réaliser deux choix pour vous entrainer.';
%DrawMyText(display.window,textstring,ftsz_small,[255 255 255],[x,H*3/5],maxCharPline_instruc);
DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(waitAft_bigTtl);
KbWait;
wait4release()

% Trial structure
%----------------------------------------------
interrupt_task = false;
for iTrial = 1:nTrainingChoices
    
    % inter-trial
    Screen('DrawTexture',display.window,cross,[],rectcross);
    KbReleaseWait;
    Screen(display.window,'Flip');
    WaitSecs(ITI_duration);
    wait4release()
    buttons = 0;
    
    % instruction
    DrawMyText(display.window,text.quePref,ftsz_small,[100 100 100],[x,y*2/5]);
    
    % Display small option
    smallRewardText = double(sprintf(' %.2f  € \n',tableTrialTrainingChoice.smallForceAmount(iTrial)));
    DrawMyText(display.window,smallRewardText,ftsz_mid,[255 255 255],[(tableTrialTrainingChoice.sideHighForce(iTrial)+0.5)*x,y-200]);
    display_ED(display.window,(tableTrialTrainingChoice.sideHighForce(iTrial)+0.5)*x,y,tableTrialTrainingChoice.smallForce(iTrial),0);
    
    % Display big option
    bigRewardText = double(sprintf(' %.2f  € \n',tableTrialTrainingChoice.highForceAmount(iTrial)));
    DrawMyText(display.window,bigRewardText,ftsz_mid,[255 255 255],[(-(tableTrialTrainingChoice.sideHighForce(iTrial)-1)+0.5)*x,y-200]);
    display_ED(display.window,(-(tableTrialTrainingChoice.sideHighForce(iTrial)-1)+0.5)*x,y,tableTrialTrainingChoice.highForce(iTrial),0);
    
    tableTrialTrainingChoice.trialTime(iTrial)=Screen(display.window,'Flip');
    
    exit=0;
    while exit==0 && ~interrupt_task
        % Record Response
        [keyisdown, ~, keycode] = KbCheck;
        if keyisdown == 1
            % monitor validation & exit
            if keycode(key.escape) == 1
                exit=1;
                interrupt_task = 1;
                break
                
            else
                if  keycode(key.left)==1
                    exit=1;
                    tableTrialTrainingChoice.isLeftChoice(iTrial)=1;
                    tableTrialTrainingChoice.choiceTime(iTrial) = GetSecs ;
                elseif keycode(key.right)==1
                    exit=1;
                    tableTrialTrainingChoice.isLeftChoice(iTrial)=0;
                    tableTrialTrainingChoice.choiceTime(iTrial) = GetSecs ;
                end
            end
        end
        
        [xMouse,~,buttons] = recordResponse(display.window);
        if buttons(1)~=0
            tableTrialTrainingChoice.choiceTime(iTrial) = GetSecs ;
            tableTrialTrainingChoice.isLeftChoice(iTrial) = sign(x-xMouse);
            if tableTrialTrainingChoice.isLeftChoice(iTrial) ==-1; tableTrialTrainingChoice.isLeftChoice(iTrial) =0; end
            exit=1;
        end
    end
    
    if interrupt_task; break; end
    
    tableTrialTrainingChoice.isHardChoice(iTrial) = tableTrialTrainingChoice.isLeftChoice(iTrial) == tableTrialTrainingChoice.sideHighForce(iTrial);
    WaitSecs(waitAft_trial);
    
    %% Display answer
    DrawMyText(display.window,text.quePref,ftsz_small,[100 100 100],[x,y*2/5]);
    
    % Display small option
    smallRewardText = double(sprintf(' %.2f  € \n',tableTrialTrainingChoice.smallForceAmount(iTrial)));
    DrawMyText(display.window,smallRewardText,ftsz_mid,[255 255 255],[(tableTrialTrainingChoice.sideHighForce(iTrial)+0.5)*x,y-200]);
    display_ED(display.window,(tableTrialTrainingChoice.sideHighForce(iTrial)+0.5)*x,y,tableTrialTrainingChoice.smallForce(iTrial),0);
    
    % Display big option
    bigRewardText = double(sprintf(' %.2f  € \n',tableTrialTrainingChoice.highForceAmount(iTrial)));
    DrawMyText(display.window,bigRewardText,ftsz_mid,[255 255 255],[(-(tableTrialTrainingChoice.sideHighForce(iTrial)-1)+0.5)*x,y-200]);
    display_ED(display.window,(-(tableTrialTrainingChoice.sideHighForce(iTrial)-1)+0.5)*x,y,tableTrialTrainingChoice.highForce(iTrial),0);
    
    if tableTrialTrainingChoice.isLeftChoice(iTrial)
        Screen('FrameRect', display.window,[255 255 255],[0.2*x y*0.5 0.8*x y*1.8],8);
    else
        Screen('FrameRect', display.window,[255 255 255],[1.2*x y*0.5 1.8*x y*1.8],8);
    end
    
    Screen(display.window,'Flip');
    WaitSecs(blanktime);
end

% Testing
%-----------------------------------------------
% instructions:  start
interrupt_task = false;

DrawMyText(display.window,text.pretDebut,ftsz_big,[255 255 255],[x,y]);
DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(waitAft_bigTtl);
KbWait;
wait4release()

% Trial structure
%-----------------------------------------------
for iTrial=1:nTrial
    
    % inter-trial
    Screen('DrawTexture',display.window,cross,[],rectcross);
    KbReleaseWait;
    Screen(display.window,'Flip');
    WaitSecs(ITI_duration);
    wait4release()
    buttons =0;
    
    % instruction
    DrawMyText(display.window,text.quePref,ftsz_small,[100 100 100],[x,y*2/5]);
    
    % Display small option
    smallRewardText = double(sprintf(' %.2f  € \n',tableTrial.smallForceAmount(iTrial)));
    DrawMyText(display.window,smallRewardText,ftsz_mid,[255 255 255],[(tableTrial.sideHighForce(iTrial)+0.5)*x,y-200]);
    display_ED(display.window,(tableTrial.sideHighForce(iTrial)+0.5)*x,y,tableTrial.smallForce(iTrial),0);
    
    % Display big option
    bigRewardText = double(sprintf(' %.2f  € \n',tableTrial.highForceAmount(iTrial)));
    DrawMyText(display.window,bigRewardText,ftsz_mid,[255 255 255],[(-(tableTrial.sideHighForce(iTrial)-1)+0.5)*x,y-200]);
    display_ED(display.window,(-(tableTrial.sideHighForce(iTrial)-1)+0.5)*x,y,tableTrial.highForce(iTrial),0);
    
    tableTrial.trialTime(iTrial)=Screen(display.window,'Flip');
    
    exit=0;
    while exit==0 && ~interrupt_task
        % Record Response
        [keyisdown, ~, keycode] = KbCheck;
        if keyisdown==1
            % monitor validation & exit
            if keycode(key.escape)==1
                exit=1;
                interrupt_task = true;
                break
            else
                if  keycode(key.left)==1
                    exit=1;
                    tableTrial.isLeftChoice(iTrial)=1;
                    tableTrial.choiceTime(iTrial) = GetSecs ;
                elseif keycode(key.right)==1
                    exit=1;
                    tableTrial.isLeftChoice(iTrial)=0;
                    tableTrial.choiceTime(iTrial) = GetSecs ;
                    
                end
            end
        end
        [xMouse,yMouse,buttons] = recordResponse(display.window);
        if buttons(1)~=0
            tableTrial.choiceTime(iTrial) = GetSecs ;
            tableTrial.isLeftChoice(iTrial) = sign(x-xMouse);
            if tableTrial.isLeftChoice(iTrial) ==-1; tableTrial.isLeftChoice(iTrial) =0; end
            tableSupp.choicePositions{iTrial} = [xMouse,yMouse];
            exit=1;
        end
    end
    if interrupt_task; break; end
    
    tableTrial.isHardChoice(iTrial) = tableTrial.isLeftChoice(iTrial) == tableTrial.sideHighForce(iTrial);
    
    %% Display answer
    % instruction
    DrawMyText(display.window,text.quePref,ftsz_small,[100 100 100],[x,y*2/5]);
    
    % Display small option
    smallRewardText = double(sprintf(' %.2f  € \n',tableTrial.smallForceAmount(iTrial)));
    DrawMyText(display.window,smallRewardText,ftsz_mid,[255 255 255],[(tableTrial.sideHighForce(iTrial)+0.5)*x,y-200]);
    display_ED(display.window,(tableTrial.sideHighForce(iTrial)+0.5)*x,y,tableTrial.smallForce(iTrial),0);
    
    % Display big option
    bigRewardText = double(sprintf(' %.2f  € \n',tableTrial.highForceAmount(iTrial)));
    DrawMyText(display.window,bigRewardText,ftsz_mid,[255 255 255],[(-(tableTrial.sideHighForce(iTrial)-1)+0.5)*x,y-200]);
    display_ED(display.window,(-(tableTrial.sideHighForce(iTrial)-1)+0.5)*x,y,tableTrial.highForce(iTrial),0);
    
    if tableTrial.isLeftChoice(iTrial)
        Screen('FrameRect', display.window,[255 255 255],[0.2*x y*0.5 0.8*x y*1.8],8);
    else
        Screen('FrameRect', display.window,[255 255 255],[1.2*x y*0.5 1.8*x y*1.8],8);
    end
    
    Screen(display.window,'Flip');
    WaitSecs(blanktime);
end

%% Execution Phase
if ~interrupt_task
    % - Instructions
    Screen('TextSize', display.window, ftsz_small);
    DrawFormattedText(display.window,text.doChoice1,'center','center',  ...
        [255 255 255], maxCharPline_instruc, 0, 0, 2, 0, []);
    DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,H*4/5]);
    Screen(display.window,'Flip');
    WaitSecs(waitAft_instruc);
    KbWait;
    
    % Instructions spécifiques
    Screen('TextSize', display.window, ftsz_mid);
    DrawFormattedText(display.window,text.doChoice2,'center','center',  ...
        [255 255 255],maxCharPline_instruc, 0, 0, 2, 0, []);
    DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,H*4/5]);
    Screen(display.window,'Flip');
    WaitSecs(waitAft_instruc);
    KbWait;
    wait4release()
    
    for iTrial = 1:nTrial
        
        if tableTrial.doPerf(iTrial)
            
            % instruction
            if tableTrial.isLeftChoice(iTrial) == tableTrial.sideHighForce(iTrial)
                chosenForce = tableTrial.highForce(iTrial);
            else
                chosenForce = tableTrial.smallForce(iTrial);
            end
            textstring = sprintf(text.doChoice3,chosenForce);
            DrawMyText(display.window,textstring,ftsz_small,[255 255 255],[x,y]);
            Screen(display.window,'Flip');
            WaitSecs(waitAft_choice2do);
            
            % Display choosen effort
            i=0; stop = 0;
            onset = 0; offset = 0;
            iTimeCounter=0;
            
            while offset == 0
                % monitor grip
                i=i+1;
                [actualForce,~]=readGrip(Handle);
                level=max(0,actualForce/calibratedForce*100);
                
                % display chosen option
                display_ED(display.window,x,y,chosenForce,level);
                
                % onset criterion
                if stop==0 && level>=chosenForce
                    % detect & count time
                    onset = 1;
                    if iTimeCounter==0
                        tableTrial.effortTime(iTrial)=GetSecs;
                    end
                    iTimeCounter = iTimeCounter + (GetSecs-forceTime);
                end
                forceTime = GetSecs;
                
                % offset criterion
                if onset == 1
                    if iTimeCounter>=forceDuration
                        stop = 1;
                        textstring = 'OK !';
                        DrawMyText(display.window,textstring,ftsz_mid,[0 255 0],[x,y*2/5]);
                    end
                    
                    if stop && level<targetStopCriterion*chosenForce % force onset & offset criterion
                        offset = 1;
                    end
                end
                
                % refresh screen
                Screen(display.window,'Flip');
            end
        end
    end
end

% display end
Screen(display.window,'Flip');
sca;

%grip_onoff(cfg,2);
switch gripdevice
    case 'vernier'
        Handle.stop();
    case 'mie'
        CloseGripDevice('MIE',Handle);
end

%% Data saving
%-----------------------------------------------
if interrupt_task
    sub_data.(cfg.sessNber_str).tasks.taskChoice_GripEffort.completed...
        = false;
else; sub_data.(cfg.sessNber_str).tasks.taskChoice_GripEffort.completed...
        = true;
end
sub_data.(cfg.sessNber_str).tasks.taskChoice_GripEffort.results =       ...
    struct('tableTrialTrainingChoice', tableTrialTrainingChoice,        ...
    'tableTrialTrainingPerf',tableTrialTrainingPerf, 'data',            ...
    tableTrial, 'suppResults', tableSupp);

end