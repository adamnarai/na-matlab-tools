function EEG = add_ica_weights(EEG, ica_weights)
% ADD_ICA_WEIGHTS  Add ICA weights to EEGLAB structure.
%
% INPUTS:
%           EEG = EEGLAB data
%           ica_weights = structure of ICA weights
% OUTPUTS:
%           EEG = EEGLAB data with ICA weights
%
% Adam Narai, RCNS HAS, 2019
%

% Copy weights
EEG.icawinv = ica_weights.icawinv;
EEG.icasphere = ica_weights.icasphere;
EEG.icaweights = ica_weights.icaweights;
EEG.icachansind = ica_weights.icachansind;

% EEG checkset
EEG = eeg_checkset(EEG);
