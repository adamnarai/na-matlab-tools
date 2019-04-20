function eeglab_init()
% EEGLAB_INIT  Initialize and setup EEGLAB.
% Use for adding EEGLAB paths and setting precision to double.
%
% Adam Narai, RCNS HAS, 2019
%

% Add EEGLAB paths
evalc('eeglab');

% Set precision to double
evalc('pop_editoptions(''option_single'', 0)');

% Clear command window
close