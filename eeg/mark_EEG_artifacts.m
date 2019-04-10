function EEG = mark_EEG_artifacts(EEG, channels)
% MARK_EEG_ARTIFACTS  Automatic EEGLAB artifact marking.
%
% INPUTS:
%           EEG = epoched EEGLAB data
%           channels = EEGLAB channels structure
% OUTPUTS:
%           EEG = EEGLAB data with reject info
%
% Adam Narai, RCNS HAS, 2019
%

% Defaults
if nargin < 2
    channels = 1:EEG.nbchan;    % use all channels
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
