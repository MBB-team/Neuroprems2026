function [readGrip] = grip_tare(cfg)

%% Text loading
input_texts = cfg.input_texts.(mfilename);
if cfg.english
    inputText_iScript = input_texts(:,1);
else
    inputText_iScript = input_texts(:,2);
end

%% Configuration (unpacking)
display  = cfg.psychtlbx.display;
H        = display.H;
x        = display.x;
y        = display.y;

key = cfg.psychtlbx.key;

gripdevice  = cfg.grip.gripdevice;
Handle      = cfg.grip.Handle;
readGrip    = cfg.grip.readGrip;

% fontsize
ftsz_big    = cfg.psychtlbx.fontsize.global.ftsz_big;
ftsz_mid    = cfg.psychtlbx.fontsize.global.ftsz_mid;
ftsz_small  = cfg.psychtlbx.fontsize.global.ftsz_small;

% timing variables
waitAft_bigTtl = 0.2;
waitAft_instruc = 0.5;
waitAft_trial = 0.007;

%% Main
grip_onoff(cfg,1);

switch gripdevice
    case 'mie' % device reset
        
%         if on
            textstring = inputText_iScript{2}; % text:2
            DrawMyText(display.window,textstring,ftsz_mid,[255 0 0],[x,y]);
            textstring = inputText_iScript{1}; % text:1
            DrawMyText(display.window,textstring,ftsz_small,[255 0 0],[x,1.5*y]);
            Screen(display.window,'Flip');
            WaitSecs(waitAft_instruc);
            KbWait;
%         else % off
%             CloseGripDevice('MIE',Handle);
%         end
        
    case 'vernier'
%         if on
%             % if not initialised
%             if ~isfield(cfg.grip,'Handle')
%                 cfg.grip.Handle = dynamometer;
%             end
%             % if recording: 1
%             if isfield(cfg.grip,'Handle')                              ...
%                         && isprop(cfg.grip.Handle,'recording')         ...
%                         && cfg.grip.Handle.recording == true
%                 Handle.stop();
%                 % recording: 0
%             end
%             % if working: 0
%             if isfield(cfg.grip,'Handle')                              ...
%                         && isprop(cfg.grip.Handle,'working')         ...
%                         && cfg.grip.Handle.working == false
%                 Handle.open();
%                 % working: 1
%             end
%             % if recording: 0
%             if isfield(cfg.grip,'Handle')                               ...
%                         && isprop(cfg.grip.Handle,'working')            ...
%                         && cfg.grip.Handle.working == true              ...
%                         && isprop(cfg.grip.Handle,'recording')          ...
%                         && cfg.grip.Handle.recording == false
%                 Handle.start();
%                 % recording: 1
%             end
                
%             else
%                 try Handle.start();
%                 catch
%                     clear functions
%                     cfg.grip.Handle     = dynamometer;
%                     cfg.grip.readGrip   = @readVernier;
%                     Handle              = cfg.grip.Handle;
%                     readGrip            = cfg.grip.readGrip;
%                     Handle.start();
%                     %sca;
%                     %rethrow(lasterror)
%                     % error('check grip connection')
%                 end
%             end

        
%            cfg.grip.readGrip       = @readVernier;
        
            textstring = inputText_iScript{3}; % text:3
            % DrawMyText(display.window,textstring,ftsz_mid,[255 255 255],[2*x,y*1/2],40);
            Screen('TextSize', display.window, ftsz_mid);
            DrawFormattedText(display.window,textstring,'center','center',[255 255 255],50, 0, 0, 2, 0, []);
            textstring = inputText_iScript{1};  % text:1
            DrawMyText(display.window,textstring,ftsz_small,[100 100 100],[x,1.5*y]);
            Screen(display.window,'Flip');
            WaitSecs(waitAft_instruc);
            signal = [];
            rec = 1;
            while rec == 1
                grip = readGrip(Handle);
                signal = [signal,grip];
                rec = ~(KbCheck);
            end
            offset = nanmin(signal);
            readGrip = @(Handle) readVernier(Handle,offset);
%         else % off
%             Handle.stop();
%             Handle.close();
%         end
end
end
