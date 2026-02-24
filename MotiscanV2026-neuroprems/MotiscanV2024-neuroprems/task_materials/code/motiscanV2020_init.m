function [sub_data, cfg] = motiscanV2020_init(cfg)
%[sub_data, cfg] = motiscanV2020_init(cfg)
% Initialises the motivational battery session (at the beginning of
% motiscanV2020_run; study protocol, subject's ID, sessions number, paths)
% and checks if there is a session that has already been started. If so,
% asks whether the experimenter wants to continue with it and loads the
% available configuration/data or not.
%
%
% OUTPUTS:
%   -   sub_data: subject's data structure, with the study_name
%   (sub_data.study_name), the subject's ID (sub_data.sub_id), the field
%   for the session to be completed and its number
%   (sub_data.(sessNber_str), .sess_nber),
%
%
%   -   cfg: configuration structure, added with paths (e.g., code, data,
%   etc.) as well as cfg.subId_str and cfg.sessNber_str needed to access
%   sub_data.(cfg.sessNber_str) later on.
%
%
% by C. Jaffre, P. Carillo & T. Landron <teddy.landron@gmail.com> (2020)

% Updated February 2023 for V2023, R.JOLY

%% Output initialisation
if ~isstruct(cfg); cfg = struct; end
sub_data = struct;
paths    = struct;

%% Forcing directory
cd(fileparts(which('motiscanV2020_run')))

paths.main = ['..', filesep, '..', filesep];

%% Main directories
% task directory
paths.task.main     = [paths.main 'task_materials' filesep];
paths.task.code     = [paths.task.main 'code' filesep];
paths.task.images   = [paths.task.main 'images', filesep];
paths.task.devices  = [paths.task.main 'devices', filesep];
paths.task.text     = [paths.task.main 'text', filesep];

addpath(genpath(paths.task.main))

%% ID system
[~, cfg.hostname] = system('hostname');

% workstations
if contains_forOlder(cfg.hostname,'PESSI-WF001')
    cfg.system_id = 'CJs_PC';
elseif contains_forOlder(cfg.hostname,'PESSI-WF002')
    cfg.system_id = 'PCs_PC';
elseif contains_forOlder(cfg.hostname,'UMR-PESSI-WF003')
    cfg.system_id = 'TLs_PC';
elseif contains_forOlder(cfg.hostname,'ICM-PESSI-WF016')
    cfg.system_id = 'RJs_PC';
elseif contains_forOlder(cfg.hostname,'ICM-PESSI-WF007')
    cfg.system_id = 'ACs_PC';

    % laptops
elseif contains_forOlder(cfg.hostname,'shuRecherche-HP')
    cfg.system_id = 'SHU_laptop';
    
    % tablets
% elseif contains_forOlder(cfg.hostname,'ICM-PESSI-WT001')
%     cfg.system_id = 'MOTIstroke_tablet';
    elseif contains_forOlder(cfg.hostname,'ICM-PESSI-WT003')
    cfg.system_id = 'FTDISI_tablet';

    elseif contains_forOlder(cfg.hostname,'ICM-PESSI-WT007')
    cfg.system_id = 'Motineuro_tablet';


    elseif contains_forOlder(cfg.hostname,'ICM-PESSI-WT008')
    cfg.system_id = 'MotineuroAC_tablet';


    % PRISM
elseif contains_forOlder(cfg.hostname,'ICM-PRISM')
    cfg.system_id = 'PRISM_PC';
    
    % personal
elseif contains_forOlder(cfg.hostname,'Ted')
    cfg.system_id = 'TLs_MBP';
elseif contains_forOlder(cfg.hostname,'Raphael')
    cfg.system_id = 'RJs_MBP';

elseif contains_forOlder(cfg.hostname,'antonius-thinkpad')
    cfg.system_id = 'AWs_laptop';
elseif contains_forOlder(cfg.hostname,'air-de-alice-3.home')
    cfg.system_id = 'ACs_laptop';
    
else
    cfg.system_id = 'Other_PC';

end

%% Specific paths
switch cfg.system_id
    % workstations
    case {'CJs_PC'} % CHANGE???
        paths.PTBtouch = 'K:\toolbox\PsychtoolboxTactile';
        paths.PTB      = 'K:\toolbox\Psychtoolbox-3-Psychtoolbox-3-ea9028e';
        paths.PTB2     = 'C:\toolbox\Psychtoolbox-3-Psychtoolbox-3-ea9028e';
    case {'PCs_PC'} % CHANGE???
        paths.PTBtouch = 'K:\toolbox\PsychtoolboxTactile';
        paths.PTB      = 'K:\toolbox\Psychtoolbox-3-Psychtoolbox-3-ea9028e';
        paths.PTB2     = 'C:\toolbox\Psychtoolbox-3-Psychtoolbox-3-ea9028e';
    case {'TLs_PC'}
        paths.PTBtouch = fullfile('..','..','..','..','MATLAB',          ...
            'PsychtoolboxTouch');
        paths.PTB = fullfile('C:','Users','teddy.landron','Documents',   ...
            'MATLAB','Psychtoolbox'); % CHECK
    case {'RJs_PC'}
        paths.PTBtouch = fullfile('C:\toolbox\PsychtoolboxTouch');
        paths.PTB = fullfile('C:\toolbox\Psychtoolbox');

    case {'ACs_PC'}
        paths.PTBtouch = fullfile('C:\Users\alice.clerouin\Documents\MATLAB\toolbox\Psychtoolbox');
        paths.PTB = fullfile('C:\Users\alice.clerouin\Documents\MATLAB\toolbox\Psychtoolbox');

    case 'PRISM_PC'
        paths.PTBtouch = fullfile('K:','toolbox','PsychtoolboxTactile');  % for debug, no touch PTB avialable on laptop
        paths.PTB = fullfile('K:','toolbox','Psychtoolbox');
        
        % laptops
    case {'SHU_laptop'}
        paths.PTBtouch = fullfile('C:','toolbox','Psychtoolbox');  % for debug, no touch PTB avialable on laptop
        paths.PTB = fullfile('C:','toolbox','Psychtoolbox');
        
        % tablets
    case {'MOTIstroke_tablet'}
        paths.PTBtouch = fullfile('..','..','..','..','MATLAB',          ...
            'PsychtoolboxTouch');
        paths.PTB = fullfile('C:','Users','teddy.landron','Documents',   ...
            'MATLAB','Psychtoolbox');
    
    case {'FTDISI_tablet'}
        paths.PTBtouch = fullfile('C:','toolbox','PsychtoolboxTouch');
        paths.PTB = fullfile('C:','toolbox','Psychtoolbox')
  
    case {'Motineuro_tablet'}
        paths.PTBtouch = fullfile('C:','Dowloads','Psychtoolbox-3-master');
        paths.PTB = fullfile('C:','Downloads','Psychtoolbox-3-master');

    case {'MotineuroAC_tablet'}
        paths.PTBtouch = fullfile('C:\Users\alice.clerouin\Documents\MATLAB\toolbox\Psychtoolbox-3-master');
        paths.PTB = fullfile('C:\Users\alice.clerouin\Documents\MATLAB\toolbox\Psychtoolbox-3-master');


        % personal
    case {'TLs_MBP'}
        paths.PTBtouch = fullfile('..','..','..','..','MATLAB',          ...
            'PsychtoolboxTouch');
        paths.PTB = '/Applications/Psychtoolbox/';
    case {'RJs_MBP'}
        paths.PTBtouch = fullfile('..','..','..','..','MATLAB',          ...
            'PsychtoolboxTouch','Psychtoolbox"');
        paths.PTB = '/Applications/Psychtoolbox/';
        
    case {'Other_PC'}
        paths.PTBtouch = fullfile('C:','toolbox','PsychtoolboxTouch');
        paths.PTB = fullfile('C:','toolbox','Psychtoolbox');
        

end
% removes PTBtouch if still in path, later re-added if needed
if exist('getMouseTransient','file'); rmpath(genpath(paths.PTBtouch)); end
% adds PTB if not in path
if ~exist('getMouse','file'); addpath(genpath(paths.PTB)); end

%% Packing paths
cfg.paths = paths;

%% Text .mat
language_input = false;
while ~language_input
    cfg.english = input('\nLang(u)age? (FR: 0/EN: 1): ');
    if any(ismember(cfg.english,[0 1]))
        language_input = true;
    end
end

if ~exist('motiscanV2020_inputText.mat','file') || cfg.force_textUpdate
    motiscanV2020_makeInputText(cfg)
end

tmp = load('motiscanV2020_inputText.mat');
cfg.input_texts = tmp.input_texts;

inputText_iScript = cfg.input_texts.(mfilename);
if cfg.english
    inputText_iScript = inputText_iScript(:,1);
else
    inputText_iScript = inputText_iScript(:,2);
end

%% Fontsize

%% Study selection
study_names = {'vortiobat', 'motistroke', 'ketabi', 'conhect', 'delai', 'cogperf', 'pilote','motineuro','ddt','neuroprems'};
i_study = input_num(cfg,inputText_iScript{1},[1,2,3,4,5,6,7,8,9,10]); % text:1
sub_data.study_name = study_names{i_study};
fprintf(inputText_iScript{2},sub_data.study_name); % text:2

%% Generated data directories
paths.data         = [paths.main,'data',filesep];
paths.data_study   = [paths.data sub_data.study_name filesep];
paths.data_backups = [paths.data_study 'backups' filesep];
if ~exist(paths.data_backups,'file')
    mkdir(paths.data_backups);
end

%% Subject & session input
sub_data.sub_id     = input_num(cfg,inputText_iScript{3},1:99999); % text:3
%sub_data.sub_id = 1;%debug
subId_str           = ['sub' num2str(sub_data.sub_id)];
tmp_sub_code        = input_subCode(cfg,subId_str);
sub_data.sub_code   = tmp_sub_code;
paths.data_sub      = [paths.data_study filesep subId_str filesep];
if ~exist(paths.data_sub,'file')
    mkdir(paths.data_sub);
end

sess_nber      = input_num(cfg,inputText_iScript{4},1:999); % text:4
%sess_nber = 1;%debug
sess_str                        = ['sess' num2str(sess_nber)];
sub_data.(sess_str).sess_nber   = sess_nber;

% check previous configuration
filename = [paths.data_sub filesep sub_data.study_name '_' subId_str '_'...
    sess_str '_subdata.mat'];
if exist(filename,'file')
    tmp  = load(filename);
    date = tmp.sub_data.(sess_str).date;
    input_text = sprintf(inputText_iScript{5},sub_data.sub_id,sess_nber,date); % text:5
    cfg.from_start = logical(1 - input_num(cfg,input_text,[0,1]));
    if ~strcmp(sub_data.sub_code,tmp_sub_code)
        warning(inputText_iScript{8},                                   ...
            sub_data.sub_id,sub_data.sub_code,tmp_sub_code); % text:8
        input_text = sprintf(inputText_iScript{9},                      ...
            sub_data.sub_code,tmp_sub_code); % text:9
        what2do = input_num(cfg,input_text,0:2);
        switch what2do
            case 1; sub_data.sub_code = tmp_sub_code;
            case 2; error(inputText_iScript{10}) % text:10
        end
    end
    if cfg.from_start
        warning(inputText_iScript{6},            ...
            sub_data.study_name, sess_nber, sub_data.sub_id); % text:6
        cfg.keep_taskSel = false;
    else
        sub_data = tmp.sub_data;
        taskSel_cat = [];
        for i_task = 1:numel(sub_data.(sess_str).cfg.task.task_sel)
            if isempty(taskSel_cat)
                taskSel_cat = [' - ' sub_data.(sess_str).cfg.task.task_sel{1}];
            else
                taskSel_cat = [taskSel_cat '\n - '                      ...
                    sub_data.(sess_str).cfg.task.task_sel{i_task}];
            end
        end
        input_text = sprintf(inputText_iScript{7},taskSel_cat); % text:7
        cfg.keep_taskSel = logical(input_num(cfg,input_text,[0,1]));
    end
else
    cfg.from_start = true;
    cfg.keep_taskSel = false;
end

%% Output

cfg.paths           = paths;
cfg.subId_str       = subId_str;
cfg.sessNber_str    = sess_str;
