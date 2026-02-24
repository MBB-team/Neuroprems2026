function [sub_data] = taskChoice_MoneyRisk_V2020(sub_data, cfg)
%function [sub_data] = taskChoice_MoneyRisk_V2(sub_data, cfg)
%
% taskChoice_MoneyRisk - execute the risky-money choice task (from motiscan battery)
% Launch the task with this function for testing one subject.
% The subject has to choose between 2 options his prefered one.
% Each option is formulated as a monetary gain to obtain with a given
% probability
%
% Modified version of 2020 :
% Grid from -14 to 19 euros for a small risk (100 % of winning)
% versus 20 euros (always) for a big risk (40, 52, 64, 83%)
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

maxCharPline_instruc = 68;

height_scaler = 2;

% Load stimuli
%-----------------------------------------------
% informative icons
cd(cfg.paths.task.images); % enter img dir
cross=Screen('MakeTexture',display.window,imread('Cross.bmp'));
rectcross=CenterRectOnPoint(Screen('Rect',cross),x,y);
% instructions images
instruction = struct('texture',{},'position',{});
for i=1:1
    instruction(i).texture = Screen('MakeTexture',display.window,imread(['instruction_Choice' 'R' '.bmp']));
end

% proba images
cd(['stim_probaDisc' filesep 'amount' filesep]); % enter img dir
% Define list
list_bigRisk = [40, 52, 64, 83]; % In %
list_bigRiskLabel = {'avec 40% de chance', 'avec 52% de chance', 'avec 64% de chance', 'avec 83% de chance'};
n_bigRisk = length(list_bigRisk);
list_bigRiskStr = cell(1,n_bigRisk); %{'100','83','64','52','40'};
for i_bigRisk = 1:n_bigRisk
    iBigRisk_str = num2str(list_bigRisk(i_bigRisk));
    list_bigRiskStr{i_bigRisk} = iBigRisk_str;
end
list_bigRiskAmount = 20; % in euros
list_bigRiskAmountStr = '20';

list_smallRisk = 100; % always 100% chance
list_smallRiskStr = '100';
list_smallRiskLabel = {'avec 100% de chance'};
list_smallRiskAmount = round(linspace(-19, 19, 12));  % in euros
n_smallRiskAmount = length(list_smallRiskAmount);
list_smallRiskAmountStr = cell(1,n_smallRiskAmount);
for i_smallRiskAmount = 1:n_smallRiskAmount
    iAmount_str = num2str(list_smallRiskAmount(i_smallRiskAmount));
    list_smallRiskAmountStr{i_smallRiskAmount} = iAmount_str;
end

for i_bigRisk = 1:n_bigRisk
    [ img,map ] = imread(['stim_proba' list_bigRiskStr{i_bigRisk}      ...
        '_amount' list_bigRiskAmountStr '.png']);

    if size(img,3) == 1
        img = ind2rgb(img,map);
    %     img = ind2gray(img,map);
        img = img.*255;
    end
    stim_bigRisk(i_bigRisk).texture =  Screen('MakeTexture',display.window,img);
end
for i_smallRiskAmount = 1:n_smallRiskAmount
    %[ img,map ] = imread(['stim_proba52.png']);
    [ img,map ] = imread(['stim_proba' list_smallRiskStr '_amount'      ...
        list_smallRiskAmountStr{i_smallRiskAmount} '.png']);
    if size(img,3) == 1
        img = ind2rgb(img,map); 
        %     img = ind2gray(img,map);
        img = img.*255;
    end
    stim_smallRisk(i_smallRiskAmount).texture =  Screen('MakeTexture',display.window,img);
end

cd(['..' filesep '..' filesep cfg.paths.task.code]); % exit img dir

% recurring textstring
text.instruc = 'Instructions';
text.instrucText1 = ['Dans ce test, vous allez devoir choisir entre '   ...
    'deux offres. L''offre de gauche vous propose de gagner ou perdre ' ...
    'un montant de manière certaine. À l''inverse, l''offre de droite ' ...
    'est un pari : son résultat est incertain.'];
text.instrucText2 = ['À droite, un diagramme vous montrera ce pari : '  ...
    'la probabilité de gagner 20 euros ou de les perdre. Plus le '      ...
    'diagramme est rouge plus vous avez des chances de perdre '         ...
    'l''argent, plus il est vert plus vous avez des chances de le gagner.'];
text.instrucText3 = 'Sélectionner simplement l''offre que vous préférez.';

text.training = 'Entrainement';
text.appuyer = 'appuyer sur une touche pour continuer...';
text.quePref  = 'Que préférez-vous ?';
text.pretDebut = 'Prêt à débuter ?';
text.timesUp = 'Temps écoulé !';
text.respFaster = 'Répondez plus rapidement svp.';

