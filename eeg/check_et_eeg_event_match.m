function error = check_et_eeg_event_match(ETALL, EEGALL, et_start_event, et_end_event, eeg_start_event)
% CHECK_ET_EEG_EVENT_MATCH  Matching ET-EEG events and throwing error at mismatch.
% Use this function as a failsafe by calling it right after loading data. 
% Returns 0 if everything is fine, otherwise breaks with error.
% The performed checks:
% - ET stim start/end event index matching
% - ET-EEG stim start event count matching
% - ET-EEG stim start within run drift check (<20 ms)
%
% INPUTS:
%           p = paramater structure with event codes
%           ETALL = array of ET data structures
%           EEGALL = array of EEGLAB data structures
% OUTPUTS:
%           error = 0 if no error found
%
% Adam Narai, RCNS HAS, 2019
%

% Params
time_diff_th = 20;  % ET-EEG drift threshold

% Loop for runs
for n = 1:numel(ETALL)
    % Get trigger messages
    et_messages = {ETALL(n).FEVENT.message};
    valid_et_messages = cellfun(@(x) ~isempty(x), et_messages);
    et_messages = et_messages(valid_et_messages);
    events = ETALL(n).FEVENT(valid_et_messages);
    
    % Get the stim start/end numbers
    stim_on_nums = cellfun(@(x) sscanf(x, et_start_event), et_messages, 'UniformOutput', 0);
    stim_off_nums = cellfun(@(x) sscanf(x, et_end_event), et_messages, 'UniformOutput', 0);
    
    % Get the stim start/end times and numbers
    clear stim_times
    stim_times(:,1) = [events(cellfun(@(x) ~isempty(x), stim_on_nums)).sttime]';
    stim_times(:,3) = cell2mat(stim_on_nums);
    stim_times(:,2) = [events(cellfun(@(x) ~isempty(x), stim_off_nums)).sttime]';
    stim_times(:,4) = cell2mat(stim_off_nums);
    
    % Get EEG linestarts
    stim_starts = EEGALL(n).event(strcmp({EEGALL(n).event.type}, eeg_start_event));
    
    % Check ET stim start/end event match
    if ~isequal(stim_times(:,3), stim_times(:,4))
        error('Mismatch between stim start and end ET events');
    end
    
    % Check EEG-ET stim start event match
    if size(stim_times,1) ~= numel(stim_starts)
        error('Different number of stim start events between EEG and ET');
    end
    
    % Check ET-EEG time drift
    rel_et_stim_start_times = stim_times(:,1)-stim_times(1,1);
    rel_eeg_stim_start_times = eeglab_lat2ms([stim_starts.latency]', EEGALL(n).srate)...
        - eeglab_lat2ms(stim_starts(1).latency, EEGALL(n).srate);
    diff = abs(double(rel_et_stim_start_times) - rel_eeg_stim_start_times);
    
    % Error if drift above threshold
    if max(diff) >= time_diff_th
        [max_diff, max_diff_idx] = max(diff);
        error(['Difference between ET and EEG "stim start" times is too large ',...
            '(', num2str(max_diff), ' ms at line ', num2str(stim_times(max_diff_idx,3)),...
            '), there may be a mismatch between events.']);
    end
end
error = 0;

