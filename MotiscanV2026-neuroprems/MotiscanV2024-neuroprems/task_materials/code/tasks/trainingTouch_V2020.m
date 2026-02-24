function [sub_data] = trainingTouch_V2020(sub_data, cfg)
% function [sub_data] = trainingTouch_V2(sub_data, cfg)
%
% Training task, the subject has to touch various illuminated targets in
% a horizontal scale (alike the rating scales in the next few tasks)
%
% INPUT : sub_data and cfg structures
%
% OUTPUT : updated sub_data with the results = data table with
% trialNumber, positions, target, press_responsetime, validation_responsetime
%
% Adapted March 2020 for V2020, P. CARRILLO

%% Configuration
% -----------------------------------------------
cfg = motiscanV2020_setTask(cfg);

display  = cfg.ptb.display;
H        = display.H;
x        = display.x;
y        = display.y;

key = cfg.ptb.key;

% fontsize
if isfield(cfg.ptb,mfilename)
    ftsz_iTask = cfg.ptb.fontsize.(mfilename);
else;   ftsz_iTask = cfg.ptb.fontsize.global;
end
ftsz_big    = ftsz_iTask.ftsz_big;
ftsz_mid    = ftsz_iTask.ftsz_mid;
ftsz_small  = ftsz_iTask.ftsz_small;
%maxCharPline_instruc = ftsz_iTask.maxCharPline_instruc;
maxCharPline_instruc = 75;

% recurrent textstrings
text.instruc = 'Instructions';
text.appuyer = 'appuyer sur une touche pour continuer...';
text.pretDebut = ['Prêt à débuter ?'];

% timings
ITI_duration = 0.5;
ITI_jitter = 0.5;
blanktime = 0.5;
waitAft_bigTtl = 0.2;
waitAft_instruc = 0.5;
waitAft_trial = 0.007;
maxResponseDuration = 10e3;

% instruction: explanations
DrawMyText(display.window,text.instruc,ftsz_big,[255 255 255],[x,y]);
DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
KbWait;

textstring = ['Au cours de ce test, vous allez vous familiariser avec ' ...
    'l''utilisation de l''interface. Une échelle graduée et une cible ' ...
    '(de couleur verte) seront affichées à l''écran. Le but est de ' ...
    'toucher la cible, prenez le temps nécessaire pour le faire correctement.'];
Screen('TextSize', display.window, ftsz_small);
DrawFormattedText(display.window, textstring,'center','center',     ...
    [255 255 255],maxCharPline_instruc, 0, 0, 2, 0, []);
Screen(display.window,'Flip');
WaitSecs(waitAft_instruc);
KbWait;

% instructions:  start
DrawMyText(display.window,text.pretDebut,ftsz_big,[255 255 255],    ...
    [x,y]);
DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],    ...
    [x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(waitAft_bigTtl);
KbWait;

% Clear screen to background:
Screen('FillRect', display.window, [0 0 0]);
Screen('Flip', display.window);
TouchReleaseWait;

% parameters
nTraining = 3;
xScaleLim = [x*1/5, x*9/5];

% data preparation
validation_responsetime = nan(1,nTraining);
press_responsetime = nan(1,nTraining);
rating = nan(1,nTraining);
target = round(rand(1,nTraining)*100);

% Trial structure
%-----------------------------------------------
interrupt_task=0; ntrial=0; repeat=0;
while ntrial < nTraining
    
    if repeat==0
        ntrial=ntrial+1;
    end
    if interrupt_task
        break
    end
    KbReleaseWait;
    TouchReleaseWait;
    Screen(display.window,'Flip');
    WaitSecs(ITI_duration);
    
    %  Check Response
    exit=0;
    iCursor = 1;
    cursor{ntrial}(iCursor) = 50;
    startime=GetSecs;
    
    while exit==0
        % draw rating scale
        display_rating_likert(display.window,x,y,[],target(ntrial));
        
        Screen(display.window,'Flip');
        iCursor = iCursor + 1;
        cursor{ntrial}(iCursor) = cursor{ntrial}(iCursor-1);
        
        % Check keys
        [keyisdown, ~, keycode] = KbCheck;
        if keyisdown==1
            % monitor validation & exit
            if  keycode(key.space)==1
                exit=1;
                validation_responsetime(ntrial) = GetSecs - startime;
            elseif keycode(key.escape)==1
                exit=1;
                interrupt_task=1;
            else
                % monitor rating time
                if isnan(press_responsetime(ntrial))
                    press_responsetime(ntrial) = GetSecs - startime;
                end
                if  keycode(key.right)==1
                    cursor{ntrial}(iCursor) =                       ...
                        min([cursor{ntrial}(iCursor)+1 100]);
                elseif keycode(key.left)==1
                    cursor{ntrial}(iCursor) =                       ...
                        max([cursor{ntrial}(iCursor)-1 0]);
                end
            end
        end
        [xMouse,~,buttons] = GetMouseTransient(display.window);
        xcursor = (xMouse - xScaleLim(1))/diff(xScaleLim)*100;
        xcursor = round(max([min([xcursor,100]),0]));
        cursor{ntrial}(iCursor) = xcursor ;
        % monitor rating time
        if isnan(press_responsetime(ntrial)) % && cursor{ntrial}(iCursor)~=cursor{ntrial}(1)
            press_responsetime(ntrial) = GetSecs - startime;
        end
        % monitor confirmation
        exit = buttons(1);
        validation_responsetime(ntrial) = GetSecs - startime;
        WaitSecs(waitAft_trial);
    end
    
    % record data
    rating(ntrial)=cursor{ntrial}(iCursor);
    display_rating_likert(display.window,x,y,rating(ntrial),        ...
        target(ntrial))
    Screen(display.window,'Flip');
    WaitSecs(blanktime);
    
end

Screen(display.window,'Flip');
sca;

%% Data saving
%-----------------------------------------------
% data creation
positions   = rating;
trialNumber = 1:nTraining;
varNames = {'trialNumber', 'position', 'target', 'press_RT',        ...
    'validation_RT'};
data = table(trialNumber',positions',target',press_responsetime',   ...
    validation_responsetime', 'VariableNames', varNames);
% saving
if interrupt_task
    sub_data.(cfg.sessNber_str).tasks.trainingResp.completed = false;
else; sub_data.(cfg.sessNber_str).tasks.trainingResp.completed = true;
end
sub_data.(cfg.sessNber_str).tasks.trainingResp.results =            ...
    struct('data',data);

end

