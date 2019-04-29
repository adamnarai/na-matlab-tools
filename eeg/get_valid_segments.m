function [EEG, segments] = get_valid_segments(EEG, start_event, end_event, seg_length, incl_last)
% GET_VALID_SEGMENTS  Find valid segments in EEG data.
% This function is used before artifact rejection. Start/end events mark
% the stimulus presentation times from which fixed length segments are extracted.
% Returns epoched EEG and segment timestamps in [ms].
%
% INPUTS:
%           triggers = struct of EEG and ET events/timestamps/latency
%           seglength = desired segment length in [ms]
%           srate = sampling rate of EEG data (EEG time saved in
%                   datapoints)
%           incLast = [0|1] include last (not full) segment with extra data
%                   marked, default: 0
% OUTPUTS:
%           segments = rowN x [segN x 2] cell array of segment start/end
%                   timestamps for every row in EEG timing [ms]
%           rowseg = [rowN x 2] start/end times of every row segment [ms]
%
% Adam Narai, RCNS HAS, 2019
%

% Defaults
if nargin < 5
    incl_last = 0;
end

% Parameters
seg_epoch_name = 'seg';
event_fields = {'type', 'latency', 'duration', 'code'};

% Get stimulus start/end times
start_times = [EEG.event(strcmp({EEG.event.type}, start_event)).latency];
end_times = [EEG.event(strcmp({EEG.event.type}, end_event)).latency];
start_times = eeglab_lat2ms(start_times, EEG.srate);
end_times = eeglab_lat2ms(end_times, EEG.srate);
if numel(start_times) ~= numel(end_times)
    error('Mismatch between start and end events.');
end

% Loop for stimuli
event_num = 0;
for stim = 1:numel(start_times)    
    % Get segment number
    if incl_last
        seg_num = ceil((end_times(stim)-start_times(stim))/seg_length);
    else
        seg_num = floor((end_times(stim)-start_times(stim))/seg_length);
    end
    
    % Find segments
    for seg = 1:seg_num
        % Get segment timestamps
        segments{stim}(seg,1) = start_times(stim) + (seg-1)*seg_length;
        segments{stim}(seg,2) = segments{stim}(seg,1) + seg_length-1;
        
        event_num = event_num + 1;
        event_list(event_num,:) = {seg_epoch_name, segments{stim}(seg,1), 0, seg_epoch_name};
    end
end

% Add EEG events
EEG = pop_importevent(EEG,...
    'append', 'yes',...
    'event', event_list,...
    'fields', event_fields,...
    'timeunit', 1e-3); % [ms]

% Epoching EEG
EEG = pop_epoch(EEG, {seg_epoch_name}, [0 seg_length/1000]);

% Remove segment events
EEG = pop_selectevent(EEG, 'omitevent', find(strcmp({EEG.event.type}, seg_epoch_name)),...
    'deleteepochs', 'off', 'deleteevents', 'on');
