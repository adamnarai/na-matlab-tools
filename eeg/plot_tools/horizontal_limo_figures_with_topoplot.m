% Plot space-time t values on horizontal plot
function mainfig = horizontal_limo_figures_with_topoplot(cfg)
add_subpath('bin/external/othercolor');
root = fileparts(which('limo_eeg'));
addpath([root filesep 'limo_cluster_functions'])
addpath([root filesep 'external'])
addpath([root filesep 'external' filesep 'psom'])
addpath([root filesep 'external' filesep 'othercolor'])
addpath([root filesep 'help'])

work_path = get_work_path();
glm_dir = [work_path, '/results/GLM_lp_35'];

% Data
cfg.filepath{1} = [glm_dir, filesep, 'ANCOVA8_t_lp_35_saccamp_0_26_one_sample/contr/contrast_[-1 4 -1 -1 -1]'];
cfg.filepath{2} = [glm_dir, filesep, 'ANCOVA8_t_lp_35_saccamp_0_26_one_sample/dys/contrast_[-1 4 -1 -1 -1]'];

% Space-time plot setup
cfg.titles{1} = 'Control';
cfg.titles{2} = 'Dyslexic';
cfg.trim = [NaN NaN];
cfg.trim = [100 400];
correction = 3;
correction_2 = 2;    % background, omitted if empty
alpha = 0.3;
start_ch = [];
end_ch = [];
one_sided = 0;
zeroLine = 0;
isBaseLine = 0;

% Topoplot setup
Dirs = {cfg.filepath{1} cfg.filepath{1} cfg.filepath{2} cfg.filepath{2}};
topoTitles = {'' '' '' ''};
timePoints = [135 250 135 250];

% Colormap
colors = flipud(othercolor('RdBu11',100));
if one_sided
    colors = colors(1:size(colors,1)/2,:);
end

figwidth = 1400;
widthratio = figwidth/1000;

if isempty(correction_2)
    mcc_type_list = 1;
else
    mcc_type_list = 1:2;
end
for mcc_type = mcc_type_list
    handles.start_time_val = cfg.trim(1);
    handles.end_time_val = cfg.trim(2);
    handles.p = 0.05;
