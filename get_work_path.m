function work_path = get_work_path(levels)
% GET_WORK_PATH  Get the project folder.
% Relies on the relative location of this script.
%
% INPUT:
%           levels = indicates how deep is this function in the directory
%                    structure (0 means the work_path)
%
% Adam Narai, RCNS HAS, 2018
%

% Default, assuming work_path/bin/external/na-matlab-tools structure
if nargin < 1
    levels = 3;
end

% Get path
work_path = fileparts(mfilename('fullpath'));
for i = 1:levels
    work_path = fileparts(work_path);
end

% Check if the original caller is from this working dir
st = dbstack('-completenames');
caller_path = st(end).file;
if ~all(ismember(work_path, caller_path))
    error(['The found work path (', work_path, ') is invalid.', char(10),...
        'get_work_path() was found in ', mfilename('fullpath'), char(10),...
        'however the caller is from ', caller_path,...
        'You can resolve this error by adding only the valid get_work_path() to Matlab path.']);
end

