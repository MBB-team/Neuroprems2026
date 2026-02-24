function [sub_data] = taskChoice_CogEffort_V2020(sub_data, cfg)
% function [sub_data] = taskChoice_CogEffort_V2(sub_data, cfg)
%
% taskChoice_CogEffort - execute the choice cognitive effort task for a
% single subject
% The subject has to choose between two options, a variable, between-trials, amount (1-19.9)
% of euros for a fixed easy cognitive efforts (touching dots in any order)
% against winning a fixed amount of money (20€) for a variable,
% between-trials cognitive effort (touching dots in a specific order)
%
% Input : sub_data and cfg structures
%
% Output : updated sub_data with results
%
% Modified for V2, march 2020, C. JAFFRE and P. CARRILLO

%%%%%%%%%%%%%%%%%%
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

mouse = cfg.ptb.mouse;
touch = cfg.ptb.touch;

% fontsize
if isfield(cfg.ptb,mfilename)
        ftsz_iTask = cfg.ptb.fontsize.(mfilename);
else;   ftsz_iTask = cfg.ptb.fontsize.global;
end
ftsz_big    = ftsz_iTask.ftsz_big;
ftsz_mid    = ftsz_iTask.ftsz_mid;
ftsz_small  = ftsz_iTask.ftsz_small;

Screen('TextSize', display.window, ftsz_small);

%%%%%%%%%%%%%%%%%%%%%%%%
%% Main task parameters
% -----------------------------------------------
% stimuli inside the dots, extracted from an xls file
cd(cfg.paths.task.text) % text folder

[NUM,TXT,~] = xlsread('stimuliPerDimension.xlsx');
stimuliPerDimension = cell(length(NUM),4);
for iStim = 1:length(NUM)
    stimuliPerDimension{iStim,1} = num2str(NUM(iStim));
    stimuliPerDimension{iStim,2} = TXT{iStim,1};
    stimuliPerDimension{iStim,3} = TXT{iStim,2};
    stimuliPerDimension{iStim,4} = TXT{iStim,3};
end

nDots     = 12; % number of dots to select in the mental effort task
nRealPerf = 2;  % Combien de fois effectuer réellement le TMT choisi

% Liste des niveaux et efforts
listEasyCogEffort      = 0; % always 0 list (select dots in any order)
listEasyCogEffortLabel = {'Sans ordre particulier'};
listEasyCogEffortInstructions = {'Touchez tous les points dans n''importe quel ordre'};

dotCarac = sprintf('\x2022');
%newLine = sprintf('\n');
listHardCogEffort      = [1, 2, 3, 4]; %4 levels of difficulty
listHardCogEffortLabel = {'En suivant 1 liste', ...
    'En alternant entre 2 listes', ...
    'En alternant entre 3 listes', ...
    'En alternant entre 4 listes'};
listLongInstructions1 = {
    ['Touchez tous les points dans n''importe quel ordre.'],...
    ['Touchez les points en suivant l''ordre des chiffres.'], ...
    ['Touchez les points en alternant chiffres et lettres.'], ...
    ['Touchez les points en alternant chiffres, lettres et dés.'], ...
    ['Touchez les points en alternant chiffres, minuscules, dés et MAJUSCULES.']
    };
listLongInstructions2 = {
    [' '],...
    ['Par exemple 1-2-3-4-...'], ...
    ['Par exemple 1-a-2-b-...'], ...
    ['Par exemple 1-a-' dotCarac '-2-...'], ...
    ['Par exemple 1-a-' dotCarac '-A-2-...']
    };
listHardCogEffortInstructions = {'Touchez les points en suivant l''ordre des chiffres', ...
    'Touchez les points en alternant chiffres et lettres', ...
    'Touchez les points en alternant chiffres, lettres et dés', ...
    'Touchez les points en alternant chiffres, minuscules, dés et MAJUSCULES'};

nPerfLevels = length(listHardCogEffort) + length(listEasyCogEffort); % total number of levels

% Liste des récompenses en jeu
listEasyCogEffortAmount = [0.1 1 3 6 10 13 16 17 18 19 19.5 19.9];  % in euros
listHardCogEffortAmount = 20; % in euros

%% Define trial tables
% Defining all possible combinations
nHardCogEffort       = length(listHardCogEffort);
nEasyCogEffortAmount = length(listEasyCogEffortAmount);
temp = CombVec(1:nEasyCogEffortAmount, 1:nHardCogEffort)';

nTrial = length(temp);

% Randomization such that there is no correlation between time and conditions
crit = Inf;
while crit > 3.1
    temp(:, 3) = Shuffle(1:nTrial);
    crit = sum(sum(abs(corr(temp))));
end
temp(:, 4) = 1:nTrial;
temp = sortrows(temp, 3);

% Make a table per Block (training Perf, traning Choice and task) and a supp table
% for additional data, store everything into a struct (results) which will be
% unpacked at the end
results = struct;

iTrial             = (1:nTrial)';
results.tableTrial = table(iTrial);
% results.tableTrial.orderTrial(:, 1)          = temp(:, 4);
results.tableTrial.easyCogEffortLevel        = ones(nTrial, 1);
results.tableTrial.hardCogEffortLevel        = temp(:, 2);
results.tableTrial.easyCogEffortAmountLevel  = temp(:, 1);
results.tableTrial.hardCogEffortAmountLevel  = ones(nTrial, 1);
results.tableTrial.easyCogEffortAmount       = ...
    listEasyCogEffortAmount(results.tableTrial.easyCogEffortAmountLevel)';
results.tableTrial.hardCogEffortAmount       = ...
    listHardCogEffortAmount(results.tableTrial.hardCogEffortAmountLevel);
results.tableTrial.easyCogEffort             = ...
    listEasyCogEffort(results.tableTrial.easyCogEffortLevel);
results.tableTrial.hardCogEffort             = ...
    listHardCogEffort(results.tableTrial.hardCogEffortLevel)';
results.tableTrial.easyCogEffortLabel        = ...
    listEasyCogEffortLabel(results.tableTrial.easyCogEffortLevel);
results.tableTrial.hardCogEffortLabel        = ...
    listHardCogEffortLabel(results.tableTrial.hardCogEffortLevel)';
results.tableTrial.easyCogEffortInstructions = ...
    listEasyCogEffortInstructions(results.tableTrial.easyCogEffortLevel);
results.tableTrial.hardCogEffortInstructions = ...
    listHardCogEffortInstructions(results.tableTrial.hardCogEffortLevel)';
results.tableTrial.sideHardCogEffort         = zeros(nTrial, 1); % 1 left, 0 right
% Preallocation of responses :
results.tableTrial.isLeftChoice          = nan(nTrial, 1); % 1 left, 0 right
results.tableTrial.isHardCogEffortChoice = nan(nTrial, 1);
results.tableTrial.RTchoice              = nan(nTrial, 1);
results.tableTrial.RTperf                = nan(nTrial, 1);
% Random assignment of nRealPerf performance trials
perfTrial = datasample(1:1:nTrial, nRealPerf, 'Replace', false);
results.tableTrial.doPerf = ismember(results.tableTrial.iTrial, perfTrial);

% Make tables for choice training
nTrainingChoice = 2; % Number of traning trials (the two extremes : for 1 and 49 euros)
results.tableTrialTrainingChoice                           = results.tableTrial(1:nTrainingChoice, :);
results.tableTrialTrainingChoice.orderTrial                = (1:nTrainingChoice)';
results.tableTrialTrainingChoice.hardCogEffortLevel        = [1 max(results.tableTrial.hardCogEffortLevel)]';
results.tableTrialTrainingChoice.easyCogEffortAmountLevel  = ...
    [1 max(results.tableTrial.easyCogEffortAmountLevel)]';
results.tableTrialTrainingChoice.easyCogEffort             = ...
    listEasyCogEffort(results.tableTrialTrainingChoice.easyCogEffortLevel);
results.tableTrialTrainingChoice.hardCogEffort             = ...
    listHardCogEffort(results.tableTrialTrainingChoice.hardCogEffortLevel)';
results.tableTrialTrainingChoice.easyCogEffortAmount       = ...
    listEasyCogEffortAmount(results.tableTrialTrainingChoice.easyCogEffortAmountLevel)';
results.tableTrialTrainingChoice.hardCogEffortAmount       = ...
    listHardCogEffortAmount(results.tableTrialTrainingChoice.hardCogEffortAmountLevel);
results.tableTrialTrainingChoice.easyCogEffortLabel        = ...
    listEasyCogEffortLabel(results.tableTrialTrainingChoice.easyCogEffortLevel);
results.tableTrialTrainingChoice.hardCogEffortLabel        = ...
    listHardCogEffortLabel(results.tableTrialTrainingChoice.hardCogEffortLevel)';
results.tableTrialTrainingChoice.easyCogEffortInstructions =  ...
    listEasyCogEffortInstructions(results.tableTrialTrainingChoice.easyCogEffortLevel);
results.tableTrialTrainingChoice.hardCogEffortInstructions =  ...
    listHardCogEffortInstructions(results.tableTrialTrainingChoice.hardCogEffortLevel)';
results.tableTrialTrainingChoice.sideHardCogEffort         = zeros(nTrainingChoice, 1); % 1 left, 0 right
% Preallocation of responses :
results.tableTrialTrainingChoice.isLeftChoice              = nan(nTrainingChoice, 1);
results.tableTrialTrainingChoice.isHardCogEffortChoice     = nan(nTrainingChoice, 1);
results.tableTrialTrainingChoice.RTchoice                  = nan(nTrainingChoice, 1);
results.tableTrialTrainingChoice.RTperf                    = [];
results.tableTrialTrainingChoice.doPerf                    = [];

