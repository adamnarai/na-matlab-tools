function hash = get_git_hash(WorkPath)
% Get current GIT hash based if available
%
% INPUT:
%           WorkPath = project directory, containing .git
%
% Adam Narai, RCNS HAS, 2018

try
    command = ['git -C ' WorkPath ' rev-parse HEAD'];
    [status,hash] = system(command);
    if( status ~= 0 )
        hash = [];
    end
catch
    hash = [];
end