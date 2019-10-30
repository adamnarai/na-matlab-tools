% Plot space-time t values on horizontal plot
function mainfig = horizontal_limo_figures_merge(cfg)
add_subpath('bin/external/othercolor');
root = fileparts(which('limo_eeg'));
addpath([root filesep 'limo_cluster_functions'])
addpath([root filesep 'external'])
addpath([root filesep 'external' filesep 'psom'])
addpath([root filesep 'external' filesep 'othercolor'])
addpath([root filesep 'help'])

work_path = get_work_path();
colors = flipud(othercolor('RdBu11',100));
filepath{1} = 'ANCOVA8_t_lp_35_saccamp_0_26_one_sample/contr/contrast_[-1 4 -1 -1 -1]';
filepath{2} = 'ANCOVA8_t_lp_35_saccamp_0_26_one_sample/dys/contrast_[-1 4 -1 -1 -1]';

analysis_dirs = {filepath{1} filepath{1} filepath{2} filepath{2}};

% Data
titles{1} = 'Control';
titles{2} = 'Dyslexic';
cfg.analysis_subdir = filepath{1};
cfg.trim = [100 400];
cfg.colorbar_label = ' ';

cfg.MCC = 3;
cfg.plot_alpha = 1;
[fig_handle, min_max_value] = horizontal_limo_figure(cfg);
fig_list{1}{1} = fig_handle;
abs_maxval(1) = max(abs(min_max_value));

cfg.MCC = 2;
cfg.plot_alpha = 0.3;
[fig_handle, min_max_value] = horizontal_limo_figure(cfg);
fig_list{1}{2} = fig_handle;
abs_maxval(2) = max(abs(min_max_value));

cfg.analysis_subdir = filepath{2};
cfg.MCC = 3;
cfg.plot_alpha = 1;
[fig_handle, min_max_value] = horizontal_limo_figure(cfg);
fig_list{2}{1} = fig_handle;
abs_maxval(3) = max(abs(min_max_value));

cfg.MCC = 2;
cfg.plot_alpha = 0.3;
[fig_handle, min_max_value] = horizontal_limo_figure(cfg);
fig_list{2}{2} = fig_handle;
abs_maxval(4) = max(abs(min_max_value));

timePoints = [135 250 135 250];

%% Maps
mainfig = figure;
pos = get(gcf, 'position');

figWidth = .6;
figHeight = .33;
col1Offset = .097;
row1Offset = .62;
row2Offset = .13;
cBarWidth = 0.01;

c = max(abs_maxval);
set(gcf, 'position', [pos(1) pos(2) 1400 420]);
for mcc_type = 1:2
    for res_idx = 1:2
        ax = get(fig_list{res_idx}{mcc_type},'children');
        caxis(ax(2), [-c c]);
        
        ax = get(fig_list{res_idx}{mcc_type},'children');
        copyobj(ax(2), mainfig);
        caxis(ax(2), [-c c]);
    end
end

ax = get(mainfig,'children');
set(ax(3), 'position', [col1Offset row2Offset figWidth figHeight], 'units', 'normalized');
set(ax(4), 'position', [col1Offset row1Offset figWidth figHeight], 'units', 'normalized');
set(ax(1),'color','none');
set(ax(2),'color','none');
set(ax(1), 'position', [col1Offset row2Offset figWidth figHeight], 'units', 'normalized');
set(ax(2), 'position', [col1Offset row1Offset figWidth figHeight], 'units', 'normalized');

set(ax,'fontsize', 11);
colormap(mainfig, colors);
colorbar(ax(1),'location', 'manual', 'position', [col1Offset+figWidth+cBarWidth row2Offset cBarWidth row1Offset+figHeight-row2Offset],...
    'units', 'normalized', 'linewidth', 0.01);

text(ax(2), -0.09, 0.5, titles{1}, 'units', 'normalized', 'rotation', 90,...
    'horizontalalignment', 'center', 'fontsize', 14, 'fontweight', 'bold');
text(ax(1), -0.09, 0.5, titles{2}, 'units', 'normalized', 'rotation', 90,...
    'horizontalalignment', 'center', 'fontsize', 14, 'fontweight', 'bold');

text(ax(1), 1.026, -0.13, 't', 'units', 'normalized', 'rotation', 0,...
    'horizontalalignment', 'center', 'fontsize', 12);
set(findall(gcf,'-property','FontName'),'FontName','Arial');
% close(figList{:});
% set(gcf, 'renderer', 'painters');

%% Topoplots
topoOffset = col1Offset+figWidth+cBarWidth*3;
topoX = topoOffset + 0.01;
topoY = 0.1;
topoW = 0.35;
topoH = 0.35;
topoXdist = 0.12;
topoYdist = 0.45;

for topoIdx = 1:4    
    topoAx(topoIdx) = axes;
    switch topoIdx
        case 1
            set(topoAx(topoIdx), 'position', [topoX-topoXdist topoY+topoYdist topoW topoH], 'units', 'normalized');
        case 2
            set(topoAx(topoIdx), 'position', [topoX topoY+topoYdist topoW topoH], 'units', 'normalized');
        case 3
            set(topoAx(topoIdx), 'position', [topoX-topoXdist topoY topoW topoH], 'units', 'normalized');
        case 4
            set(topoAx(topoIdx), 'position', [topoX topoY topoW topoH], 'units', 'normalized');
    end
    
    cfg.analysis_subdir = analysis_dirs{topoIdx};
    cfg.time_point = timePoints(topoIdx);
    limo_topoplot(cfg);
    
    title([num2str(timePoints(topoIdx)), ' ms'], 'fontsize', 11);
    
    caxis([-c c]);
    colormap(colors);
    set(findall(gcf,'-property','FontName'),'FontName','Arial');
end

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