%Define trial table for training perf
nTrainingPerf = nPerfLevels*2;
iTrial                = (1:nTrainingPerf)';
results.tableTrialTrainingPerf                       = table(iTrial);
results.tableTrialTrainingPerf.CogEffortLevel        = ...
    repmat(vertcat(unique(results.tableTrial.easyCogEffortLevel), unique(results.tableTrial.hardCogEffortLevel)),2,1);
results.tableTrialTrainingPerf.CogEffort             = ...
    repmat(vertcat(unique(results.tableTrial.easyCogEffort), unique(results.tableTrial.hardCogEffort)),2,1);
results.tableTrialTrainingPerf.CogEffortLabel        = ...
    repmat(vertcat(listEasyCogEffortLabel', listHardCogEffortLabel'),2,1);
results.tableTrialTrainingPerf.CogEffortInstructions = ...
    repmat(vertcat(listEasyCogEffortInstructions', listHardCogEffortInstructions'),2,1);
% Preallocation of responses :
results.tableTrialTrainingPerf.RTperf                = nan(nTrainingPerf, 1);

% Résultats supplémentaires
choicePositions   = cell(nTrial, 1);  % x,y position during choice trials
results.tableSupp = table(choicePositions);
results.tableSupp.perfPositions            = cell(nTrial, 1);  % x,y cursor/touch position
results.tableSupp.perfPositionsTime        = cell(nTrial, 1);  % Timing for each cursor/touch position
results.tableSupp.perfSequence             = cell(nTrial, 1);  % Order of dots clicked
results.tableSupp.perfCorrectSequenceTime  = cell(nTrial, 1);  % Timing of correct each dot
results.tableSupp.perfSequenceTime         = cell(nTrial, 1);  % Timing of each dot

%% Screen configuration
screen_center = [x, y];

% position on screen
left_margin     = x*(1/4); % left of the screen
right_margin    = x*(3/4); % close to center of screen
up_margin       = y*(1/4);
low_margin      = y*(7/4);
right_col_pos = [right_margin+x  up_margin  2*x             low_margin]; % Used during dot presentation
center_pos    = [right_margin    up_margin  left_margin+x   low_margin]; % Used before dot presentation

% extract corresponding size of each symbol:
[width_dots, hight_dots] = deal(NaN(size(stimuliPerDimension)));
for iDim = [1,2,4]
    for iStim = 1:size(stimuliPerDimension,1)
        [width_dots(iStim, iDim), hight_dots(iStim, iDim)] = RectSize(Screen('TextBounds', display.window, stimuliPerDimension{iStim,iDim}));
    end
end

% colors
white   = [255 255 255];
grey    = [128 128 128];
red     = [255 0   0];
green   = [0   255 0];

% max characters per line
wrapat_nb_char = 26;

% cross
pic_cross   = Screen('MakeTexture',display.window,imread('cross.bmp'));
rect_cross  = CenterRectOnPoint(Screen('Rect',pic_cross),x,y);

%% dot characteristics
dotSize     = 70; % diameter of the dots to be selected
dot_minDist = 3*dotSize/2; % minimal distance between each dot (in pixels)

% pixel confidence interval around the dots of interest
pix_conf = dotSize/2;

% size of the rectangle around the dots
baseRect = [0 0 dotSize dotSize];
% % For Ovals we set a miximum diameter up to which it is perfect for
% maxDiameter = max(baseRect)*1.01;
% set the size of the oval contour
circle_thick    = 5;
% line_thick      = 5;

% Use the meshgrid command to create our base dot coordinates. This will
% simply be a grid of equally spaced coordinates in the X and Y dimensions,
% centered on 0,0
dimScale   = 40;
pixelScale = 2*y / (dimScale * 2 + 2);
dotMinDistnonPixel = floor(dot_minDist/pixelScale)+ 1; % ensures that all the dots will have a minimal distance between each other
[xDotGrid, yDotGrid] = meshgrid((-dimScale + dotMinDistnonPixel):dotMinDistnonPixel:(dimScale - dotMinDistnonPixel),...
    (-dimScale + dotMinDistnonPixel):dotMinDistnonPixel:(dimScale - dotMinDistnonPixel));
% Here we scale the grid so that it is in pixel coordinates. We just scale
% it by the screen size so that it will fit. This is simply a
% multiplication.
xDotGrid            = xDotGrid .* pixelScale;
yDotGrid            = yDotGrid .* pixelScale;
numTotalDotPosition = numel(xDotGrid);
% Make the matrix of positions for the dots. This need to be a two row
% vector. The top row will be the X coordinate of the dot and the bottom
% row the Y coordinate of the dot. Each column represents a single dot.
dotPositionMatrix = [reshape(xDotGrid, 1, numTotalDotPosition); reshape(yDotGrid, 1, numTotalDotPosition)];

% dot associated names, preallocation
mental_E_task.performance.dot_nm = cell(nDots, nTrial);
% select the 'nDots' dots that will be displayed on screen
mental_E_task.performance.dots_xyPos      = NaN(2,nDots,nTrial);
mental_E_task.performance.dots_xyPos_ref  = zeros(nDots,nTrial); % keep track on the dots already selected or not for the reference case where no order has been established between the different dots
mental_E_task.performance.dot_nm_xyPos    = NaN(2,nDots,nTrial); % (x,y) coordinates for dot name position)
% idem for the trainingPerf block
    mental_E_task.training.dot_nm    = cell(nDots, nTrainingPerf);
    mental_E_task.training.dots_xyPos      = NaN(2,nDots,nTrial);
    mental_E_task.training.dots_xyPos_ref  = zeros(nDots,nTrial); % keep track on the dots already selected or not for the reference case where no order has been established between the different dots
    mental_E_task.training.dot_nm_xyPos    = NaN(2,nDots,nTrial); % (x,y) coordinates for dot name position)

% Dots grid allocation for each block (training and performance)
nStartingBlock = 1;

for iBlock = nStartingBlock:2
    switch iBlock
        case 1
            blockName = 'training';
            nTrialInBlock = nTrainingPerf;
        case 2
            blockName = 'performance';
            nTrialInBlock = nTrial;
    end
    for iTrial = 1:nTrialInBlock
        dist_ok = 0;
        rng('shuffle', 'twister');% reinitialize the 'rand' function from Matlab everytime
        while dist_ok == 0 % sample until you get dots which all a 'dot_minDist' distance between each other minimally (to avoid text overlaps)
            pickDots = randperm(length(dotPositionMatrix),nDots);
            % check that each dot respects the minimal distance with the previous ones
            n_bad_dots = 0;
            for iDot = 2:nDots
                for jDot = 1:(iDot - 1)
                    % if X and Y distance is smaller than the min distance =>
                    % leave this dot disposition and try a new one
                    n_bad_dots = n_bad_dots +...
                        (abs(dotPositionMatrix(1,iDot) - dotPositionMatrix(1,jDot)) <= dot_minDist)*(abs(dotPositionMatrix(2,iDot) - dotPositionMatrix(2,jDot)) <= dot_minDist);
                end
            end
            % if all dots have a correct distance with each other, keep this selection
            if n_bad_dots == 0
                dist_ok = 1;
            end
        end
        % save dot coordinates
        mental_E_task.(blockName).dots_xyPos(:,:,iTrial) = dotPositionMatrix(:,pickDots);
        % start filling dot name coordinates
        mental_E_task.(blockName).dot_nm_xyPos(1,:,iTrial) = mental_E_task.(blockName).dots_xyPos(1,:,iTrial) + x;
        mental_E_task.(blockName).dot_nm_xyPos(2,:,iTrial) = mental_E_task.(blockName).dots_xyPos(2,:,iTrial) + y;
        %pre-allocation dice indexes
        mental_E_task.(blockName).dice_idx = zeros(nDots, nTrialInBlock);
    end
end

%% dice specific info
% size of the dots used for the "dice" dimension
dice_dotSize = dotSize/8;
% x and y distance between the center and each dot
dice_dot_dist = dice_dotSize*2;
% check that distance is ok
if dice_dot_dist <= dice_dotSize || dice_dot_dist*3 >= dotSize
    sca;
    error('adjust dice dots distance or dotSize');
end

%% Time variables
blanktime              = 1; % Blank interval after each choice
fixation_duration    = 0.5; % Fixation interval before each choice (only with joystick ?)
maxResponseDuration    = 10e3; % Choice maximum duration
t_dispEtime            = 3; % display random choice selected for t_dispEtime seconds
t_cross_ITI            = 0.5; % fixation cross duration between each choice trial
error_TimeWait         = 0.3; % error waiting
time_release_tolerance = 0.3; % leave 'time_release_tolerance' seconds since last correct press until to consider that the button press is an error
times_to_check = {'blockStart_message',...
    'blockStart',...
    'cross_ITI',...
    'cross_ITI_too_early_press',...
    'display_optionsE',...
    'display_chosenE',...
    'display_E_information',...
    'display_E',...
    'corrSelection_E',...
    'mental_E_error',...
    'display_E_postError',...
    'mental_E_task'};
for iVar = 1:length(times_to_check)
    [onset.(times_to_check{iVar}),...
        duration.(times_to_check{iVar})] = deal([]);
end

%% Now the task, 1 to three blocks depending on the training flag
nStartingBlock = 1;
interrupt_task = 0;

