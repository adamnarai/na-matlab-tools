function ax = plot_erp(data, cfg, ax)
% PLOT_ERP  Get EEG cluster average.
%          
% INPUTS:
%           data = [times x type] EEG data
%           cfg = cfg structure with the following fields:
%               times
%               title
%               x_label
%               y_label
%               x_lim
%               y_lim
%               legend
%               line_color (cell array)
%               line_style (cell array)
%               line_width (array)
%               hline
%           ax = axes to plot on
% OUTPUTS:
%           ax = plot axes
%
% Adam Narai, RCNS HAS, 2019

% Defaults
cfg = set_cfg_default(cfg, 'title', '');
cfg = set_cfg_default(cfg, 'x_label', 'Time (ms)');
cfg = set_cfg_default(cfg, 'y_label', 'Amplitude');
cfg = set_cfg_default(cfg, 'x_lim', [cfg.times(1) cfg.times(end)]);
cfg = set_cfg_default(cfg, 'y_lim', []);
cfg = set_cfg_default(cfg, 'legend', []);
cfg = set_cfg_default(cfg, 'line_color', cell(1,size(data,2)));
cfg = set_cfg_default(cfg, 'line_style', repmat({'-'},1,size(data,2)));
cfg = set_cfg_default(cfg, 'line_width', repmat(2,1,size(data,2)));
cfg = set_cfg_default(cfg, 'hline', 0);
if nargin < 3
    ax = axes();
end

% Plot ERP
for i = 1:size(data,2)
    hold(ax, 'on');
    h = plot(ax, cfg.times, data(:,i), 'linewidth', cfg.line_width(i), 'LineStyle', cfg.line_style{i});
    if ~isempty(cfg.line_color{i})
        h.Color = cfg.line_color{i};
    end
    hold(ax, 'off');
end

% Plot zero lines
if cfg.hline
    line(ax, [cfg.times(1), cfg.times(end)], [0 0], 'LineStyle', ':', 'Color', 'k', 'LineWidth', 1);
end

% Plot properties
box(ax, 'off');
if ~isempty(cfg.legend)
    legend(ax, cfg.legend, 'Box', 'off');
end

xlim(cfg.x_lim);
if ~isempty(cfg.y_lim)
    ylim(cfg.y_lim);
end

title(cfg.title);

xlabel(cfg.x_label);
ylabel(cfg.y_label);