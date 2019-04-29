function p = add_history(p, comment, reset)
% ADD_HISTORY  Add new record to history field of p struct.
% Each history record contains the following:
%   comment, date, username, script name
%
% INPUTS:
%           p = p struct (history field created if not present)
%           comment = comment string
%           reset = if 1, history is reset before adding new record
% OUTPUTS:
%           p = p struct with history field updated
%
% Adam Narai, RCNS HAS, 2019
%

% Defaults
if nargin < 3
    reset = 0;
end

% Get caller
caller_script = dbstack(1);

% Reset history
if reset
    p.history = [];
end

% Add record
if ~isfield(p, 'history')
    idx = 1;
else
    idx = numel(p.history) + 1;
end
p.history(idx).comment = comment;
p.history(idx).date = datestr(now, 'yyyy-mm-dd HH:MM:SS');
p.history(idx).username = getenv('username');
p.history(idx).username = getenv('computername');
p.history(idx).script = caller_script.name;