%% Lancement de la tâche
for iBlock = nStartingBlock:3
    switch iBlock
        case 1
            blockSize    = nTrainingPerf;
            doChoiceFlag = 0;
            doPerfFlag   = 1;
            tableName    = 'tableTrialTrainingPerf';
            
            %% Instructions
            textstring = 'Instructions';
            DrawMyText(display.window,textstring,ftsz_big,[255 255 255],[x,y]);
            textstring = 'appuyer sur une touche pour continuer';
            DrawMyText(display.window,textstring,ftsz_small,[100 100 100],[x,H*4/5]);
            Screen(display.window,'Flip');
            WaitSecs(0.2);
            KbWait;
            
            % - slide 1
            textstring = ['Dans ce test, vous allez devoir choisir entre deux offres. ',...
                'Chaque offre est composée d''une somme d''argent et d''un exercice à réaliser pour l''obtenir.'];
            Screen('TextSize', display.window, ftsz_mid);
            DrawFormattedText(display.window, textstring,'center','center',[255 255 255], 50, 0, 0, 2, 0, []);
            Screen(display.window,'Flip');
            WaitSecs(1);
            KbWait;
            % - slide 2
            textstring = ['Nous allons vous présenter cet exercice, on vous demandera de toucher des points dans un',...
                ' ordre particulier.'];
            Screen('TextSize', display.window, ftsz_mid);
            DrawFormattedText(display.window, textstring,'center','center',[255 255 255], 50, 0, 0, 2, 0, []);
            Screen(display.window,'Flip');
            WaitSecs(1);
            KbWait;
            
            % display
            textstring = 'Entrainement aux exercices';
            DrawMyText(display.window,textstring,ftsz_big,[255 255 255],[x,y]);
            textstring = 'appuyer sur une touche pour continuer';
            DrawMyText(display.window,textstring,ftsz_small,[100 100 100],[x,H*4/5]);
            Screen(display.window,'Flip');
            WaitSecs(0.2);
            KbWait;
            
            wait4release()
            
        case 2
            blockSize    = nTrainingChoice;
            doChoiceFlag = 1;
            doPerfFlag   = 0;
            tableName    = 'tableTrialTrainingChoice';
            
            % - Instructions slide 1
            textstring = 'Pour le choix, on vous demande simplement de sélectionner l''offre que vous préférez. ';
            Screen('TextSize', display.window, ftsz_mid);
            DrawFormattedText(display.window, textstring,'center','center',[255 255 255], 50, 0, 0, 2, 0, []);
            Screen(display.window,'Flip');
            WaitSecs(1);
            KbWait;
            % - slide 2
            textstring = 'Attention : à la fin de vos choix, certains seront tirés au sort et vous devrez réaliser la force choisie.';
            Screen('TextSize', display.window, ftsz_mid);
            DrawFormattedText(display.window, textstring,'center','center',[255 255 255], 50, 0, 0, 2, 0, []);
            Screen(display.window,'Flip');
            WaitSecs(1);
            KbWait;
            
            % Instructions sépcifiques
            textstring = 'Entrainement';
            Screen('TextSize', display.window, ftsz_mid);
            DrawFormattedText(display.window, textstring,'center','center',[255 255 255], 50, 0, 0, 2, 0, []);
            textstring = 'Vous allez réaliser deux choix pour vous entrainer';
            DrawMyText(display.window,textstring,ftsz_mid,[255 255 255],[x,H*3/5]);
            textstring = 'appuyer sur une touche pour continuer';
            DrawMyText(display.window,textstring,ftsz_small,[100 100 100],[x,H*4/5]);
            Screen(display.window,'Flip');
            WaitSecs(0.2);
            KbWait;
            wait4release()
            
        case 3
            blockSize    = nTrial;
            doChoiceFlag = 1;
            doPerfFlag   = 0; % Mais sera conditionné par le tirage aléatoire en début de script
            tableName    = 'tableTrial';
            % Instructions sépcifiques
            textstring = 'Prêt à débuter ?';
            DrawMyText(display.window,textstring,ftsz_big,[255 255 255],[x,y]);
            textstring = 'appuyer sur une touche pour continuer';
            DrawMyText(display.window,textstring,ftsz_small,[100 100 100],[x,H*4/5]);
            Screen(display.window,'Flip');
            WaitSecs(0.2);
            KbWait;
    end
    
    for iTrial = 1:blockSize
        %% Choices
        % Appuyer sur ECHAP pour quitter
        if doChoiceFlag == 1
            if interrupt_task
                break
            end
            repeat = 0;
            Screen('TextSize', display.window, ftsz_mid);
            
            % Check Response
            exit=0;
            startime = GetSecs;
            isLeftChoice = NaN;
            buttons = 0;
            while exit==0
                % refresh screen
                DrawMyText(display.window,'Que préférez-vous ?',ftsz_small,[100 100 100],[x,y-300]);
                DrawMyText(display.window, double([ num2str(results.(tableName).easyCogEffortAmount(iTrial)) ' €' ]) ,ftsz_small,[255 255 255],[ (results.(tableName).sideHardCogEffort(iTrial)+0.5)*x,y*7/8]);
                DrawMyText(display.window, double([ num2str(results.(tableName).hardCogEffortAmount(iTrial)) ' €' ]) ,ftsz_small,[255 255 255],[ (-(results.(tableName).sideHardCogEffort(iTrial)-1)+0.5)*x,y*7/8]);
                DrawMyText(display.window, results.(tableName).easyCogEffortLabel{iTrial} ,ftsz_small,[255 255 255],[ (results.(tableName).sideHardCogEffort(iTrial)+0.5)*x,y*9/8]);
                DrawMyText(display.window, results.(tableName).hardCogEffortLabel{iTrial} ,ftsz_small,[255 255 255],[ (-(results.(tableName).sideHardCogEffort(iTrial)-1)+0.5)*x,y*9/8]);
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
                        interrupt_task=1;
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
                        if isLeftChoice == -1;isLeftChoice=0;end
                        choicePositions = [xMouse, yMouse];
                        timedown=GetSecs;
                        repeat=0;
                        exit=1;
                    end
                WaitSecs(0.007);
                isHardCogEffortChoice = isLeftChoice == results.(tableName).sideHardCogEffort(iTrial);
                
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
                easyCogEffortColor = [255*(isHardCogEffortChoice==1) 255 255*(isHardCogEffortChoice==1)];
                hardCogEffortColor = [255*(isHardCogEffortChoice==0) 255 255*(isHardCogEffortChoice==0)];
                DrawMyText(display.window,'Que préférez-vous ?',ftsz_small,[100 100 100],[x,y-300]);
                DrawMyText(display.window, double([ num2str(results.(tableName).easyCogEffortAmount(iTrial)) ' €' ]) ,ftsz_small,easyCogEffortColor,[ (results.(tableName).sideHardCogEffort(iTrial)+0.5)*x,y*7/8]);
                DrawMyText(display.window, double([ num2str(results.(tableName).hardCogEffortAmount(iTrial)) ' €' ]) ,ftsz_small,hardCogEffortColor,[ (-(results.(tableName).sideHardCogEffort(iTrial)-1)+0.5)*x,y*7/8]);
                DrawMyText(display.window, results.(tableName).easyCogEffortLabel{iTrial} ,ftsz_small,easyCogEffortColor,[ (results.(tableName).sideHardCogEffort(iTrial)+0.5)*x,y*9/8]);
                DrawMyText(display.window, results.(tableName).hardCogEffortLabel{iTrial} ,ftsz_small,hardCogEffortColor,[ (-(results.(tableName).sideHardCogEffort(iTrial)-1)+0.5)*x,y*9/8]);
                Screen('LineStipple',display.window, 1, 2, mod(ceil((1:16)/8),2));
                Screen('DrawLine', display.window, [255 255 255]*0.5, x, y*1/2 ,  x, y*3/2, 3);
                Screen(display.window,'Flip');
                WaitSecs(blanktime);
            else
                % instruction: speed-up warning
                textstring = 'Temps écoulé.';
                DrawMyText(display.window,textstring,ftsz_big,[255 0 0],[x,y]);
                textstring = 'Répondez plus rapidement.';
                DrawMyText(display.window,textstring,ftsz_big,[255 0 0],[x,y*1.2]);
                Screen(display.window,'Flip');
                WaitSecs(blanktime+1);
            end
            
            results.(tableName).isLeftChoice(iTrial) = isLeftChoice; % 1 = left ; 2 = right
            results.(tableName).isHardCogEffortChoice(iTrial) = isHardCogEffortChoice; % 1 = left ; 2 = right
            results.(tableName).RTchoice(iTrial) = RT;
            if iBlock == 3
                try
                    results.tableSupp.choicePositions{iTrial} = choicePositions;
                catch
                    results.tableSupp.choicePositions{iTrial} = nan;
                end
            end
            
        end

