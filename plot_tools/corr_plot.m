%% Correlation function
function corr_plot(cfg, X, Y, outliers)

% Defaults
if nargin < 4
    outliers = [];
end
if ~isfield(cfg, 'title')
    cfg.title = '';
end
if ~isfield(cfg, 'label_list')
    label_list = {};
else
    label_list = cfg.label_list;
end
if ~isfield(cfg, 'save_path')
    cfg.save_path = '';
end
if ~isfield(cfg, 'hline')
    cfg.hline = 0;
end
if ~isfield(cfg, 'vline')
    cfg.vline = 0;
end
if ~isfield(cfg, 'figsize')
    cfg.figsize = [560 420];
end

% Create figure and axes
fig = figure('position', [100 100 cfg.figsize]);
ax = axes();

% Remove outliers
X_outl = X(outliers);
Y_outl = Y(outliers);
X(outliers) = [];
Y(outliers) = [];

% Scatterplot with OLS line
scatter(ax, X, Y, 30, 'b', 'filled');
h1 = lsline(ax);
h1.Color = 'k';
h1.LineWidth = 2;

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
scatter(ax, X_outl, Y_outl, 30, 'r', 'filled');
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

% Save plot
if ~isempty(cfg.save_path)
    savefig(fig, strrep(cfg.save_path, char(10), ''));
end
end
