function p = start_log(scriptName, logDir)

if nargin < 1
    st = dbstack;
    try
        scriptName = st(2).name;
    catch
        scriptName = 'unknown';
    end
end
if nargin < 2
    logDir = [get_work_path(), filesep, 'log'];
end

create_directory(logDir);
time = now;
logFileName = ['log_', scriptName, datestr(time,'yy_mm_dd_HH_MM_SS'), '.txt'];
logPath = [logDir, filesep, logFileName];

% Start loging
diary(logPath); 
diary on;

% Write into log file
disp(['Script running: ', char(10), scriptName]);
disp(['Time: ', char(10), datestr(time,'yyyy.mm.dd HH:MM:SS'), char(10)]);

% Save parameters
p.scriptName = logPath;
p.logFile = logPath;
p.startTime = datestr(time,'yyyy.mm.dd HH:MM:SS');
p.gitHash = get_git_hash(get_work_path());
p.PC = getenv('computername');
p.workPath = get_work_path();
