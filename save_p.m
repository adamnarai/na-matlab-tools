function save_p(p, OutPath)

% Include script and log text
try
    p.script.text = fileread(p.script.file);
end
try
    p.log.text = fileread(p.log.file);
end

p.outPath = OutPath;
save([OutPath, filesep, 'p'], 'p');