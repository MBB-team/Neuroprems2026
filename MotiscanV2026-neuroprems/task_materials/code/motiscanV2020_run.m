

%% Script motiscanV2020_run
% Runs the MOTIscan battery in its 2020 version. This version attempts to
% homogenise the code, the overall data structure & the further data
% analsyses.
%    
% 
% OUTPUT : This script creates a folder with the subject number in the
% 'data' folder 
% 
% 
% 
% 
% 
% 
% 
%  r. In it it creates and updates a sub_data structure after
% each task with the formatted data in it.
%
%       
% 
% From N. Borderies, R. Le Bouc, M. Pessiglione & F. Vinckier.
% Updated by P. Carrillo, C. Jaffre & T. Landron (2020).
% Updated February 2023 for V2023, R.JOLY


%% Initialization & study selection
clc
clear all
% Unfortunately this seems mandatory to avoid unfound library
% error with the dynamometer

cfg = struct;
cfg.force_textUpdate = true;
cfg.ptb.fullscreen = true;
cfg.debug = true;
[sub_data, cfg] = motiscanV2020_init(cfg);

%% Text loading
input_texts = cfg.input_texts.(mfilename);
if cfg.english
    inputText_iScript = input_texts(:,1);
else
    inputText_iScript = input_texts(:,2);
end

%% Task selection
cfg.task.task_all = {
    'trainingResp',             ...'trainingJoystick',   %1
    'taskRatingR',              ...
    'taskRatingP',              ...
    'taskRatingE',              ...
    'taskChoiceR',              ...
    'taskChoiceP',              ...             
    'taskChoiceE',              ...
    'taskWeightRE',             ...
    'taskWeightPE',             ...
    'taskWeightRP',             ...
    'taskChoice_MoneyDelay',    ...
    'taskChoice_MoneyRisk',     ...
    'taskChoice_CogEffort',     ...
    'taskChoice_GripEffort',    ...
    'taskRating_gripExerted',   ...
    'taskConfidencePrecision',  ...
    'taskRatingN',              ...  %17
    'taskCogEffort',            ...
    'taskRatingR2',             ...  %19
    'taskRatingE2',             ...  %20
    'taskRatingS',              ...  %21
    'taskRatingAS',             ...
    'taskChoiceN1D' ,           ...
    'taskChoiceE21D',           ...
    'taskChoiceR21D',           ...
    'taskWeightR2E2',           ...  %26
    'taskWeightR2d',            ...  %27
    'taskWeightE2d' ,           ...
    'ChoiceDelayR2_txt'         ...  %29
    'taskChoice4DNR2AS',        ...  %30
    'taskChoiceDelayR2',        ...  %31
    'taskControlSemantic',      ...
    'taskControlTOM',           ...
    'taskControlPerception',    ...  
    'taskGripRP',               ...
    };

if strcmp(sub_data.study_name, 'vortiobat')
    input_text = sprintf(inputText_iScript{1},sub_data.study_name); % text:1
    task_selNber_sorted = 1:18;
elseif strcmp(sub_data.study_name, 'motistroke')
    input_text = sprintf(inputText_iScript{2},sub_data.study_name); % text:2
    task_selNber_sorted = [1:12,14:15];
elseif strcmp(sub_data.study_name, 'ketabi')
    input_text = sprintf(inputText_iScript{1},sub_data.study_name); % text:1
    task_selNber_sorted = 1:17;
elseif strcmp(sub_data.study_name, 'conhect')
    input_text = sprintf(inputText_iScript{6},sub_data.study_name); % text:6
    task_selNber_sorted = [2:10, 11:14, 15, 17];
elseif strcmp(sub_data.study_name, 'delai')
    input_text = sprintf(inputText_iScript{6},sub_data.study_name); % text:6
    task_selNber_sorted = [8, 17];
elseif strcmp(sub_data.study_name, 'cogperf')
    input_text = sprintf(inputText_iScript{6},sub_data.study_name); % text:6
    task_selNber_sorted = [1, 11:14, 17, 18];
elseif strcmp(sub_data.study_name, 'pilote')
    input_text = sprintf(inputText_iScript{1},sub_data.study_name); % text:1
    task_selNber_sorted = 1:18;
