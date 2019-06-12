function locations = pair_channels(chanlocs, tolerance)
% PAIR_CHANNELS  Find contralateral channel pairs in EEGLAB chanlocs.
% Certain montages have relatively high asymmetricity and may require a
% tolerance as high as 0.1
%
% INPUTS:
%           chanlocs = EEGLAB chanlocs struct array
%           tolerance = maximal difference where coordinates are regarded 
%               as the same (default: 1E-3)
% OUTPUTS:
%           locations = structure with left, right and center fields
%               containing channel numbers, channel numbers at the same 
%               index in the left and right list are pairs
%
% Adam Narai, RCNS HAS, 2019
%

% Defaults
if nargin < 2
    tolerance = 1E-3;
end

% Init
locations.left = [];
locations.right = [];
locations.center = [];
centN = 1;
latN = 1;

% Loop for channels
for ch1 = 1:numel(chanlocs)
    if chanlocs(ch1).radius == 0 || chanlocs(ch1).theta == 0 || chanlocs(ch1).theta == 180
        % Center channel found
        locations.center(centN) = ch1;
        centN = centN + 1;
    else
        % Loop for unlabeld channels
        for ch2 = ch1+1:numel(chanlocs)
            % Test for radius and theta
            radiusCrit = abs(chanlocs(ch1).radius - chanlocs(ch2).radius) <= tolerance;
            thetaCrit = abs(chanlocs(ch1).theta + chanlocs(ch2).theta) <= tolerance;
            if radiusCrit && thetaCrit
                % Pair found
                if chanlocs(ch1).theta < chanlocs(ch2).theta
                    locations.left(latN) = ch1;
                    locations.right(latN) = ch2;
                else
                    locations.left(latN) = ch2;
                    locations.right(latN) = ch1;
                end
                latN = latN + 1;
            end
        end
    end
end

% Check if each channel has a label
if numel(chanlocs) ~= (numel(locations.left) + numel(locations.right) + numel(locations.center))
    error('Channel pairing was not succesfull, some channels have no label.');
end