%         [~,timenow1,~,~,~] = Screen(display.window,'Flip');
%         onset.cross_ITI = [onset.cross_ITI; timenow1];
%         WaitSecs(t_cross_ITI);
% 
%         timenow2 = GetSecs;
%         dur = timenow2 - timenow1;
%         duration.cross_ITI = [duration.cross_ITI; dur];
        %
        % initialize RT/dot
        rt_E_task_dots = NaN(1,nDots);
        rtAllDots = [];
        dotSequence = {};
        
        if doPerfFlag == 1
            %% Training
            
            % training difficulty
            % two first trials = 0 difficulty
            %             switch iBlock
            %                 case 1 % Dans ce cas on est à l'entrainement donc on propose les 5 niveaux
            chosenDiff         = results.(tableName).CogEffort(iTrial);
            chosenInstructions = results.(tableName).CogEffortInstructions{iTrial};
            chosenLongInstruction1 = listLongInstructions1{results.(tableName).CogEffort(iTrial)+1};
            chosenLongInstruction2 = listLongInstructions2{results.(tableName).CogEffort(iTrial)+1};
            chosenLongInstruction2 = double(chosenLongInstruction2);
            gridName = 'training';
            %         %                 case 3 % Dans ce cas on propose l'effort choisi pendant le choix
            %         if results.(tableName).isHardCogEffortChoice(iTrial)
            %             chosenDiff         = results.(tableName).hardCogEffort(iTrial);
            %             chosenInstructions = results.(tableName).hardCogEffortInstructions{iTrial};
            %         else
            %             chosenDiff         = results.(tableName).easyCogEffort(iTrial);
            %             chosenInstructions = results.(tableName).easyCogEffortInstructions{iTrial};
            %         end
            %         gridName = 'performance';
            %             end
            % extract corresponding dot location, dot names and for
            % training block, position order and rank of dot selection
            dots_xyPos      = mental_E_task.(gridName).dots_xyPos(:,:,iTrial);
            dot_nm          = mental_E_task.(gridName).dot_nm(:,iTrial);
            dot_nm_xyPos    = mental_E_task.(gridName).dot_nm_xyPos(:,:,iTrial);
            dots_xyPos_ref  = mental_E_task.(gridName).dots_xyPos_ref(:,iTrial);
            
            %% display on screen the information about the trial to be performed (incentive and difficulty level) before starting it
            Screen('TextSize', display.window, ftsz_small);
