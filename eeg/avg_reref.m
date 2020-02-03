function EEG = avg_reref(EEG, chanlocs, ref_label)
% AVG_REREF  Rereference EEG to average.
%          
% INPUTS:
%           EEG = eeglab struct
%           chanlocs = chanlocs structure with last ch as reference
%           ref_label = reference label (usually TP10)
% OUTPUTS:
%           EEG = modified eeglab struct
%
% Adam Narai, RCNS HAS, 2019

% Sanity check
if numel(chanlocs) ~= (EEG.nbchan + 1)
    error('Not matching channel number');
end
if ~strcmp(ref_label, chanlocs(end).labels)
    error('Ref label is not the last channel.');
end

% Add zero reference channel
EEG.nbchan = EEG.nbchan + 1;
EEG.chanlocs = chanlocs;
dim = numel(size(EEG.data));
if dim == 2        % 2D (continuous)
    EEG.data(end+1,:) = zeros(1, EEG.pnts);
elseif dim == 3    % 3D (epoched)
    EEG.data(end+1,:,:) = zeros(1, EEG.pnts, EEG.trials);
end

% Re-reference to average
if dim == 2        % 2D (continuous)
   EEG.data = EEG.data - repmat(mean(EEG.data, 1), EEG.nbchan, 1);
elseif dim == 3    % 3D (epoched)
   EEG.data = EEG.data - repmat(mean(EEG.data, 1), EEG.nbchan, 1, 1);
end

EEG.ref = 'averef';
