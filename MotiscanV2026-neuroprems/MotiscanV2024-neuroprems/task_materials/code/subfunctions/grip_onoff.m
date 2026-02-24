function grip_onoff(cfg,on)
%grip_onoff(cfg,on)
% on:
%  -  1: on
%  -  2: partial off (stop)
%  -  3: full off (stop & close)
%
% by <teddy.landron@gmail.com> (Sept. 2020)

gripdevice  = cfg.grip.gripdevice;
if isfield(cfg.grip,'Handle'); Handle = cfg.grip.Handle; end

switch gripdevice
    case 'mie' % device reset
        switch on; case 1 ;otherwise; CloseGripDevice('MIE',Handle); end
    case 'vernier'
        switch on
            case 1
                % if not initialised
                if ~isfield(cfg.grip,'Handle')
                    cfg.grip.Handle = dynamometer;
                end
                % if recording: 1
                if isfield(cfg.grip,'Handle')                              ...
                        && isprop(cfg.grip.Handle,'recording')         ...
                        && cfg.grip.Handle.recording == true
                    Handle.stop();
                    % recording: 0
                end
                % if working: 0
                if isfield(cfg.grip,'Handle')                              ...
                        && isprop(cfg.grip.Handle,'working')         ...
                        && cfg.grip.Handle.working == false
                    Handle.open();
                    % working: 1
                end
                % if recording: 0
                if isfield(cfg.grip,'Handle')                               ...
                        && isprop(cfg.grip.Handle,'working')            ...
                        && cfg.grip.Handle.working == true              ...
                        && isprop(cfg.grip.Handle,'recording')          ...
                        && cfg.grip.Handle.recording == false
                    Handle.start();
                    % recording: 1
                end
            case 2 % stop
                % recording:0 -> 1
                if isfield(cfg.grip,'Handle')                               ...
                        && isprop(cfg.grip.Handle,'working')            ...
                        && cfg.grip.Handle.working == true              ...
                        && isprop(cfg.grip.Handle,'recording')          ...
                        && cfg.grip.Handle.recording == true
                    Handle.stop();
                end
            case 3 % full off: stop & close
                % recording:0 -> 1
                if isfield(cfg.grip,'Handle')                               ...
                        && isprop(cfg.grip.Handle,'working')            ...
                        && cfg.grip.Handle.working == true              ...
                        && isprop(cfg.grip.Handle,'recording')          ...
                        && cfg.grip.Handle.recording == true
                    Handle.stop();
                end
                
                % working: 1 -> 0
                if isfield(cfg.grip,'Handle')                               ...
                        && isprop(cfg.grip.Handle,'working')            ...
                        && cfg.grip.Handle.working == true              ...
                        && isprop(cfg.grip.Handle,'recording')          ...
                        && cfg.grip.Handle.recording == false
                    Handle.close()
                end
        end
end