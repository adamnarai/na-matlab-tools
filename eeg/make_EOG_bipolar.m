function EEG = make_EOG_bipolar(EEG, eogLabel, chLabel, newLabel)
% MAKE_EOG_BIPOLAR  Transform monopolar EOG to bipolar.
%
% INPUTS:
%           EEG = EEGLAB structure
%           eogLabel = label of EOG channel
%           chLabel = label of channel above EOG electrode
% OUTPUTS:
%           EEG = new EEGLAB structure
%
% Adam Narai, RCNS HAS, 2018
%

% Defaults
if nargin < 4
    newLabel = 'Bip_EOG';
end

% Get channel indices
eogIdx = find(strcmp({EEG.chanlocs.labels}, eogLabel));
chIdx = find(strcmp({EEG.chanlocs.labels}, chLabel));

% Make EOG bipolar
EEG.data(eogIdx,:,:) = EEG.data(chIdx,:,:) - EEG.data(eogIdx,:,:);

% Change channel label
EEG.chanlocs(eogIdx).labels = newLabel;