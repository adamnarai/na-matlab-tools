function [EEG, Th] = mark_EOG_blink(EEG, ch, Th, openGUI)
% MARK_EOG_BLINKS  Mark blinks in EEG based on EOG.
%
% INPUTS:
%           EEG = epoched EEGLAB data with blink events
%           ch = channel number of bipolar EOG
%           Th = threshold in [uV]
%           openGUI = 1: open GUI for manual Th setting (default:0)
% OUTPUTS:
%           EEG = modified EEGLAB data
%           Th = modified Th
%
% Adam Narai, RCNS HAS, 2018
%
% See also 

% Defaults
if nargin < 4
    openGUI = 0;
end
if nargin < 3
    Th = 75;   % usually a good threshold
end

disp('Adding EOG blink events to EEG...');

% Define fields for eeglab events
fields = {'type', 'latency', 'duration', 'code', 'epoch'};

% Get epochs
data = squeeze(EEG.data(ch,:,:));

% Calculate max of epochs
M = max(data,[], 1);

% Sort M
[sorted, I] = sort(M);

% Plot
if openGUI
    Th = set_EOG_blink_th(data, Th);
end

% Calculate threshold index
[~, th] = min(abs(sorted - Th));

% Get epoch numbers with blink
blinkEpochs = I(th:end);

events = cell(numel(blinkEpochs),5);
for i = 1:numel(blinkEpochs)
    % Find latency of max within epoch
    [~, lat] = max(data(:,blinkEpochs(i)));
    
    % Calculate EEGLAB event latency
    latency = (blinkEpochs(i)-1)*EEG.pnts + lat;
    
    % Add to events array
    events(i,:) = {'EOGBlink',...
        eeglab_lat2ms(latency, EEG.srate),...
        0,...
        'EOGBlinks',...
        blinkEpochs(i)};
end

% Add events to EEG
EEG = pop_importevent(EEG,...
    'append', 'yes',...
    'event', events,...
    'fields', fields,...
    'timeunit', 1e-3...
    );

disp('Done.');

