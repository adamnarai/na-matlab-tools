function add_parent_path(level, incl_sub)
% ADD_RELPATH  Add parent path relative to caller's directory.
%
% INPUT:
%           level = level of parentage (0 means current directory, 
%               1 means immediate parent, etc.)
%           incl_sub = 1: include subdirectories
%
% Adam Narai, RCNS HAS, 2018
%

% Defaults
if nargin < 2
    incl_sub = 0;
end
if nargin < 1
    level = 1;
end

% Get parent dir
st = dbstack('-completenames');
parent_dir = fileparts(st(2).file);
for i = 1:level
    parent_dir = fileparts(parent_dir);
end

% Add directories to path
if incl_sub
    addpath(genpath(parent_dir));
else
    addpath(parent_dir);
end