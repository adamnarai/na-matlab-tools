function EEG = mark_EEG_artifacts(EEG, channels, specdata_path)
% MARK_EEG_ARTIFACTS  Automatic EEGLAB artifact marking.
% Specdata may be saved and reloaded to reduce computational time.
%
% INPUTS:
%           EEG = epoched EEGLAB data
%           channels = EEGLAB channels structure
%           specdata_path = path to save/load specdata
% OUTPUTS:
%           EEG = EEGLAB data with reject info
%
% Adam Narai, RCNS HAS, 2019
%

% Defaults
if nargin < 2 || isempty(channels)
    channels = 1:EEG.nbchan;    % use all channels
end
if nargin < 3
    specdata_path = [];
end

% Load specdata if already computed
if ~isempty(specdata_path) && exist(specdata_path, 'file')
    temp = load(specdata_path, 'specdata');
    EEG.specdata = temp.specdata;
end

% Threshold
EEG = pop_eegthresh(EEG,...
    1,...               % channels (not ICA)
    channels,...        % channels to use
    -100,...            % lower threshold [uV]
    100,...             % upper threshold [uV]
    EEG.xmin,...        % start time [s]
    EEG.xmax,...        % end time [s]
    1,...               % superpose with different colors
    0);                 % just label (don't reject)

% Joint probability
EEG = pop_jointprob(EEG,...
    1,...               % channels (not ICA)
    channels,...        % channels to use
    5,...               % SD threshold for one channel
    5,...               % global SD threshold
    1,...               % superpose with different colors
    0);                 % just label (don't reject)

% Kurtosis
EEG = pop_rejkurt(EEG,...
    1,...               % channels (not ICA)
    channels,...        % channels to use
    5,...               % kurtosis SD threshold for one channel
    5,...               % global kurtosis SD threshold
    1,...               % superpose with different colors
    0);                 % just label (don't reject)

% Trend
EEG = pop_rejtrend(EEG,...
    1,...               % channels (not ICA)
    channels,...        % channels to use
    250,...             % window size
    25,...              % max abs slope
    0.5,...             % min R^2
    1,...               % superpose with different colors
    0);                 % just label (don't reject)

% Frequency threshold
EEG = pop_rejspec(EEG,...
    1,...                               % channels (not ICA)
    'elecrange', channels,...           % channels to use
    'threshold', [-50 50; -100 25],...  % th limit in dB
    'freqlimits', [0 2; 20 40],...      % freq limit in Hz
    'eegplotplotallrej', 1,...          % superpose with different colors
    'eegplotreject', 0);                % just label (don't reject)
close   % Close plot opened by pop_rejspec

% Save specdata
if ~isempty(specdata_path) && ~exist(specdata_path, 'file')
    specdata = EEG.specdata;
    save(specdata_path, 'specdata');
end