%             DrawFormattedText(display.window, chosenLongInstruction,...
%                 'center',2*y/3, white, wrapat_nb_char,0,0,2,0, center_pos);
            Screen('DrawText',display.window, chosenLongInstruction1,...
            x/3,y, white);
            Screen('DrawText',display.window, chosenLongInstruction2,...
            x/3,5*y/4, white);
            [~,timenow1,~,~,~] = Screen(display.window,'Flip');
            WaitSecs(t_dispEtime);
            timenow2 = GetSecs;
            dur = timenow2 - timenow1;
            onset.display_E_information     = [onset.display_E_information; timenow1];
            duration.display_E_information  = [duration.display_E_information; dur];
            
            %% perform the trial selected (without temporal constraint)
            % display the points that have to be linked with all the relevant information
            % display on screen on which order the dimensions have to be selected
            % display the order of the colours
            DrawFormattedText(display.window, chosenInstructions,...
                3*x/2,2*y/3, white, wrapat_nb_char,0,0,2,0, right_col_pos);
            
            % extract name for each dot
            [dot_nm, dot_nm_xyPos, dice_idx] = dot_nm_extraction(nDots, chosenDiff, stimuliPerDimension,...
                width_dots, hight_dots,...
                dot_nm, dot_nm_xyPos);
            
            % display the corresponding dots on screen
            Screen('TextFont', display.window, 'harrington');
            %change the police to 'harrigton' to differenctiate c and C
            
            for iDot = 1:nDots
                % Center the rectangle on the centre of the dot
                centeredRect = CenterRectOnPointd(baseRect, dots_xyPos(1,iDot)+x, dots_xyPos(2,iDot)+y);
                Screen('FrameOval', display.window, white,...
                    centeredRect,circle_thick);
                % add the number corresponding to each dot
                Screen('DrawText', display.window, dot_nm{iDot},...
                    dot_nm_xyPos(1,iDot), dot_nm_xyPos(2,iDot),...
                    white);
                % add dice numbers if necessary
                if chosenDiff >= 3 % no dice for lower difficulties
                    if dice_idx(iDot) > 0 % only for the dice case
                        draw_dice_dots(display.window, dice_idx(iDot), dots_xyPos(:,iDot), dice_dotSize, dice_dot_dist, screen_center, white);
                    end
                end
            end
            
            [~,timenow1,~,~,~] = Screen(display.window,'Flip');
            lastTimeStamp = timenow1;
            start_mental_E = timenow1;
            onset.display_E = [onset.display_E; timenow1];
            onset.mental_E_task = [onset.mental_E_task; timenow1];
            
            %% check the subject responses, when a correct option is selected display the circles in different colours
            jDot = 1;
            nErrors = 0;
            while jDot <= nDots
                if mouse
                    [xMouse,yMouse,buttons] = recordResponse(display.window); % window does not seem to work sadly...
                elseif touch
                    [xMouse,yMouse,buttons] = recordResponse(display.window);
                    %                     mental_E_task.(gridName).cursor.fingerPress{1,iTrial} = [mental_E_task.(gridName).cursor.fingerPress{1,iTrial}; buttons(4)];
                end
                % record position
                positionTime = GetSecs;
                % Save it in the supp results
                results.tableSupp.perfPositions{iTrial}     = [results.tableSupp.perfPositions{iTrial} ; xMouse yMouse];
                results.tableSupp.perfPositionsTime{iTrial} = [results.tableSupp.perfPositionsTime{iTrial} positionTime];
                
                if chosenDiff > 0 % for all cases except reference
                    % keep displaying the order of the dim on screen
                    Screen('TextFont', display.window, 'arial');
                    DrawFormattedText(display.window,chosenInstructions,...
                        3*x/2,2*y/3, white, wrapat_nb_char,0,0,2,0, right_col_pos);
                    Screen('TextFont', display.window, 'harrington');
                    
                    %% check that the subject did not click on a wrong target (and if so, display a red cross on the target for a short delay)
                    timenow1 = GetSecs;
                    if ~isempty(onset.corrSelection_E)
                        last_correct_time = max(onset.corrSelection_E);
                    else
                        last_correct_time = 0;
                    end
                    
                    for iDot_errorCheck = 1:nDots
                        if iDot_errorCheck ~= jDot &&...
                                (timenow1 - last_correct_time > time_release_tolerance) &&...
                                ((xMouse >= dots_xyPos(1,iDot_errorCheck) + x - pix_conf) && (xMouse <= dots_xyPos(1,iDot_errorCheck) + x + pix_conf) &&...
                                (yMouse >= dots_xyPos(2,iDot_errorCheck) + y - pix_conf) && (yMouse <= dots_xyPos(2,iDot_errorCheck) + y + pix_conf)) &&...
                                ((mouse || touch) && any(buttons~=0))
                            buttons = 0;
                            
                            % get incorrect RT
                            timenow3 = GetSecs;
                            uncorrectRT = timenow3 - lastTimeStamp;
                            rtAllDots = [rtAllDots uncorrectRT];
                            lastTimeStamp = timenow3;
                            
                            % DRAW THE DOTS
                            for iDot = 1:nDots
                                % colour of the circle depends on if
                                % not-selected/last-selected/selected
                                % previously (but not the last)
                                if iDot == iDot_errorCheck
                                    colour_dot = red;
                                elseif iDot < (jDot - 1) && jDot > 1 % all previously selected dots (except the last one) in orange
                                    colour_dot = grey;
                                elseif iDot == (jDot - 1) % last selected dot
                                    colour_dot = green;
                                else % non-selected dots in white
                                    colour_dot = white;
                                end
                                % add dice numbers if necessary
                                if chosenDiff >= 3 % no dice for lower difficulties
                                    if dice_idx(iDot) > 0 % only for the dice case
                                        draw_dice_dots(display.window, dice_idx(iDot), dots_xyPos(:,iDot), dice_dotSize, dice_dot_dist, screen_center, colour_dot);
                                    end
                                end
                                
                                % display the circle around each datapoint
                                % Center the rectangle on the centre of the dot
                                centeredRect = CenterRectOnPointd(baseRect, dots_xyPos(1,iDot)+x, dots_xyPos(2,iDot)+y);
                                Screen('FrameOval', display.window, colour_dot,...
                                    centeredRect, circle_thick);
                                
                                % increment number for each dot
                                % add the number corresponding to each dot
                                Screen('DrawText', display.window, dot_nm{iDot},...
                                    dot_nm_xyPos(1,iDot), dot_nm_xyPos(2,iDot),...
                                    colour_dot);
                            end
                            
                            [~,timenow1,~,~,~] = Screen(display.window,'Flip');
                            onset.mental_E_error = [onset.mental_E_error; timenow1];
                            
                            % Increment error count
                            nErrors = nErrors+1;
                            
                            % add the incorrect dot to the sequence
                            if isempty(dot_nm{iDot_errorCheck})
                                dotSequence{length(rtAllDots)} = ['d',num2str(dice_idx(iDot_errorCheck))];
                            else
                                dotSequence{length(rtAllDots)} = dot_nm{iDot_errorCheck};
                            end
                            
                            WaitSecs(error_TimeWait);
                            timenow2 = GetSecs;
                            dur = timenow2 - timenow1;
                            duration.mental_E_error = [duration.mental_E_error; dur];
                            
                            %% back to normal display after error message displayed for the determined time
                            % keep displaying the order of the dim on screen
                            Screen('TextFont', display.window, 'arial');
                            DrawFormattedText(display.window,chosenInstructions,...
                                3*x/2,2*y/3, white, wrapat_nb_char,0,0,2,0, right_col_pos);
                            Screen('TextFont', display.window, 'harrington');
                            
                            % DRAW THE DOTS
                            for iDot = 1:nDots
                                % colour of the circle depends on if
                                % not-selected/last-selected/selected
                                % previously (but not the last)
                                if iDot < (jDot - 1) && jDot > 1 % all previously selected dots (except the last one) in orange
                                    colour_dot = grey;
                                elseif iDot == (jDot - 1) % last selected dot
                                    colour_dot = green;
                                else % non-selected dots in white
                                    colour_dot = white;
                                end
                                % add dice numbers if necessary
                                if chosenDiff >= 3 % no dice for lower difficulties
                                    if dice_idx(iDot) > 0 % only for the dice case
                                        draw_dice_dots(display.window, dice_idx(iDot), dots_xyPos(:,iDot), dice_dotSize, dice_dot_dist, screen_center, colour_dot);
                                    end
                                end
                                
                                % display the circle around each datapoint
                                % Center the rectangle on the centre of the dot
                                centeredRect = CenterRectOnPointd(baseRect, dots_xyPos(1,iDot)+x, dots_xyPos(2,iDot)+y);
                                Screen('FrameOval', display.window, colour_dot,...
                                    centeredRect, circle_thick);
                                
                                % increment number for each dot
                                % add the number corresponding to each dot
                                Screen('DrawText', display.window, dot_nm{iDot},...
                                    dot_nm_xyPos(1,iDot), dot_nm_xyPos(2,iDot),...
                                    colour_dot);
                            end
                            [~,timenow1,~,~,~] = Screen(display.window,'Flip');
                            onset.display_E_postError = [onset.display_E_postError; timenow1];
                        end
                    end
                    
                    %% check if correct target selected and link the dots accordingly
                    % keep displaying the order of the dim on screen
                    Screen('TextFont', display.window, 'arial');
                    DrawFormattedText(display.window,chosenInstructions,...
                        3*x/2,2*y/3, white, wrapat_nb_char,0,0,2,0, right_col_pos);
                    Screen('TextFont', display.window, 'harrington');
                    
                    if ((xMouse >= dots_xyPos(1,jDot) + x - pix_conf) && (xMouse <= dots_xyPos(1,jDot) + x + pix_conf) &&...
                            (yMouse >= dots_xyPos(2,jDot) + y - pix_conf) && (yMouse <= dots_xyPos(2,jDot) + y + pix_conf)) &&...
                            ((mouse || touch) && any(buttons~=0))
                        if mouse || touch; buttons = 0; end
                        timenow1 = GetSecs;
                        onset.corrSelection_E = [onset.corrSelection_E; timenow1];
                        % save RT for each dot selected
                        if jDot == 1
                            rt_E_task_dots(jDot) = onset.corrSelection_E(end) - onset.display_E(end);
                            rtAllDots = [rtAllDots timenow1-lastTimeStamp];
                        else
                            rt_E_task_dots(jDot) = onset.corrSelection_E(end) - onset.corrSelection_E(end - 1);
                            rtAllDots = [rtAllDots timenow1-lastTimeStamp];
                        end
                        
                        % update list keeping track of the dot selected
                        if isempty(dot_nm{jDot})
                            dotSequence{length(rtAllDots)} = ['d',num2str(dice_idx(jDot))];
                        else
                            dotSequence{length(rtAllDots)} = dot_nm{jDot};
                        end
                        
                        % DRAW THE DOTS
                        for iDot = 1:nDots
                            % colour of the circle depends on if
                            % not-selected/last-selected/selected
                            % previously (but not the last)
                            if iDot < jDot && jDot > 1 % all previously selected dots (except the last one) in orange
                                colour_dot = grey;
                            elseif iDot == jDot % last selected dot
                                colour_dot = green;
                            else % non-selected dots in white
                                colour_dot = white;
                            end
                            % add dice numbers if necessary
                            if chosenDiff >= 3 % no dice for lower difficulties
                                if dice_idx(iDot) > 0 % only for the dice case
                                    draw_dice_dots(display.window, dice_idx(iDot), dots_xyPos(:,iDot), dice_dotSize, dice_dot_dist, screen_center, colour_dot);
                                end
                            end
                            
                            % display the circle around each datapoint
                            % Center the rectangle on the centre of the dot
                            centeredRect = CenterRectOnPointd(baseRect, dots_xyPos(1,iDot)+x, dots_xyPos(2,iDot)+y);
                            Screen('FrameOval', display.window, colour_dot,...
                                centeredRect, circle_thick);
                            
                            % increment number for each dot
                            % add the number corresponding to each dot
                            Screen('DrawText', display.window, dot_nm{iDot},...
                                dot_nm_xyPos(1,iDot), dot_nm_xyPos(2,iDot),...
                                colour_dot);
                        end
                        
                        [~,timenow1,~,~,~] = Screen(display.window,'Flip');
                        onset.corrSelection_E = [onset.corrSelection_E; timenow1];
                        jDot = jDot + 1;
                        lastTimeStamp = timenow1;
                    end
                    
                elseif chosenDiff == 0 % reference selected : particular case since there is no
                    % specific order defined about how to select the different dots together
                    % DRAW THE DOTS
                    for iDot = 1:nDots
                        % adapt the colour for the dots that already have
                        % been selected
                        if dots_xyPos_ref(iDot) >= 1 && dots_xyPos_ref(iDot) < max( dots_xyPos_ref )% datapoints previously selected in grey (except last selected in green)
                            colour_dot = grey;
                            
                        elseif jDot > 1 && dots_xyPos_ref(iDot) == max( dots_xyPos_ref ) % (when no dot has been selected yet, maximum = 0 = all dots)
                            colour_dot = green;
                            
                        elseif (dots_xyPos_ref(iDot) == 0 &&...
                                (xMouse >= dots_xyPos(1,iDot) + x - pix_conf) && (xMouse <= dots_xyPos(1,iDot) + x + pix_conf) &&...
                                (yMouse >= dots_xyPos(2,iDot) + y - pix_conf) && (yMouse <= dots_xyPos(2,iDot) + y + pix_conf)) &&...
                                ((mouse || touch) && any(buttons~=0)) % last datapoint selected in green
                            if mouse || touch; buttons = 0; end
                            colour_dot = green;
                            
                            timenow1 = GetSecs;
                            onset.corrSelection_E = [onset.corrSelection_E; timenow1];
                            
                            % save RT for each dot selected
                            if jDot == 1
                                rt_E_task_dots(jDot) = onset.corrSelection_E(end) - onset.display_E(end);
                                rtAllDots = [rtAllDots timenow1-lastTimeStamp];
                            else
                                rt_E_task_dots(jDot) = onset.corrSelection_E(end) - onset.corrSelection_E(end - 1);
                                rtAllDots = [rtAllDots timenow1-lastTimeStamp];
                            end
                            lastTimeStamp = timenow1;
                            
                            % update list keeping track of the dots already
                            % selected
                            prev_max_dot_rank = max( dots_xyPos_ref );
                            dots_xyPos_ref(iDot) = 1 + prev_max_dot_rank; % extract the order the dots have been selected!
                            
                            jDot = jDot + 1;
                            
                        else % other datapoints in white (= not-selected yet)
                            colour_dot = white;
                        end
                        
                        % display all the datapoints on screen
                        % Center the rectangle on the centre of the dot
                        centeredRect = CenterRectOnPointd(baseRect, dots_xyPos(1,iDot)+x, dots_xyPos(2,iDot)+y);
                        % display all the datapoints on screen
                        Screen('FrameOval', display.window, colour_dot,...
                            centeredRect, circle_thick);
                    end
                    [~,timenow1,~,~,~] = Screen(display.window,'Flip');
                end
                
            end
            Screen('TextFont', display.window, 'arial');
            
            % extract the global RT from start to end of mental effort task
            end_mental_E        = timenow1;
            rt_E_trial          = end_mental_E - start_mental_E;
            results.(tableName).RTperf(iTrial)        = rt_E_trial;
            results.tableSupp.perfSequence{iTrial}            = dotSequence;
            results.tableSupp.perfCorrectSequenceTime{iTrial} = rt_E_task_dots;
            results.tableSupp.perfSequenceTime{iTrial}        = rtAllDots;
            results.(tableName).perfErrors(iTrial)            = nErrors;
        end
    end
end

%% Performance realisation
% some trials (nRealPerf)are performed by the participant

