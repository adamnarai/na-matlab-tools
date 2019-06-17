function latency = peak_detection(eeg, channel_idx, start_time, times, step_size, offset_max, type)
% PEAK_DETECTIN  Find eeg local min/max of ch cluster around start_time.
%
% INPUT:
%           eeg = [ch x time] EEG data
%           channel_idx = channel cluster idx
%           start_time = search start time in ms
%           times = time values (ms) corresponding to indices
%           step_size = iteration step size (default: 1)
%           offset_max = max offset, error if crossed (default: 100)
%           type = [string] search for local 'min' or 'max' (default: 'min')
%
% OUTPUT:
%           latency = local min/max latency in ms
%
% Adam Narai, RCNS HAS, 2019
%

% Defaults
if nargin < 5
    step_size = 1;
end
if nargin < 6
    offset_max = 100;
end
if nargin < 7
    type = 'min';
end

% Get channel cluster
cluster_data = squeeze(mean(eeg(channel_idx, :), 1));

% Iteratively larger time windows while min/max is on edge
step = 1;
while (step == 1 || ismember(idx, search_range_idx)) && (step*step_size < offset_max)
    offset = step*step_size;
    search_range_idx = time2idx([start_time-offset, start_time+offset], times);
    if strcmp(type, 'min')
        [~, idx] = min(cluster_data(search_range_idx(1):search_range_idx(2)));
    elseif strcmp(type, 'max')
        [~, idx] = max(cluster_data(search_range_idx(1):search_range_idx(2)));
    else
        error('Invalid type.');
    end
    idx = idx + search_range_idx(1) - 1;
    step = step + 1;
end

% Error is offset max crossed
if offset >= offset_max
    error('Offset maximum crossed.');
end

% Get latency
latency = times(idx);
end