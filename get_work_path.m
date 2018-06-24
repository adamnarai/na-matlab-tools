function WorkPath = get_work_path(levels)
% Get the project path based on this functions location
%
% INPUT:
%           levels = indicates how deep is this function in the directory
%                    structure (0 means the WorkPath)
%
% Adam Narai, RCNS HAS, 2018

% Default, assuming WorkPath/bin/external/na-matlab-tools structure
if nargin < 1
    levels = 3;
end

WorkPath = fileparts(mfilename('fullpath'));
for i = 1:levels
    WorkPath = fileparts(WorkPath);
end

