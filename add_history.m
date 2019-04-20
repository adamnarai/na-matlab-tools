function history = add_history(history, comment)
% ADD_HISTORY  Add new record to history field with comment.
% Each history record contains the following:
%   comment, date, username, script name, git hash
%
% INPUTS:
%           history = history struct array (created if empty)
%           comment = comment string
% OUTPUTS:
%           history = history struct array with the new record
%
% Adam Narai, RCNS HAS, 2019
%

% Get caller
caller_script = dbstack(1);

% Add record
idx = numel(history) + 1;
history(idx).comment = comment;
history(idx).date = datestr(now, 'yyyy-mm-dd HH:MM:SS');
history(idx).username = getenv('username');
history(idx).script = caller_script.name;
history(idx).git_hash = get_git_hash(get_work_path());