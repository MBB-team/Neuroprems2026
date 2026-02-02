function [sub_data] = taskChoice_MoneyDelay_V2020(sub_data, cfg)
% function [sub_data] = taskChoice_MoneyDelay_V2(sub_data, cfg)
%
% taskChoice_MoneyDelay - execute the delay-money choice task (from
% motiscan battery V2)
% Launch the task with this function for testing one subject.
% The subject has choose between 2 options his prefered one.
% Each option is formulated as a monetary gain to obtain in a certain
% delay.
%
% Modified version of 2020 :
% Grid from 1 to 19 euros for a short delay (today)
% versus 20 euros (always) for a long delay (1 day, 1 week, 1 month, 1
% year)
%
% Input : sub_data and cfg structures
%
% Output : modified sub_data with data and training data
%
% Modified march 2020, C. JAFFRE et P. CARRILLO

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

maxCharPline_instruc = 70;

% Load stimuli
%-----------------------------------------------
% informative icons
cd(cfg.paths.task.images)
cross=Screen('MakeTexture',display.window,imread('Cross.bmp'));
rectcross=CenterRectOnPoint(Screen('Rect',cross),x,y);
% instructions images
instruction = struct('texture',{},'position',{});
for i=1:1
    instruction(i).texture = Screen('MakeTexture',display.window,imread(['instruction_Choice' 'R' '.bmp']));
end
cd(cfg.paths.task.code); % exit img dir

% recurring textstring
text.instruc = 'Instructions';
text.instrucText1 = ['Dans ce test, il vous est demandé de choisir '    ...
    'entre deux offres. Chaque offre est composée d''une somme '        ...
    'd''argent et d''un délai à attendre pour l''obtenir. Par exemple ' ...
    ': « 20 euros dans 1 mois » ou bien « 10 euros maintenant ».\n\n'   ...
    'Sélectionnez simplement l''offre que vous préférez.'];
%text.instrucText2 = ;
text.training = 'Entrainement';
text.appuyer = 'appuyer sur une touche pour continuer...';
text.quePref  = 'Que préférez-vous ?';
text.pretDebut = 'Prêt à débuter ?';
text.timesUp = 'Temps écoulé !';
text.respFaster = 'Répondez plus rapidement svp.';

% Experimental conditions
%-----------------------------------------------
% Define list
listShortDelay = 0; % always immediate (today)
listShortDelayLabel = {'aujourd''hui'};
listLongDelay = [1, 7, 30, 365]; % In days
listLongDelayLabel = {'demain', 'dans une semaine', 'dans un mois', 'dans un an'};
nLongDelay = length(listLongDelay);

listShortDelayAmount = [0.1 1 3 6 10 13 16 17 18 19 19.5 19.9];  % in euros
listLongDelayAmount = 20; % in euros
nShortDelayAmount = length(listShortDelayAmount);

% Define trial table
temp = CombVec(1:nShortDelayAmount, 1:nLongDelay)';
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
orderTrial = temp(:, 4);
shortDelayLevel = ones(nTrial, 1);
longDelayLevel = temp(:, 2);
shortDelayAmountLevel = temp(:, 1);
longDelayAmountLevel = ones(nTrial, 1);
shortDelay =  listShortDelay(shortDelayLevel);
longDelay  =  listLongDelay(longDelayLevel)';
shortDelayAmount =  listShortDelayAmount(shortDelayAmountLevel)';
longDelayAmount  =  listLongDelayAmount(longDelayAmountLevel);
shortDelayLabel =  listShortDelayLabel(shortDelayLevel);
longDelayLabel  =  listLongDelayLabel(longDelayLevel)';
sideLongDelay = zeros(nTrial, 1); % 1 = left ; 0 = right

tableTrial = table(iTrial, orderTrial, shortDelayLevel, longDelayLevel, ...
    shortDelayAmountLevel, longDelayAmountLevel, shortDelay, longDelay,...
    shortDelayAmount, longDelayAmount, shortDelayLabel, longDelayLabel, sideLongDelay);

