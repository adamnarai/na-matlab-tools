function p = get_dirs(p)
% GET_DIRS  Get default dirs under work path.
%
% INPUT:
%           p = params structure
% OUTPUT:
%           p = params structure with default directory paths
%
% Adam Narai, RCNS Brain Imaging Centre, 2019
%

% Default
if nargin < 1
    p = [];
end

% Define default directories
p.work_path = get_work_path();
p.results_dir = [p.work_path, filesep, 'results'];
p.data_dir = [p.work_path, filesep, 'data'];
p.settings_dir = [p.work_path, filesep, 'settings'];