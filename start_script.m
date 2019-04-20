function p = start_script()
% START_SCRIPT  Call at the begining of scripts.
% Call end_script() at the end.
%
% OUTPUTS:
%           p = params structure
%
% Adam Narai, RCNS HAS, 2019
%
% See also end_script(), start_log()

% Setup
clc
tic

% Add na-matlab-toolbox subfolders
addpath(genpath(fileparts(mfilename('fullpath'))));

% Get caller script name
st = dbstack;
try
    script_name = st(2).name;
catch
    script_name = 'unknown';
end

% Start log with caller script name
p = start_log(script_name);
