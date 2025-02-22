function bilateral_cluster_activity_with_topoplot(cfg, eeg_data, chanlocs, times, right_cluster, topo_times)

% Defaults
if ~isfield(cfg, 'LI') || isempty(cfg.LI)
    cfg.LI = 0;
end
if ~isfield(cfg, 'title') || isempty(cfg.title)
    cfg.title = '';
end
if ~isfield(cfg, 'save_path') || isempty(cfg.save_path)
    cfg.save_path = '';
end
if ~isfield(cfg, 'figsize') || isempty(cfg.figsize)
    cfg.figsize = [600 500];
end
if ~isfield(cfg, 'xlabel') || isempty(cfg.xlabel)
    cfg.xlabel = 'Times (ms)';
end
if ~isfield(cfg, 'ylabel') || isempty(cfg.ylabel)
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

% Create figure
figure('Position', [100 100 cfg.figsize])
set(gcf, 'units', 'normalized');

% Create axes
ax = axes('Position', [0.12 0.1 0.8 0.5]);

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
saved_ylim = ax.YLim;
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
for i = 1:numel(topo_idx)
    y_pos = 0.12 + (i-1)*0.8/numel(topo_idx) + (0.8/numel(topo_idx)-0.2)/2;
    topo_ax = axes('Position', [y_pos 0.65 0.2 0.2]);
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


