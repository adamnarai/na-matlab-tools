function copy_files(file_names, dest_dir)
% COPY_FILES  Copy a list of files or directories to a given folder.
%
% INPUT:
%           file_names = cell array or string of file/dir names
%           dest_dir = destination directory
%
% Adam Narai, RCNS HAS, 2018
%

% Handle string input
if ~iscell(file_names)
    file_names = cellstr(file_names);
end

% Loop for files/dirs and copy
for i = 1:numel(file_names)
    copyfile(file_names{i}, dest_dir);
end