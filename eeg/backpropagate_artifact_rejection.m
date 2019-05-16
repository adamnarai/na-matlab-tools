function EEG = backpropagate_artifact_rejection(EEG, EEG_man_rej)
% BACKPROPAGATE_ARTIFACT_REJECTION  Remove artifact epoct events from continuous EEG.
%
% INPUTS:
%           EEG = continuous EEG data (with the same events as the source
%               of the epoched EEG data)
%           EEG_man_rej = epoched data with artifacts marked
% OUTPUTS:
%           EEG = continuous EEG data without artifact epoch events
%
% Adam Narai, RCNS HAS, 2019
%

% Superpose rejection markings
EEG_man_rej = eeg_rejsuperpose(EEG_man_rej,1,1,1,1,1,1,1,1);

% Get artifact epochs
artifact_epochs = EEG_man_rej.epoch(EEG_man_rej.reject.rejglobal);

% Get list of urevent indices
for i = 1:numel(artifact_epochs)
    trig_event_idx = find([artifact_epochs(i).eventlatency{:}] == 0);
    urevent_list(i) = artifact_epochs(i).eventurevent{trig_event_idx};
    eventtype_list{i} = artifact_epochs(i).eventtype{trig_event_idx};
    if ~strcmp(EEG.event(ismember([EEG.event.urevent], urevent_list(i))).type, eventtype_list{i})
        error(['Urevent ', num2str(urevent_list(i)), ' has no match found in the continuous EEG data.']);
    end
end

% Find urivent numbers in the continuous data
event_idx_list = find(ismember([EEG.event.urevent], urevent_list));

% Error if events not found
if numel(artifact_epochs) ~= numel(event_idx_list)
    error('Not all urevents were found.');
end

% Remove artifact events
EEG = pop_selectevent(EEG, 'omitevent', event_idx_list, 'deleteevents', 'on');