% % Experimental conditions
% %-----------------------------------------------

% Experimental conditions (Modified)

% % Define list
% list_smallRisk = 100; % always 100% chance
% list_smallRiskLabel = {'avec 100% de chance'};
% list_bigRisk = [40, 52, 64, 83]; % In %
% list_bigRiskLabel = {'avec 40% de chance', 'avec 52% de chance', 'avec 64% de chance', 'avec 83% de chance'};
% n_bigRisk = length(list_bigRisk);
% 
% list_smallRiskAmount = round(linspace(-19, 19, 12));  % in euros
% list_bigRiskAmount = 20; % in euros
% n_smallRiskAmount = length(list_smallRiskAmount);

% Define trial table
temp = CombVec(1:n_smallRiskAmount, 1:n_bigRisk)';
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
tableTrial.smallRiskLevel = ones(height(tableTrial), 1);
tableTrial.bigRiskLevel = temp(:, 2);
tableTrial.smallRiskAmountLevel = temp(:, 1);
tableTrial.bigRiskAmountLevel = ones(height(tableTrial), 1);
tableTrial.smallRisk =  list_smallRisk(tableTrial.smallRiskLevel);
tableTrial.bigRisk  =  list_bigRisk(tableTrial.bigRiskLevel)';
tableTrial.smallRiskAmount =  list_smallRiskAmount(tableTrial.smallRiskAmountLevel)';
tableTrial.bigRiskAmount  =  list_bigRiskAmount(tableTrial.bigRiskAmountLevel);
tableTrial.smallRiskLabel =  list_smallRiskLabel(tableTrial.smallRiskLevel);
tableTrial.bigRiskLabel =  list_bigRiskLabel(tableTrial.bigRiskLevel)';
tableTrial.sideBigRisk = zeros(height(tableTrial), 1); % 1 = left ; 0 = right
nTrial = height(tableTrial);

% Define trial table for training
tableTrialTrainingChoice = tableTrial(1:2, :);
tableTrialTrainingChoice.orderTrial = (1:2)';
tableTrialTrainingChoice.bigRiskLevel = [1 max(tableTrial.bigRiskLevel)]';
tableTrialTrainingChoice.smallRiskAmountLevel = [1 max(tableTrial.smallRiskAmountLevel)]';
tableTrialTrainingChoice.smallRisk =  list_smallRisk(tableTrialTrainingChoice.smallRiskLevel);
tableTrialTrainingChoice.bigRisk  =  list_bigRisk(tableTrialTrainingChoice.bigRiskLevel)';
tableTrialTrainingChoice.smallRiskAmount =  list_smallRiskAmount(tableTrialTrainingChoice.smallRiskAmountLevel)';
tableTrialTrainingChoice.bigRiskAmount  =  list_bigRiskAmount(tableTrialTrainingChoice.bigRiskAmountLevel);
tableTrialTrainingChoice.smallRiskLabel =  list_smallRiskLabel(tableTrialTrainingChoice.smallRiskLevel);
tableTrialTrainingChoice.bigRiskLabel  =  list_bigRiskLabel(tableTrialTrainingChoice.bigRiskLevel)';
tableTrialTrainingChoice.sideBigRisk = zeros(height(tableTrialTrainingChoice), 1); % 1 = left ; 0 = right
nTraining = height(tableTrialTrainingChoice);

% Supplementary results
choicePositions   = cell(nTrial, 1);
tableSupp = table(choicePositions);

% timing variables
ITI_duration = 0.5;
forceDuration = 0.5; % duration of force exertion (seconds)
targetStopCriterion = 2/3; % threshold to cross to stop trial (in% of target force level)
blanktime = 0.5;
ITI_jitter = 0.5;
waitAft_bigTtl = 0.2;
waitAft_instruc = 0.5;
waitAft_trial = 0.007;
maxResponseDuration = 10e3;

%% Training
%-----------------------------------------------
DrawMyText(display.window,text.instruc,ftsz_big,[255 255 255],[x,y]);
DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(waitAft_bigTtl);
KbWait;

% instruction: explanations
% - slide 1
Screen('TextSize',display.window,ftsz_small);
DrawFormattedText(display.window,text.instrucText1,'center','center',   ...
    [255 255 255],maxCharPline_instruc, 0, 0, 2, 0, []);
Screen(display.window,'Flip');
WaitSecs(waitAft_instruc);
KbWait;
% - slide 2
Screen('TextSize',display.window,ftsz_small);
DrawFormattedText(display.window,text.instrucText2,'center','center',   ...
    [255 255 255],maxCharPline_instruc, 0, 0, 2, 0, []);
