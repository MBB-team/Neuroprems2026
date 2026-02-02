function [sorted_output, output] = input_num(cfg, text, options)
%[sorted_output, output] = input_num(cfg, text, options)
% personalised input function that ensures the input is a numeric digit or 
% a numerical array which value is/are included within a specified range 
% (options).
%
%
% INPUTS:
%   -   cfg: configuration structure with at least the input_texts
%   (cfg.inputs_texts).
%
%   -   input_text: input text, e.g., "Please enter a task number: " 
%   (str array).
%
%   -   options: range of possible values to be chosen, e.g., [1:18] 
%   (numeric digit or array).
%
%
% OUTPUTS:
%   -   sorted_output: sorted output (from min to max; numeric digit or
%   array).
%
%   -   output: output of the input function if condition are checked 
%   (numeric digit or array).
%
%
% by <teddy.landron@gmail.com> (Jan. 2020) 

%% Text loading
input_texts = cfg.input_texts.(mfilename);
if cfg.english
    inputText_iScript = input_texts(:,1);
else
    inputText_iScript = input_texts(:,2);
end

%% Main
output = NaN;
while ~all(ismember(output,options))
    output = input(text, 's');
    try 
        output = eval(output);
    catch
        output = NaN;   
    end
    if any(~isnumeric(output)) || ~all(ismember(output,options)) 
        if numel(options) == 2
            fprintf(inputText_iScript{1},options) % text:1
        elseif numel(options) > 2
            fprintf(inputText_iScript{2},options(1),options(end)) % text:2
        end
    end
end
sorted_output = sort(output);
end