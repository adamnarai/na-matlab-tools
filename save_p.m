function save_p(p, out_path)
% SAVE_P  Saving the p structure of parameters.
% If available the script and log text are also included.
% If a p.mat is already present, the previous 'p' is added to the 'old' struct.
%
% INPUTS:
%           p = params structure
%           out_path = output path for saving p
%
% Adam Narai, RCNS HAS, 2019
%
% See also start_script(), end_script()

% Create p path
p_path = [out_path, filesep, 'p.mat'];

% Include script and log text in p struct
try
    p.script.text = fileread(p.script.file);
end
try
    p.log.text = fileread(p.log.file);
end
p.outPath = out_path;

% Keep previous p structs in old
if exist(p_path, 'file')
    temp = load(p_path);
    if isfield(temp, 'old')
        temp.old{end+1} = temp.p;
    else
        temp.old{1} = temp.p;
    end
    old = temp.old;
    save(p_path, 'p', 'old');
else
    save(p_path, 'p');
end


