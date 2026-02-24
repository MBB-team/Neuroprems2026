function [sub_data, cfg] = tasks_order(sub_data, cfg)
%[sub_data, cfg] = tasks_order(sub_data, cfg)
% Returns the global order according to which the tasks will be launched.
% Within the tasks that can ordered differenlty (Ratings, Choices 1D,
% Choices 2D, MoneyDiscounting, Cog/PhysEffort) assigns a randomised order. 
% 
%
% INPUTS:
%   -   sub_data: subject's data structure.
%
%   -   cfg: configuration structure, with at least the session number 
%   (cfg.sessNber_str), the selected tasks (cfg.tasks.task_sel).
%
%
% OUTPUTS:
%   -   sub_data: subject's data structure, added with the global order 
%   (sub_data.(cfg.sessNber_str).tasks.global_order).
%
%   -   cfg: configuration structure (also added with the global order
%   (cfg.tasks.global_order).
%
%
% NEEDS: rec_isfield.m
%
%
% by <teddy.landron@gmail.com> (Feb. 2020)

%% Text loading
input_texts = cfg.input_texts.(mfilename);
if cfg.english
    inputText_iScript = input_texts(:,1);
else
    inputText_iScript = input_texts(:,2);
end

%% Checks if already existing order
if rec_isfield(sub_data.(cfg.sessNber_str), 'global_order')          ...
        && ~isempty(sub_data.(cfg.sessNber_str).tasks.global_order)
    cfg.task.global_order = sub_data.(cfg.sessNber_str).tasks.global_order;
    return
end    

%% Init
n_taskSel = numel(cfg.task.task_sel);
tasks_orders = struct;

%% Ratings & Choice1D tasks
% Ratings
taskRatingX = cfg.task.task_sel(ismember(cfg.task.task_sel,       ...
    {'taskRatingR','taskRatingP','taskRatingE'}));
n_taskRatingX = numel(taskRatingX);

switch n_taskRatingX        
    case {3, 2}
%        unidimList  = {'R', 'P', 'E'};
        unidimList = cell(n_taskRatingX, 1);
        for i_task = 1:n_taskRatingX
            unidimList{i_task,1} = taskRatingX{i_task}(end);
        end
        order_tmp           = unidimList(randperm(numel(unidimList)),1);
        tasks_orders.unidim =                                           ...
            cellstr([repmat('taskRating',n_taskRatingX,1),char(order_tmp)]);
        fprintf(inputText_iScript{1}, cell2mat(order_tmp')); % text:1
%     case 2 
%         unidimList = {taskRatingX{1}(end), taskRatingX{2}(end)};
%         order_tmp  = unidimList(randperm(numel(unidimList)))';
%         order       = cellstr([repmat('taskRating',2,1),char(order_tmp)]);
%         sub_data.(cfg.sessNber_str).tasks.task_order.unidim = order;
%         fprintf(['Order 1D-task(s): ' cell2mat(order_tmp') ' \n']); 
    case 1
        tasks_orders.unidim = taskRatingX;
        fprintf(inputText_iScript{2},taskRatingX{:}(end)); % text:2
end

% Choice1D
taskChoiceX = cfg.task.task_sel(ismember(cfg.task.task_sel,       ...
    {'taskChoiceR','taskChoiceP','taskChoiceE'}));
n_taskChoiceX = numel(taskChoiceX);
if (exist('unidimList', 'var') && ~isempty(unidimList))                    ...
        && (exist('taskChoiceX', 'var') && ~isempty(taskChoiceX))
    order_toCat = cellstr([repmat('taskChoice',n_taskChoiceX,1),        ...
        char(order_tmp(1:n_taskChoiceX))]);
    tasks_orders.unidim = [tasks_orders.unidim ; order_toCat];
end

%% Choice2D tasks
taskWeightXX = cfg.task.task_sel(ismember(cfg.task.task_sel,       ...
    {'taskWeightRE','taskWeightPE','taskWeightRP'}));
n_taskWeightXX = numel(taskWeightXX);

switch n_taskWeightXX
    case {3,2}
%        bidimList   = {'RE', 'PE', 'RP'};
        bidimList = cell(n_taskWeightXX, 1);
        for i_task = 1:n_taskWeightXX
            bidimList{i_task,1} = taskWeightXX{i_task}(end-1:end);
        end
        order_tmp           = bidimList(randperm(numel(bidimList)),1);
        tasks_orders.bidim  =                                           ...
            cellstr([repmat('taskWeight',n_taskWeightXX,1),char(order_tmp)]);
        fprintf(inputText_iScript{3},cell2mat(order_tmp')); % text:3
%     case 2 
%         bidimList   = {taskWeightXX{1}(end-1:end), taskWeightXX{2}(end-1:end)};
%         order_tmp   = bidimList(randperm(numel(bidimList)))';
%         task_orders.bidim = cellstr([repmat('taskWeight',2,1),char(order_tmp)]);
%         fprintf(['Order 2D-task(s): ' char(39) cell2mat(order_tmp')     ...
%             char(39) '.\n']); 
    case 1
        tasks_orders.bidim = taskWeightXX;
        fprintf(inputText_iScript{4}, taskWeightXX{1}(end-1:end)); % text:4
end

%% Money tasks
taskChoice_MoneyX = cfg.task.task_sel(ismember(cfg.task.task_sel,       ...
    {'taskChoice_MoneyDelay','taskChoice_MoneyRisk'}));
n_taskChoice_MoneyX = numel(taskChoice_MoneyX);

switch n_taskChoice_MoneyX
    case 2
        moneyTaskList = {'Risk'; 'Delay'}; % Proba = Risk
        order_tmp     = moneyTaskList(randperm(numel(moneyTaskList)),1);
        tasks_orders.moneyDiscount =                                    ...
            cellstr([repmat('taskChoice_Money',2,1),char(order_tmp)]);
        fprintf(inputText_iScript{5},cell2mat(order_tmp')); % text:5
    case 1 
        tasks_orders.moneyDiscount = taskChoice_MoneyX;
        fprintf(inputText_iScript{6},taskChoice_MoneyX{:}); % text:6
end

%% Effort tasks
taskChoice_XEffort = cfg.task.task_sel(ismember(cfg.task.task_sel,...
    {'taskChoice_CogEffort','taskChoice_GripEffort'}));
n_taskChoice_XEffort = numel(taskChoice_XEffort);

switch n_taskChoice_XEffort
    case 2
        effortTaskList = {'CogEffort'; 'GripEffort'}; % Proba = Risk
        order_tmp      = effortTaskList(randperm(numel(effortTaskList)),1);
        tasks_orders.effortChoice = cellstr([repmat('taskChoice_',2,1), ...
            char(order_tmp)]);
        fprintf(inputText_iScript{7},cell2mat(order_tmp')); % text:7
    case 1 
        tasks_orders.effortChoice = taskChoice_XEffort;
        fprintf(inputText_iScript{7},taskChoice_XEffort{:}); % text:8
end


%% Global task order 
cfg.task.global_order = cell(n_taskSel,1);
if any(ismember(cfg.task.task_sel,'trainingResp'))
    cfg.task.global_order{1,1} = 'trainingResp';
    row = 2;
else; row = 1;
end

orders = fieldnames(tasks_orders);
if ~isempty(orders)
    for i_order = 1:numel(orders)
        if ~isempty(tasks_orders.(orders{i_order}))
            n_row = size(tasks_orders.(orders{i_order}),1);
            cfg.task.global_order(row:row+n_row-1,1) =                  ...
                tasks_orders.(orders{i_order});
            row = row + n_row;
        end
    end
end
left_task = cfg.task.task_sel(ismember(cfg.task.task_sel,         ...
    {'taskRating_gripExerted';'taskConfidencePrecision';'taskCogEffort';'taskRatingR2';'taskRatingN';'taskRatingS';'taskRatingE2';'taskChoiceR21D';'taskChoiceE21D';'taskChoiceN1D';'taskChoice4DNR2AS';'taskChoiceDelayR2';'taskWeightR2E2';'taskGripRP';'taskControlPerception';'taskControlSemantic';'taskControlTOM';'taskRatingAS';'ChoiceDelayR2_txt'}));
cfg.task.global_order(row:n_taskSel) = left_task';

sub_data.(cfg.sessNber_str).tasks.global_order = cfg.task.global_order;

end