function eventr_str = eeg_event_str(event_num)
% EEG_EVENT_STR  Create 'S%3.d' style EEG event string based on event number.
%
% INPUTS:
%           event_num = 8 bit event number
% OUTPUTS:
%           eventr_str = event string
%
% Adam Narai, RCNS HAS, 2019
%

eventr_str = sprintf('S%3.d', event_num);