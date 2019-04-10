function EEG = filter_eeg(EEG, filter)
% FILTER_EEG  Filter EEG signal on all channel.
% Zero phase filtering with filtfilt() using arbitrary number of filters
% defined by their coeeficients in a structure array.
%
% INPUTS:
%           EEG = continuous EEGLAB data
%           filter = structure array with 'num' and 'den' fields containing
%           the filter coefficients
% OUTPUTS:
%           EEG = modified EEGLAB data
%
% Adam Narai, RCNS HAS, 2018
%

% Convert EEG to double
EEG.data = double(EEG.data);

% Loop through filters
for n = 1:numel(filter)
    % Loop through channels
    for ch = 1:size(EEG.data, 1)
        EEG.data(ch,:) = filtfilt(filter(n).num, filter(n).den, EEG.data(ch,:));
    end
end