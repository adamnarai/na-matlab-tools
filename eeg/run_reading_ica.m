function ica_weights = run_reading_ica(EEG, ica_path)
% RUN_READING_ICA  Run ICA on clean epochs.
%
% INPUTS:
%           EEG = epoched EEGLAB structure with valid epoch reject data
%           ica_path = path for loading/saving ICA weights (optional)
% OUTPUTS:
%           ica_weights = ICA weights structure containing the EEGLAB ICA
%               fiels
%
% Adam Narai, RCNS HAS, 2019
%

% Defaults
if nargin < 2
    ica_path = '';
end

% Reject artifact marked epochs
EEG = eeg_rejsuperpose(EEG,1,1,1,1,1,1,1,1);
EEG = pop_rejepoch(EEG, find(EEG.reject.rejglobal), 0);

% Run ICA
if ~isempty(ica_path) && exist(ica_path, 'file')
    load(ica_path, 'ica_weights');
else
    try
        EEG = pop_runica(EEG, 'icatype', 'cudaica', 'extended', 1, 'stop', 1e-7, 'maxsteps', 1024);
    catch
        EEG = pop_runica(EEG, 'extended', 1, 'stop', 1e-7, 'maxsteps', 1024);
    end
    ica_weights = get_ica_weights(EEG);
    save(ica_path, 'ica_weights');
end