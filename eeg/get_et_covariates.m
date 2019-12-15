function covariates = get_et_covariates(ET_results, stim, sacc, cons_sacc_num)
% GET_ET_COVARIATES  Get features of consecutive ET events (sacc, fix).
%
% INPUTS:
%           ET_results = Adaptive algorithm results
%           stim = stimulus number
%           sacc = saccade number within stimulus
%           cons_sacc_num = number of consecutive saccades to use
% OUTPUTS:
%           covariates = table of ET event features
%
% Adam Narai, RCNS HAS, 2019
%

covariates = table();

% Defaults
if nargin < 5
    cons_sacc_num = 1;
end
prev_sacc_time_limit = 1;   % [sec]
next_sacc_time_limit = 1;   % [sec]
prev_fix_time_limit = 0.1;  % [sec]
next_fix_time_limit = 0.1;  % [sec]

% Get saccade number
sacc_num = numel([ET_results.saccadeInfo(1,stim,:).end]);

% Current saccade
get_sacc_info(ET_results, stim, sacc, 'curr');

% Prev saccade
get_sacc_nans('prev');
if sacc > 1
    prev_sacc_end = ET_results.saccadeInfo(1,stim,sacc-1).end;
    if prev_sacc_end > (covariates.('curr_sacc_end') - prev_sacc_time_limit)
        get_sacc_info(ET_results, stim, sacc-1, 'prev');
    end
end

% Next saccade
get_sacc_nans('next');
if sacc < sacc_num
    next_sacc_end = ET_results.saccadeInfo(1,stim,sacc+1).end;
    if next_sacc_end < (covariates.('curr_sacc_end') + next_sacc_time_limit)
        get_sacc_info(ET_results, stim, sacc+1, 'next');
    end
end

% Current fixation
get_fix_nans('curr');
curr_fix_idx = find([ET_results.fixationInfo(1,stim,:).start] >= covariates.('curr_sacc_end') &...
    [ET_results.fixationInfo(1,stim,:).start] < (covariates.('curr_sacc_end') + next_fix_time_limit),1);
if ~isempty(curr_fix_idx)
    get_fix_info(ET_results, stim, curr_fix_idx, 'curr');
end

% Previous fixation
get_fix_nans('prev');
prev_fix_idx = find([ET_results.fixationInfo(1,stim,:).end] <= covariates.('curr_sacc_start') &...
    [ET_results.fixationInfo(1,stim,:).end] > (covariates.('curr_sacc_start') - prev_fix_time_limit),1,'last');
if ~isempty(prev_fix_idx)
    get_fix_info(ET_results, stim, prev_fix_idx, 'prev');
end

% Next fixation
get_fix_nans('next');
if ~isnan(covariates.('next_sacc_end'))
    next_fix_idx = find([ET_results.fixationInfo(1,stim,:).start] >= covariates.('next_sacc_end') &...
        [ET_results.fixationInfo(1,stim,:).start] < (covariates.('next_sacc_end')+next_fix_time_limit),1);
    if ~isempty(next_fix_idx)
        get_fix_info(ET_results, stim, next_fix_idx, 'next');
    end
end

if cons_sacc_num > 1
    for idx = 2:cons_sacc_num
        idx_str = ['_', num2str(idx)];
        prev_idx = idx-1;
        if prev_idx == 1
            prev_idx_str = '';
        else
            prev_idx_str = ['_', num2str(prev_idx)];
        end
        
        % Prev x sacc
        get_sacc_nans(['prev_', num2str(idx)]);
        if sacc > idx
            prev_sacc_end = ET_results.saccadeInfo(1,stim,sacc-idx).end;
            if prev_sacc_end > (covariates.(['prev', prev_idx_str, '_sacc_end']) - prev_sacc_time_limit)
                get_sacc_info(ET_results, stim, sacc-idx, ['prev', idx_str]);
            end
        end
        
        % Next x sacc
        get_sacc_nans(['next_', num2str(idx)]);
        if sacc <= sacc_num-idx
            next_sacc_end = ET_results.saccadeInfo(1,stim,sacc+idx).end;
            if next_sacc_end < (covariates.(['next', prev_idx_str, '_sacc_end']) + next_sacc_time_limit)
                get_sacc_info(ET_results, stim, sacc+idx, ['next', idx_str]);
            end
        end
    end
end

% Embeded helper functions
    function get_sacc_nans(prefix)
        covariates.([prefix, '_sacc_amp']) = NaN;
        covariates.([prefix, '_sacc_dir']) = NaN;
        covariates.([prefix, '_sacc_start']) = NaN;
        covariates.([prefix, '_sacc_end']) = NaN;
        covariates.([prefix, '_sacc_angle']) = NaN;
        covariates.([prefix, '_sacc_peak_vel']) = NaN;
        covariates.([prefix, '_sacc_is_gliss']) = NaN;
    end

    function get_sacc_info(ET_results, stim, sacc, prefix)
        covariates.([prefix, '_sacc_amp']) = ET_results.saccadeInfo(1,stim,sacc).amplitude;
        covariates.([prefix, '_sacc_dir']) = ET_results.saccadeInfo(1,stim,sacc).forward;
        covariates.([prefix, '_sacc_start']) = ET_results.saccadeInfo(1,stim,sacc).start;
        covariates.([prefix, '_sacc_end']) = ET_results.saccadeInfo(1,stim,sacc).end;
        covariates.([prefix, '_sacc_angle']) = ET_results.saccadeInfo(1,stim,sacc).angle;
        covariates.([prefix, '_sacc_peak_vel']) = ET_results.saccadeInfo(1,stim,sacc).peakVelocity;
        covariates.([prefix, '_sacc_is_gliss']) = double(~isempty(ET_results.glissadeInfo(1,stim,sacc).amplitude));
    end

    function get_fix_nans(prefix)
        covariates.([prefix, '_fix_dur']) = NaN;
        covariates.([prefix, '_fix_start']) = NaN;
        covariates.([prefix, '_fix_end']) = NaN;
        covariates.([prefix, '_fix_pos_x']) = NaN;
        covariates.([prefix, '_fix_pos_y']) = NaN;
    end

    function get_fix_info(ET_results, stim, fix, prefix)
        covariates.([prefix, '_fix_dur']) = ET_results.fixationInfo(1,stim,fix).duration;
        covariates.([prefix, '_fix_start']) = ET_results.fixationInfo(1,stim,fix).start;
        covariates.([prefix, '_fix_end']) = ET_results.fixationInfo(1,stim,fix).end;
        covariates.([prefix, '_fix_pos_x']) = ET_results.fixationInfo(1,stim,fix).X;
        covariates.([prefix, '_fix_pos_y']) = ET_results.fixationInfo(1,stim,fix).Y;
    end
end

