function [idx, logIdx] = get_str_idx(strCellArray, str)
% Get index of string in cell array of strings
%
% INPUT:
%           strCellArray = cell array of strings
%           str = string to find
%
% OUTPUT:
%           idx = index in array
%           logIdx = logical indexing for the array
%
% Adam Narai, RCNS HAS, 2018

logIdx = strcmp(strCellArray, str);
idx = find(logIdx, 1);