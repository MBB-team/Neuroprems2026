function found = rec_isfield(S,target)
%  found = rec_isfield(S,target)
% This function check if the string `target` is a field of the structure
% `S`. If it is not it will recursively check if `target` is a field of the
% fields of `S`.
% INPUT:
%   S:      a structure
%   target: a string
% OUTPUT:
%   found:  a boolean
%
% Author: brochard.jules@gmail.com 
% Created on: 26/02/2020 (D/M/Y)
% Last Edit:  26/02/2020 (D/M/Y)

if ~isstruct(S)
    found = false;
else
    found = isfield(S,target);
    
    if ~found % then look at other fields
        idx = 1;
        all_fields = fieldnames(S);
        idx_max = numel(all_fields);
        while idx <= idx_max && ~found
            found = rec_isfield(S.(all_fields{idx}),target);
            idx = idx + 1;
        end
        
    end
end
end
