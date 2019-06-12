function db_table_add(file_path, key, var_name, value, table_name)
% DB_TABLE_ADD  Add value(s) to Matlab table database.
% Multiple key can be provided in a cell array.
% If the database *.mat file not found, it will be created.
%
% INPUTS:
%           file_path = path of *.mat database file
%           key = string or cell array of strings for table rows
%           var_name = string for table column
%           value = data or array of data
%           table_name = table name string (default: 'data')
%
% Adam Narai, RCNS HAS, 2019
%
% See also: db_table_get()

% Defaults
if nargin < 5
    table_name = 'data';
end

% Fix extension
if ~strcmp(file_path(end-3:end), '.mat')
    file_path = [file_path, '.mat'];
end

% Load or create file and table
if exist(file_path, 'file')
    try
        db = load(file_path);
        data = db.(table_name);
    catch
        disp(['Creating new table: ', table_name]);
        data = table();
    end
else
    disp(['Creating new database file with table ',table_name , '.'])
    create_dir(fileparts(file_path));
    data = table();
    eval([table_name, ' = data;']);
    save(file_path, table_name);
end

% Add data
warning off
if isnumeric(value) && isequal(size(value), [numel(cellstr(key)), 1])
    data{key, var_name} = value;
else
    data{key, var_name} = {value};
end
warning on

% Save table
db.(table_name) = data;
save(file_path, '-struct', 'db');
