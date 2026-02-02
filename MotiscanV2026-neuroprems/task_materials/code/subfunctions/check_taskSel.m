function [consistent] = check_taskSel(cfg)
%[consistent] = check_taskSel(cfg)
% Checks if the selected tasks are consistent (e.g., RatingsX needed for
% ChoiceX (1D & 2D)).
%
%
% INPUTS:
%   -   cfg: configuration structure, with at least the selected tasks 
%   (cfg.tasks.task_sel)
%
%
% OUTPUTS:
%   -   consistent: true if consistent, false otherwise (bool).
%
%
% by <teddy.landron@gmail.com> (feb. 2020)


%% Text loading
input_texts = cfg.input_texts.(mfilename);
if cfg.english
    inputText_iScript = input_texts(:,1);
else
    inputText_iScript = input_texts(:,2);
end

%% Main
for sub_task = ['R', 'P', 'E']
    if ~any(ismember(cfg.task.task_sel, ['taskRating' sub_task]))
        which_taskWeight = regexp(cfg.task.task_sel,['taskW[eightRPE]+(?=' sub_task ')'],'match');
        with_taskWeight = nan(numel(which_taskWeight),1);
        for i_task = 1:numel(which_taskWeight)
            with_taskWeight(i_task,1) = ~isempty(which_taskWeight{i_task});
        end
        if any(contains_forOlder(cfg.task.task_sel, ['taskChoice' sub_task]))    ...
            || any(with_taskWeight)
        warning(inputText_iScript{1}) %text:1
        fprintf(inputText_iScript{2}) %text:2
        consistent = false;
        return
        else
            consistent = true;
        end
    else 
        consistent = true;
    end
end
end
