function [EEG, covariates] = extract_fixation_related_epochs(EEG, ET_results, segments, rejglobal, eeg_stim_start_event, epoch_times, start_trim, end_trim)
% EXTRACT_FIXATION_RELATED_EPOCHS  Extracting valid FRA epochs.
% Epochs are triggered to saccade endings. Epochs are only extragted if
% they do not overlap with rejected segments or start/end trim intervals.
%
% INPUTS:
%           EEG = EEGLAB structure of continuous data
%           ET_results = adaptive ET results
%           segments = segment timings grouped in cells for the stimuli
%           rejglobal = logical reject vector for segments
%           eeg_stim_start_event = string of EEG stimulus start event
%           epoch_times = [start end] vector of epoch start/end relative to
%               trigger event
%           start_trim = invalid time range at the beginning [ms]
%           end_trim = invalid time range at the end [ms]
% OUTPUTS:
%           EEG = EEGLAB structure containing FRA epochs
%           covariates = table of ET covariates
%
% Adam Narai, RCNS HAS, 2019
%

% Params
event_name = 'sacc_end';

% Get EEG stim start events and convert to times
eeg_stim_start_events = EEG.event(strcmp({EEG.event.type}, eeg_stim_start_event));
eeg_stim_start_times = eeglab_lat2ms([eeg_stim_start_events.latency], EEG.srate);

% Add reject info to segments
reject_info = rejglobal;
for stim = 1:numel(segments)
    segments{stim}(:,3) = reject_info(1:size(segments{stim},1));
    reject_info(1:size(segments{stim},1)) = [];
end
if ~isempty(reject_info)
    error('Reject info does not match with segments.');
end

% Loop for stimuli
event_idx = 0;
events = {};
covariates = table();
valid_sacc_end = table();
stim_num = table();
for stim = 1:numel(segments)
    % Saccade number
    sacc_num = numel([ET_results.saccadeInfo(1,stim,:).end]);
    
    % Get stim start/end times
    stim_start = eeg_stim_start_times(stim);
    stim_end = stim_start + size([ET_results.data(1,stim,:).X],2)*1000/ET_results.samplingFreq;
    
    % Loop for saccades
    for sacc = 1:sacc_num
        % Assume valid as default
        valid = 1;
        
        % Get trigger time
        sacc_end = stim_start + ET_results.saccadeInfo(1,stim,sacc).end*1000;
        
        % Get epoch range
        epoch_range = sacc_end + epoch_times;
        
        % Check if not rejected
        for rej_seg = find(segments{stim}(:,3) == 1)'
            seg_start = segments{stim}(rej_seg,1);
            seg_end = segments{stim}(rej_seg,2);
            
            % Current artifact segment and epoch overlaps
            if (seg_start < epoch_range(2)) && (seg_end > epoch_range(1))
                valid = 0;
            end
        end
        
        % Check if not in start/end trim
        if (epoch_range(1) < (stim_start + start_trim)) || (epoch_range(2) > (stim_end - end_trim))
            valid = 0;
        end
        
        % Add saccade end event
        if valid
            event_idx = event_idx + 1;
            events(event_idx,:) = {event_name, sacc_end, 0, event_name};
        end
        
        % Get ET covariates related to current saccade end
        covariates = [covariates; get_et_covariates(ET_results, stim, sacc)];
        valid_sacc_end{size(covariates,1), 'eeg_trial'} = valid;
        stim_num{size(covariates,1), 'stim_num'} = stim;
    end
end

% Check covariate number
if sum(valid_sacc_end.eeg_trial) ~= size(events, 1)
    error('EEG trial related covariate number not equals with the number of trials.');
end

% Mark ET covariates corresponding to EEG trials
covariates = [valid_sacc_end, stim_num, covariates];

% Add events to EEG
EEG = pop_importevent(EEG,...
    'append', 'yes',...
    'event', events,...
    'fields', {'type', 'latency', 'duration', 'code'},...
    'timeunit', 1e-3); % [ms]

% EEG segmentation
EEG = pop_epoch(EEG, {event_name}, [epoch_times(1)/1000, epoch_times(2)/1000 + 1/EEG.srate]);
