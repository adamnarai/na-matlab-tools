function value = db_table_get(file_path, key, var_name, table_name)
% DB_TABLE_GET  Get value(s) from Matlab table database.
% Multiple key can be provided in a cell array. Multiple numeric variable
% can be requested at once using cell array.
%
% INPUTS:
%           file_path = path of *.mat file with tables
%           key = string or cell array of strings for table rows
%           var_name = string or cell array of strings for table columns
%           table_name = table name string (default: 'data')
% OUTPUTS:
%           value = requested data or array of data
%
% Adam Narai, RCNS HAS, 2019
%
% See also: db_table_add()

% Defaults
if nargin < 4
    table_name = 'data';
end

% Load table
if exist(file_path, 'file')
    try
        db = load(file_path, table_name);
    catch
        error(['Table ', table_name, ' not found in ', file_path]);
    end
    data = db.(table_name);
else
    error(['Database (Matlab table) file ', file_path, ' not found.']);
end

% Handle multiple variables
if iscell(var_name) && (numel(var_name) > 1)
    % Check if all numeric value
    valid = false(1, numel(var_name));
    for i = 1:numel(var_name)
        valid(i) = isnumeric(data{:, var_name{i}}) && (size(data{:, var_name{i}}, 2) == 1);
    end
    
    % Error if multiple non numeric variables requested
    if ~all(valid)
        error('Multiple variables can only read if all are numeric.');
    end
end

% Get value
value = data{key, var_name};
