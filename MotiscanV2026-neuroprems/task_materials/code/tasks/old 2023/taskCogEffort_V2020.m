function [sub_data] = taskCogEffort_V2020(sub_data, cfg)
%function [sub_data] = taskCogEffort_V2(sub_data, cfg)
%
% taskCogEffort - execute the cognitive effort task, where reward is proportional to RT
% Launch the task with this function for testing one subject.
% The subject has to perform successive TMT tasks with various difficulty
% Each trial the maximum reward is variable, to win the most of it
% the subject has to complete the task the quicker he can.
%
% Input : sub_data and cfg structures
%
% Output : modified sub_data with data and training data
%
% Modified march 2020, C. JAFFRE et P. CARRILLO

% Pour générer une nouvelle séquences de points : décommenter lignes 247-313

%% Config
% -----------------------------------------------
cfg = motiscanV2020_setTask(cfg);

display  = cfg.ptb.display;
H        = display.H;
x        = display.x;
y        = display.y;

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

%% Experiment preparation
% ----------------------------------------------
% Loads images and creates positions
%-----------------------------------------------
cd(cfg.paths.task.images); % enter img dir
% incentive icons
for i=1:6
    pic_inc{i,1}=Screen('MakeTexture',display.window,imread(['pic_inc_' num2str(i) '.bmp']));
    [wrect{i},hrect{i}] = RectSize(Screen('Rect',pic_inc{i}));
    rect_inc{i}=CenterRectOnPoint(Screen('Rect',pic_inc{i}),x,y);
    rect_inc2{i}=CenterRectOnPoint(Screen('Rect',pic_inc{i}),(3/10)*x,y+hrect{i}/2-300);
    pic_inc{i,2}=Screen('MakeTexture',display.window,imread(['pic_inc_' num2str(i) 'neg.bmp']));
end

cd(cfg.paths.task.text) % returning to code

% Experimental conditions
% __________________________________________________________________________
% stimuli inside the dots, extracted from an xls file
[NUM,TXT,~] = xlsread('stimuliPerDimension.xlsx');
stimuliPerDimension = cell(length(NUM),4);
for iStim = 1:length(NUM)
    stimuliPerDimension{iStim,1} = num2str(NUM(iStim));
    stimuliPerDimension{iStim,2} = TXT{iStim,1};
    stimuliPerDimension{iStim,3} = TXT{iStim,2};
    stimuliPerDimension{iStim,4} = TXT{iStim,3};
end

cd(cfg.paths.task.code) % returning to code

nDot             = 12; % number of dots to select in the mental effort task
nLoopFirstBlock  = 5; % How many times each incentive/difficulty level pairs have to be presented
nLoopSecondBlock = 5; % How many times each incentive/difficulty level pairs have to be presented
nBlock           = 2;

% Liste des niveaux d'effort
dotCarac = sprintf('\x2022');
listCogEffortLevels       = [0, 1, 2, 3, 4];
listCogEffortLabels       = {
    'Sans ordre particulier',...
    'En suivant 1 liste', ...
    'En alternant entre 2 listes', ...
    'En alternant entre 3 listes', ...
    'En alternant entre 4 listes'
    };
listLongInstructions = {
    'N''importe quel ordre.',...
    'Niveau 1-2-3-4-...', ...
    'Niveau 1-a-2-b-...', ...
    ['Niveau 1-a-' dotCarac '-2-...'], ...
    ['Niveau 1-a-' dotCarac '-A-2-...']
    };
listCogEffortInstructions = {
    'Touchez tous les points dans n''importe quel ordre',...
    'Touchez les points en suivant l''ordre des chiffres', ...
    'Touchez les points en alternant chiffres et lettres', ...
    'Touchez les points en alternant chiffres, lettres et dés', ...
    'Touchez les points en alternant chiffres, minuscules, dés et MAJUSCULES'
    };

nPerfLevels = length(listCogEffortLevels);

% Liste des récompenses en jeu
listIncentiveLevels  = [   2, 4, 5,  6];
listIncentiveAmounts = [0.20, 1, 5, 20]; % in euros

nIncentiveLevels     = length(listIncentiveLevels);

