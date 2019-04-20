function hash = get_git_hash(git_path)
% Get current GIT hash if available
%
% INPUT:
%           git_path = project directory, containing the .git folder
%
% Adam Narai, RCNS HAS, 2019

try
    command = ['git -C ' git_path ' rev-parse HEAD'];
    [status, hash] = system(command);
    if status ~= 0
        hash = [];
    end
catch
    hash = [];
end