function cluster_data = average_eeg_ch_cluster(data, ch_list, chanlocs)
% AVERAGE_EEG_CH_CLUSTER  Get EEG cluster average.
%          
% INPUTS:
%           data = EEG data with [ch x times x...] dimensions
%           ch_list = cell array of channel strings
%           chanlocs = EEGLAB chanlocs structure
% OUTPUTS:
%           cluster_data = channel cluster mean with [times x...] dimensions
%
% Adam Narai, RCNS HAS, 2019

% Check data-chanlocs match
if size(data,1) ~= numel(chanlocs)
    error(['Different channel number in data and chanlocs (',...
        num2str(size(data,1)), ' vs ', num2str(numel(chanlocs)), ')']);
end

% Get channel indices
[found, idx] = ismember(ch_list, {chanlocs.labels});
if ~all(found)
    error(['The following channels were not found in chanlocs: ', strjoin(ch_list(~found),', ')]);
end

% Average channels
cluster_data = mean(array_slice(data, 1, idx), 1);

% Eliminate singleton first dimension
cluster_data = shiftdim(cluster_data);