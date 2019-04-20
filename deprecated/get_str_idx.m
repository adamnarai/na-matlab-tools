function [idx, log_idx] = get_str_idx(str_cell_array, str)
% GET_STR_IDX  Get first index of string in cell array of strings.
%
% INPUT:
%           str_cell_array = cell array of strings
%           str = string to find
%
% OUTPUT:
%           idx = index in array
%           log_idx = logical indexing for the array
%
% Adam Narai, RCNS HAS, 2018
%

log_idx = strcmp(str_cell_array, str);
idx = find(log_idx, 1);