elseif strcmp(sub_data.study_name, 'motineuro')
    input_text = sprintf(inputText_iScript{7},sub_data.study_name); % text:7​
    rng('shuffle'); % Ensure different randomization each time
    
    block1 = {17,19,20,21,22};
    block2 = {23,24,25};
    block3 = {26,29,30,31};
    block4 = {32,33,34};
    shuffledBlock1 = block1(randperm(length(block1)));
    shuffledBlock2 = block2(randperm(length(block2)));
    shuffledBlock3 = block3(randperm(length(block3)));
    shuffledBlock4 = block4(randperm(length(block4)));
    Block1 = [shuffledBlock1{:}];
    Block2 = [shuffledBlock2{:}];
    Block3 = [shuffledBlock3{:}];
    Block4 = [shuffledBlock4{:}];

    % Debug print statements to verify randomization 
    disp('Shuffled Block 1:');
    disp(Block1); 
    disp('Shuffled Block 2:'); 
    disp(Block2); 
    disp('Shuffled Block 3:'); 
    disp(Block3); 
    disp('Shuffled Block 4:'); 
    disp(Block4);
    task_selNber_sorted = [1, Block1, Block2, Block3, Block4, 35];
    
elseif strcmp(sub_data.study_name, 'ddt')
    input_text = sprintf(inputText_iScript{6},sub_data.study_name); % text:1
    task_selNber_sorted = [1 19 31];
elseif strcmp(sub_data.study_name, 'neuroprems')
    input_text = sprintf(inputText_iScript{6},sub_data.study_name); % text:1
    task_selNber_sorted = [1 19 20 26 31 30];
    
else
    error('study_name error!')
end

if ~cfg.keep_taskSel; predeter = logical(input_num(cfg,input_text, 0:1));
else; predeter = false;
end

if predeter % && ~cfg.keep_taskSel if from start == true, keep_taskSel == false
    cfg.task.task_sel = cfg.task.task_all(task_selNber_sorted)';
elseif (cfg.from_start && ~predeter) || ~cfg.keep_taskSel
    consistent = false;
    input_text = sprintf(inputText_iScript{3}, 1:18, 1,18); %text:3
    %task_selNber_sorted = 5:19; %debug
    while ~consistent
        [task_selNber_sorted, ~] = input_num(cfg,input_text, 1:18);
        cfg.task.task_sel = cfg.task.task_all(task_selNber_sorted)';
        [consistent] = check_taskSel(cfg);
    end
    sub_data.(cfg.sessNber_str).tasks.taskSel_list = cfg.task.task_sel;
else % cfg.keep_taskSel
    cfg.task.task_sel = sub_data.(cfg.sessNber_str).cfg.task.task_sel;
end

n_taskSel = numel(cfg.task.task_sel);

% task order
if cfg.from_start
    [sub_data, cfg] = tasks_order(sub_data, cfg);
else
    cfg.task.global_order = sub_data.(cfg.sessNber_str).tasks.global_order;
end

% experiment starting time
sub_data.(cfg.sessNber_str).date                = datestr(now,'yyyymmdd');
if cfg.from_start || ~rec_isfield(sub_data.(cfg.sessNber_str), 'sess_start')
    sub_data.(cfg.sessNber_str).time.sess_start = datestr(now,'HHMM');
end

%% MOTIscan tasks setting
% set psychtoolbox
try
    [cfg] = motiscanV2020_setPTB(cfg);
    
    % set grip
    grip_tasks = {'taskChoice_GripEffort',                                  ...
        'taskRating_gripExerted',                                 ...
        'taskConfidencePrecision',                                ...
        'taskGripRP'};
    is_gripUsed = any(ismember(grip_tasks, cfg.task.task_sel));
    if is_gripUsed
        cfg.grip.gripdevice = 'vernier'; %,'mie','pneumo'
        [sub_data, cfg] = motiscanV2020_setHandGrip(sub_data, cfg);
    end
catch
    if is_gripUsed; grip_onoff(cfg,3); end % switch grip off
    sca;
    rethrow(lasterror)
end
sub_data.(cfg.sessNber_str).cfg = cfg;

% Save the grip calib results
filename = [cfg.paths.data_sub sub_data.study_name '_'          ...
    cfg.subId_str '_' cfg.sessNber_str '_subdata.mat'];
save(filename,'sub_data');



