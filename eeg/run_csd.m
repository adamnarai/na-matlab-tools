function EEG = run_csd(EEG, CSD_parameters, chanlocs, rm_ref)
% RUN_CSD  Run CSD on EEGLAB data.
%
% INPUTS:
%           EEG = channel labels in cell array
%           CSD_parameters = structure of CSD parameters, especially the G
%               and H matrices
%           chanlocs = chanlocs file indluding the referenc ch at the end
%           rm_ref = 1: remove ref ch after CSD, 0: include ref (default)
% OUTPUTS:
%           EEG = EEGLAB structure with CSD transformed data
%
% Adam Narai, RCNS HAS, 2019
%
% See also: run_csd()

% Defaults
if nargin < 3
    chanlocs = [];
end
if nargin < 4
    rm_ref = 0;
end

% Add a zero column for the reference channel
if ~isempty(CSD_parameters.reference_label)
    eeg_size = size(EEG.data);
    eeg_size(1) = 1;
    EEG.data = [EEG.data; zeros(eeg_size)];
end

% Perform CSD transformation
EEG.data = CSD(EEG.data, CSD_parameters.G, CSD_parameters.H, CSD_parameters.lambda);

% Remove the reference channel
if rm_ref && ~isempty(CSD_parameters.reference_label)
    EEG.data(end,:) = [];
end

% Add new chanlocs
if ~isempty(chanlocs)
    % Check if reference is at the last place
    if ~strcmp(chanlocs(end).labels, CSD_parameters.reference_label)
        error('Reference channel is not at the last position in chanlocs.');
    end
    EEG.nbchan = numel(chanlocs);
    EEG.chanlocs = chanlocs;
end
