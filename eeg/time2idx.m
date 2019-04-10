function idx_list = time2idx(time_list, ref_times)
% TIME2IDX  Converts time values to closest indices based on a time list.
% The use-case is getting EEG data indices based on ms value vector.
%
% INPUTS:
%           time_list = list of time values to convert
%           time_vect = vector with time values for each data index
% OUTPUTS:
%           idx_list = indices corresponding to the values in time_list
%
% Adam Narai, RCNS HAS, 2019

idx_list = nan(size(time_list));
for i = 1:length(time_list)
    [~, idx] = min(abs(ref_times-time_list(i)));
    idx_list(i) = idx;
end

