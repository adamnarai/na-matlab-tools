function delete_files(file_names)
% DELETE_FILES  Delete a list of files or directories.
%
% INPUT:
%           file_names = cell array of file/dir names or paths
%
% Adam Narai, RCNS HAS, 2018
%

% Handle string input
if ~iscell(file_names)
    file_names = cellstr(file_names);
end

% Loop for files/dirs
for i = 1:numel(file_names)
    if isdir(file_names{i})
        rmdir(file_names{i}, 's');
    elseif exist(file_names{i}, 'file')
        delete(file_names{i});
    end
end

