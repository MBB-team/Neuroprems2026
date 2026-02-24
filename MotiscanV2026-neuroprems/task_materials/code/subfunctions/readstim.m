function [ matrix ] = readstim( filepath )
% READSTIM reads an excel file that contains items with parametric values,
% and extract a NxM matrix.
% N is the number of the stimulus
% M is the parametric level

[num,txt,raw] = xlsread(filepath);
matrix=txt(1:end,:)';

end

