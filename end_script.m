function end_script(p, OutPath)

% Stop timer
elapsedTime = toc;

% Get caller
st = dbstack;
try
    scriptName = st(2).name;
catch
    scriptName = 'Script';
end

% Finish message
fprintf(['\n------------------------------------',...
    '\n ', datestr(now),...
    '\n ', scriptName, ' finished. ',...
    '\n Elapsed time: ', num2str(ceil(elapsedTime/60)), ' minutes',...
    '\n------------------------------------\n']);

% End diary if started
diary off

% Save p.mat
if nargin > 1
    save_p(p, OutPath);
end

