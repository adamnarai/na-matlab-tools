function p = start_script(mode)
% START_SCRIPT  Call at the begining of scripts.
% Call end_script() at the end.
%
% INPUTS:
%           mode = 'path': only adding na-matlab-toolbox subfolders
%                  ''    : full script start (default) 
% OUTPUTS:
%           p = params structure
%
% Adam Narai, RCNS HAS, 2019
%
% See also end_script(), start_log()

% Defaults
if nargin < 1
    mode = '';
end

% Add na-matlab-toolbox subfolders
addpath(genpath(fileparts(mfilename('fullpath'))));

% Setup
if strcmp(mode, '')
    evalin('base', 'clear all');
    evalin('base', 'close all');
    clc
end

% Start timer
tic

% Get caller script name
st = dbstack;
try
    script_name = st(2).name;
catch
    script_name = 'unknown';
end

% Start log with caller script name
p = start_log(script_name);

% Create default dir params
p.work_path = get_work_path();
p.results_dir = [p.work_path, filesep, 'results'];
p.data_dir = [p.work_path, filesep, 'data'];
p.settings_dir = [p.work_path, filesep, 'settings'];