% Defining all possible combinations
temp = repmat(CombVec(1:nPerfLevels, 1:nIncentiveLevels)',nLoopFirstBlock,1);

nTrialFirstBlock = length(temp);

% Randomization such that there is no correlation between time and conditions
crit = Inf;

while crit > 3.1
    temp(:, 3) = Shuffle(1:nTrialFirstBlock);
    crit       = sum(sum(abs(corr(temp))));
end

% temp(:, 4) = 1:nTrials;
temp = sortrows(temp, 3);

%% Création d'une table contenant pour chaque trial le niveau de récompense et de difficulté
tableTrial              = table;
tableTrial.iTrial(1:nTrialFirstBlock,1) = (1:nTrialFirstBlock)';
for iTrial = 1:nTrialFirstBlock
    tableTrial.CogEffortLevel(iTrial)        = listCogEffortLevels(temp(iTrial, 1));
    tableTrial.IncentiveLevel(iTrial)        = listIncentiveLevels(temp(iTrial, 2));
    tableTrial.CogEffortLabel(iTrial)        = listCogEffortLabels(temp(iTrial, 1));
    tableTrial.CogEffortInstructions(iTrial) = listCogEffortInstructions(temp(iTrial, 1));
    tableTrial.IncentiveAmount(iTrial)       = listIncentiveAmounts(temp(iTrial, 2))';
end

%% On fait pareil pour le second bloc
% Defining all possible combinations
temp = repmat(CombVec(1:nPerfLevels, 1:nIncentiveLevels)',nLoopSecondBlock,1);

nTrialSecondBlock = length(temp);
nTotalTrial       = nTrialFirstBlock + nTrialSecondBlock;

% Randomization such that there is no correlation between time and conditions
crit = Inf;

while crit > 3.1
    temp(:, 3) = Shuffle(1:nTrialSecondBlock);
    crit       = sum(sum(abs(corr(temp))));
end

% temp(:, 4) = 1:nTrials;
temp = sortrows(temp, 3);

% Remplissage contenant pour chaque trial le niveau de récompense et de difficulté
tableTrial.iTrial(nTrialFirstBlock+1:nTotalTrial,1) = (nTrialFirstBlock+1:nTotalTrial)';
for iTrial = 1:nTrialSecondBlock
    tableTrial.CogEffortLevel(iTrial+nTrialFirstBlock)        = listCogEffortLevels(temp(iTrial, 1));
    tableTrial.IncentiveLevel(iTrial+nTrialFirstBlock)        = listIncentiveLevels(temp(iTrial, 2));
    tableTrial.CogEffortLabel(iTrial+nTrialFirstBlock)        = listCogEffortLabels(temp(iTrial, 1));
    tableTrial.CogEffortInstructions(iTrial+nTrialFirstBlock) = listCogEffortInstructions(temp(iTrial, 1));
    tableTrial.IncentiveAmount(iTrial+nTrialFirstBlock)       = listIncentiveAmounts(temp(iTrial, 2))';
end

% Preallocation of responses :
tableTrial.nCorrectDot = nan(nTotalTrial, 1);
% Résultats supplémentaires
tableSupp = table;
tableSupp.Positions            = cell(nTotalTrial, 1);  % x,y cursor/touch position
tableSupp.PositionsTime        = cell(nTotalTrial, 1);  % Timing for each cursor/touch position
tableSupp.Sequence             = cell(nTotalTrial, 1);  % Order of dots clicked
tableSupp.CorrectSequenceTime  = cell(nTotalTrial, 1);  % Timing of correct each dot
tableSupp.SequenceTime         = cell(nTotalTrial, 1);  % Timing of each dot
tableSupp.SequenceAbsoluteTime = cell(nTotalTrial, 1);  % Timing of each dot

%% Calibration
nRepetition = 2;
nCalibrationPerf = nPerfLevels*nRepetition;                      
tableTrialCalibrationPerf                       = table;
tableTrialCalibrationPerf.iTrial                = (1:nCalibrationPerf)';
tableTrialCalibrationPerf.CogEffortLevel        = repmat(vertcat(unique(tableTrial.CogEffortLevel)),nRepetition,1);
tableTrialCalibrationPerf.CogEffortLabel        = repmat(vertcat(listCogEffortLabels'),nRepetition,1);
tableTrialCalibrationPerf.CogEffortInstructions = repmat(vertcat(listCogEffortInstructions'),nRepetition,1);
% Preallocation of responses :
tableTrialCalibrationPerf.RTperf                = nan(nCalibrationPerf, 1);


%% Screen configuration
screen_center = [x, y];

% position on screen
left_margin     = x*(1/4); % left of the screen
right_margin    = x*(3/4); % close to center of screen
up_margin       = y*(1/4);
low_margin      = y*(7/4);
right_col_pos = [right_margin+x  up_margin  2*x             low_margin]; % Used during dot presentation
left_col_pos  = [left_margin     up_margin  right_margin    low_margin]; % Used during dot presentation
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
% mental_E_task.performance.dot_nm = cell(nDot, nTotalTrial);
% % select the 'nDots' dots that will be displayed on screen
% mental_E_task.performance.dots_xyPos      = NaN(2,nDot,nTotalTrial);
% mental_E_task.performance.dots_xyPos_ref  = zeros(nDot,nTotalTrial); % keep track on the dots already selected or not for the reference case where no order has been established between the different dots
% mental_E_task.performance.dot_nm_xyPos    = NaN(2,nDot,nTotalTrial); % (x,y) coordinates for dot name position)
% % idem for the calibration
% mental_E_task.calibration.dot_nm    = cell(nDot, nCalibrationPerf);
% mental_E_task.calibration.dots_xyPos      = NaN(2,nDot,nCalibrationPerf);
% mental_E_task.calibration.dots_xyPos_ref  = zeros(nDot,nCalibrationPerf); % keep track on the dots already selected or not for the reference case where no order has been established between the different dots
% mental_E_task.calibration.dot_nm_xyPos    = NaN(2,nDot,nCalibrationPerf); % (x,y) coordinates for dot name position)

% nBlock = 2; % calibration and performance

% for iBlock = 1:nBlock
%     switch iBlock
%         case 1
%             blockName = 'calibration';
%             nTrialInBlock = nCalibrationPerf;
%         case 2
%             blockName = 'performance';
%             nTrialInBlock = nTotalTrial;
%     end
%     for iTrial = 1:nTrialInBlock
%         dist_ok = 0;
%         spacing_ok = 0;
%         rng('shuffle', 'twister');% reinitialize the 'rand' function from Matlab everytime
%         while dist_ok == 0 || spacing_ok ==0 % sample until you get dots which all a 'dot_minDist' distance between each other minimally (to avoid text overlaps)
%             pickDots = randperm(length(dotPositionMatrix),nDot);
%             % check that each dot respects the minimal distance with the previous ones
%             n_bad_dots = 0;
%             totalDistance =0;
%             for iDot = 2:nDot
%                 for jDot = 1:(iDot - 1)
%                     % if X and Y distance is smaller than the min distance =>
%                     % leave this dot disposition and try a new one
%                     n_bad_dots = n_bad_dots +...
%                         (abs(dotPositionMatrix(1,iDot) - dotPositionMatrix(1,jDot)) <= dot_minDist)*(abs(dotPositionMatrix(2,iDot) - dotPositionMatrix(2,jDot)) <= dot_minDist);
%                 end
%             end
%             % if all dots have a correct distance with each other, keep this selection
%             if n_bad_dots == 0
%                 dist_ok = 1;
%             end
%             
%             % Ajout dernière version : on vérifie que la distance totale à parcourir est comprise entre 5500 et 6500 pixels
%             for iDot = 1:nDot-1
%                 totalDistance = totalDistance + sum(abs(dotPositionMatrix(:,pickDots(iDot))-dotPositionMatrix(:,pickDots(iDot+1))));
%             end
%             
%             if totalDistance < 7000 && totalDistance > 6000
%                 spacing_ok =1;
%             end
%         end
%         % save dot coordinates
%         mental_E_task.(blockName).dots_xyPos(:,:,iTrial) = dotPositionMatrix(:,pickDots);
%         % start filling dot name coordinates
%         mental_E_task.(blockName).dot_nm_xyPos(1,:,iTrial) = mental_E_task.(blockName).dots_xyPos(1,:,iTrial) + x;
%         mental_E_task.(blockName).dot_nm_xyPos(2,:,iTrial) = mental_E_task.(blockName).dots_xyPos(2,:,iTrial) + y;
%         %pre-allocation dice indexes
%         mental_E_task.(blockName).dice_idx = zeros(nDot, nTrialInBlock);
%     end
% end
% 
% %pre-allocation dice indexes
% mental_E_task.performance.dice_idx = zeros(nDot, nTotalTrial);

% save('cogEffort_dotSequence', 'mental_E_task')
load('cogEffort_dotSequence.mat', 'mental_E_task')

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
% maxResponseDuration    = 10e3; % Choice maximum duration
t_dispEtime            = 1.5; % display random choice selected for t_dispEtime seconds
t_cross_ITI            = 0.5; % fixation cross duration between each choice trial
error_TimeWait         = 0.3; % error waiting
time_release_tolerance = 0.3; % leave 'time_release_tolerance' seconds since last correct press until to consider that the button press is an error
feedbackDuration       = 2;
% times_to_check = {'blockStart_message',...
%     'blockStart',...
%     'display_optionsE',...
%     'display_chosenE',...
%     'display_E',...
%     'corrSelection_E',...
%     'mental_E_error',...
%     'display_E_postError',...
%     'mental_E_task'};
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

%% Instructions
% - slide 1
textstring = ['Dans ce test, vous allez devoir réaliser un exercice : il faudra toucher des ronds dans un ordre particulier,' ...
    ' avec plusieurs niveaux de difficultés.'];
Screen('TextSize', display.window, ftsz_mid);
DrawFormattedText(display.window, textstring,'center','center',[255 255 255], 50, 0, 0, 2, 0, []);
Screen(display.window,'Flip');
WaitSecs(1);
KbWait;
% - slide 2
textstring = ['A chaque essai vous jouez pour une somme d''argent. '...
    ' Plus vous êtes lent, plus la somme à gagner diminue. '...
    'Il est important d''aller vite !'];
Screen('TextSize', display.window, ftsz_mid);
DrawFormattedText(display.window, textstring,'center','center',[255 255 255], 50, 0, 0, 2, 0, []);
Screen(display.window,'Flip');
WaitSecs(1);
KbWait;
% - slide 3
textstring = 'Le but du test est d''accumuler le plus d''argent possible. A vous de gérer votre performance pour parvenir à ce but.';
Screen('TextSize', display.window, ftsz_mid);
DrawFormattedText(display.window, textstring,'center','center',[255 255 255], 50, 0, 0, 2, 0, []);
Screen(display.window,'Flip');
WaitSecs(1);
KbWait;

% - slide 4
textstring = 'Pour commencer, vous allez résoudre chaque niveau le plus rapidement possible.';
Screen('TextSize', display.window, ftsz_mid);
DrawFormattedText(display.window, textstring,'center','center',[255 255 255], 50, 0, 0, 2, 0, []);
Screen(display.window,'Flip');
WaitSecs(1);
KbWait;

% instructions:  start
textstring = 'Entraînement : touchez les ronds le plus rapidement possible !';
DrawMyText(display.window,textstring,ftsz_mid,[255 255 255],[x,y]);
Screen('TextSize', display.window, ftsz_mid);
textstring = 'appuyer sur une touche pour continuer';
DrawMyText(display.window,textstring,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(1);
KbWait;
wait4release()

% Calibration
for iTrial = 1:nCalibrationPerf
    
    chosenDiff         = tableTrialCalibrationPerf.CogEffortLevel(iTrial);
    chosenInstructions = tableTrialCalibrationPerf.CogEffortInstructions{iTrial};
    % initialize RT/dot
    rt_E_task_dots = NaN(1,nDot);
    rtAllDot = [];
    timeAllDot = [];
    dotSequence = {};
    
    gridName = 'calibration';
    
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
    [dot_nm, dot_nm_xyPos, dice_idx] = dot_nm_extraction(nDot, chosenDiff, stimuliPerDimension,...
        width_dots, hight_dots,...
        dot_nm, dot_nm_xyPos);
    
    % display the corresponding dots on screen
    Screen('TextFont', display.window, 'harrington');
    %change the police to 'harrigton' to differenctiate c and C
    
    for iDot = 1:nDot
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
    while jDot <= nDot
        if mouse
            [xMouse,yMouse,buttons] = recordResponse(display.window); % window does not seem to work sadly...
        elseif touch
            [xMouse,yMouse,buttons] = recordResponse(display.window);
            %                     mental_E_task.(gridName).cursor.fingerPress{1,iTrial} = [mental_E_task.(gridName).cursor.fingerPress{1,iTrial}; buttons(4)];
        end
        % record position
        %         positionTime = GetSecs;
        %NO saving of position
        %     % Save it in the supp results
        %     results.tableSupp.perfPositions{iTrial}     = [results.tableSupp.perfPositions{iTrial} ; xMouse yMouse];
        %     results.tableSupp.perfPositionsTime{iTrial} = [results.tableSupp.perfPositionsTime{iTrial} positionTime];
        
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
            
            for iDot_errorCheck = 1:nDot
                if iDot_errorCheck ~= jDot &&...
                        (timenow1 - last_correct_time > time_release_tolerance) &&...
                        ((xMouse >= dots_xyPos(1,iDot_errorCheck) + x - pix_conf) && (xMouse <= dots_xyPos(1,iDot_errorCheck) + x + pix_conf) &&...
                        (yMouse >= dots_xyPos(2,iDot_errorCheck) + y - pix_conf) && (yMouse <= dots_xyPos(2,iDot_errorCheck) + y + pix_conf)) &&...
                        ((mouse || touch) && any(buttons~=0))
                    buttons = 0;
                    
                    % get incorrect RT
                    timenow3 = GetSecs;
                    uncorrectRT = timenow3 - lastTimeStamp;
                    rtAllDot = [rtAllDot uncorrectRT];
                    timeAllDot = [timeAllDot timenow3];
                    lastTimeStamp = timenow3;
                    
                    % DRAW THE DOTS
                    for iDot = 1:nDot
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
                        dotSequence{length(rtAllDot)} = ['d',num2str(dice_idx(iDot_errorCheck))];
                    else
                        dotSequence{length(rtAllDot)} = dot_nm{iDot_errorCheck};
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
                    for iDot = 1:nDot
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
                buttons = 0;
                timenow1 = GetSecs;
                onset.corrSelection_E = [onset.corrSelection_E; timenow1];
                % save RT for each dot selected
                if jDot == 1
                    rt_E_task_dots(jDot) = onset.corrSelection_E(end) - onset.display_E(end);
                    rtAllDot = [rtAllDot timenow1-lastTimeStamp];
                    timeAllDot = [timeAllDot timenow1];
                else
                    rt_E_task_dots(jDot) = onset.corrSelection_E(end) - onset.corrSelection_E(end - 1);
                    rtAllDot = [rtAllDot timenow1-lastTimeStamp];
                    timeAllDot = [timeAllDot timenow1];
                end
                
                % update list keeping track of the dot selected
                if isempty(dot_nm{jDot})
                    dotSequence{length(rtAllDot)} = ['d',num2str(dice_idx(jDot))];
                else
                    dotSequence{length(rtAllDot)} = dot_nm{jDot};
                end
                
                % DRAW THE DOTS
                for iDot = 1:nDot
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
            for iDot = 1:nDot
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
                    buttons = 0;
                    colour_dot = green;
                    
                    timenow1 = GetSecs;
                    onset.corrSelection_E = [onset.corrSelection_E; timenow1];
                    
                    % save RT for each dot selected
                    if jDot == 1
                        rt_E_task_dots(jDot) = onset.corrSelection_E(end) - onset.display_E(end);
                        rtAllDot = [rtAllDot timenow1-lastTimeStamp];
                        timeAllDot = [timeAllDot timenow1];
                    else
                        rt_E_task_dots(jDot) = onset.corrSelection_E(end) - onset.corrSelection_E(end - 1);
                        rtAllDot = [rtAllDot timenow1-lastTimeStamp];
                        timeAllDot = [timeAllDot timenow1];
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
    end_mental_E        = timenow1;
    rt_E_trial          = end_mental_E - start_mental_E;
    tableTrialCalibrationPerf.RTperf(iTrial)        = sum(rt_E_task_dots);
    aga = cumsum(rt_E_task_dots);
    tableTrialCalibrationPerf.dotInTwo(iTrial) = sum(aga<2);
    tableTrialCalibrationPerf.dotInSix(iTrial) = sum(aga<6);
end

%% Inferring times for the testing phase, that is how much time should the subject have
chrono = nan(5,1);
% maxTime = [4 8 10 12 16];
for iLevel = 1:5
    %     chrono(iLevel) = min(min(tableTrialCalibrationPerf.RTperf(tableTrialCalibrationPerf.CogEffortLevel ==iLevel-1)), maxTime(iLevel));
    if iLevel == 1
        chrono(iLevel) = 2;
    else
        chrono(iLevel) = 6;
    end
end

Fmax = nan(1,5);

for iLevel = 1:5
    if iLevel == 1
        Fmax(iLevel) = max(tableTrialCalibrationPerf.dotInTwo(tableTrialCalibrationPerf.CogEffortLevel ==iLevel-1));
    else
        Fmax(iLevel) = max(tableTrialCalibrationPerf.dotInSix(tableTrialCalibrationPerf.CogEffortLevel ==iLevel-1));
    end
end

%% Task launch
% instructions:  start
textstring = 'Prêt à débuter?';
DrawMyText(display.window,textstring,ftsz_big,[255 255 255],[x,y]);
textstring = 'appuyer sur une touche pour continuer';
DrawMyText(display.window,textstring,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(1);
KbWait;
wait4release()

cumWinnings         = 0;
% rewardDecreaseRate  = 0.5^(1/max(tableTrialCalibrationPerf.RTperf));

for iBlock = 1:nBlock
    switch iBlock
        case 1
            nStartTrial = 1;
            nEndTrial   = nTrialFirstBlock;
        case 2
            nStartTrial = nTrialFirstBlock+1;
            nEndTrial   = nTotalTrial;
            % Sauvegarde à la fin du bloc 1
            sub_data.(cfg.sessNber_str).tasks.taskCogEffort.results = struct('data', tableTrial, 'suppResults', tableSupp, 'calibration', tableTrialCalibrationPerf);
            
            textstring = 'Courte pause';
            DrawMyText(display.window,textstring,ftsz_big,[255 255 255],[x,y]);
            textstring = 'appuyer sur une touche pour continuer quand vous le souhaitez';
            DrawMyText(display.window,textstring,ftsz_small,[100 100 100],[x,H*4/5]);
            Screen(display.window,'Flip');
            WaitSecs(1);
            KbWait;
    end
    for iTrial = nStartTrial:nEndTrial
        % short fixation cross between choice trials and effort actual performance
        Screen('DrawTexture',display.window,pic_cross,[],rect_cross);
        % onset
        [~,~,~,~,~] = Screen(display.window,'Flip');
        WaitSecs(t_cross_ITI);
        
        % initialize RT/dot
        rt_E_task_dots = NaN(1,nDot);
        rtAllDot = [];
        timeAllDot = [];
        dotSequence = {};
        
        %% select the effort trials to be performed
        
        % training difficulty
        % two first trials = 0 difficulty
        chosenDiff         = tableTrial.CogEffortLevel(iTrial);
        chosenRewardLevel  = tableTrial.IncentiveLevel(iTrial);
        chosenRewardAmount = tableTrial.IncentiveAmount(iTrial);
        chosenInstructions = tableTrial.CogEffortInstructions{iTrial};
        chosenLongInstruction = listLongInstructions{tableTrial.CogEffortLevel(iTrial)+1};
        chosenLongInstruction = double(chosenLongInstruction);
        gridName = 'performance';
        % extract corresponding dot location, dot names and for
        % training block, position order and rank of dot selection
        dots_xyPos      = mental_E_task.(gridName).dots_xyPos(:,:,iTrial);
        dot_nm          = mental_E_task.(gridName).dot_nm(:,iTrial);
        dot_nm_xyPos    = mental_E_task.(gridName).dot_nm_xyPos(:,:,iTrial);
        dots_xyPos_ref  = mental_E_task.(gridName).dots_xyPos_ref(:,iTrial);
        
        %% display on screen the information about the trial to be performed (incentive and difficulty level) before starting it
        Screen('TextSize', display.window, ftsz_small);
        timeLeft = 1; % proportion de temps restant
        Screen('DrawTexture',display.window,pic_inc{chosenRewardLevel,1},[],rect_inc{chosenRewardLevel});
        [~,~,~,~,~] = Screen(display.window,'Flip');
        WaitSecs(blanktime);
        Screen('DrawText',display.window, chosenLongInstruction,...
            x-3/20*x,y, white);
        Screen('DrawTexture',display.window,pic_inc{chosenRewardLevel,1},[],rect_inc2{chosenRewardLevel});
        Screen('FillRect',display.window,white,[((3/10)*x-20) (y) ((3/10)*x+20) (y+400)]);
        Screen('FillRect',display.window,green,[((3/10)*x-20) (y+400-timeLeft*400) ((3/10)*x+20) (y+400)]);
        [~,~,~,~,~] = Screen(display.window,'Flip');
        WaitSecs(t_dispEtime);
        
        %% perform the trial selected (without temporal constraint)
        % display the points that have to be linked with all the relevant information
        % display on screen on which order the dimensions have to be selected
        % display the order of the colours
        Screen('DrawTexture',display.window,pic_inc{chosenRewardLevel,1},[],rect_inc2{chosenRewardLevel});
        DrawFormattedText(display.window, chosenInstructions,...
            3*x/2,2*y/3, white, wrapat_nb_char,0,0,2,0, right_col_pos);
        Screen('FillRect',display.window,white,[((3/10)*x-20) (y) ((3/10)*x+20) (y+400)]);
        Screen('FillRect',display.window,green,[((3/10)*x-20) (y+400-timeLeft*400) ((3/10)*x+20) (y+400)]);
        Screen('TextSize', display.window, ftsz_small);
        % extract name for each dot
        [dot_nm, dot_nm_xyPos, dice_idx] = dot_nm_extraction(nDot, chosenDiff, stimuliPerDimension,...
            width_dots, hight_dots,...
            dot_nm, dot_nm_xyPos);
        
        
        % display the corresponding dots on screen
        Screen('TextFont', display.window, 'harrington');
        %change the police to 'harrigton' to differenctiate c and C
        
        for iDot = 1:nDot
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
        timeLeft = min(1-(timenow1-start_mental_E)/chrono(chosenDiff+1), 0);
        
        %% check the subject responses, when a correct option is selected display the circles in different colours
        jDot = 1;
        nErrors = 0;
        stopTrial = 0;
        while ~stopTrial
            if mouse
                [xMouse,yMouse,buttons] = recordResponse(display.window); % window does not seem to work sadly...
            elseif touch
                [xMouse,yMouse,buttons] = recordResponse(display.window);
                %                     mental_E_task.(gridName).cursor.fingerPress{1,iTrial} = [mental_E_task.(gridName).cursor.fingerPress{1,iTrial}; buttons(4)];
            end
            % record position
            positionTime = GetSecs;
            % Save it in the supp results
            tableSupp.Positions{iTrial}     = [tableSupp.Positions{iTrial} ; xMouse yMouse];
            tableSupp.PositionsTime{iTrial} = [tableSupp.PositionsTime{iTrial} positionTime];
            
            if chosenDiff > 0 % for all cases except reference
                % keep displaying the order of the dim on screen
                
                Screen('TextFont', display.window, 'arial');
                DrawFormattedText(display.window,chosenInstructions,...
                    3*x/2,2*y/3, white, wrapat_nb_char,0,0,2,0, right_col_pos);
                Screen('TextFont', display.window, 'harrington');
                
                Screen('DrawTexture',display.window,pic_inc{chosenRewardLevel,1},[],rect_inc2{chosenRewardLevel});
                Screen('FillRect',display.window,white,[((3/10)*x-20) (y) ((3/10)*x+20) (y+400)]);
                Screen('FillRect',display.window,green,[((3/10)*x-20) (y+400-timeLeft*400) ((3/10)*x+20) (y+400)]);
                for iDot = 1:nDot
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
                Screen(display.window,'Flip');
                %% check that the subject did not click on a wrong target (and if so, display a red cross on the target for a short delay)
                timenow1 = GetSecs;
                if ~isempty(onset.corrSelection_E)
                    last_correct_time = max(onset.corrSelection_E);
                else
                    last_correct_time = 0;
                end
                timeLeft = max(1-(timenow1-start_mental_E)/chrono(chosenDiff+1),0);
                
                for iDot_errorCheck = 1:nDot
                    
                    if iDot_errorCheck ~= jDot &&...
                            (timenow1 - last_correct_time > time_release_tolerance) &&...
                            ((xMouse >= dots_xyPos(1,iDot_errorCheck) + x - pix_conf) && (xMouse <= dots_xyPos(1,iDot_errorCheck) + x + pix_conf) &&...
                            (yMouse >= dots_xyPos(2,iDot_errorCheck) + y - pix_conf) && (yMouse <= dots_xyPos(2,iDot_errorCheck) + y + pix_conf)) &&...
                            ((mouse || touch) && any(buttons~=0))
                        if mouse || touch; buttons = 0; end
                        
                        % get incorrect RT
                        timenow3 = GetSecs;
                        uncorrectRT = timenow3 - lastTimeStamp;
                        rtAllDot = [rtAllDot uncorrectRT];
                        timeAllDot = [timeAllDot timenow3];
                        lastTimeStamp = timenow3;
                        % DRAW THE DOTS
                        for iDot = 1:nDot
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
                        %                     start_x1_error_line = dots_xyPos(1,iDot_errorCheck) + x - dotSize/(2*sqrt(2));
                        %                     start_y1_error_line = dots_xyPos(2,iDot_errorCheck) + y - dotSize/(2*sqrt(2));
                        %                     end_x1_error_line   = dots_xyPos(1,iDot_errorCheck) + x + dotSize/(2*sqrt(2));
                        %                     end_y1_error_line   = dots_xyPos(2,iDot_errorCheck) + y + dotSize/(2*sqrt(2));
                        %                     start_x2_error_line = dots_xyPos(1,iDot_errorCheck) + x + dotSize/(2*sqrt(2));
                        %                     start_y2_error_line = dots_xyPos(2,iDot_errorCheck) + y - dotSize/(2*sqrt(2));
                        %                     end_x2_error_line   = dots_xyPos(1,iDot_errorCheck) + x - dotSize/(2*sqrt(2));
                        %                     end_y2_error_line   = dots_xyPos(2,iDot_errorCheck) + y + dotSize/(2*sqrt(2));
                        %                     Screen('DrawLine', display.window, red,...
                        %                         start_x1_error_line, start_y1_error_line,...
                        %                         end_x1_error_line, end_y1_error_line,...
                        %                         line_thick);
                        %                     Screen('DrawLine', display.window, red,...
                        %                         start_x2_error_line, start_y2_error_line,...
                        %                         end_x2_error_line, end_y2_error_line,...
                        %                         line_thick);
                        
                        Screen('TextFont', display.window, 'arial');
                        DrawFormattedText(display.window,chosenInstructions,...
                            3*x/2,2*y/3, white, wrapat_nb_char,0,0,2,0, right_col_pos);
                        Screen('TextFont', display.window, 'harrington');
                        
                        Screen('DrawTexture',display.window,pic_inc{chosenRewardLevel,1},[],rect_inc2{chosenRewardLevel});
                        Screen('FillRect',display.window,white,[((3/10)*x-20) (y) ((3/10)*x+20) (y+400)]);
                        Screen('FillRect',display.window,green,[((3/10)*x-20) (y+400-timeLeft*400) ((3/10)*x+20) (y+400)]);[~,timenow1,~,~,~] = Screen(display.window,'Flip');
                        onset.mental_E_error = [onset.mental_E_error; timenow1];
                        timeLeft = max(1-(timenow1-start_mental_E)/chrono(chosenDiff+1),0);
                        
                        % Increment error count
                        nErrors = nErrors+1;
                        
                        % add the incorrect dot to the sequence
                        if isempty(dot_nm{iDot_errorCheck})
                            dotSequence{length(rtAllDot)} = ['d',num2str(dice_idx(iDot_errorCheck))];
                        else
                            dotSequence{length(rtAllDot)} = dot_nm{iDot_errorCheck};
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
                        
                        Screen('DrawTexture',display.window,pic_inc{chosenRewardLevel,1},[],rect_inc2{chosenRewardLevel});
                        Screen('FillRect',display.window,white,[((3/10)*x-20) (y) ((3/10)*x+20) (y+400)]);
                        Screen('FillRect',display.window,green,[((3/10)*x-20) (y+400-timeLeft*400) ((3/10)*x+20) (y+400)]);% DRAW THE DOTS
                        for iDot = 1:nDot
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
                        timeLeft = max(1-(timenow1-start_mental_E)/chrono(chosenDiff+1),0);
                    end
                end
                
                %% check if correct target selected and link the dots accordingly
                % keep displaying the order of the dim on screen
                
                Screen('TextFont', display.window, 'arial');
                DrawFormattedText(display.window,chosenInstructions,...
                    3*x/2,2*y/3, white, wrapat_nb_char,0,0,2,0, right_col_pos);
                Screen('TextFont', display.window, 'harrington');
                
                Screen('DrawTexture',display.window,pic_inc{chosenRewardLevel,1},[],rect_inc2{chosenRewardLevel});
                Screen('FillRect',display.window,white,[((3/10)*x-20) (y) ((3/10)*x+20) (y+400)]);
                Screen('FillRect',display.window,green,[((3/10)*x-20) (y+400-timeLeft*400) ((3/10)*x+20) (y+400)]);
                
                if ((xMouse >= dots_xyPos(1,jDot) + x - pix_conf) && (xMouse <= dots_xyPos(1,jDot) + x + pix_conf) &&...
                        (yMouse >= dots_xyPos(2,jDot) + y - pix_conf) && (yMouse <= dots_xyPos(2,jDot) + y + pix_conf)) &&...
                        ((mouse || touch) && any(buttons~=0))
                    if mouse || touch; buttons = 0; end
                    timenow1 = GetSecs;
                    onset.corrSelection_E = [onset.corrSelection_E; timenow1];
                    timeLeft = max(1-(timenow1-start_mental_E)/chrono(chosenDiff+1),0);
                    % save RT for each dot selected
                    if jDot == 1
                        rt_E_task_dots(jDot) = onset.corrSelection_E(end) - onset.display_E(end);
                        rtAllDot = [rtAllDot timenow1-lastTimeStamp];
                        timeAllDot = [timeAllDot timenow1];
                    else
                        rt_E_task_dots(jDot) = onset.corrSelection_E(end) - onset.corrSelection_E(end - 1);
                        rtAllDot = [rtAllDot timenow1-lastTimeStamp];
                        timeAllDot = [timeAllDot timenow1];
                    end
                    
                    % update list keeping track of the dot selected
                    if isempty(dot_nm{jDot})
                        dotSequence{length(rtAllDot)} = ['d',num2str(dice_idx(jDot))];
                    else
                        dotSequence{length(rtAllDot)} = dot_nm{jDot};
                    end
                    
                    % DRAW THE DOTS
                    for iDot = 1:nDot
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
                    if jDot ==13
                        stopTrial = 1;
                    end
                    lastTimeStamp = timenow1;
                    timeLeft = max(1-(timenow1-start_mental_E)/chrono(chosenDiff+1),0);
                end
                
            elseif chosenDiff == 0 % reference selected : particular case since there is no
                % specific order defined about how to select the different dots together
                Screen('DrawTexture',display.window,pic_inc{chosenRewardLevel,1},[],rect_inc2{chosenRewardLevel});
                Screen('FillRect',display.window,white,[((3/10)*x-20) (y) ((3/10)*x+20) (y+400)]);
                Screen('FillRect',display.window,green,[((3/10)*x-20) (y+400-timeLeft*400) ((3/10)*x+20) (y+400)]);% DRAW THE DOTS
                for iDot = 1:nDot
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
                        timeLeft = max(1-(timenow1-start_mental_E)/chrono(chosenDiff+1),0);
                        
                        % save RT for each dot selected
                        if jDot == 1
                            rt_E_task_dots(jDot) = onset.corrSelection_E(end) - onset.display_E(end);
                            rtAllDot = [rtAllDot timenow1-lastTimeStamp];
                            timeAllDot = [timeAllDot timenow1];
                        else
                            rt_E_task_dots(jDot) = onset.corrSelection_E(end) - onset.corrSelection_E(end - 1);
                            rtAllDot = [rtAllDot timenow1-lastTimeStamp];
                            timeAllDot = [timeAllDot timenow1];
                        end
                        lastTimeStamp = timenow1;
                        
                        % update list keeping track of the dots already
                        % selected
                        prev_max_dot_rank = max( dots_xyPos_ref );
                        dots_xyPos_ref(iDot) = 1 + prev_max_dot_rank; % extract the order the dots have been selected!
                        
                        jDot = jDot + 1;
                        if jDot == 13
                            stopTrial = 1;
                        end
                        
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
                timeLeft = max(1-(timenow1-start_mental_E)/chrono(chosenDiff+1),0);
            end
            % Vérifions le temps
            timenow1 = GetSecs;
            if timenow1-start_mental_E > chrono(chosenDiff+1)
                stopTrial = 1;
            end
        end
        
        Screen(display.window,'Flip'); % Rafraichissement de l'écran
        
        % extract the global RT from start to end of mental effort task
        %         end_mental_E        = timenow1;
        %         timeLeft = max(1-(timenow1-start_mental_E)/chrono(chosenDiff+1),0);
        %         rt_E_trial          = end_mental_E - start_mental_E;
        %         tableTrial.RTperf(iTrial)             = rt_E_trial;
        tableSupp.Sequence{iTrial}            = dotSequence;
        tableSupp.CorrectSequenceTime{iTrial} = rt_E_task_dots;
        tableSupp.SequenceTime{iTrial}        = rtAllDot;
        tableSupp.SequenceAbsoluteTime{iTrial}= timeAllDot;
        tableTrial.perfErrors(iTrial)         = nErrors;
        
        % On regarde combien de point ont été correctement selectionés
        nCorrectDot = length(tableSupp.SequenceTime{iTrial}) - tableTrial.perfErrors(iTrial);
        tableTrial.nCorrectDot(iTrial)        = nCorrectDot;

        % repasse l'écriture en arial
        Screen('TextFont', display.window, 'arial');
        
        % Feedback
        winnings    = (round(nCorrectDot/Fmax(chosenDiff+1)*chosenRewardAmount*100))/100;
        cumWinnings = cumWinnings + winnings;
        textstring  = ['Vous avez touché ' num2str(nCorrectDot) ' points et gagné : ', num2str(winnings), ' euros !'];
        DrawMyText(display.window,textstring,ftsz_big,green,[x,y]);
        textstring = ['Total : ', num2str(cumWinnings), ' euros'];
        DrawMyText(display.window,textstring,ftsz_big,white,[x,y+100]);
        Screen(display.window,'Flip');
        WaitSecs(feedbackDuration);
        wait4release()
        
        sub_data.(cfg.sessNber_str).tasks.taskCogEffort.results = struct('data', tableTrial, 'suppResults', tableSupp, 'calibration', tableTrialCalibrationPerf);
        tic
        save([cfg.paths.data_backups '\tempSubDataCogEffort'], 'sub_data');
        toc
    end
end

% display end
Screen(display.window,'Flip');
Screen('CloseAll');

%%%%%%%%%%%%%%%%%%%%%%%%%
%% Data saving
%-----------------------------------------------

sub_data.(cfg.sessNber_str).tasks.taskCogEffort.results = struct('data', tableTrial, 'suppResults', tableSupp, 'calibration', tableTrialCalibrationPerf);

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