function delete_files(FileNames)
% Delete a list of files or directories
%
% INPUT:
%           FileNames = cell array of file/dir names or paths
%
% Adam Narai, RCNS HAS, 2018

if ~iscell(FileNames)
    FileNames = cellstr(FileNames);
end

for i = 1:numel(FileNames)
    if isdir(FileNames{i})
        rmdir(FileNames{i}, 's');
    elseif exist(FileNames{i}, 'file')
        delete(FileNames{i});
    end
end

