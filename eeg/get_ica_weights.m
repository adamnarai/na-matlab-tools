function ica_weights = get_ica_weights(EEG)
% ADD_ICA_WEIGHTS  Add ICA weights to EEGLAB structure.
%
% INPUTS:
%           EEG = EEGLAB data with ICA weights
% OUTPUTS:
%           ica_weights = structure of ICA weights
%
% Adam Narai, RCNS HAS, 2019
%

% Copy ICA weights
ica_weights.icawinv = EEG.icawinv;
ica_weights.icasphere = EEG.icasphere;
ica_weights.icaweights = EEG.icaweights;
ica_weights.icachansind = EEG.icachansind;