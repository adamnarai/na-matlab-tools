function copy_files(FileNames, Destination)
% Copy a list of files or directories to a given folder
%
% INPUT:
%           FileNames = cell array of file/dir names or paths
%           Destination = destination paths
%
% Adam Narai, RCNS HAS, 2018

if ~iscell(FileNames)
    FileNames = cellstr(FileNames);
end

for i = 1:numel(FileNames)
    copyfile(FileNames{i}, Destination);
end