function valid_trials = filter_covariates(cfg, covariates)
% FILTER_COVARIATES  Filter covariates based on NaN values, sacc direction 
% and max sacc amplitude.
%
% INPUT:
%           cfg = config structure
%           covariates = table of covariates for each EEG trial
% OUTPUT:
%           valid_trials = logical vector marking valid trials
%
%   cfg fields:
%       cfg.cov_names: covariate names
%       cfg.exclude_nan: exclude trials with any NaN covariate
%       cfg.curr_sacc_dir: current sacc direction (1: forward, 0: backward)
%       cfg.next_sacc_dir: next sacc direction (1: forward, 0: backward)
%       cfg.max_sacc_amp: max curr sacc amp in vis deg ([] means no max)
%       cfg.min_sacc_amp: min curr sacc amp in vis deg ([] means no min)
%       cfg.fix_pos_x_limit: limit X position [min max]
%
% Adam Narai, RCNS HAS, 2019
%

% Check if only EEG trials are present
if ~all(covariates.eeg_trial) && ~cfg.allow_non_eeg_trial
    error('Not only EEG trials are present in covariates.');
end

% All trials valid by default
valid_trials = true(size(covariates,1),1);

% Get model covariates
model_cov = covariates(:, cfg.cov_names);

% Exclude NaNs
if cfg.exclude_nan 
    valid_trials(any(isnan(model_cov{:,:}),2)) = false;
end

% Curr sacc dir
if ~isempty(cfg.curr_sacc_dir)
    if cfg.curr_sacc_dir == 1 || cfg.curr_sacc_dir == 0
        valid_trials(covariates.curr_sacc_dir ~= cfg.curr_sacc_dir) = false;
    else
        error('Invalid curr_sacc_dir');
    end
end

% Next sacc dir
if ~isempty(cfg.next_sacc_dir)
    if cfg.next_sacc_dir == 1 || cfg.next_sacc_dir == 0
        valid_trials(covariates.next_sacc_dir ~= cfg.next_sacc_dir) = false;
    else
        error('Invalid next_sacc_dir');
    end
end

% Limit sacc amplitude
if ~isempty(cfg.max_sacc_amp)
    valid_trials(covariates{:,'curr_sacc_amp'} > cfg.max_sacc_amp) = false;
end
if ~isempty(cfg.min_sacc_amp)
    valid_trials(covariates{:,'curr_sacc_amp'} < cfg.min_sacc_amp) = false;
end

% Limit X position
if isfield(cfg, 'fix_pos_x_limit') && (numel(cfg.fix_pos_x_limit) == 2)
    condtition = covariates.curr_fix_pos_x > cfg.fix_pos_x_limit(1) & covariates.curr_fix_pos_x <= cfg.fix_pos_x_limit(2);
    valid_trials(~condtition) = false;
end

% Limit valid words
if ~isempty(cfg.only_valid_words)
    valid_trials(covariates{:,'valid_word'} == 0) = false;
end

% Limit curr sacc is gliss
if ~isempty(cfg.curr_sacc_is_gliss)
    valid_trials(covariates{:,'curr_sacc_is_gliss'} ~= cfg.curr_sacc_is_gliss) = false;
end

% Limit fixation rank
if ~isempty(cfg.fix_rank_limits)
    valid_trials((covariates{:,'fix_rank'} < cfg.fix_rank_limits(1)) |...
        (covariates{:,'fix_rank'} > cfg.fix_rank_limits(2))) = false;
end
