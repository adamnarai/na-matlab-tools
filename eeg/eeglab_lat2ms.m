function time = eeglab_lat2ms(latency, srate)
% EEGLAB_LAT2MS  Convert EEGLAB latency to ms.
%
% INPUTS:
%           latency = EEGLAB latency [datapoints]
%           srate = sampling rate [Hz]
% OUTPUTS:
%           time = time of latency in [ms]
%
% Adam Narai, RCNS HAS, 2018
%
% See also

% Substract 1, since 0 ms = 1 latency in EEGLAB
% *1000 to make it [ms] in the end
% /srate to converte into time dimension
time = (latency-1)*1000 / srate;
