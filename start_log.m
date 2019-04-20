function p = start_log(log_name, log_dir)
% START_LOG  Start logging Command Window.
% This function creates the params (p) structure.
%
% INPUTS:
%           script_name = name of the caller script
%           log_dir = log file directory
% OUTPUTS:
%           p = params structure
%
% Adam Narai, RCNS HAS, 2019
%

% Defaults
if nargin < 1 || isempty(log_name)
    % Use caller script name
    st = dbstack;
    try
        log_name = st(2).name;
    catch
        log_name = 'unknown';
    end
end
if nargin < 2 || isempty(log_dir)
    log_dir = [get_work_path(), filesep, 'log'];
end

% Create log path
create_dir(log_dir);
curr_time = now;
log_file_name = ['log_', log_name, datestr(curr_time,'yy_mm_dd_HH_MM_SS'), '.txt'];
log_path = [log_dir, filesep, log_file_name];

% Start loging
diary(logPath); 
diary on;

% Write into log file
disp(['Script running: ', char(10), which(log_name)]);
disp(['Time: ', datestr(curr_time,'yyyy.mm.dd HH:MM:SS'), char(10)]);

% Save parameters
p.script.file = which(log_name);
p.log.file = logPath;
p.startTime = datestr(curr_time,'yyyy.mm.dd HH:MM:SS');
p.gitHash = get_git_hash(get_work_path());
p.PC = getenv('computername');
p.workPath = get_work_path();
