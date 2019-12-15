function ax = bilateral_cluster_activity_with_topoplot(cfg, eeg_data, chanlocs, times, right_cluster, topo_times)
% BILATERAL_CLUSTER_ACTIVITY_WITH_TOPOPLOT  
% Line plots of contralateral cluster average activity with topoplots.
%          
% INPUTS:
%           cfg = config structure
%           eeg_data = data matrix [ch x times]
%           chanlocs = EEGLAB chanlocs structure
%           times = times vector for eeg samples
%           right_cluster = right channel cluster to use for line-plot
%               (left cluster will be determined automatically)
%           topo_times = list of times for topoplots
% OUTPUTS:
%           ax = axes handle for the plot
%
%   cfg fields (all optional):
%       cfg.ax: axes handle
%       cfg.LI: data is LI
%       cfg.title: plot title
%       cfg.xlabel: x axis label
%       cfg.ylabel: y axis label
%       cfg.trim: time (x axis) limits
%       cfg.title_pos: title position (normalized)
%
% Adam Narai, RCNS HAS, 2019
%

% Defaults
if ~isfield(cfg, 'ax') || isempty(cfg.ax)
    ax = axes();
else
    ax = cfg.ax;
end
if ~isfield(cfg, 'LI') || isempty(cfg.LI)
    cfg.LI = 0;
end
if ~isfield(cfg, 'title')
    cfg.title = '';
end
if ~isfield(cfg, 'xlabel')
    cfg.xlabel = 'Times (ms)';
end
if ~isfield(cfg, 'ylabel')
    cfg.ylabel = 'Amplitude (\muV/m^2)';
end
if ~isfield(cfg, 'trim')
    cfg.trim = [];
end
if ~isfield(cfg, 'title_pos') || isempty(cfg.title_pos)
    cfg.title_pos = [0.05, 0.9];
end
ch_label_list = {chanlocs.labels};
color.b = [0.12, 0.38, 0.66];
color.r = [0.80, 0.15, 0.15];

% Get topo idx
topo_idx = time2idx(topo_times, times);

% Set colors
colors = flip(othercolor('RdBu11', 100));

% Get channel idx
cluster_idx_right = find(ismember(ch_label_list, right_cluster));
locations = pair_channels(chanlocs, 0.1);
cluster_idx_left = locations.left(ismember(locations.right, cluster_idx_right));

% Get cluster average erp
erp_right = mean(eeg_data(cluster_idx_right,:),1);
erp_left = mean(eeg_data(cluster_idx_left,:),1);

% Plot erp
hold(ax, 'on');
if ~cfg.LI
    plot(ax, times, erp_left, 'color', color.r, 'linewidth', 2);
end
plot(ax, times, erp_right, 'color', color.b, 'linewidth', 2);
hold(ax, 'off');
if ~cfg.LI
    legend({'left', 'right'});
    legend boxoff
end
if isempty(cfg.trim)
    xlim(ax, [times(1), times(end)]);
else
    xlim(ax, cfg.trim);
end
xlabel(cfg.xlabel);
ylabel(cfg.ylabel);
box on
ax.LineWidth = 1;
if ~isfield(cfg, 'y_lim')
    saved_ylim = ax.YLim;
else
    saved_ylim = cfg.y_lim;
end
text(ax, cfg.title_pos(1), cfg.title_pos(2), cfg.title, 'units', 'normalized', 'fontweight', 'bold', 'fontsize', 12);

% Draw subplot connection lines
for i = 1:numel(topo_times)
    if ~cfg.LI
        line([topo_times(i), topo_times(i)],...
            [min(erp_right(topo_idx(i)), erp_left(topo_idx(i))), saved_ylim(2)],...
            'linewidth', 1.2, 'color', 'k');
        line([topo_times(i), topo_times(i)],...
            [erp_right(topo_idx(i)), erp_left(topo_idx(i))],...
            'linewidth', 2, 'color', 'k');
    else
        line([topo_times(i), topo_times(i)],...
            [erp_right(topo_idx(i)), saved_ylim(2)],...
            'linewidth', 1.2, 'color', 'k');
    end
    ylim(saved_ylim);
end

% Topoplot
ax_pos = get(ax, 'position');
for i = 1:numel(topo_idx)
    x_pos = ax_pos(1) - 0.09 + (i-0.5)*ax_pos(3)/numel(topo_idx);
    topo_ax = axes('Position', [x_pos ax_pos(2)+ax_pos(4)*1.04 ax_pos(3)*0.45 ax_pos(3)*0.45]);
    topoplot(eeg_data(:,topo_idx(i)), chanlocs,...
        'style','map',...   % map, both
        'whitebk','on',...
        'headrad',0.66,...
        'electrodes','off',...
        'emarker2',{[cluster_idx_right, cluster_idx_left],'.','k', 10});
    colormap(colors);
    title([num2str(topo_times(i)), ' ms']);
    [ann_topo_x, ann_topo_y] = axescoord2figurecoord(0, -0.49);
    axes(ax);
    [ann_plot_x, ann_plot_y] = axescoord2figurecoord(topo_times(i), saved_ylim(2));
    annotation('line', [ann_plot_x ann_topo_x], [ann_plot_y ann_topo_y], 'linewidth', 1.2, 'color', 'k');
end


