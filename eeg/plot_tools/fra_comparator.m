function fra_comparator(data, cfg)
% cfg.var_name_list = eeg_var_name;
% cfg.var_idx_list = eeg_idx;
% cfg.chanlocs = chanlocs;
% cfg.is_li = is_li;
% cfg.left_cluster = left_cluster;
% cfg.right_cluster = right_cluster;
% cfg.subj_codes = subj_code_list;
% cfg.times = p.times;

% Get LI chanlocs
locations = pair_channels(cfg.chanlocs, 0.1);
chanlocs_li = cfg.chanlocs;
chanlocs_li(locations.center) = [];

% Get subject idx
data_subj_idx = ismember(data.Properties.RowNames, cfg.subj_codes);

% Create figure
fig = figure('Position', [100 100 1000 800]);
ax_1 = subplot(4,1,1:3);
if numel(cfg.var_name_list) == 2
    ax_2 = subplot(4,1,4);
end
color.b = [0.12, 0.38, 0.66];
color.r = [0.80, 0.15, 0.15];

% Get channel idx
if ~cfg.is_li
    left_cluster_idx = find(ismember({cfg.chanlocs.labels}, cfg.left_cluster));
    right_cluster_idx = find(ismember({cfg.chanlocs.labels}, cfg.right_cluster));
else
    left_cluster_idx = [];
    right_cluster_idx = find(ismember({chanlocs_li.labels}, cfg.right_cluster));
end

legend_list = {};
for i = 1:numel(cfg.var_name_list)
    % Get group data
    if ~cfg.is_li
        temp_data = cellfun(@(x) x(:,:,cfg.var_idx_list(i)), data{data_subj_idx, cfg.var_name_list{i}}, 'UniformOutput', false);
        eeg{i} = mean(cat(3, temp_data{:}), 3);
    else
        temp_data = cellfun(@(x) x(:,:,cfg.var_idx_list(i)), data{data_subj_idx, cfg.var_name_list{i}}, 'UniformOutput', false);
        if 2*size(temp_data{1}, 1) == numel(chanlocs_li)
            % Only right half is present
            temp_data = cellfun(@(x) mirror_half_LI(x, cfg.chanlocs), temp_data, 'UniformOutput', false);
        elseif size(temp_data{1}, 1) ~= numel(chanlocs_li)
            error('Mismatch between LI data and canlocs.');
        end
        eeg{i} = mean(cat(3, temp_data{:}), 3);
    end
    
    % Get cluster average erp
    left_erp{i} = mean(eeg{i}(left_cluster_idx,:),1);
    right_erp{i} = mean(eeg{i}(right_cluster_idx,:),1);
    
    % Plot erp
    hold(ax_1, 'on');
    switch i
        case 1
            if ~cfg.is_li
                plot(ax_1, cfg.times, left_erp{i}, 'color', color.r, 'linewidth', 2);
            end
            plot(ax_1, cfg.times, right_erp{i}, 'color', color.b, 'linewidth', 2);
        case 2
            if ~cfg.is_li
                plot(ax_1, cfg.times, left_erp{i}, 'color', color.r, 'linewidth', 2, 'LineStyle', '--');
            end
            plot(ax_1, cfg.times, right_erp{i}, 'color', color.b, 'linewidth', 2, 'LineStyle', '--');
        otherwise
            error('Too many analysis types.');
    end
    hold(ax_1, 'off');
    legend_list = {legend_list{:}, ['left  ', cfg.var_name_list{i}], ['right  ', cfg.var_name_list{i}]};
    xlim(ax_1, [cfg.times(1), cfg.times(end)]);
end

xlabel(ax_1, 'Time (ms)');
ylabel(ax_1, 'Amplitude');
box(ax_1, 'on');
ax_1.LineWidth = 1;
legend(ax_1, legend_list, 'Interpreter', 'none', 'Box', 'off');
title(ax_1, ['Clusters: ', strjoin(cfg.left_cluster, '+'), '   ', strjoin(cfg.right_cluster, '+')]);

if numel(cfg.var_name_list) == 2
    hold(ax_2, 'on');
    if ~cfg.is_li
        plot(ax_2, cfg.times, left_erp{2}-left_erp{1}, 'color', color.r, 'linewidth', 2);
    end
    plot(ax_2, cfg.times, right_erp{2}-right_erp{1}, 'color', color.b, 'linewidth', 2);
    line(ax_2, [cfg.times(1), cfg.times(end)], [0 0], 'Color', 'k', 'LineStyle', '--');
    hold(ax_2, 'off');
    xlim(ax_2, [cfg.times(1), cfg.times(end)]);
    ylabel(ax_2, [cfg.var_name_list{2}, ' - ', char(10), cfg.var_name_list{1}, ' diff'], 'Interpreter', 'none');
end

% Topoplot mouse event
topo_code = [...
    'dat = get(gcf, ''userdata'');',...
    'pt = get(gca,''CurrentPoint'');',...
    'time = round(pt(1));',...
    '[~,idx] = min(abs(dat.times-time));',...
    'if numel(dat.eeg) == 2 clim = max(abs([dat.eeg{1}(:,idx);dat.eeg{2}(:,idx)])); end;',...
    'for i = 1:numel(dat.eeg)',...
    'axes(dat.topo_ax{i});',...
    'topoplot(dat.eeg{i}(:,idx), dat.chanlocs,''style'',''map'',''whitebk'',''on'',''headrad'',0.66,''electrodes'',''off'',''emarker2'',{dat.ch_idx,''.'',''k'',14,1});',...
    'title([num2str(round(time)), '' ms'']);',...
    'if numel(dat.eeg) == 2 caxis([-clim clim]); end;',...
    'end;'];

set(fig,'WindowButtonDownFcn', topo_code);
topo_ax{1} = axes('units', 'normalized', 'position', [0.13 0.74 0.15 0.15]);
colormap(topo_ax{1}, flip(othercolor('RdBu11', 100)));
if numel(cfg.var_name_list) == 2
    topo_ax{2} = axes('units', 'normalized', 'position', [0.13 0.35 0.15 0.15]);
    colormap(topo_ax{2}, flip(othercolor('RdBu11', 100)));
end

dat.eeg = eeg;
dat.topo_ax = topo_ax;
if ~cfg.is_li
    dat.chanlocs = cfg.chanlocs;
else
    dat.chanlocs = chanlocs_li;
end
dat.ch_idx = [left_cluster_idx, right_cluster_idx];
dat.times = cfg.times;
set(fig, 'userdata', dat);
for i = 1:numel(topo_ax)
    axes(topo_ax{i})
    topoplot(zeros(numel(dat.chanlocs),1), dat.chanlocs,...
        'style','map',...
        'whitebk','on',...
        'headrad',0.66,...
        'electrodes','off',...
        'emarker2',{dat.ch_idx,'.','k',14,1}...
        );
end
end