% - Instructions
textstring = 'Les choix sont terminés. Nous avons tiré au sort certains de vos choix : vous devez les réaliser.';
Screen('TextSize', display.window, ftsz_mid);
DrawFormattedText(display.window, textstring,'center','center',[255 255 255], 50, 0, 0, 2, 0, []);
textstring = 'appuyer sur une touche pour continuer';
DrawMyText(display.window,textstring,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(1);
KbWait;
% Instructions spécifiques
textstring = 'Réalisation de vos choix !';
Screen('TextSize', display.window, ftsz_mid);
DrawFormattedText(display.window, textstring,'center','center',[255 255 255], 50, 0, 0, 2, 0, []);
textstring = 'appuyer sur une touche pour continuer';
DrawMyText(display.window,textstring,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(0.2);
KbWait;
wait4release()


for iTrial = 1:nTrial
    tableName    = 'tableTrial';
    if results.tableTrial.doPerf(iTrial)
        % short fixation cross between choice trials and effort actual performance
        Screen('DrawTexture',display.window,pic_cross,[],rect_cross);
        % onset
        [~,timenow1,~,~,~] = Screen(display.window,'Flip');
        %             onset.cross_ITI = [onset.cross_ITI; timenow1];
        WaitSecs(t_cross_ITI);
        % duration
        timenow2 = GetSecs;
        dur = timenow2 - timenow1;
        duration.cross_ITI = [duration.cross_ITI; dur];
        
        % initialize RT/dot
        rt_E_task_dots = NaN(1,nDots);
        rtAllDots = [];
        dotSequence = {};
        
        %% select the effort trials to be performed
        
        % training difficulty
        % two first trials = 0 difficulty
        %             switch iBlock
        %                 case 1 % Dans ce cas on est à l'entrainement donc on propose les 5 niveaux
        %                     chosenDiff         = results.(tableName).CogEffort(iTrial);
        %                     chosenInstructions = results.(tableName).CogEffortInstructions{iTrial};
        %                     chosenLongInstruction = listLongInstructions{results.(tableName).CogEffort(iTrial)+1};
        %                     gridName = 'training';
        %                 case 3 % Dans ce cas on propose l'effort choisi pendant le choix
        if results.(tableName).isHardCogEffortChoice(iTrial)
            chosenDiff         = results.(tableName).hardCogEffort(iTrial);
            chosenInstructions = results.(tableName).hardCogEffortInstructions{iTrial};
        else
            chosenDiff         = results.(tableName).easyCogEffort(iTrial);
            chosenInstructions = results.(tableName).easyCogEffortInstructions{iTrial};
        end
        gridName = 'performance';
        %             end
        % extract corresponding dot location, dot names and for
        % training block, position order and rank of dot selection
        dots_xyPos      = mental_E_task.(gridName).dots_xyPos(:,:,iTrial);
        dot_nm          = mental_E_task.(gridName).dot_nm(:,iTrial);
        dot_nm_xyPos    = mental_E_task.(gridName).dot_nm_xyPos(:,:,iTrial);
        dots_xyPos_ref  = mental_E_task.(gridName).dots_xyPos_ref(:,iTrial);
        
        %% display on screen the information about the trial to be performed (incentive and difficulty level) before starting it 
        Screen('TextSize', display.window, ftsz_small);
        DrawFormattedText(display.window, chosenInstructions,...
            'center',2*y/3, white, wrapat_nb_char,0,0,2,0, center_pos);
        
        [~,timenow1,~,~,~] = Screen(display.window,'Flip');
        WaitSecs(t_dispEtime);
        timenow2 = GetSecs;
        dur = timenow2 - timenow1;
        onset.display_E_information     = [onset.display_E_information; timenow1];
        duration.display_E_information  = [duration.display_E_information; dur];
        
        %% perform the trial selected (without temporal constraint)
        % display the points that have to be linked with all the relevant information
        % display on screen on which order the dimensions have to be selected
        % display the order of the colours
        DrawFormattedText(display.window, chosenInstructions,...
            3*x/2,2*y/3, white, wrapat_nb_char,0,0,2,0, right_col_pos);
        
        Screen('TextSize', display.window, ftsz_small);
        % extract name for each dot
        [dot_nm, dot_nm_xyPos, dice_idx] = dot_nm_extraction(nDots, chosenDiff, stimuliPerDimension,...
            width_dots, hight_dots,...
            dot_nm, dot_nm_xyPos);
        
        Screen('TextFont', display.window, 'harrington');
        %change the police to 'harrigton' to differenctiate c and C
        
        % display the corresponding dots on screen
        for iDot = 1:nDots
            % Center the rectangle on the centre of the dot
            centeredRect = CenterRectOnPointd(baseRect, dots_xyPos(1,iDot)+x, dots_xyPos(2,iDot)+y);
            Screen('FrameOval', display.window, white,...
                centeredRect,circle_thick);
            % add the number corresponding to each dot
            Screen('DrawText', display.window, dot_nm{iDot},...
                dot_nm_xyPos(1,iDot), dot_nm_xyPos(2,iDot),...
                white);
            % add dice numbers if necessary
            if chosenDiff >= 3 % no dice for lower difficulties
                if dice_idx(iDot) > 0 % only for the dice case
                    draw_dice_dots(display.window, dice_idx(iDot), dots_xyPos(:,iDot), dice_dotSize, dice_dot_dist, screen_center, white);
                end
            end
        end
        
        [~,timenow1,~,~,~] = Screen(display.window,'Flip');
        lastTimeStamp = timenow1;
        start_mental_E = timenow1;
        onset.display_E = [onset.display_E; timenow1];
        onset.mental_E_task = [onset.mental_E_task; timenow1];
        
        %% check the subject responses, when a correct option is selected display the circles in different colours
        jDot = 1;
        nErrors = 0;
        while jDot <= nDots
            if mouse
                [xMouse,yMouse,buttons] = recordResponse(display.window); % window does not seem to work sadly...
            elseif touch
                [xMouse,yMouse,buttons] = recordResponse(display.window);
                %                     mental_E_task.(gridName).cursor.fingerPress{1,iTrial} = [mental_E_task.(gridName).cursor.fingerPress{1,iTrial}; buttons(4)];
            end
            % record position
%             positionTime = GetSecs;
            % No saving : we only save the traings
%             results.tableSupp.perfPositions{iTrial}     = [results.tableSupp.perfPositions{iTrial} ; xMouse yMouse];
%             results.tableSupp.perfPositionsTime{iTrial} = [results.tableSupp.perfPositionsTime{iTrial} positionTime];
            
            if chosenDiff > 0 % for all cases except reference
                % keep displaying the order of the dim on screen
                DrawFormattedText(display.window,chosenInstructions,...
                    3*x/2,2*y/3, white, wrapat_nb_char,0,0,2,0, right_col_pos);
                
                %% check that the subject did not click on a wrong target (and if so, display a red cross on the target for a short delay)
                timenow1 = GetSecs;
                if ~isempty(onset.corrSelection_E)
                    last_correct_time = max(onset.corrSelection_E);
                else
                    last_correct_time = 0;
                end
                
                for iDot_errorCheck = 1:nDots
                    if iDot_errorCheck ~= jDot &&...
                            (timenow1 - last_correct_time > time_release_tolerance) &&...
                            ((xMouse >= dots_xyPos(1,iDot_errorCheck) + x - pix_conf) && (xMouse <= dots_xyPos(1,iDot_errorCheck) + x + pix_conf) &&...
                            (yMouse >= dots_xyPos(2,iDot_errorCheck) + y - pix_conf) && (yMouse <= dots_xyPos(2,iDot_errorCheck) + y + pix_conf)) &&...
                            ((mouse || touch) && any(buttons~=0))
                        if mouse || touch; buttons = 0; end
                        
                        % get incorrect RT
                        timenow3 = GetSecs;
                        uncorrectRT = timenow3 - lastTimeStamp;
                        rtAllDots = [rtAllDots uncorrectRT];
                        lastTimeStamp = timenow3;
                        % DRAW THE DOTS
                        
                        for iDot = 1:nDots
                            % colour of the circle depends on if
                            % not-selected/last-selected/selected
                            % previously (but not the last)
                            if iDot == iDot_errorCheck
                                colour_dot = red;
                            elseif iDot < (jDot - 1) && jDot > 1 % all previously selected dots (except the last one) in orange
                                colour_dot = grey;
                            elseif iDot == (jDot - 1) % last selected dot
                                colour_dot = green;
                            else % non-selected dots in white
                                colour_dot = white;
                            end
                            % add dice numbers if necessary
                            if chosenDiff >= 3 % no dice for lower difficulties
                                if dice_idx(iDot) > 0 % only for the dice case
                                    draw_dice_dots(display.window, dice_idx(iDot), dots_xyPos(:,iDot), dice_dotSize, dice_dot_dist, screen_center, colour_dot);
                                end
                            end
                            
                            % display the circle around each datapoint
                            % Center the rectangle on the centre of the dot
                            centeredRect = CenterRectOnPointd(baseRect, dots_xyPos(1,iDot)+x, dots_xyPos(2,iDot)+y);
                            Screen('FrameOval', display.window, colour_dot,...
                                centeredRect, circle_thick);
                            
                            % increment number for each dot
                            % add the number corresponding to each dot
                            Screen('DrawText', display.window, dot_nm{iDot},...
                                dot_nm_xyPos(1,iDot), dot_nm_xyPos(2,iDot),...
                                colour_dot);
                        end
                        
                        % draw red cross on the wrongly selected target
                        %                             start_x1_error_line = dots_xyPos(1,iDot_errorCheck) + x - dotSize/(2*sqrt(2));
                        %                             start_y1_error_line = dots_xyPos(2,iDot_errorCheck) + y - dotSize/(2*sqrt(2));
                        %                             end_x1_error_line   = dots_xyPos(1,iDot_errorCheck) + x + dotSize/(2*sqrt(2));
                        %                             end_y1_error_line   = dots_xyPos(2,iDot_errorCheck) + y + dotSize/(2*sqrt(2));
                        %                             start_x2_error_line = dots_xyPos(1,iDot_errorCheck) + x + dotSize/(2*sqrt(2));
                        %                             start_y2_error_line = dots_xyPos(2,iDot_errorCheck) + y - dotSize/(2*sqrt(2));
                        %                             end_x2_error_line   = dots_xyPos(1,iDot_errorCheck) + x - dotSize/(2*sqrt(2));
                        %                             end_y2_error_line   = dots_xyPos(2,iDot_errorCheck) + y + dotSize/(2*sqrt(2));
                        %                             Screen('DrawLine', display.window, red,...
                        %                                 start_x1_error_line, start_y1_error_line,...
                        %                                 end_x1_error_line, end_y1_error_line,...
                        %                                 line_thick);
                        %                             Screen('DrawLine', display.window, red,...
                        %                                 start_x2_error_line, start_y2_error_line,...
                        %                                 end_x2_error_line, end_y2_error_line,...
                        %                                 line_thick);
                        [~,timenow1,~,~,~] = Screen(display.window,'Flip');
                        onset.mental_E_error = [onset.mental_E_error; timenow1];
                        
                        % Increment error count
                        nErrors = nErrors+1;
                        
                        % add the incorrect dot to the sequence
                        if isempty(dot_nm{iDot_errorCheck})
                            dotSequence{length(rtAllDots)} = ['d',num2str(dice_idx(iDot_errorCheck))];
                        else
                            dotSequence{length(rtAllDots)} = dot_nm{iDot_errorCheck};
                        end
                        
                        WaitSecs(error_TimeWait);
                        timenow2 = GetSecs;
                        dur = timenow2 - timenow1;
                        duration.mental_E_error = [duration.mental_E_error; dur];
                        
                        %% back to normal display after error message displayed for the determined time
                        % keep displaying the order of the dim on screen
                        DrawFormattedText(display.window,chosenInstructions,...
                            3*x/2,2*y/3, white, wrapat_nb_char,0,0,2,0, right_col_pos);
                        
                        % DRAW THE DOTS
                        for iDot = 1:nDots
                            % colour of the circle depends on if
                            % not-selected/last-selected/selected
                            % previously (but not the last)
                            if iDot < (jDot - 1) && jDot > 1 % all previously selected dots (except the last one) in orange
                                colour_dot = grey;
                            elseif iDot == (jDot - 1) % last selected dot
                                colour_dot = green;
                            else % non-selected dots in white
                                colour_dot = white;
                            end
                            % add dice numbers if necessary
                            if chosenDiff >= 3 % no dice for lower difficulties
                                if dice_idx(iDot) > 0 % only for the dice case
                                    draw_dice_dots(display.window, dice_idx(iDot), dots_xyPos(:,iDot), dice_dotSize, dice_dot_dist, screen_center, colour_dot);
                                end
                            end
                            % display the circle around each datapoint
                            % Center the rectangle on the centre of the dot
                            centeredRect = CenterRectOnPointd(baseRect, dots_xyPos(1,iDot)+x, dots_xyPos(2,iDot)+y);
                            Screen('FrameOval', display.window, colour_dot,...
                                centeredRect, circle_thick);
                            
                            % increment number for each dot
                            % add the number corresponding to each dot
                            Screen('DrawText', display.window, dot_nm{iDot},...
                                dot_nm_xyPos(1,iDot), dot_nm_xyPos(2,iDot),...
                                colour_dot);
                        end
                        [~,timenow1,~,~,~] = Screen(display.window,'Flip');
                        onset.display_E_postError = [onset.display_E_postError; timenow1];
                    end
                end
                
                %% check if correct target selected and link the dots accordingly
                % keep displaying the order of the dim on screen
                DrawFormattedText(display.window,chosenInstructions,...
                    3*x/2,2*y/3, white, wrapat_nb_char,0,0,2,0, right_col_pos);
                
                if ((xMouse >= dots_xyPos(1,jDot) + x - pix_conf) && (xMouse <= dots_xyPos(1,jDot) + x + pix_conf) &&...
                        (yMouse >= dots_xyPos(2,jDot) + y - pix_conf) && (yMouse <= dots_xyPos(2,jDot) + y + pix_conf)) &&...
                        ((mouse || touch) && any(buttons~=0))
                    if mouse || touch; buttons = 0; end
                    timenow1 = GetSecs;
                    onset.corrSelection_E = [onset.corrSelection_E; timenow1];
                    % save RT for each dot selected
                    if jDot == 1
                        rt_E_task_dots(jDot) = onset.corrSelection_E(end) - onset.display_E(end);
                        rtAllDots = [rtAllDots timenow1-lastTimeStamp];
                    else
                        rt_E_task_dots(jDot) = onset.corrSelection_E(end) - onset.corrSelection_E(end - 1);
                        rtAllDots = [rtAllDots timenow1-lastTimeStamp];
                    end
                    
                    % update list keeping track of the dot selected
                    if isempty(dot_nm{jDot})
                        dotSequence{length(rtAllDots)} = ['d',num2str(dice_idx(jDot))];
                    else
                        dotSequence{length(rtAllDots)} = dot_nm{jDot};
                    end
                    
                    % DRAW THE DOTS
                    for iDot = 1:nDots
                        % colour of the circle depends on if
                        % not-selected/last-selected/selected
                        % previously (but not the last)
                        if iDot < jDot && jDot > 1 % all previously selected dots (except the last one) in orange
                            colour_dot = grey;
                        elseif iDot == jDot % last selected dot
                            colour_dot = green;
                        else % non-selected dots in white
                            colour_dot = white;
                        end
                        % add dice numbers if necessary
                        if chosenDiff >= 3 % no dice for lower difficulties
                            if dice_idx(iDot) > 0 % only for the dice case
                                draw_dice_dots(display.window, dice_idx(iDot), dots_xyPos(:,iDot), dice_dotSize, dice_dot_dist, screen_center, colour_dot);
                            end
                        end
                        
                        % display the circle around each datapoint
                        % Center the rectangle on the centre of the dot
                        centeredRect = CenterRectOnPointd(baseRect, dots_xyPos(1,iDot)+x, dots_xyPos(2,iDot)+y);
                        Screen('FrameOval', display.window, colour_dot,...
                            centeredRect, circle_thick);
                        
                        % increment number for each dot
                        % add the number corresponding to each dot
                        Screen('DrawText', display.window, dot_nm{iDot},...
                            dot_nm_xyPos(1,iDot), dot_nm_xyPos(2,iDot),...
                            colour_dot);
                    end
                    
                    [~,timenow1,~,~,~] = Screen(display.window,'Flip');
                    onset.corrSelection_E = [onset.corrSelection_E; timenow1];
                    jDot = jDot + 1;
                    lastTimeStamp = timenow1;
                end
                
            elseif chosenDiff == 0 % reference selected : particular case since there is no
                % specific order defined about how to select the different dots together
                % DRAW THE DOTS
                for iDot = 1:nDots
                    % adapt the colour for the dots that already have
                    % been selected
                    if dots_xyPos_ref(iDot) >= 1 && dots_xyPos_ref(iDot) < max( dots_xyPos_ref )% datapoints previously selected in grey (except last selected in green)
                        colour_dot = grey;
                        
                    elseif jDot > 1 && dots_xyPos_ref(iDot) == max( dots_xyPos_ref ) % (when no dot has been selected yet, maximum = 0 = all dots)
                        colour_dot = green;
                        
                    elseif (dots_xyPos_ref(iDot) == 0 &&...
                            (xMouse >= dots_xyPos(1,iDot) + x - pix_conf) && (xMouse <= dots_xyPos(1,iDot) + x + pix_conf) &&...
                            (yMouse >= dots_xyPos(2,iDot) + y - pix_conf) && (yMouse <= dots_xyPos(2,iDot) + y + pix_conf)) &&...
                            ((mouse || touch) && any(buttons~=0)) % last datapoint selected in green
                        if mouse || touch; buttons = 0; end
                        colour_dot = green;
                        
                        timenow1 = GetSecs;
                        onset.corrSelection_E = [onset.corrSelection_E; timenow1];
                        
                        % save RT for each dot selected
                        if jDot == 1
                            rt_E_task_dots(jDot) = onset.corrSelection_E(end) - onset.display_E(end);
                            rtAllDots = [rtAllDots timenow1-lastTimeStamp];
                        else
                            rt_E_task_dots(jDot) = onset.corrSelection_E(end) - onset.corrSelection_E(end - 1);
                            rtAllDots = [rtAllDots timenow1-lastTimeStamp];
                        end
                        lastTimeStamp = timenow1;
                        
                        % update list keeping track of the dots already
                        % selected
                        prev_max_dot_rank = max( dots_xyPos_ref );
                        dots_xyPos_ref(iDot) = 1 + prev_max_dot_rank; % extract the order the dots have been selected!
                        
                        jDot = jDot + 1;
                        
                    else % other datapoints in white (= not-selected yet)
                        colour_dot = white;
                    end
                    
                    % display all the datapoints on screen
                    % Center the rectangle on the centre of the dot
                    centeredRect = CenterRectOnPointd(baseRect, dots_xyPos(1,iDot)+x, dots_xyPos(2,iDot)+y);
                    % display all the datapoints on screen
                    Screen('FrameOval', display.window, colour_dot,...
                        centeredRect, circle_thick);
                end
                [~,timenow1,~,~,~] = Screen(display.window,'Flip');
            end
            
        end
        
        Screen('TextFont', display.window, 'arial');
        
        % extract the global RT from start to end of mental effort task
        end_mental_E        = timenow1;
        rt_E_trial          = end_mental_E - start_mental_E;
        results.(tableName).RTperf(iTrial)        = rt_E_trial;
        results.(tableName).perfErrors(iTrial)            = nErrors;
    end
end
% display end

Screen(display.window,'Flip');
Screen('CloseAll');

%%%%%%%%%%%%%%%%%%%%%%%%%
%% Data saving
%-----------------------------------------------
if interrupt_task
    sub_data.(cfg.sessNber_str).tasks.taskChoice_CogEffort.completed...
        = false;
else; sub_data.(cfg.sessNber_str).tasks.taskChoice_CogEffort.completed...
        = true;
end
sub_data.(cfg.sessNber_str).tasks.taskChoice_CogEffort.results =        ...
    struct('tableTrialTrainingChoice', results.tableTrialTrainingChoice,...
    'tableTrialTrainingPerf',results.tableTrialTrainingPerf, 'data',    ...
    results.tableTrial, 'suppResults', results.tableSupp);

end

%% sub-functions
%   dot_nm_extraction
%   draw_dice_dots

function [dot_nm, dot_nm_xyPos, dice_idx] = dot_nm_extraction(nDots, curr_diff_level, stimuliPerDimension,...
    width_dots, hight_dots,...
    dot_nm, dot_nm_xyPos)
% [dot_nm, dot_nm_xyPos] = dot_nm_extraction(nDots, curr_diff_level, stimuliPerDimension,...
%     width_dots, hight_dots,...
%     dot_nm, dot_nm_xyPos)
% extracts the name corresponding to each dot and the [x,y] center position
% where to set the text
%
% INPUTS
% nDots: total number of dots per trial
%
% curr_diff_level: current difficulty level (value should be between 0 and
% 4)
%
% stimuliPerDimension: cell containing all the names (except for the dice
% dimension)
%
% width_dots, hight_dots: estimated x and y size of the text to center the
% text inside the dot
%
% INPUTS & OUTPUTS
% dot_nm: empty cell (for the current trial) to fill with the names
% corresponding to each dot
%
% dot_nm_xyPos: empty vector (for the current trial) to fill with the [x;y]
% coordinates corresponding to each dot text center
%
% ("pure") OUTPUT
% dice_idx: for difficulty level 3 and 4 indicates
%
%
%
% See also task_mental_EE_choice.m



% extract name for each dot
for iDot = 1:nDots % loop through dots
    
    if curr_diff_level == 0 % nothing
        dot_nm{iDot} = '';
        
    elseif curr_diff_level == 1 % numbers only
        dim = 1;
        dot_nm{iDot} = stimuliPerDimension{iDot, dim};
        % rearrange dot name position to center it
        dot_nm_xyPos(1,iDot) = dot_nm_xyPos(1,iDot) - width_dots(iDot,dim)/2; % left border
        dot_nm_xyPos(2,iDot) = dot_nm_xyPos(2,iDot) - hight_dots(iDot,dim)/2; % top border
        
    elseif curr_diff_level == 2 % numbers + letters 1/a/2/b/...
        % total number of items per dimension
        n_item_per_dim = nDots/curr_diff_level;
        % index for numbers
        nbers_idx = repmat([1,0],1,n_item_per_dim);
        nbers_idx(nbers_idx == 1) = 1:n_item_per_dim;
        % index for letters
        letters_idx = repmat([0,1],1,n_item_per_dim);
        letters_idx(letters_idx == 1) = 1:n_item_per_dim;
        
        % extract the corresponding number or letter
        if nbers_idx(iDot) > 0
            dim = 1;
            dot_nm{iDot} = stimuliPerDimension{nbers_idx(iDot),dim};
        elseif letters_idx(iDot) > 0
            dim = 2;
            dot_nm{iDot} = stimuliPerDimension{letters_idx(iDot),dim};
        end
        % rearrange dot name position to center it
        dot_nm_xyPos(1,iDot) = dot_nm_xyPos(1,iDot) - width_dots(iDot,dim)/2; % left border
        dot_nm_xyPos(2,iDot) = dot_nm_xyPos(2,iDot) - hight_dots(iDot,dim)/2; % top border
        
    elseif curr_diff_level == 3
        
        % total number of items per dimension
        n_item_per_dim = nDots/curr_diff_level;
        % index for numbers
        nbers_idx = repmat([1,0,0],1,n_item_per_dim);
        nbers_idx(nbers_idx == 1) = nbers_idx(nbers_idx == 1).*(1:n_item_per_dim);
        % index for letters
        letters_idx = repmat([0,1,0],1,n_item_per_dim);
        letters_idx(letters_idx == 1) = 1:n_item_per_dim;
        % index for dice
        dice_idx = repmat([0,0,1],1,n_item_per_dim);
        dice_idx(dice_idx == 1) = 1:n_item_per_dim;
        
        % extract the corresponding number or letter
        if nbers_idx(iDot) > 0
            dim = 1;
            dot_nm{iDot} = stimuliPerDimension{nbers_idx(iDot),dim};
        elseif letters_idx(iDot) > 0
            dim = 2;
            dot_nm{iDot} = stimuliPerDimension{letters_idx(iDot),dim};
        elseif dice_idx(iDot) > 0
            dim = 3;
            dot_nm{iDot} = ''; % empty because we will display the dice with Screen('DrawDots') instead of a written character
        end
        % rearrange dot name position to center it
        dot_nm_xyPos(1,iDot) = dot_nm_xyPos(1,iDot) - width_dots(iDot,dim)/2; % left border
        dot_nm_xyPos(2,iDot) = dot_nm_xyPos(2,iDot) - hight_dots(iDot,dim)/2; % top border
        
    elseif curr_diff_level == 4
        % total number of items per dimension
        n_item_per_dim = nDots/curr_diff_level;
        % index for numbers
        nbers_idx = repmat([1,0,0,0],1,n_item_per_dim);
        nbers_idx(nbers_idx == 1) = 1:n_item_per_dim;
        % index for letters
        letters_idx = repmat([0,1,0,0],1,n_item_per_dim);
        letters_idx(letters_idx == 1) = 1:n_item_per_dim;
        % index for dice
        dice_idx = repmat([0,0,1,0],1,n_item_per_dim);
        dice_idx(dice_idx == 1) = 1:n_item_per_dim;
        % index for majuscule letters
        bigLETTERS_idx = repmat([0,0,0,1],1,n_item_per_dim);
        bigLETTERS_idx(bigLETTERS_idx == 1) = 1:n_item_per_dim;
        
        % extract the corresponding number or letter
        if nbers_idx(iDot) > 0
            dim = 1;
            dot_nm{iDot} = stimuliPerDimension{nbers_idx(iDot),dim};
        elseif letters_idx(iDot) > 0
            dim = 2;
            dot_nm{iDot} = stimuliPerDimension{letters_idx(iDot),dim};
        elseif dice_idx(iDot) > 0
            dim = 3;
            dot_nm{iDot} = ''; % empty because we will display the dice with Screen('DrawDots') instead of a written character
        elseif bigLETTERS_idx(iDot) > 0
            dim = 4;
            dot_nm{iDot} = stimuliPerDimension{bigLETTERS_idx(iDot),dim};
        end
        % rearrange dot name position to center it
        dot_nm_xyPos(1,iDot) = dot_nm_xyPos(1,iDot) - width_dots(iDot,dim)/2; % left border
        dot_nm_xyPos(2,iDot) = dot_nm_xyPos(2,iDot) - hight_dots(iDot,dim)/2; % top border
    end
end

% need to fill the output dice_idx, even for difficulty levels when not
% included
if curr_diff_level <= 2
    dice_idx = [];
end

end

function [] = draw_dice_dots(window, dice_idx, dot_xyPos, dice_dotSize, dice_dot_dist, screen_center, dice_dot_colour)
%draw_dice_dots(window, dice_idx, dots_xyPos, dice_dot_dist, screen_center, dice_dot_colour)
% draws dice dots corresponding to the number located in 'dice_idx'
%
% Function required for task_mental_EE_choice.m, requires Psychtoolbox
%
% INPUTS
% window: psychtoolbox window reference
%
% dice_idx: value from 1 to 6 indicating which dice to display
%
% dot_xyPos: dot center coordinates (n*1) 1st line = x coordinate, 2nd
% line= y coordinate
%
% dice_dotSize: number indicating the size of the dice dots
%
% dice_dot_dist: minimal distance between each dot
%
% screen_center: [x,y] vector where x is the x-coordinate of the center of
% the screen and y is the y-coordinate of the center of the screen
%
% dice_dot_colour: [r,g,b] vector indicating which colour should the dice
% dots be
%
% See also task_mental_EE_choice.m


% draw the dots in the corresponding locations
% of the circle
% make a dot on the center
if ismember(dice_idx,[1,3,5])
    Screen('DrawDots', window, dot_xyPos(:),...
        dice_dotSize, dice_dot_colour, screen_center, 2);
end

% make upper left and lower right dots
if ismember(dice_idx,[2,4,5,6])
    Screen('DrawDots', window,...
        [dot_xyPos(1) - dice_dot_dist; dot_xyPos(2) - dice_dot_dist],...
        dice_dotSize, dice_dot_colour, screen_center, 2); % upper left
    Screen('DrawDots', window,...
        [dot_xyPos(1) + dice_dot_dist; dot_xyPos(2) + dice_dot_dist],...
        dice_dotSize, dice_dot_colour, screen_center, 2); % lower right
end


% make upper right and lower left dots
if ismember(dice_idx,[3,4,5,6])
    Screen('DrawDots', window,...
        [dot_xyPos(1) + dice_dot_dist; dot_xyPos(2) - dice_dot_dist],...
        dice_dotSize, dice_dot_colour, screen_center, 2); % upper right
    Screen('DrawDots', window,...
        [dot_xyPos(1) - dice_dot_dist, dot_xyPos(2) + dice_dot_dist],...
        dice_dotSize, dice_dot_colour, screen_center, 2); % lower left
end


% make two middle dots
if dice_idx == 6
    Screen('DrawDots', window,...
        [dot_xyPos(1) - dice_dot_dist; dot_xyPos(2)],...
        dice_dotSize, dice_dot_colour, screen_center, 2); % middle left
    Screen('DrawDots', window,...
        [dot_xyPos(1) + dice_dot_dist; dot_xyPos(2)],...
        dice_dotSize, dice_dot_colour, screen_center, 2); % middle right
end


end