%Define trial table for training
tableTrialTrainingChoice = tableTrial(1:2, :);
tableTrialTrainingChoice.orderTrial = (1:2)';
tableTrialTrainingChoice.longDelayLevel = [1 max(tableTrial.longDelayLevel)]';
tableTrialTrainingChoice.shortDelayAmountLevel = [1 max(tableTrial.shortDelayAmountLevel)]';
tableTrialTrainingChoice.shortDelay =  listShortDelay(tableTrialTrainingChoice.shortDelayLevel);
tableTrialTrainingChoice.longDelay  =  listLongDelay(tableTrialTrainingChoice.longDelayLevel)';
tableTrialTrainingChoice.shortDelayAmount =  listShortDelayAmount(tableTrialTrainingChoice.shortDelayAmountLevel)';
tableTrialTrainingChoice.longDelayAmount  =  listLongDelayAmount(tableTrialTrainingChoice.longDelayAmountLevel);
tableTrialTrainingChoice.shortDelayLabel =  listShortDelayLabel(tableTrialTrainingChoice.shortDelayLevel);
tableTrialTrainingChoice.longDelayLabel  =  listLongDelayLabel(tableTrialTrainingChoice.longDelayLevel)';
tableTrialTrainingChoice.sideLongDelay = zeros(height(tableTrialTrainingChoice), 1); % 1 = left ; 0 = right

nTraining = height(tableTrialTrainingChoice);

% Supplementary results
choicePositions   = cell(nTrial, 1);
tableSupp = table(choicePositions);

% timing variables
blanktime = 0.4;
ITI_duration = 0.5;
waitAft_bigTtl = 0.2;
waitAft_instruc = 0.5;
waitAft_trial = 0.007;
maxResponseDuration=10e3;

%% Training
%-----------------------------------------------
DrawMyText(display.window,text.instruc,ftsz_big,[255 255 255],[x,y]);
DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(waitAft_bigTtl);
KbWait;

% instruction: explanations
% - slide 1
Screen('TextSize', display.window, ftsz_small);
DrawFormattedText(display.window,text.instrucText1,'center','center',   ...
    [255 255 255], maxCharPline_instruc, 0, 0, 2, 0, []);
Screen(display.window,'Flip');
WaitSecs(waitAft_instruc);
KbWait;
% - slide 2
% Screen('TextSize', display.window,ftsz_small);
% DrawFormattedText(display.window,text.instrucText2,'center','center',   ...
%     [255 255 255], maxCharPline_instruc, 0, 0, 2, 0, []);
% Screen(display.window,'Flip');
% WaitSecs(1);
% KbWait;

% display
DrawMyText(display.window,text.training,ftsz_big,[255 255 255],[x,y]);
%textstring = 'Vous allez réaliser deux choix pour vous entrainer';
%DrawMyText(display.window,textstring,ftsz_mid,[255 255 255],[x,H*3/5]);
DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(waitAft_bigTtl);
KbWait;

wait4release()

