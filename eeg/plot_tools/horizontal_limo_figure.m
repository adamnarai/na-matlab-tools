% Plot space-time t values on horizontal plot
function [fig_handle, min_max_value] = horizontal_limo_figure(cfg)
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
cfg = set_cfg_default(cfg, 'trim', [-250 600]);
cfg = set_cfg_default(cfg, 'MCC', 3);
cfg = set_cfg_default(cfg, 'plot_alpha', 1);
cfg = set_cfg_default(cfg, 'one_sided', 0);
cfg = set_cfg_default(cfg, 'zero_line', 0);
cfg = set_cfg_default(cfg, 'p', 0.05);
cfg = set_cfg_default(cfg, 'font_size', 11);
cfg = set_cfg_default(cfg, 'y_label', 'Time (ms)');
cfg = set_cfg_default(cfg, 'fig_size', [1400 250]);
cfg = set_cfg_default(cfg, 'ax_pos', [.07 .2 .85 .75]);
cfg = set_cfg_default(cfg, 'ax_units', 'normalized');
cfg = set_cfg_default(cfg, 'colorbar_dist', .01);
cfg = set_cfg_default(cfg, 'colorbar_width', .01);
cfg = set_cfg_default(cfg, 'colorbar_label', 't');
cfg = set_cfg_default(cfg, 'colorbar_label_pos', [1.018 -0.08]);

% Sample data
cfg = set_cfg_default(cfg, 'analysis_subdir', 'ANCOVA8_t_lp_35_saccamp_0_26_one_sample/contr/contrast_[-1 4 -1 -1 -1]');

cfg.file_path = [work_path, cfg.glm_subdir, filesep, cfg.analysis_subdir];

% Colormap
colors = flipud(othercolor('RdBu11',100));
if cfg.one_sided
    colors = colors(1:size(colors,1)/2,:);
end

handles.start_time_val = cfg.trim(1);
handles.end_time_val = cfg.trim(2);
handles.p = cfg.p;
handles.MCC = cfg.MCC;
handles.dir = cfg.file_path;

% Open limo figure and save data to LIMO.cache
display_limo_fig(find_stat_file(cfg.file_path), cfg.file_path, handles);

% Get results data
load([cfg.file_path, '/LIMO.mat'], 'LIMO');
if ~isequal(LIMO.cache.fig.MCC, handles.MCC)
    error(['Expected MCC type ', num2str(handles.MCC), ', found type ', num2str(LIMO.cache.fig.MCC)]);
end

chan_labels = {LIMO.data.chanlocs.labels};
stats = LIMO.cache.fig.stats;
mask = LIMO.cache.fig.mask;
to_plot = stats.*mask;
min_max_value = [min(to_plot(:)), max(to_plot(:))];

% Plot
fig_handle = figure;
ax_handle = axes('position', cfg.ax_pos, 'units', cfg.ax_units);
set(fig_handle, 'position', [100 100 cfg.fig_size]);

image = imagesc(ax_handle, [1 size(to_plot,1)],[cfg.trim(1) cfg.trim(2)], to_plot');
set(ax_handle,'YDir','normal')
set(image,'AlphaData', cfg.plot_alpha*mask');
colormap(colors);
colorbar(ax_handle,...
    'position', [cfg.ax_pos(1)+cfg.ax_pos(3)+cfg.colorbar_dist cfg.ax_pos(2) cfg.colorbar_width cfg.ax_pos(4)],...
    'location', 'manual', 'units', cfg.ax_units, 'linewidth', 0.01);
text(ax_handle, cfg.colorbar_label_pos(1), cfg.colorbar_label_pos(2), cfg.colorbar_label,...
    'units', cfg.ax_units, 'horizontalalignment', 'center', 'fontsize', cfg.font_size);

set(ax_handle,'XTick', 1:size(to_plot,1));
set(ax_handle,'XTickLabel', chan_labels);
set(ax_handle,'TickLength',[0 1])

ax = ancestor(image, 'axes');
ax.XTickLabelRotation = 90;
if cfg.zero_line
    line(get(ax,'XLim'),[0 0],'Color','k', 'LineStyle', '--');
end
ylabel(cfg.y_label);
set(ax_handle, 'fontsize', cfg.font_size);

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

function display_limo_fig(FileName, PathName, handles)
cd(PathName); handles.LIMO = load('LIMO.mat');
handles.LIMO.LIMO = trim_time(handles.LIMO.LIMO, handles.start_time_val, handles.end_time_val);
handles.LIMO.LIMO.cache = [];
limo_display_results(1,FileName,PathName,handles.p,handles.MCC,handles.LIMO.LIMO);

function LIMO = trim_time(LIMO, start_time, end_time)
data = LIMO.data;

if ~isnan(start_time) && ~isnan(end_time)
    % Save original time boundaries
    if ~isfield(data, 'data_start')
        data.data_start = data.start;
    end
    if ~isfield(data, 'data_end')
        data.data_end = data.end;
    end
    
    % Create times vector
    data.times = data.data_start:(1000/data.sampling_rate):data.data_end;
    
    % Find closest match for trim times
    [~, idx] = min(abs(data.times - start_time));
    data.start = data.times(idx);
    data.trim1 = idx;
    [~, idx] = min(abs(data.times - end_time));
    data.end = data.times(idx);
    data.trim2 = idx;
else
    % Restor times
    if isfield(data, 'data_start')
        data.start = data.data_start;
    end
    if isfield(data, 'data_end')
        data.end = data.data_end;
    end
    
    % Remove trim fields
    if isfield(data, 'trim1')
        data = rmfield(data, 'trim1');
    end
    if isfield(data, 'trim2')
        data = rmfield(data, 'trim2');
    end
end
% Save data to LIMO struct
LIMO.data = data;
save LIMO LIMO
