function [eeg, concat_eeg] = get_mean_eeg_from_tb(data, subj_codes, var_name, stat_type, trim_perc)
% GET_MEAN_EEG_FROM_TB  Get group mean of EEG data from table.
%          
% INPUTS:
%           data = table with subject codes as row names, each cell
%               contains one subject EEG data with [ch x times x...] dim
%           subj_codes = cell array of subject codes
%           var_name = variable name in table
%           stat_type = str of stat to calculate across subjects (default: 'mean')
%               valid options: 'mean', 'median', 'trimmean'
%           trim_perc = total trim percent used only for 'trimmean' stat_type
%               (default: 20%)
% OUTPUTS:
%           eeg = mean EEG data
%           concat_eeg = eeg before aggregation stats with the last dimension
%               being subjects
%
% Adam Narai, RCNS HAS, 2019

% Defaults
if nargin < 4
    stat_type = 'mean';
end
if nargin < 4
    trim_perc = 20;
end

% Get subject EEG data in cell array
subj_eeg_list = data{subj_codes, var_name};

% Get EEG data dimension
dim_num = ndims(subj_eeg_list{1});

% Concatenate subjects
concat_eeg = cat(dim_num+1, subj_eeg_list{:});

% Get subject stat
switch stat_type
    case 'mean'
        eeg = mean(concat_eeg, dim_num+1);
    case 'median'
        eeg = median(concat_eeg, dim_num+1);
    case 'trimmean'
        eeg = trimmean(concat_eeg, trim_perc, dim_num+1);
end
