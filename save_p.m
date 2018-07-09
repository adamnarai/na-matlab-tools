function save_p(p, OutPath)
pPath = [OutPath, filesep, 'p'];

% Include script and log text
try
    p.script.text = fileread(p.script.file);
end
try
    p.log.text = fileread(p.log.file);
end
p.outPath = OutPath;

if exist(pPath, 'file')
    temp = load(pPath);
    if isfield(temp, 'old')
        temp.old{end+1} = temp.p;
    else
        temp.old{1} =temp.p;
    end
    old = temp.old;
    save(pPath, 'p', 'old');
else
    save(pPath, 'p');
end


