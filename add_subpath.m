function add_subpath(sub_dir, incl_sub, work_path)
% ADD_SUBPATH  Add subdirectories to Matlab search path.
%
% INPUT:
%           sub_dir = directory to add (relative to work_path)
%           incl_sub = 0: add only sub_dir, 1: add subdirectories
%           work_path = main project path
%
% Adam Narai, RCNS HAS, 2018
%

% Defaults
if nargin < 3
    work_path = get_work_path();
end
if nargin < 2
    incl_sub = 0;
end

% Add directories
if incl_sub
    addpath(genpath([work_path, filesep, sub_dir]));
else
    addpath([work_path, filesep, sub_dir]);
end