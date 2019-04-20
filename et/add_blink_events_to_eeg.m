function EEGALL = add_blink_events_to_eeg(EEGALL, ET_features, run_nums, eeg_seg_start_event)
% ADD_BLINK_EVENTS_TO_EEG  Add EEG events where ET data is missing.
%
% INPUTS:
%           EEGALL = array of EEGLAB structures
%           ET_features = adaptive ET algorithm results
%           run_nums = run numbers for each segment (EEGALL index)
%           eeg_seg_start_event = EEG segment start event string
% OUTPUTS:
%           EEGALL = array of EEGLAB structures with blink events
%
% Adam Narai, RCNS HAS, 2019
%

% Params
fields = {'type', 'latency', 'duration', 'code'};

% Loop for runs
for n = 1:numel(EEGALL)
    curr_lines = (run_nums == n);
    eeg_line_start_list = EEGALL(n).event(strcmp({EEGALL(n).event.type}, eeg_seg_start_event));
    
    % Finding blink events
    event_num = 0;
    eeg_row = 0;
    for seg = find(curr_lines)
        % Get EEG linestart
        eeg_row = eeg_row + 1;
        eeg_line_start = eeglab_lat2ms(eeg_line_start_list(eeg_row).latency, EEGALL(n).srate);
        
        % Loop for blinks
        labels = bwlabel(ET_features.nanIdx(seg).Idx);
        for label = 2:max(labels)   % Starts from 2 since segments always start with NaN
            % Get relative time
            rel_et_time_start = find(labels == label, 1, 'first')*1000/ET_features.samplingFreq;
            rel_et_time_end = find(labels == label, 1, 'last')*1000/ET_features.samplingFreq;
            abs_eeg_time_start = eeg_line_start + rel_et_time_start;
            abs_eeg_time_end = eeg_line_start + rel_et_time_end;
            
            % Add blink event
            event_num = event_num + 1;
            blink_events(event_num,:) = {'blink_sta', abs_eeg_time_start, abs_eeg_time_end-abs_eeg_time_start, 'blink'};
            event_num = event_num + 1;
            blink_events(event_num,:) = {'blink_end', abs_eeg_time_end, 0, 'blink'};
        end
    end
    
    % Add events to EEG
    EEGALL(n) = pop_importevent(EEGALL(n),...
        'append', 'yes',...
        'event', blink_events,...
        'fields', fields,...
        'timeunit', 1e-3); % [ms]
end