Screen(display.window,'Flip');
WaitSecs(waitAft_instruc);
KbWait;
%     DemoWheelOfFortune_risk;
% - slide 3
Screen('TextSize',display.window, ftsz_small);
DrawFormattedText(display.window,text.instrucText3,'center','center',   ...
    [255 255 255],maxCharPline_instruc, 0, 0, 2, 0, []);
Screen(display.window,'Flip');
WaitSecs(waitAft_instruc);
KbWait;

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
interrupt_task = 0;iTrial=0; repeat=0;
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
    while exit==0
        
        % refresh screen
        display_risky_options(display,ftsz_iTask,                       ...
            tableTrialTrainingChoice.smallRiskAmount(iTrial),           ...
            tableTrialTrainingChoice.bigRiskAmount(iTrial),             ...
            tableTrialTrainingChoice.smallRisk(iTrial),                 ...
            tableTrialTrainingChoice.bigRisk(iTrial),                   ...
            tableTrialTrainingChoice.sideBigRisk(iTrial),               ...
            stim_bigRisk(tableTrialTrainingChoice.bigRiskLevel(iTrial)), ...
            stim_smallRisk(tableTrialTrainingChoice.smallRiskAmountLevel(iTrial)),...
            height_scaler);
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
        [xMouse,~,buttons] = recordResponse(display.window);
        if buttons(1)~=0
            isLeftChoice = sign(x-xMouse);
            if isLeftChoice == -1; isLeftChoice = 0; end
            timedown=GetSecs;
            repeat=0;
            exit=1;
        end
        WaitSecs(waitAft_trial);
        isBigRiskChoice = isLeftChoice == tableTrialTrainingChoice.sideBigRisk(iTrial);
        
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
        display_risky_options(display,ftsz_iTask,                       ...
            tableTrialTrainingChoice.smallRiskAmount(iTrial),           ...
            tableTrialTrainingChoice.bigRiskAmount(iTrial),             ...
            tableTrialTrainingChoice.smallRisk(iTrial),                 ...
            tableTrialTrainingChoice.bigRisk(iTrial),                   ...
            tableTrialTrainingChoice.sideBigRisk(iTrial),               ...
            stim_bigRisk(tableTrialTrainingChoice.bigRiskLevel(iTrial)), ...
            stim_smallRisk(tableTrialTrainingChoice.smallRiskAmountLevel(iTrial)),...
            height_scaler);
        if isBigRiskChoice; xStart = (-(tableTrialTrainingChoice.sideBigRisk(iTrial)-1)+0.25)*x;
        else; xStart = (tableTrialTrainingChoice.sideBigRisk(iTrial)+0.25)*x;  end
        Screen('FrameRect', display.window,[255 255 255],[xStart y*0.6  xStart+x/2 y*1.6],8);
        Screen(display.window,'Flip');
        WaitSecs(blanktime);
    else
        % instruction: speed-up warning
        DrawMyText(display.window,text.timesUp,ftsz_big,[255 255 255],[x,y]);
        DrawMyText(display.window,text.respFaster,ftsz_big,[255 255 255],[x,y*1.2]);
        Screen(display.window,'Flip');
        WaitSecs(blanktime+1);
    end
    
    tableTrialTrainingChoice.isLeftChoice(iTrial, 1) = isLeftChoice;
    tableTrialTrainingChoice.isBigRiskChoice(iTrial, 1) = isBigRiskChoice;
    tableTrialTrainingChoice.RT(iTrial, 1) = RT;
    
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
interrupt_task = false; iTrial = 0; repeat = 0;
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
    startime = GetSecs;
    isLeftChoice = NaN;
    while exit==0
        
        % refresh screen
        display_risky_options(display,ftsz_iTask,                       ...
            tableTrial.smallRiskAmount(iTrial),                         ...
            tableTrial.bigRiskAmount(iTrial),                           ...
            tableTrial.smallRisk(iTrial),tableTrial.bigRisk(iTrial),    ...
            tableTrial.sideBigRisk(iTrial),                             ...
            stim_bigRisk(tableTrial.bigRiskLevel(iTrial)), ...
            stim_smallRisk(tableTrial.smallRiskAmountLevel(iTrial)),    ...
            height_scaler);
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
        isBigRiskChoice = isLeftChoice == tableTrial.sideBigRisk(iTrial);
        
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
        display_risky_options(display,ftsz_iTask,                       ...
            tableTrial.smallRiskAmount(iTrial),                         ...
            tableTrial.bigRiskAmount(iTrial),                           ...
            tableTrial.smallRisk(iTrial),tableTrial.bigRisk(iTrial),    ...
            tableTrial.sideBigRisk(iTrial),                             ...
            stim_bigRisk(tableTrial.bigRiskLevel(iTrial)),              ...
            stim_smallRisk(tableTrial.smallRiskAmountLevel(iTrial)),    ...
            height_scaler);
        if isBigRiskChoice; xStart = (-(tableTrial.sideBigRisk(iTrial)-1)+0.25)*x;
        else; xStart = (tableTrial.sideBigRisk(iTrial)+0.25)*x;  end
        Screen('FrameRect', display.window,[255 255 255],[xStart y*0.6  xStart+x/2 y*1.6],8);
        Screen(display.window,'Flip');
        WaitSecs(blanktime); 
    else
        % instruction: speed-up warning
        DrawMyText(display.window,text.timesUp,ftsz_big,[255 255 255],[x,y]);
        DrawMyText(display.window,text.respFaster,ftsz_big,[255 255 255],[x,y*1.2]);
        Screen(display.window,'Flip');
        WaitSecs(blanktime+1);
    end
    tableTrial.isLeftChoice(iTrial, 1) = isLeftChoice;
    tableTrial.isBigRiskChoice(iTrial, 1) = isBigRiskChoice;
    tableTrial.RT(iTrial, 1) = RT;
    tableSupp.choicePositions {iTrial, 1} = {xMouse, yMouse};
    
