function [valid_trials, filter_stats] = filter_covariates(cfg, covariates)
% FILTER_COVARIATES  Filter covariates.
%
% INPUT:
%           cfg = config structure
%           covariates = table of covariates for each EEG trial
% OUTPUT:
%           valid_trials = logical vector marking valid trials
%           filter_stats = structure with rejected trials and unique
%               rejected trials tables describing filtering for each
%               trial/filter
%
%   cfg fields:
%       cfg.cov_names: covariate names
%       cfg.exclude_nan: exclude trials with any NaN covariate
%       cfg.curr_sacc_dir: current sacc direction (1: forward, 0: backward)
%       cfg.next_sacc_dir: next sacc direction (1: forward, 0: backward)
%       cfg.max_sacc_amp: max curr sacc amp in vis deg ([] means no max)
%       cfg.min_sacc_amp: min curr sacc amp in vis deg ([] means no min)
%       cfg.fix_pos_x_limit: limit X position [min max]
%       cfg.only_valid_words: use fixations within word boundaries
%
% Adam Narai, RCNS HAS, 2019
%

% Check if only EEG trials are present
if ~all(covariates.eeg_trial) && ~cfg.allow_non_eeg_trial
    error('Not only EEG trials are present in covariates.');
end

% All trials valid by default
valid_trials = true(size(covariates,1),1);
nan_idx = false(size(covariates,1),1);
curr_sacc_dir_idx = false(size(covariates,1),1);
next_sacc_dir_idx = false(size(covariates,1),1);
max_sacc_amp_idx = false(size(covariates,1),1);
min_sacc_amp_idx = false(size(covariates,1),1);
fix_pos_x_limit_idx = false(size(covariates,1),1);
valid_words_idx = false(size(covariates,1),1);

% Get model covariates
model_cov = covariates(:, cfg.cov_names);

% Exclude NaNs
if cfg.exclude_nan
    nan_idx = any(isnan(model_cov{:,:}),2);
    valid_trials(nan_idx) = false;
end

% Curr sacc dir
if ~isempty(cfg.curr_sacc_dir)
    if cfg.curr_sacc_dir == 1 || cfg.curr_sacc_dir == 0
        curr_sacc_dir_idx = covariates.curr_sacc_dir ~= cfg.curr_sacc_dir;
        valid_trials(curr_sacc_dir_idx) = false;
    else
        error('Invalid curr_sacc_dir');
    end
end

% Next sacc dir
if ~isempty(cfg.next_sacc_dir)
    if cfg.next_sacc_dir == 1 || cfg.next_sacc_dir == 0
        next_sacc_dir_idx = covariates.next_sacc_dir ~= cfg.next_sacc_dir;
        valid_trials(next_sacc_dir_idx) = false;
    else
        error('Invalid next_sacc_dir');
    end
end

% Limit sacc amplitude
if ~isempty(cfg.max_sacc_amp)
    max_sacc_amp_idx = covariates{:,'curr_sacc_amp'} > cfg.max_sacc_amp;
    valid_trials(max_sacc_amp_idx) = false;
end
if ~isempty(cfg.min_sacc_amp)
    min_sacc_amp_idx = covariates{:,'curr_sacc_amp'} < cfg.min_sacc_amp;
    valid_trials(min_sacc_amp_idx) = false;
end

% Limit X position
if isfield(cfg, 'fix_pos_x_limit') && (numel(cfg.fix_pos_x_limit) == 2)
    fix_pos_x_limit_idx = ~(covariates.curr_fix_pos_x > cfg.fix_pos_x_limit(1) &...
        covariates.curr_fix_pos_x <= cfg.fix_pos_x_limit(2));
    valid_trials(fix_pos_x_limit_idx) = false;
end

% Limit valid words
if cfg.only_valid_words
    valid_words_idx = covariates{:,'valid_word'} == 0;
    valid_trials(valid_words_idx) = false;
end

%% Generate filter stats
% Reject table
all_idx = ~valid_trials;
filter_stats.reject_filter_tbl = table(nan_idx, curr_sacc_dir_idx,...
    next_sacc_dir_idx, max_sacc_amp_idx, min_sacc_amp_idx,...
    fix_pos_x_limit_idx, valid_words_idx, all_idx);

% Unique reject table (exclude last 'all_idx' variable)
filter_stats.unique_reject_filter_tbl = table();
for i = 1:size(filter_stats.reject_filter_tbl,2)
    filter_stats.unique_reject_filter_tbl{:,i} = (filter_stats.reject_filter_tbl{:,i} & all(~(filter_stats.reject_filter_tbl{:,[1:i-1, i+1:size(filter_stats.reject_filter_tbl,2)-1]}),2));
end
filter_stats.unique_reject_filter_tbl.Properties.VariableNames = filter_stats.reject_filter_tbl.Properties.VariableNames;