%% Tasks launching
for i_task = 1:n_taskSel
    iTask_str = sub_data.(cfg.sessNber_str).tasks.global_order{i_task};

    % Tries to reach the status of task (completed : y/n), if ~isfield
    % or isempty, completed = false. Once the task done, completed = true
    % (within task script). If isfield & ~isempty & completed = true, lets
    % the experimenter know the task has already been done
    try
        if ~isfield(sub_data.(cfg.sessNber_str).tasks.(iTask_str),'completed')...
                || isempty(sub_data.(cfg.sessNber_str).tasks.(iTask_str).completed)
            sub_data.(cfg.sessNber_str).tasks.(iTask_str).completed = false;
        elseif sub_data.(cfg.sessNber_str).tasks.(iTask_str).completed
            fprintf(inputText_iScript{4}) % text:4
        end
    catch
    end

    input_text = sprintf(inputText_iScript{5},iTask_str);
    cont = input_num(cfg,input_text, 0:2); % text:5

    if cont == 1
        try
            % timer
            sub_data.(cfg.sessNber_str).time.([iTask_str '_start'])  = datestr(now,'HHMM');
            sub_data.(cfg.sessNber_str).tasks.(iTask_str).date       = datestr(now,'yyyymmdd');
            sub_data.(cfg.sessNber_str).tasks.(iTask_str).time_start = datestr(now,'HHMM');

            switch iTask_str % call for the task function fo each task
                case 'trainingResp' % Training for the user device (mouse|touchscreen)
                    if cfg.ptb.mouse
                        [sub_data] = trainingMouse_V2020(sub_data, cfg);
                    elseif cfg.ptb.touch
                        [sub_data] = trainingTouch_V2020(sub_data, cfg);
                    end

                case 'taskRatingR'
                    [sub_data] = taskRating1D_V2020(sub_data,cfg,'R');

                case 'taskRatingP'
                    [sub_data] = taskRating1D_V2020(sub_data,cfg,'P');

                case 'taskRatingE'
                    [sub_data] = taskRating1D_V2020(sub_data,cfg,'E');

                case 'taskChoiceR'
                    [sub_data] = taskChoice1D2O_V2020(sub_data,cfg,'R');

                case 'taskChoiceP'
                    [sub_data] = taskChoice1D2O_V2020(sub_data,cfg,'P');

                case 'taskChoiceE'
                    [sub_data] = taskChoice1D2O_V2020(sub_data,cfg,'E');

                case 'taskWeightRE'
                    [sub_data] = taskChoice2D1O_V2020(sub_data,cfg,'RE');

                case 'taskWeightPE'
                    [sub_data] = taskChoice2D1O_V2020(sub_data,cfg,'PE');

                case 'taskWeightRP'
                    [sub_data] = taskChoice2D1O_V2024(sub_data,cfg,'RP');

                case 'taskChoice_MoneyDelay'
                    [sub_data] = taskChoice_MoneyDelay_V2020(sub_data, cfg);

                case 'taskChoice_MoneyRisk'
                    [sub_data] = taskChoice_MoneyRisk_V2020(sub_data, cfg);

                case 'taskChoice_CogEffort'
                    [sub_data] = taskChoice_CogEffort_V2020(sub_data, cfg);

                case 'taskChoice_GripEffort'
                    cfg = check_hand(iTask_str, cfg);
                    sub_data.(cfg.sessNber_str).tasks.(iTask_str).hand_used = ...
                        cfg.grip.hand_used;
                    [sub_data] = taskChoice_GripEffort_V2020(sub_data, cfg);

                case 'taskRating_gripExerted'
                    cfg = check_hand(iTask_str, cfg);
                    sub_data.(cfg.sessNber_str).tasks.(iTask_str).hand_used = ...
                        cfg.grip.hand_used;
                    [sub_data] = taskRating_gripExerted_V2020(sub_data, cfg);

                case 'taskConfidencePrecision'
                    cfg = check_hand(iTask_str, cfg);
                    sub_data.(cfg.sessNber_str).tasks.(iTask_str).hand_used = ...
                        cfg.grip.hand_used;
                    [sub_data] = taskConfidencePrecision_V2020(sub_data, cfg);

                case 'taskCogEffort'
                    [sub_data] = taskCogEffort_V2020(sub_data, cfg);

                case 'taskRatingN'
                    [sub_data] = taskRatingN_V2023_img(sub_data, cfg);

                case 'taskRatingR2'
                    [sub_data] = taskRatingR2_V2023_img(sub_data, cfg);

                case 'taskRatingE2'
                    [sub_data] = taskRatingE2_V2023_img(sub_data, cfg);

                case 'taskRatingS'
                    [sub_data] = taskRatingS_V2023_img(sub_data, cfg);

                case 'taskRatingAS'
                    [sub_data] = taskRatingAS_V2024_img(sub_data, cfg);

                case 'taskChoiceN1D'
                    [sub_data] = taskChoiceN1D_V2023_img(sub_data, cfg);

                case 'taskChoiceE21D'
                    [sub_data] = taskChoiceE21D_V2023_img(sub_data, cfg);

                case 'taskChoiceR21D'
                    [sub_data] = taskChoiceR21D_V2023_img(sub_data, cfg);

                case 'taskWeightR2E2'
                    [sub_data] = taskWeightR2E2_V2024_img(sub_data, cfg);

                case 'ChoiceDelayR2_txt'
                    [sub_data] = taskChoice_DelayR2_txt_V2024(sub_data,cfg);

                case 'taskWeightR2d'
                    [sub_data] = taskWeightR2d_V2023(sub_data, cfg);

                case 'taskWeightE2d'    
                    [sub_data] = taskWeightE2d_V2023(sub_data, cfg);

                case 'taskChoice4DNR2AS'
                    [sub_data] = taskChoice4D_NR2AS_V2024(sub_data, cfg);
                
                case 'taskChoiceDelayR2'
                    [sub_data] = taskChoice_DelayR2_V2024(sub_data,cfg);

                case 'taskControlPerception'
                    [sub_data] = taskControlPerception_V2023_img(sub_data, cfg);

                case 'taskControlSemantic'
                    [sub_data] = taskControlSemantic_V2023(sub_data, cfg);

                case 'taskControlTOM'
                    [sub_data] = taskControlTOM_V2023(sub_data, cfg);
                
                case 'taskGripRP'
                    cfg = check_hand(iTask_str, cfg);
                    sub_data.(cfg.sessNber_str).tasks.(iTask_str).hand_used = ...
                        cfg.grip.hand_used;
                    [sub_data] = taskGripRP_V2024(sub_data, cfg);
            end
        catch
            sca;
            if is_gripUsed % && isfield(cfg.grip,'Handle') %grip_onoff(3); end % full stop
                try cfg.grip.Handle.stop()
                catch; rethrow(lasterror);
                end
            end
                    rethrow(lasterror);
        end

        % status 'completed' moved above, before task launching
        %sub_data.(cfg.sessNber_str).tasks.(iTask_str).completed = true;

        % timer (in session & task info)
        sub_data.(cfg.sessNber_str).time.([iTask_str '_stop']) = datestr(now,'HHMM');
        sub_data.(cfg.sessNber_str).time.([iTask_str '_duration']) =       ...
            sub_data.(cfg.sessNber_str).time.([iTask_str '_stop'])         ...
            -sub_data.(cfg.sessNber_str).time.([iTask_str '_start']);

        sub_data.(cfg.sessNber_str).tasks.(iTask_str).time_stop = datestr(now,'HHMM');
        sub_data.(cfg.sessNber_str).tasks.(iTask_str).duration =            ...
            sub_data.(cfg.sessNber_str).time.([iTask_str '_duration']);
        sub_data.(cfg.sessNber_str).tasks.(iTask_str).cfg = cfg;

        % addtional task specific pieces of info
        sub_data.(cfg.sessNber_str).tasks.(iTask_str).cfg.scriptname =  ...
            mfilename('fullpath');  % save the name of this script

        sub_data.(cfg.sessNber_str).cfg = cfg;

        % progressive saving
        filename = [cfg.paths.data_sub sub_data.study_name '_'          ...
            cfg.subId_str '_' cfg.sessNber_str '_subdata.mat'];
        save(filename,'sub_data');
        % back-up saving
        filename = [cfg.paths.data_backups sub_data.study_name '_'      ...
            cfg.subId_str '_' cfg.sessNber_str '_subdata_'                  ...
            sub_data.(cfg.sessNber_str).tasks.(iTask_str).time_start '.mat'];
        save(filename,'sub_data');

    elseif cont == 2
        break
    end
end

if is_gripUsed %&& isfield(cfg.grip,'Handle') %grip_onoff(3); end % full stop
    try cfg.grip.Handle.stop()
    catch; rethrow(lasterror)
    end
end

% % %% Formating
% %
% % tempList = {'rating_grip','Choice_GripEffort','choice_CogEffort'};
% % format_motiscan_psyconsult(sub_dir,tempList,sub_data.session_nber);
% % % format_motiscan_psyconsult(subdir,globalTaskList,subdata.session_nber);
% %
% %
% % %% Reporting
% %
% % makeReport_motiscan_psyconsult(sub_dir,sub_data.session_nber);

