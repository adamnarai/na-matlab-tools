function latency = eeglab_ms2lat(time, srate)
% EEGLAB_LAT2MS  Convert EEGLAB latency to ms.
%
% INPUTS:
%           time = time of latency in [ms]
%           srate = sampling rate [Hz]
% OUTPUTS:
%           latency = EEGLAB latency [datapoints]
%
% Adam Narai, RCNS HAS, 2018
%
% See also

% *srate to converte into datapoint dimension
% /1000 since time in [ms] and srate in [Hz]
% Add 1, since 0 ms = 1 latency in EEGLAB
latency = round((time*srate / 1000)) + 1;