end

% display end
Screen(display.window,'Flip');
sca;

%% Data saving
%-----------------------------------------------
if interrupt_task
    sub_data.(cfg.sessNber_str).tasks.taskChoice_MoneyRisk.completed...
        = false;
else; sub_data.(cfg.sessNber_str).tasks.taskChoice_MoneyRisk.completed...
        = true;
end
sub_data.(cfg.sessNber_str).tasks.taskChoice_MoneyRisk.results =        ...
    struct('trainingData', tableTrialTrainingChoice, 'data', tableTrial,...
    'suppResults', tableSupp);

end

function display_risky_options(display,ftsz,                            ...
    smallRiskAmount,bigRiskAmount,~,bigRisk,sideBigRisk,                ...
    bigRiskLevel,smallRiskLevel,varargin)
    
if nargin == 10; height_scaler = varargin{1}; else, height_scaler = 1; end

% refresh screen
DrawMyText(display.window,'Que préférez-vous ?',ftsz.ftsz_small,[100 100 100],[display.x,display.y*2/5]);
% DrawMyText(display.window, double([num2str(smallRiskAmount) ' €' ]) ,ftsz.ftsz_big,[255 255 255],[ (sideBigRisk+0.5)*display.x,display.y*9/10]);
% DrawMyText(display.window, double([num2str(bigRiskAmount) ' €' ]) ,ftsz.ftsz_mid,[0 255 0],[ (-(sideBigRisk-1)+0.5)*display.x,display.y*8/10]);
% DrawMyText(display.window, double(['-' num2str(bigRiskAmount) ' €' ]) ,ftsz.ftsz_mid,[255 0 0],[ (-(sideBigRisk-1)+0.5)*display.x,display.y*10/10]);

texture_bigRisk  = bigRiskLevel.texture;
texture_size    = Screen('Rect',texture_bigRisk);
texture_height  = texture_size(3);
texture_width   = texture_size(4);
texture_ratio   = texture_width / texture_height;
texture_height  = texture_height * height_scaler;
texture_width   = texture_height * texture_ratio;
new_rect = [0 0 texture_height texture_width];

rect_bigRisk = CenterRectOnPoint(new_rect,        ...
    (-sideBigRisk+1+0.5)*display.x, display.y*11/10);
Screen('DrawTexture',display.window,texture_bigRisk,[],rect_bigRisk);


texture_smallRisk = smallRiskLevel.texture;
texture_size    = Screen('Rect',texture_smallRisk);
texture_height  = texture_size(3);
texture_width   = texture_size(4);
texture_ratio   = texture_width / texture_height;
texture_height  = texture_height * height_scaler;
texture_width   = texture_height * texture_ratio;
new_rect = [0 0 texture_height texture_width];

rect_smallRisk = CenterRectOnPoint(new_rect,    ...
    (sideBigRisk+1-0.5)*display.x, display.y*11/10);
Screen('DrawTexture',display.window,texture_smallRisk,[],rect_smallRisk);
Screen('LineStipple',display.window, 1, 2, mod(ceil((1:16)/8),2));
Screen('DrawLine', display.window, [255 255 255]*0.5,                   ...
    display.x, display.y*1/2 ,  display.x, display.y*7/4, 3);
end