% Trial structure
%-----------------------------------------------
interrupt_task = false; iTrial = 0; repeat = 0;
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
    
    % Check Response
    exit=0;
    startime = GetSecs;
    isLeftChoice = NaN;
    buttons = 0;
    while exit==0
        
        % refresh screen
        DrawMyText(display.window,text.quePref,ftsz_small,[100 100 100],[x,y*2/5]);
        DrawMyText(display.window, double([ num2str(tableTrialTrainingChoice.shortDelayAmount(iTrial)) ' €' ]) ,ftsz_small,[255 255 255],[ (tableTrialTrainingChoice.sideLongDelay(iTrial)+0.5)*x,y*7/8]);
        DrawMyText(display.window, double([ num2str(tableTrialTrainingChoice.longDelayAmount(iTrial)) ' €' ]) ,ftsz_small,[255 255 255],[ (-(tableTrialTrainingChoice.sideLongDelay(iTrial)-1)+0.5)*x,y*7/8]);
        DrawMyText(display.window, tableTrialTrainingChoice.shortDelayLabel{iTrial},ftsz_small,[255 255 255],[ (tableTrialTrainingChoice.sideLongDelay(iTrial)+0.5)*x,y*9/8]);
        DrawMyText(display.window, tableTrialTrainingChoice.longDelayLabel{iTrial},ftsz_small,[255 255 255],[ (-(tableTrialTrainingChoice.sideLongDelay(iTrial)-1)+0.5)*x,y*9/8]);
        Screen('LineStipple',display.window, 1, 2, mod(ceil((1:16)/8),2));
        Screen('DrawLine', display.window, [255 255 255]*0.5, x, y*1/2 ,  x, y*3/2, 3);
        Screen(display.window,'Flip');
        
        % Record Response
        [keyisdown, ~, keycode] = KbCheck;
        if keyisdown==1
            % monitor validation & exit
            if keycode(key.escape)==1
                exit=1;
                timedown=GetSecs;
                interrupt_task = true;
            else
                if  keycode(key.left)==1
                    exit=1;
                    timedown=GetSecs;
                    isLeftChoice=1;
                    repeat=0;
                elseif keycode(key.right)==1
                    exit=1;
                    timedown=GetSecs;
                    isLeftChoice=0;
                    repeat=0;
                end
            end
        end
        [xMouse,yMouse,buttons] = recordResponse(display.window);
        if buttons(1)~=0
            isLeftChoice = sign(x-xMouse);
            if isLeftChoice == -1; isLeftChoice = 0; end
            timedown=GetSecs;
            repeat=0;
            exit=1;
        end
        WaitSecs(waitAft_trial);
        
        isLongDelayChoice = isLeftChoice == tableTrialTrainingChoice.sideLongDelay(iTrial);
        
        % Monitor maximal response time
        timePassed = GetSecs-startime;
        if timePassed>maxResponseDuration
            exit=1;
            repeat=repeat+1;
        end
    end
    
    if repeat==0
        RT=timedown-startime;
        
        % refresh screen
        shortDelayColor = [255*(isLongDelayChoice==1) 255 255*(isLongDelayChoice==1)];
        longDelayColor = [255*(isLongDelayChoice==0) 255 255*(isLongDelayChoice==0)];
        DrawMyText(display.window,text.quePref,ftsz_small,[100 100 100],[x,y*2/5]);
        DrawMyText(display.window, double([ num2str(tableTrialTrainingChoice.shortDelayAmount(iTrial)) ' €' ]) ,ftsz_small,shortDelayColor,[ (tableTrialTrainingChoice.sideLongDelay(iTrial)+0.5)*x,y*7/8]);
        DrawMyText(display.window, double([ num2str(tableTrialTrainingChoice.longDelayAmount(iTrial)) ' €' ]) ,ftsz_small,longDelayColor,[ (-(tableTrialTrainingChoice.sideLongDelay(iTrial)-1)+0.5)*x,y*7/8]);
        DrawMyText(display.window, tableTrialTrainingChoice.shortDelayLabel{iTrial} ,ftsz_small,shortDelayColor,[ (tableTrialTrainingChoice.sideLongDelay(iTrial)+0.5)*x,y*9/8]);
        DrawMyText(display.window, tableTrialTrainingChoice.longDelayLabel{iTrial} ,ftsz_small,longDelayColor,[ (-(tableTrialTrainingChoice.sideLongDelay(iTrial)-1)+0.5)*x,y*9/8]);
        Screen('LineStipple',display.window, 1, 2, mod(ceil((1:16)/8),2));
        Screen('DrawLine', display.window, [255 255 255]*0.5, x, y*1/2 ,  x, y*3/2, 3);
        Screen(display.window,'Flip');
        WaitSecs(blanktime);
        
    else
        % instruction: speed-up warning
        DrawMyText(display.window,text.timesUp,ftsz_mid,[255 255 255],[x,y]);
        DrawMyText(display.window,text.respFaster,ftsz_mid,[255 255 255],[x,y*1.2]);
        Screen(display.window,'Flip');
        WaitSecs(blanktime+1);
    end
    tableTrialTrainingChoice.isLeftChoice(iTrial, 1) = isLeftChoice;
    tableTrialTrainingChoice.isLongDelayChoice(iTrial, 1) = isLongDelayChoice;
    tableTrialTrainingChoice.RT(iTrial, 1) = RT;
end

%% Testing
%-----------------------------------------------
% instructions:  start
DrawMyText(display.window,text.pretDebut,ftsz_big,[255 255 255],[x,y]);
DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(waitAft_instruc);
KbWait;
wait4release()

