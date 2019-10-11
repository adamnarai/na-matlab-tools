function latency = peak_detection(eeg, channel_idx, start_time, times, step_size, offset_max, type, init_offset)
% PEAK_DETECTIN  Find eeg local min/max of ch cluster around start_time.
%
% INPUT:
%           eeg = [ch x time] EEG data
%           channel_idx = channel cluster idx
%           start_time = search start time in ms
%           times = time values (ms) corresponding to indices
%           step_size = [backward forward] or [both] iteration step size in ms (default: 1)
%           offset_max = max offset in ms (default: 100)
%           type = [string] search for local 'min' or 'max' (default: 'min')
%           init_offset = [backward forward] or [both] initial offsets in ms, 
%                   (default: step_size)
%
% OUTPUT:
%           latency = local min/max latency in ms, NaN if offset max
%           reached
%
% Adam Narai, RCNS HAS, 2019
%

% Defaults
if nargin < 5
    step_size = [1 1];
end
if nargin < 6
    offset_max = 100;
end
if nargin < 7
    type = 'min';
end
if nargin < 8
    init_offset = step_size;
end
if length(step_size) == 1
    step_size(2) = step_size(1);
end
if length(init_offset) == 1
    init_offset(2) = init_offset(1);
end

% Get channel cluster
cluster_data = squeeze(mean(eeg(channel_idx, :), 1));

% Iteratively larger time windows while min/max is on edge
step = 0;
while (step == 0 || ismember(idx, search_range_idx))
    offset =  init_offset + step*step_size;
    % Error is offset max crossed
    if any(offset >= offset_max)
        latency = NaN;
        return
    end
    
    search_range_idx = time2idx([start_time-offset(1), start_time+offset(2)], times);
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

% Get latency
latency = times(idx);
