function eeg_out = mirror_half_LI(eeg, chanlocs)
% MIRROR_HALF_LI  Mirror right hemisphere EEG stats to the left with
% inverted sign.
%
% INPUT:
%           eeg = [ch x time] right hemisphere EEG data matrix (channels in original order)
%           chanlocs = chanlocs struct with all channels
%
% Adam Narai, RCNS HAS, 2019
%

% Pair channels and remove center
locations = pair_channels(chanlocs, 0.1);
chanlocs_li = chanlocs;
chanlocs_li(locations.center) = [];
locations_li = pair_channels(chanlocs_li, 0.1);

% Create NaN EEG
eeg_out = NaN(numel(chanlocs_li), size(eeg,2));



% Add right channels
eeg_out(sort(locations_li.right),:) = eeg;

% Add left channels as inverted right
eeg_out(locations_li.left,:) = -eeg_out(locations_li.right,:);

