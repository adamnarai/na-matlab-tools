function create_dir(dir_path)
% CREATE_DIR  Create non-existent directories based on full path.
% If the directory already exists, this function does nothing.
%
% INPUT:
%           dir_path = string or cell array of directory path(s) to create
%
% Adam Narai, RCNS HAS, 2018
%

% Handle string input
if ~iscell(dir_path)
    dir_path = cellstr(dir_path);
end

% Loop for dirs
for i = 1:numel(dir_path)
    if ~isdir(dir_path{i})
        mkdir(dir_path{i});
    end
end