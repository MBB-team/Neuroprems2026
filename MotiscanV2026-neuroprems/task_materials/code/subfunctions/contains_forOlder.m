function [TF] = contains_forOlder(STR,PATTERN)
%[TF] = contains_forOlder(STR,PATTERN)
% mimics the built-in function 'contains', even for older versions ofr
% MATLAB
%
% by <teddy.landron@gmail.com> & the Internet

ver_str = version('-release');
if strcmp(ver_str, '2016b'); ver_year = 2017;
elseif numel(ver_str) > 4; ver_year = str2num(ver_str(1:end-1)); 
else; ver_year = str2num(ver_str); 
end

% ver_year = 2015; % debug
if ver_year > 2016; TF = contains(STR,PATTERN);
else
    if ischar(STR) && numel({STR}) == 1, STR = {STR}; end
    if ischar(PATTERN) && numel({PATTERN}) == 1, PATTERN = {PATTERN}; end 
    TF = false(1,numel(STR));
        for i_ptn = 1:numel(PATTERN)
            tmp_idx = strfind(STR,PATTERN{i_ptn});
            idx = find(not(cellfun('isempty',tmp_idx)));
            TF(idx) = true(1,numel(idx));
        end
end
end
