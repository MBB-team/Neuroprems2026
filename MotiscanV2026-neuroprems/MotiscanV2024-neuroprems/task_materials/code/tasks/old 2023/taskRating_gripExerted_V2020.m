function [sub_data] = taskRating_gripExerted_V2020(sub_data, cfg)
% function [sub_data] = taskRating_gripExerted_V2(sub_data, cfg)
%
% MBB motivational battery (version 2.2).
%
% Written by Raphael Le Bouc - September 2013



%% Configuration
% -----------------------------------------------
cfg = motiscanV2020_setTask(cfg);

display  = cfg.ptb.display;
x        = display.x;
y        = display.y;
H        = display.H;

key = cfg.ptb.key;

wait4release   = cfg.ptb.wait4release;
recordResponse = cfg.ptb.recordResponse;

gripdevice  = cfg.grip.gripdevice;
Handle      = cfg.grip.Handle;
readGrip    = cfg.grip.readGrip;

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

% texts
text.instruc = 'Instructions';
text.instrucText = ['Dans ce test, il vous est demandé de serrer '      ...
    'PROGRESSIVEMENT la poignée de force pour atteindre la force cible '...
    'puis d''indiquer une note de pénibilité par rapport à l''effort fourni.'];
% text.instrucText = ['Dans ce test, vous allez devoir serrer la poignée '...
%     'de force pour atteindre la force cible puis indiquer une note de '...
%     'pénibilité par rapport à l''effort fourni.'];

