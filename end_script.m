function end_script(p, out_path)
% END_SCRIPT  Call at the end of scripts paired to strat_script().
%
% INPUTS:
%           p = params structure
%           out_path = output path for saving p
%
% Adam Narai, RCNS HAS, 2019
%
% See also start_script()

% Stop timer
elapsed_time = toc;

% Get caller
st = dbstack;
try
    script_name = st(2).name;
catch
    script_name = 'Script';
end

% Finish message
fprintf(['\n------------------------------------',...
    '\n ', datestr(now, 'yyyy-mm-dd HH:MM:SS'),...
    '\n ', script_name, ' finished. ',...
    '\n Elapsed time: ', num2str(ceil(elapsed_time/60)), ' minutes',...
    '\n------------------------------------\n']);

% End diary if started
diary off

% Save p.mat
if nargin > 1
    save_p(p, out_path);
end