% Trial structure
%-----------------------------------------------
interrupt_task = false;iTrial=0; repeat=0;
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
    
    % Check Response
    exit=0;
    buttons = 0;
    startime = GetSecs;
    isLeftChoice = NaN;
    while exit==0
        
        % refresh screen
        DrawMyText(display.window,text.quePref,ftsz_small,[100 100 100],[x,y*2/5]);
        DrawMyText(display.window, double([ num2str(tableTrial.shortDelayAmount(iTrial)) ' €' ]) ,ftsz_small,[255 255 255],[ (tableTrial.sideLongDelay(iTrial)+0.5)*x,y*7/8]);
        DrawMyText(display.window, double([ num2str(tableTrial.longDelayAmount(iTrial)) ' €' ]) ,ftsz_small,[255 255 255],[ (-(tableTrial.sideLongDelay(iTrial)-1)+0.5)*x,y*7/8]);
        DrawMyText(display.window, tableTrial.shortDelayLabel{iTrial} ,ftsz_small,[255 255 255],[ (tableTrial.sideLongDelay(iTrial)+0.5)*x,y*9/8]);
        DrawMyText(display.window, tableTrial.longDelayLabel{iTrial} ,ftsz_small,[255 255 255],[ (-(tableTrial.sideLongDelay(iTrial)-1)+0.5)*x,y*9/8]);
        Screen('LineStipple',display.window, 1, 2, mod(ceil((1:16)/8),2));
        Screen('DrawLine', display.window, [255 255 255]*0.5, x, y*1/2 ,  x, y*3/2, 3);
        Screen(display.window,'Flip');
        
        % Record Response
        [keyisdown, ~, keycode] = KbCheck;
        if keyisdown==1
            % monitor validation & exit
            if keycode(key.escape)==1
                exit=1;
                timedown=GetSecs;
                interrupt_task = true;
            else
                if  keycode(key.left)==1
                    exit=1;
                    timedown=GetSecs;
                    isLeftChoice=1;
                    repeat=0;
                elseif keycode(key.right)==1
                    exit=1;
                    timedown=GetSecs;
                    isLeftChoice=0;
                    repeat=0;
                end
            end
        end
        [xMouse,yMouse,buttons] = recordResponse(display.window);
        if buttons(1)~=0
            isLeftChoice = sign(x-xMouse);
            if isLeftChoice == -1; isLeftChoice = 0; end
            timedown=GetSecs;
            repeat=0;
            exit=1;
        end
        WaitSecs(waitAft_trial);
        isLongDelayChoice = isLeftChoice == tableTrial.sideLongDelay(iTrial);
        
        % Monitor maximal response time
        timePassed = GetSecs-startime;
        if timePassed>maxResponseDuration
            exit=1;
            repeat=repeat+1;
        end
    end
    
    if repeat==0
        RT=timedown-startime;
        
        % refresh screen
        shortDelayColor = [255*(isLongDelayChoice==1) 255 255*(isLongDelayChoice==1)];
        longDelayColor = [255*(isLongDelayChoice==0) 255 255*(isLongDelayChoice==0)];
        DrawMyText(display.window,text.quePref,ftsz_small,[100 100 100],[x,y*2/5]);
        DrawMyText(display.window, double([ num2str(tableTrial.shortDelayAmount(iTrial)) ' €' ]) ,ftsz_small,shortDelayColor,[ (tableTrial.sideLongDelay(iTrial)+0.5)*x,y*7/8]);
        DrawMyText(display.window, double([ num2str(tableTrial.longDelayAmount(iTrial)) ' €' ]) ,ftsz_small,longDelayColor,[ (-(tableTrial.sideLongDelay(iTrial)-1)+0.5)*x,y*7/8]);
        DrawMyText(display.window, tableTrial.shortDelayLabel{iTrial} ,ftsz_small,shortDelayColor,[ (tableTrial.sideLongDelay(iTrial)+0.5)*x,y*9/8]);
        DrawMyText(display.window, tableTrial.longDelayLabel{iTrial} ,ftsz_small,longDelayColor,[ (-(tableTrial.sideLongDelay(iTrial)-1)+0.5)*x,y*9/8]);
        Screen('LineStipple',display.window, 1, 2, mod(ceil((1:16)/8),2));
        Screen('DrawLine', display.window, [255 255 255]*0.5, x, y*1/2 ,  x, y*3/2, 3);
        Screen(display.window,'Flip');
        WaitSecs(blanktime);
    else
        % instruction: speed-up warning
        DrawMyText(display.window,text.timesUp,ftsz_mid,[255 255 255],[x,y]);
        DrawMyText(display.window,text.respFaster,ftsz_mid,[255 255 255],[x,y*1.2]);
        Screen(display.window,'Flip');
        WaitSecs(blanktime+1);
    end
    tableTrial.isLeftChoice(iTrial, 1) = isLeftChoice;
    tableTrial.isLongDelayChoice(iTrial, 1) = isLongDelayChoice;
    tableTrial.RT(iTrial, 1) = RT;
    tableSupp.choicePositions {iTrial, 1} = {xMouse, yMouse};
end

% display end
Screen(display.window,'Flip');
sca;

%% Data saving
%-----------------------------------------------
if interrupt_task
    sub_data.(cfg.sessNber_str).tasks.taskChoice_MoneyDelay.completed...
        = false;
else; sub_data.(cfg.sessNber_str).tasks.taskChoice_MoneyDelay.completed...
        = true;
end
sub_data.(cfg.sessNber_str).tasks.taskChoice_MoneyDelay.results =       ...
    struct('trainingData', tableTrialTrainingChoice, 'data',            ...
    tableTrial, 'suppResults', tableSupp);

end