text.calibText1 = ['Avant de débuter, appuyer sur ''N'' et '...
    '''zero'' sur le boitier du grip']; 
text.calibText2 = ['Avant de débuter, relacher complètement'...
    ' la poignée pour l''étalonnage.']; 
text.calib = 'étalonnage...';

text.serrez = 'Serrez maintenant !';
text.question_name = 'À quel point était-ce pénible ?';
text.answer_names = {'Pas du tout','Enormément'};

text.appuyer = 'appuyer sur une touche pour continuer...';
text.quePref  = 'Que préférez-vous ?';
text.pretDebut = 'Prêt à débuter ?';
text.timesUp = 'Temps écoulé !';
text.faster = 'Répondez plus rapidement svp.';

% Experimental conditions
%-----------------------------------------------
n_trial    = 16;
n_rep      = 4;
force_list = [0.30 0.45 0.60 0.75];
forcelevel = repmat(force_list,1,n_rep);
targetStopCriterion = (2/3); % threshold to cross to stop trial (in% of target force level)
forceDuration = 0.5; % duration of force exertion (seconds)

% timing variables
ITI_duration = 0.5;
ITI_jitter = 0.5;
blanktime = 0.5;
waitAft_bigTtl = 0.2;
waitAft_instruc = 0.5;
waitAft_trial = 0.007;
maxResponseDuration = 10e3;

% Load stimuli
%__________________________________________________________________________

cd(cfg.paths.task.images); % enter img dir
% informative icons
cross=Screen('MakeTexture',display.window,imread('Cross.bmp'));
rectcross=CenterRectOnPoint(Screen('Rect',cross),x,y);

% - rating scale images
yScale = y/2;
yemoji= y + yScale + 100 ;
xScaleLim = [x*1/5,x*9/5];
% -- emojis
[img,map] = imread('emoji_neutral.png');
img = ind2rgb(img,map);img = img.*255;
emoji_neutral=Screen('MakeTexture',display.window,img);
rect_emoji_neutral=CenterRectOnPoint(Screen('Rect',emoji_neutral),xScaleLim(1),yemoji);
[img,map] = imread('emoji_effort.png');
img = ind2rgb(img,map);img = img.*255;
emoji_infinite=Screen('MakeTexture',display.window,img);
% emoji_infinite=Screen('MakeTexture',display.window,imread('emoji_effort.png'));
rect_emoji_infinite=CenterRectOnPoint(Screen('Rect',emoji_infinite),xScaleLim(2),yemoji);

cd(cfg.paths.task.code) % returning to code directory

% Data preparation
%-----------------------------------------------
[force, forcecum, perf, rating, press_responsetime, validation_responsetime] = ...
    deal(nan(1,n_trial));
is_forceReached = false(n_trial,1);

trial = 1:n_trial;
trialperm=randperm(n_trial);
forcelevel = forcelevel(trialperm);
cursor = cell(1,n_trial);
gripdata={};

ratingEsummary=nan(1,length(trial));

% Initialization
%-----------------------------------------------
% counters
calibratedForce = cfg.grip.hand_used.(cfg.grip.hand_used.to_use).calibratedFmax*1.2;

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

%% Testing
%-----------------------------------------------
DrawMyText(display.window,text.instruc,ftsz_big,[255 255 255],[x,y]);
DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(waitAft_bigTtl);
KbWait;
% instructions:  start
Screen('TextSize', display.window, ftsz_small);
DrawFormattedText(display.window,text.instrucText,'center','center',[255 255 255],maxCharPline_instruc, 0, 0, 2, 0, []);
Screen(display.window,'Flip');
WaitSecs(waitAft_instruc);
KbWait;
wait4release()

% Trial structure
%-----------------------------------------------
interrupt_task = false; i_trial = 0; repeat = 0;
while i_trial < n_trial
    if repeat==0; i_trial =i_trial+1; end
    
    if interrupt_task; break; end
    
    % fixation interval
    Screen('DrawTexture',display.window,cross,[],rectcross);
    KbReleaseWait;
    wait4release()
    Screen(display.window,'Flip');
    WaitSecs( ITI_duration + rand*ITI_jitter );
    
    % Effort Execution Phase
    % - Display Effort scale
    jaugeRect = [x*0.5 y*0.9 x*1.5 y*1.1];
    i_tmpt = 0; 
    peak = 0; 
    [stop,onset,offset,went_aboveSupThresh,went_belowLowThresh] = deal(false);
    lvl_curr = 0;
    curr_attempt = 1;
    forceTime = GetSecs;
    target = forcelevel(i_trial)*100;
    tstart=GetSecs;
    
    while offset == 0
        % display instruction
        DrawMyText(display.window,text.serrez,ftsz_mid,[255 255 255],[x,y*2/5]);
        
        % monitor dynamo
        i_tmpt = i_tmpt + 1;
        [grip,Tgrip] = readGrip(Handle);
        gripdata.grip{i_trial}(i_tmpt) = grip;
        gripdata.time{i_trial}(i_tmpt) = Tgrip;
        gripdata.attempt{i_trial}(i_tmpt) = curr_attempt;
        lvl_prev = lvl_curr;
        lvl_curr = max(0,grip/calibratedForce*100);
        peak = nanmax([peak,lvl_curr]);
        
         % onset criterion
        if stop == 0 && lvl_curr >= target             
            % detect & count time
            is_forceReached(i_trial) = true;            
            onset = 1;
        end
        
        if stop == 0 && (lvl_curr >= 0.30*target && lvl_prev < 0.30*target) 
           	went_aboveSupThresh = true;
        elseif stop == 0 && went_aboveSupThresh                            ...
                && lvl_curr < 0.15*target && lvl_prev >= 0.15*target
            went_belowLowThresh = true;
        end
        
        if stop == 0 && ~is_forceReached(i_trial)                       ...
                && went_aboveSupThresh && went_belowLowThresh
            went_aboveSupThresh = false;
            went_belowLowThresh = false;
            curr_attempt = curr_attempt + 1;
            if curr_attempt > 5; onset = 1; stop = 1; end % 5 force trials at max
        elseif stop == 0 && is_forceReached(i_trial)                    ...
                && went_belowLowThresh
            stop = 1;
        end
        
        % debugging
        % if attempt == 3
        %    figure(1);
        %    plot(gripdata.time{i_trial},gripdata.grip{i_trial})
        % end
                
        if stop; offset = 1; end

        % offset criterion
        if onset == 1
            if is_forceReached(i_trial)
                textstring = 'OK !';
                DrawMyText(display.window,textstring,ftsz_mid,[0 255 0],[x,y]);
            elseif curr_attempt == 3
                textstring = 'X';
                DrawMyText(display.window,textstring,ftsz_big,[255 255 255],[x,y]);
            end
        end
        
        % refresh screen
        Screen(display.window,'Flip');
    end
    WaitSecs(blanktime);
    
    % - Data to save
    force(i_trial)=max(gripdata.grip{i_trial});
    forcecum(i_trial) = sum(gripdata.grip{i_trial});
    perf(i_trial)=force(i_trial)/calibratedForce*100;
    
    % Effort Rating Phase
    %  Check Response
    exit=0;
    onset=0;
    
    iCursor = 1;
    cursor{i_trial}(iCursor) = 50;
    
    % Get trialtime
    startime=GetSecs;
    while exit == 0
        [xMouse,yMouse,buttons] = recordResponse(display.window);
        [xMouse,yMouse,buttons] = deal([]); %to avoid the validation of two trials in a row
        
        % Write instructions
        draw_scale_instruction_2(display.window,x,y,text.question_name,text.answer_names,ftsz_small);
        Screen('DrawTexture',display.window,emoji_neutral,[],rect_emoji_neutral);
        Screen('DrawTexture',display.window,emoji_infinite,[],rect_emoji_infinite);
        
        % Display cursor and scale
        display_rating_likert(display.window,x,y,[]);
        Screen(display.window,'Flip');
        iCursor = iCursor + 1;
        cursor{i_trial}(iCursor) = cursor{i_trial}(iCursor-1);
        
        % Check keys
        [keyisdown, ~, keycode] = KbCheck;
        if keyisdown == 1
            % monitor validation & exit
            if  keycode(key.space) == 1
                exit = 1;
                validation_responsetime(i_trial) = GetSecs - startime;
                
            elseif keycode(key.escape)==1
                exit = 1;
                interrupt_task = 1;
                break;
            else
                % monitor rating time
                if isnan(press_responsetime(i_trial))
                    press_responsetime(i_trial) = GetSecs - startime;
                end
                if  keycode(key.right)==1
                    cursor{i_trial}(iCursor)=min([cursor{i_trial}(iCursor)+1 100]);
                elseif keycode(key.left)==1
                    cursor{i_trial}(iCursor)=max([cursor{i_trial}(iCursor)-1 0]);
                end
            end
        end
        [xMouse,yMouse,buttons] = recordResponse(display.window);
        xcursor = (xMouse - xScaleLim(1))/diff(xScaleLim)*100;
        xcursor = round(max([min([xcursor,100]),0]));
        cursor{i_trial}(iCursor) = xcursor ;
        % monitor rating time
        if isnan(press_responsetime(i_trial)) && cursor{i_trial}(iCursor)~=cursor{i_trial}(1)
            press_responsetime(i_trial) = GetSecs - startime;
        end
        % monitor confirmation
        exit = any(buttons~=0) & (yMouse>=y);
        validation_responsetime(i_trial) = GetSecs - startime;
        WaitSecs(waitAft_trial);
        
    end
    if interrupt_task; break; end

    % Update data to save
    rating(i_trial)=cursor{i_trial}(iCursor);
    ratingEsummary(trialperm(i_trial))=cursor{i_trial}(iCursor);
    draw_scale_instruction_2(display.window,x,y,text.question_name,text.answer_names,ftsz_small);
    display_rating_likert(display.window,x,y,rating(i_trial)) ;
    Screen('DrawTexture',display.window,emoji_neutral,[],rect_emoji_neutral);
    Screen('DrawTexture',display.window,emoji_infinite,[],rect_emoji_infinite);
    Screen(display.window,'Flip');
    WaitSecs(blanktime);
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
% data creation
rating(rating < 5)   = 0;
rating(rating < 95 & rating >= 5) = ceil((rating(rating <95 & rating >=5)-4)/10);
rating(rating >= 95) = 10;

% main data
varNames  = {'trialNumber', 'forceLevel', 'force', 'sumForce',          ...
    'forcePercentage', 'forceReached','rating', 'pressTime', 'validationTime'};
data      = table((1:n_trial)',forcelevel',force',forcecum',perf',      ...
    is_forceReached,rating',press_responsetime',validation_responsetime',...
    'VariableNames', varNames);

% grip data (timeseries)
varNames  = {'grip', 'time', 'cursor'};
n_gripTrial = 1:numel(gripdata.grip);
tableSupp = table(gripdata.grip', gripdata.time', cursor(n_gripTrial)', 'VariableNames', varNames);

% saving
if interrupt_task
    sub_data.(cfg.sessNber_str).tasks.taskRating_gripExerted.completed...
        = false;
else; sub_data.(cfg.sessNber_str).tasks.taskRating_gripExerted.completed...
        = true;
end
sub_data.(cfg.sessNber_str).tasks.taskRating_gripExerted.results =      ...
    struct('data', data, 'suppResults', tableSupp);

end

%% Past pieces of code
% fprintf('F = %.1f %% \n',level);
% display_effortTarget(display.window,x,y,level/target*100);
% Screen(display.window,'Flip');
% 
% 
% timeCounter_supLim = 0;
% timeCounter_infLim = 0;
% 
% if stop == 0 && (lvl_curr >= 0.30*target && lvl_prev < 0.30*target)
%     % force starts to be above the upper threshold -> timeCounter_supLim reset
%     timeCounter_supLim = 0;
% elseif stop == 0 && timeCounter_supLim > 0.5                    ...
%         && lvl_curr < 0.15*target && lvl_prev >= 0.15*target
%     % force starts to go down (below the lower limit) -> timeCounter_infLim reset
%     % but only if the force was above the upper threshold
%     timeCounter_infLim = 0;
% elseif stop == 0 && lvl_curr >= 0.40*target && lvl_prev >= 0.40*target
%     % force continues to be higher than the high threshold
%     timeCounter_supLim = timeCounter_supLim + (GetSecs-forceTime);
% elseif stop == 0 && timeCounter_supLim > 0.5                    ...
%         && lvl_curr < 0.20*target && lvl_prev < 0.20*target
%     % force continues to be lower than the low threshold
%     % but only if the force was above the upper threshold
%     timeCounter_infLim = timeCounter_infLim + (GetSecs-forceTime);
% end
% forceTime = GetSecs;
% if stop == 0                                                    ...
%         && timeCounter_infLim > 0.5 % 500 ms
%     %                && (timeCounter_supLim > 0.5 && timeCounter_infLim > 0.5) % 500 ms
%     attempt = attempt + 1;
%     timeCounter_infLim = 0;
%     if attempt == 5; onset = 1; stop = 1; end % 5 force trials at max
% end
% 
% 
% 
% 
% 
% 
% 
% % display temporal jauge
% barRect = jaugeRect;
% barRect(3) = round(x*(0.5 + (iTimeCounter/forceDuration)));
% Screen('FillRect',display.window,[255 125 0],barRect);
% Screen('FrameRect',display.window,[255 255 255],jaugeRect,8);
% 
% 
% 
% 
% 
% 
% if iTimeCounter>=forceDuration
%     stop = 1;
%     textstring = 'OK !';
%     DrawMyText(display.window,textstring,ftsz_mid,[0 255 0],[x,y]);
% end
% 
% if stop && level<targetStopCriterion*target % force onset & offset criterion
%     offset = 1;
% end

