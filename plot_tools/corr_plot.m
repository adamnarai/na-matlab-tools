function ax = corr_plot(cfg, X, Y, outliers)
% CORR_PLOT  Scatterplot with OLS line.
%          
% INPUTS:
%           cfg = config structure
%           X = X data
%           Y = Y data
%           outliers = outlier indices
% OUTPUTS:
%           ax = axes handle for the plot
%
%   cfg fields (all optional):
%       cfg.ax: axes handle
%       cfg.title: plot title
%       cfg.label_list: point labels (strings)
%       cfg.hline: horizontal zero line switch
%       cfg.vline: vertical zero line switch
%       cfg.lsline: OLS line switch
%       cfg.gp_id: group id for data points (integers)
%
% Adam Narai, RCNS HAS, 2019
%

% Defaults
if nargin < 4
    outliers = [];
end
if ~isfield(cfg, 'ax') || isempty(cfg.ax)
    ax = axes();
else
    ax = cfg.ax;
end
if ~isfield(cfg, 'title')
    cfg.title = '';
end
if ~isfield(cfg, 'label_list')
    label_list = {};
else
    label_list = cfg.label_list;
end
if ~isfield(cfg, 'hline')
    cfg.hline = 0;
end
if ~isfield(cfg, 'vline')
    cfg.vline = 0;
end
if ~isfield(cfg, 'lsline')
    cfg.lsline = 1;
end
if ~isfield(cfg, 'gp_id')
    cfg.gp_id = [];
end
if ~isfield(cfg, 'dot_size')
    cfg.dot_size = 40;
end

% Get axis limits
x_margin = (max(X)-min(X))*0.05;
y_margin = (max(Y)-min(Y))*0.05;
x_lim = [min(X)-x_margin, max(X)+x_margin];
y_lim = [min(Y)-y_margin, max(Y)+y_margin];

% Remove outliers
X_outl = X(outliers);
Y_outl = Y(outliers);
X(outliers) = [];
Y(outliers) = [];
if ~isempty(cfg.gp_id)
    gp_id_outl = cfg.gp_id(outliers);
    gp_id = cfg.gp_id;
    gp_id(outliers) = [];
end

% Scatterplot
if isempty(cfg.gp_id)
    scatter(ax, X, Y, cfg.dot_size, 'k', 'filled');
else
    hold on
    scatter(ax, X(gp_id == 1), Y(gp_id == 1), cfg.dot_size, [0 0.4470 0.7410], 'filled');
    scatter(ax, X(gp_id == 2), Y(gp_id == 2), cfg.dot_size, [0.6350 0.0780 0.1840], 'filled');
    scatter(ax, X(gp_id == 3), Y(gp_id == 3), cfg.dot_size, [0.4660 0.6740 0.1880], 'filled');
    hold off
end

% OLS line
if cfg.lsline
    if isempty(cfg.gp_id)   
        h1 = lsline(ax);
        h1.Color = [0.7, 0.7, 0.7];
        h1.LineWidth = 2;
    else
        hold on
        b = regress(Y, [ones(size(X)), X]);
        plot(ax, xlim, xlim*b(2)+b(1), 'LineWidth', 2, 'Color', [0.7, 0.7, 0.7]);
        hold off
    end
end

% Mark values with subject codes
if ~isempty(label_list)
    label_list_outl = label_list(outliers);
    label_list(outliers) = [];
    for i = 1:numel(X)
        text(ax, double(X(i)), double(Y(i)), ['  ', num2str(label_list{i})]);
    end
end

% Plot outliers
hold on
if isempty(cfg.gp_id)
    scatter(ax, X_outl, Y_outl, cfg.dot_size, 'k');
else
    scatter(ax, X_outl(gp_id_outl == 1), Y_outl(gp_id_outl == 1), cfg.dot_size, [0 0.4470 0.7410]);
    scatter(ax, X_outl(gp_id_outl == 2), Y_outl(gp_id_outl == 2), cfg.dot_size, [0.6350 0.0780 0.1840]);
    scatter(ax, X_outl(gp_id_outl == 3), Y_outl(gp_id_outl == 3), cfg.dot_size, [0.4660 0.6740 0.1880]);
end
hold off

% Label outliers
if ~isempty(label_list) && ~isempty(label_list_outl)
    for i = 1:numel(X_outl)
        text(ax, double(X_outl(i)), double(Y_outl(i)), ['  ', num2str(label_list_outl{i})]);
    end
end

% Title
title(ax, cfg.title, 'FontSize', 12);

% Axis labels
xlabel(ax, cfg.xlabel, 'Interpreter', 'none');
ylabel(ax, cfg.ylabel, 'Interpreter', 'none');

% Zero lines
if cfg.hline
    if xor(ax.YLim(1) >= 0, ax.YLim(2) >= 0)
        line(ax, ax.XLim, [0 0], 'linestyle', ':', 'color', 'k');
    end
end
if cfg.vline
    if xor(ax.XLim(1) >= 0, ax.XLim(2) >= 0)
        line(ax, [0 0], ax.YLim, 'linestyle', ':', 'color', 'k');
    end
end

% Axis limits
xlim(x_lim);
ylim(y_lim);
end
