function [calibratedFmax] = grip_calib(cfg)
%[fmax] = grip_calib(varargin)
% Measure fmax using the grip device.
%
% INPUT cfg, configuration structure with at least the paths, psychtoolbox
% configuration (cfg.ptb) and grip configuration (cfg.grip).
%
% OUTPUT fmax, maximal measured force (numeric).
%
% From Raphael Le Bouc, Nicolas Borderies (nico.borderies@gmail.com,
% April 2014)
% Adapted by <teddy.landron@gmail.com> & Pablo Carrillo (Mar, Sep 2020)

%% Text loading
% input_texts = cfg.input_texts.(mfilename);
% if cfg.english
%     inputText_iScript = input_texts(:,1);
% else
%     inputText_iScript = input_texts(:,2);
% end

%% Configuration (unpacking)
cfg = motiscanV2020_setTask(cfg);

display  = cfg.ptb.display;
H        = display.H;
x        = display.x;
y        = display.y;

key = cfg.ptb.key;

gripdevice  = cfg.grip.gripdevice;
Handle      = cfg.grip.Handle;
readGrip    = cfg.grip.readGrip;

% fontsize
ftsz_big    = cfg.ptb.fontsize.global.ftsz_big;
ftsz_mid    = cfg.ptb.fontsize.global.ftsz_mid;
ftsz_small  = cfg.ptb.fontsize.global.ftsz_small;
% maxCharPline_instruc = ftsz_iTask.maxCharPline_instruc;
% maxCharPline_instruc = 75;
% max_charPline = ftsz_iTask.max_charPline;
max_charPline = 50;

% texts
text.instruc = 'Instructions';
text.instrucText1 = ['Dans ce test, il vous est demandé de serrer une poignée '...
    'mesurant votre force.\nVeuillez serrer LE PLUS FORT POSSIBLE, '    ...
    'seule la force maximale compte, pas la durée de l''effort.\n\n'     ...
    'Vous aurez trois essais pour atteindre votre score de force le plus fort !'];

text.calibText1 = ['Avant de débuter, appuyer sur ''N'' et '...
    '''zero'' sur le boitier du grip'];
text.calibText2 = ['Avant de débuter, relacher complètement'...
    ' la poignée pour l''étalonnage.'];
text.calib = 'étalonnage...';

text.trial = 'essai n°';
text.appuyer = 'appuyer sur une touche pour continuer...';
text.quePref  = 'Que préférez-vous ?';
text.pretDebut = 'Prêt à  débuter ?';
text.timesUp = 'Temps écoulé !';
text.faster = 'Répondez plus rapidement svp.';

%% Experiment preparation
% ----------------------------------------------

cd(cfg.paths.task.images); % enter img dir

% instructions images
% instruction = struct('texture',{},'position',{});
% for i=1:7
%     instruction(i).texture = Screen('MakeTexture',display.window,imread(['instruction_GripRP_' num2str(i) '.bmp']));
% end

cd(cfg.paths.task.code); % exit img dir

% Experimental conditions
ITI_duration = 0.5;
ITI_jitter = 0.5;
blanktime = 0.5;
waitAft_bigTtl = 0.2;
waitAft_instruc = 0.5;
waitAft_trial = 0.007;
maxResponseDuration = 10e3;

% instructions:  start
DrawMyText(display.window,text.instruc,ftsz_big,[255 255 255],[x,y]);
DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
KbWait;

%% Calibration
% device tare
% [readGrip] = grip_tare(cfg);
switch gripdevice
    case 'mie' % device reset
        % textstring = inputText_iScript{2}; % text:2
        textstring = text.calibText1;
        DrawMyText(display.window,textstring,ftsz_mid,[255 0 0],[x,y]);
        % textstring = inputText_iScript{1}; % text:1
        textstring = text.appuyer;
        DrawMyText(display.window,textstring,ftsz_small,[255 0 0],[x,1.5*y]);
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

DrawMyText(display.window,text.pretDebut,ftsz_big,[255 255 255],[x,y]);
DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(waitAft_bigTtl);
KbWait;

% Trial structure
exit = 0;
calib = 0;
while exit==0
    for example=1:3
        
        % Display instruction
        textstring = [text.trial num2str(example)];
        DrawMyText(display.window,textstring,ftsz_big,[255 0 0],[x,y]);
        Screen(display.window,'Flip');
        WaitSecs(ITI_duration);
        
        % Display Effort score
        calibrationtime = GetSecs;
        keep  = 0;
        while GetSecs < calibrationtime + 5
            [grip,~] = readGrip(Handle);
            keep = max([keep grip]);
            
            Screen('TextSize', display.window, ftsz_mid);
            [width,hight]=RectSize(Screen('TextBounds',display.window,'Go!'));
            Screen('DrawText',display.window,'Go!',x-width/2,y-hight/2-100,[255 0 0]);
            [width,hight]=RectSize(Screen('TextBounds',display.window,num2str(round(grip))));
            Screen('DrawText',display.window,num2str(round(grip)),x-width/2,y-hight/2,[255 255 255]);
            
            Screen('TextSize', display.window, ftsz_small);
            [width,hight]=RectSize(Screen('TextBounds',display.window,'(Record)'));
            Screen('DrawText',display.window,'(Record)',x-width/2+300,y-hight/2-100,[175 175 175]);
            Screen('TextSize', display.window, ftsz_small);
            [width,hight]=RectSize(Screen('TextBounds',display.window,num2str(round(max([calib keep])))));
            Screen('DrawText',display.window,num2str(round(max([calib keep]))),x-width/2+300,y-hight/2,[175 175 175]);
            
            Screen(display.window,'Flip');
            WaitSecs(waitAft_trial);
        end
        
        % Record the maximal force
        calib = max([calib keep]);
    end
    
    % check validity of calibration
    textstring = 'Appuyer sur [ESPACE] pour continuer ou [RETOUR] pour réessayer...'; % text:4
    % DrawMyText(display.window,textstring,ftsz_small,[255 255 255],[x,y]);
    Screen('TextSize', display.window, ftsz_small);
    DrawFormattedText(display.window,textstring,'center','center',      ...
        [255 255 255],40, 0, 0, 2, 0, []);
    Screen(display.window,'Flip');
    WaitSecs(waitAft_bigTtl);
    [~, keyCode] = KbWait;
    
    if keyCode(key.space)==1
        exit=1;
    end
end
calibratedFmax = calib;

% device stop
%grip_onoff(cfg,3); % Handle.stop
switch gripdevice
    case 'vernier'
        Handle.stop();
    case 'mie'
        CloseGripDevice('MIE',Handle);
end

Screen(display.window,'Flip');
sca;
end