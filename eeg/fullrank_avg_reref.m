function EEG = fullrank_avg_reref(EEG, exclude)
% FULLRANK_AVG_REREF  Rereference EEG to average while keeping rank.
% Function is based on Makoto's preprocessing pipeline.
% https://sccn.ucsd.edu/wiki/Makoto's_preprocessing_pipeline
%          
% INPUTS:
%           EEG = eeglab struct
%           exclude = [integer array] list of channels to exclude
% OUTPUTS:
%           EEG = modified eeglab struct
%
% Adam Narai, RCNS HAS, 2018

% Defaults
if nargin < 2
    exclude = [];
end

% Add zero reference channel
EEG.nbchan = EEG.nbchan + 1;
dim = numel(size(EEG.data));
if dim == 2        % 2D (continuous)
    EEG.data(end+1,:) = zeros(1, EEG.pnts);
elseif dim == 3    % 3D (epoched)
    EEG.data(end+1,:,:) = zeros(1, EEG.pnts, EEG.trials);
end
EEG.chanlocs(1,EEG.nbchan).labels = 'initialReference';

% Channels to re-ref
channels = 1:EEG.nbchan;
if ~isempty(exclude)
    channels(exclude) = [];
end
chNum = numel(channels);

if dim == 2        % 2D (continuous)
   EEG.data(channels,:) = EEG.data(channels,:) - ones(chNum,1)*mean(EEG.data(channels,:), 1);
elseif dim == 3    % 3D (epoched)
   EEG.data(channels,:,:) = EEG.data(channels,:,:) - ones(chNum,1)*mean(EEG.data(channels,:,:), 1);
end

% Remove ref Ch
EEG = pop_select(EEG, 'nochannel', {'initialReference'});

EEG.ref = 'averef';
