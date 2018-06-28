function p = start_script(mode)
if nargin < 1
    mode = '';
end

% Add na-matlab-toolbox subfolders
addpath(genpath(fileparts(mfilename('fullpath'))));
add_subpath('bin');

if isempty(mode)
    clc
    tic
    % Get caller
    st = dbstack;
    try
        scriptName = st(2).name;
    catch
        scriptName = 'Script';
    end
    
    p = start_log(scriptName);
end