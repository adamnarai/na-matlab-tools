% Plot space-time t values on horizontal plot
function fig_handle = limo_topoplot(cfg)
add_subpath('bin/external/othercolor');
root = fileparts(which('limo_eeg'));
addpath([root filesep 'limo_cluster_functions'])
addpath([root filesep 'external'])
addpath([root filesep 'external' filesep 'psom'])
addpath([root filesep 'external' filesep 'othercolor'])
addpath([root filesep 'help'])
work_path = get_work_path();

% Defaults
cfg = set_cfg_default(cfg, 'glm_subdir', '/results/GLM_lp_35');
cfg = set_cfg_default(cfg, 'time_point', 140);

% Sample data
cfg = set_cfg_default(cfg, 'analysis_subdir', 'ANCOVA8_t_lp_35_saccamp_0_26_one_sample/contr/contrast_[-1 4 -1 -1 -1]');

cfg.file_path = [work_path, cfg.glm_subdir, filesep, cfg.analysis_subdir];

% Colormap
colors = flipud(othercolor('RdBu11',100));

% Get stat file name
stat_file_name = find_stat_file(cfg.file_path);

% Load stat data
load([cfg.file_path, '/LIMO.mat'], 'LIMO');
temp = load([cfg.file_path, filesep, stat_file_name]);
try
    field_name = fieldnames(temp);
    EEG.data = temp.(field_name{:})(:,:,4);
catch
    error('No valid stat values found.');
end
EEG.times = LIMO.data.times/1000;
EEG.chanlocs = LIMO.data.chanlocs;
EEG.nbchan = size(EEG.data,1);
EEG.pnts = size(EEG.data,2);
EEG.trials = 1;
EEG.xmin = EEG.times(1);
EEG.xmax = EEG.times(end);

pop_topoplot(EEG, 1, cfg.time_point, '', 0,...
        'gridscale',200,...
        'style','map',...
        'whitebk','on',...
        'headrad',0.64,...
        'electrodes','off',...
        'colorbar','off'...
        );
colormap(colors);
title([num2str(cfg.time_point), ' ms']);


function stat_file_name = find_stat_file(file_path)
name_str = {'one_sample_ttest_parameter_', 'two_samples_ttest_parameter_'};
file_list = dir(file_path);
file_list = {file_list.name};
for fileIdx = 1:numel(file_list)
    stat_file_name = file_list{fileIdx};
    for samp = 1:numel(name_str)
        N = length(name_str{samp});
        if length(stat_file_name) >= N
            if strcmp(stat_file_name(1:N), name_str{samp})
                return  % File found
            end
        end
    end
end
% File not found
error(['Stat file not found in ', file_path]);