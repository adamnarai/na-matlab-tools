function p = start_script()
clc
tic

% Add na-matlab-toolbox subfolders
addpath(genpath(fileparts(mfilename('fullpath'))));

% Get caller
st = dbstack;
try
    scriptName = st(2).name;
catch
    scriptName = 'Script';
end

p = start_log(scriptName);