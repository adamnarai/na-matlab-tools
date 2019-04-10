function out_data = eeg_time2tf(data, srate, freqBins, Fc, wname)
% EEG_TIME2TF  Transform EEG to time-frequency domain.
% Transformation is performed using 1D CWT.
%
% INPUTS:
%           data = EEGLAB data (EEG.data)
%           srate = sampling rate [Hz]
%           freqBins = list of frequency bins
%           Fc = center frequency
%           wname = wavelet name
% OUTPUTS:
%           out_data = TF domain EEG data
%
% Adam Narai, RCNS HAS, 2019
%

% Defaults
if nargin < 5
    wname = 'cmor1-1';
end
if nargin < 4
    Fc = centfrq(wname);
end

% Wavelet transformation
out_data = single.empty;
for ch = 1:size(data,1)
    out_data(ch,:,:) = single(abs(cwt(data(ch,:), Fc/(1/srate)./freqBins, wname)));
end