%     handles.bootstrap = 0;
%     handles.tfce = 0;
    if mcc_type == 1
        handles.MCC = correction;
    elseif mcc_type == 2
        handles.MCC = correction_2;
    end
    
    name_str = {'one_sample_ttest_parameter_', 'two_samples_ttest_parameter_'};
    for res_idx = 1:numel(cfg.filepath)
        % Open limo plots and save to LIMO.cache
        fileList = dir(cfg.filepath{res_idx});
        fileList = {fileList.name};
        for fileIdx = 1:numel(fileList)
            stat_file_name = fileList{fileIdx};
            stat_path_name = cfg.filepath{res_idx};
            
            found = 0;
            for samp = 1:numel(name_str)
                N = length(name_str{samp});
                if length(stat_file_name) >= N
                    if strcmp(stat_file_name(1:N), name_str{samp})
                        found = 1;
                        break
                    end
                end
            end
            
            if found
                handles.dir = stat_path_name;
                display_limo_fig(stat_file_name, stat_path_name, handles);
                break
            end
        end
        
        if ~found
            error(['Stat file not found in ', stat_path_name]);
        end
        
        % Get results data
        cd(cfg.filepath{res_idx});
        load LIMO
        if ~isequal(LIMO.cache.fig.MCC, handles.MCC)
            error(['Expected MCC type ', num2str(handles.MCC), ', found type ', num2str(LIMO.cache.fig.MCC)]);
        end
        times = LIMO.data.times;
        chan_labels = {LIMO.data.chanlocs.labels};
        if isempty(start_ch)
            start_ch = 1;
        end
        if isempty(end_ch)
            end_ch = numel(chan_labels);
        end
        stats{res_idx} = LIMO.cache.fig.stats;
        mask{res_idx} = LIMO.cache.fig.mask;
        to_plot = stats{res_idx}.*mask{res_idx};
        
        fig_list{res_idx}{mcc_type} = figure;
        pos = get(gcf, 'position');
        set(gcf, 'position', [pos(1) pos(2) figwidth 210]);
        
        % Plot
        image = imagesc([start_ch end_ch],[cfg.trim(1) cfg.trim(2)],to_plot');
        set(gca,'YDir','normal')
        if mcc_type == 1
            a = 1;
        else
            a = alpha;
        end
        set(image,'AlphaData',a*mask{res_idx}');
        colormap(colors);
        colorbar('location', 'manual', 'position', [.1+.93-.1+.008*widthratio .18 .012/widthratio .75],...
            'units', 'normalized', 'linewidth', 0.01);
        
        maxvalue(res_idx+(mcc_type-1)*2) = max(abs([min(to_plot(:)),max(to_plot(:))]));
        
        set(gca,'XTick', start_ch:end_ch);
        set(gca,'XTickLabel', chan_labels(start_ch:end_ch));
        set(gca,'TickLength',[0 1])
        
        ax = ancestor(image, 'axes');
        ax.XTickLabelRotation = 90;
        if zeroLine
            line(get(ax,'XLim'),[0 0],'Color','k', 'LineStyle', '--');
        end
        ylabel('Time (ms)');
        set(gca,'fontsize', 11);
    end
end

%% Maps
mainfig = figure;
pos = get(gcf, 'position');

figWidth = .6;
figHeight = .33;
col1Offset = .097;
row1Offset = .62;
row2Offset = .13;
cBarWidth = 0.01;

set(gcf, 'position', [pos(1) pos(2) figwidth 420]);
for mcc_type = flip(mcc_type_list)
    for res_idx = 1:2
        c = max(maxvalue);
        ax = get(fig_list{res_idx}{mcc_type},'children');
        caxis(ax(2), [-c c]);
        
        ax = get(fig_list{res_idx}{mcc_type},'children');
        copyobj(ax(2), mainfig);
    end
end

ax = get(mainfig,'children');
if ~isempty(correction_2)
    set(ax(3), 'position', [col1Offset row2Offset figWidth figHeight], 'units', 'normalized');
    set(ax(4), 'position', [col1Offset row1Offset figWidth figHeight], 'units', 'normalized');
    set(ax(1),'color','none');
    set(ax(2),'color','none');
end
set(ax(1), 'position', [col1Offset row2Offset figWidth figHeight], 'units', 'normalized');
set(ax(2), 'position', [col1Offset row1Offset figWidth figHeight], 'units', 'normalized');

set(ax,'fontsize', 11);
colormap(mainfig, colors);
colorbar(ax(1),'location', 'manual', 'position', [col1Offset+figWidth+cBarWidth row2Offset cBarWidth row1Offset+figHeight-row2Offset],...
    'units', 'normalized', 'linewidth', 0.01);

text(ax(2), -0.09, 0.5, cfg.titles{1}, 'units', 'normalized', 'rotation', 90,...
    'horizontalalignment', 'center', 'fontsize', 14, 'fontweight', 'bold');
text(ax(1), -0.09, 0.5, cfg.titles{2}, 'units', 'normalized', 'rotation', 90,...
    'horizontalalignment', 'center', 'fontsize', 14, 'fontweight', 'bold');

if end_ch == 62
    text(ax(1), 1.02, -0.13, 't', 'units', 'normalized', 'rotation', 0,...
        'horizontalalignment', 'center', 'fontsize', 12);
else % endCh == 64
    text(ax(1), 1.026, -0.13, 't', 'units', 'normalized', 'rotation', 0,...
        'horizontalalignment', 'center', 'fontsize', 12);
end
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
    load([Dirs{topoIdx}, filesep, 'LIMO']);
    load([Dirs{topoIdx}, filesep, stat_file_name]);
    EEG.times = LIMO.data.times/1000;
    EEG.chanlocs = LIMO.data.chanlocs;
    EEG.data = squeeze(one_sample(:,:,4));  % t values
    
    EEG.nbchan = size(EEG.data,1);
    EEG.pnts = size(EEG.data,2);
    EEG.trials = 1;
    EEG.xmin = EEG.times(1);
    EEG.xmax = EEG.times(end);
    
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
    pop_topoplot(EEG, 1, timePoints(topoIdx), '', 0,...
        'gridscale',200,...
        'style','map',...
        'whitebk','on',...
        'headrad',0.64,...
        'electrodes','off',...
        'colorbar','off'...
        );
    %     'emarker2',{find(idx),'.','k'}...
    
    if isBaseLine
        title([topoTitles{topoIdx}, num2str(timePoints(topoIdx)), ' Hz'], 'fontsize', 11);
    else
        title([topoTitles{topoIdx}, num2str(timePoints(topoIdx)), ' ms'], 'fontsize', 11);
    end
    %     'emarker2',{[25 26 28 29 57 61],'.','k'},...
    
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
