function add_subpath(SubDir, inclSub, WorkPath)
% Add subdirectories to Matlab search path
%
% INPUT:
%           SubDir = directory to add (relative to WorkPath)
%           inclSub = 1: also add subdirectories
%           WorkPath = main project path
%
% Adam Narai, RCNS HAS, 2018

if nargin < 3
    WorkPath = get_work_path();
end

if nargin < 2
    inclSub = 0;
end

if inclSub
    addpath(genpath([WorkPath, filesep, SubDir]));
else
    addpath([WorkPath, filesep, SubDir]);
end