function create_directory(NewDir)
% Create non-existent directories based on full path
%
% INPUT:
%           NewPath = string or cell array of directory path(s) to create
%
% Adam Narai, RCNS HAS, 2018

if ~iscell(NewDir)
    NewDir = cellstr(NewDir);
end

for i = 1:numel(NewDir)
    if ~isdir(NewDir{i})
        mkdir(NewDir{i});
    end
end