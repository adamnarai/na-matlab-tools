% Plot space-time t/F values on horizontal plot
% may need to run limo_eeg beforehand
function mainfig = horizontal_limo_figures_with_topoplot()
start_script();
close all
add_subpath('bin/external/othercolor');

WorkPath = get_work_path();
ResultsDir = [WorkPath, filesep, 'results'];
GlmDir = [ResultsDir, filesep, 'GLM_lp_35'];

filepath{1} = [GlmDir, filesep, 'ANCOVA8_t_lp_35_saccamp_0_26_one_sample/contr/contrast_[-1 4 -1 -1 -1]'];
filepath{2} = [GlmDir, filesep, 'ANCOVA8_t_lp_35_saccamp_0_26_one_sample/dys/contrast_[-1 4 -1 -1 -1]'];
% 
filepath{1} = [GlmDir, filesep, 'MLR8_t_lp_35_saccamp_0_26_one_sample/contr/spacing'];
filepath{2} = [GlmDir, filesep, 'MLR8_t_lp_35_saccamp_0_26_one_sample/dys/spacing'];
% filepath{2} = [GlmDir, filesep, 'MLR8_t_lp_35_none_two_samples/spacing'];
% % %
filepath{1} = [GlmDir, filesep, 'MLR8_2  3  4  5_t_lp_35_saccamp_0_26_one_sample/contr/spacing'];
filepath{2} = [GlmDir, filesep, 'MLR8_2  3  4  5_t_lp_35_saccamp_0_26_one_sample/dys/spacing'];
% % filepath{2} = [GlmDir, filesep, 'MLR8_2  3  4  5_t_lp_35_none_two_samples/spacing'];
%
% filepath{1} = [GlmDir, filesep, 'ANCOVA8_t_lp_35_none_one_sample/contr/contrast_[0 1 -1 0 0]'];
% filepath{2} = [GlmDir, filesep, 'ANCOVA8_t_lp_35_none_one_sample/dys/contrast_[0 1 -1 0 0]'];
%
% filepath{1} = 'G:/EEG_results_save_181016/limo_time/2nd_level_results/original/ANCOVA7_orig/LIMO_2nd_lvl/contr';
% filepath{2} = 'G:/EEG_results_save_181016/limo_time/2nd_level_results/original/MLR7_orig/LIMO_2nd_lvl/parameter_1';

% filepath{1} = [ResultsDir, filesep, 'GLM', filesep, 'ANCOVA8_tf_baseline_one_sample/contr/contrast_[-1 4 -1 -1 -1]'];
% filepath{2} = [ResultsDir, filesep, 'GLM', filesep, 'ANCOVA8_tf_baseline_one_sample/dys/contrast_[-1 4 -1 -1 -1]'];
%
% filepath{1} = [ResultsDir, filesep, 'GLM', filesep, 'MLR8_tf_evoked_one_sample/O10PO10P10O2PO8P8PO4P6P4O9PO9P9O1PO7P7PO3P5P3/dys/spacing'];
% filepath{2} = [ResultsDir, filesep, 'GLM', filesep, 'MLR8_tf_evoked_one_sample/O10PO10P10O2PO8P8PO4P6P4O9PO9P9O1PO7P7PO3P5P3/dys/spacing'];
%
% filepath{1} = 'G:\EEG_results_save_181016\limo_time\2nd_level_outl_results\MLR7_OLS_t_outl\parameter_1';
% filepath{2} = 'G:\EEG_results_save_181016\limo_time\2nd_level_outl_results\MLR7_OLS_t_outl_pca\parameter_7';

% filepath{1} = [GlmDir, filesep, 'ANCOVA9_t_allCurrSacc_lp_35_one_sample/contr/contrast_[-1 4 -1 -1 -1]'];
% filepath{2} = [GlmDir, filesep, 'ANCOVA9_t_allCurrSacc_lp_35_one_sample/dys/contrast_[-1 4 -1 -1 -1]'];

% filepath{1} = [GlmDir, filesep, 'ANCOVA9_t_allCurrSacc_lp_35_one_sample/contr/currSaccAngleCos'];
% filepath{2} = [GlmDir, filesep, 'ANCOVA9_t_allCurrSacc_lp_35_one_sample/dys/currSaccAngleCos'];
% filepath{2} = [GlmDir, filesep, 'ANCOVA9_t_allCurrSacc_lp_35_two_samples/currSaccAngleCos'];
covParam = 1;

titles{1} = 'Control';
titles{2} = 'Dyslexic';

trim = [100 400];
correction = 3;
correction_2 = 2;    % background, omitted if empty
alpha = 0.3;
endCh = 64;
startCh = 1;
oneSided = 0;
zeroLine = 0;
isBaseLine = 0;

% ANCOVA contr vs dys
trim = [100 400];
Dirs = {filepath{1} filepath{1} filepath{2} filepath{2}};
topoTitles = {'' '' '' ''};
timePoints = [135 250 135 250];

% MLR contr vs dys
trim = [170 210];
Dirs = {filepath{1} filepath{1} filepath{2} filepath{2}};
topoTitles = {'' '' '' ''};
timePoints = [200 200 200 200];

% MLR 2:5 contr vs dys
trim = [100 400];
Dirs = {filepath{1} filepath{1} filepath{2} filepath{2}};
topoTitles = {'' '' '' ''};
timePoints = [130 240 130 240];

colors = flipud(othercolor('RdBu11',100));
if oneSided
    colors = colors(1:size(colors,1)/2,:);
end

chsize = (endCh-startCh+1)/62;
figwidth = 1400;
widthratio = figwidth/1000;

if isempty(correction_2)
    typeList = 1;
else
    typeList = 1:2;
end
for type = typeList
    for i = 1:2
        nameStrings = {'one_sample_ttest_parameter_',...
            'two_samples_ttest_parameter_', 'Covariate_effect_'};
        
        if ~isempty(trim)
            trimStr = ['_', num2str(trim(1)), '_', num2str(trim(2))];
            handles.start_time_val = trim(1);
            handles.end_time_val = trim(2);
        else
            trimStr = '';
            handles.start_time_val = NaN;
            handles.end_time_val = NaN;
        end
        
        handles.p = 0.05;
        if type == 1
            handles.MCC = correction;
        elseif type == 2
            handles.MCC = correction_2;
        end
        handles.bootstrap = 0;
        handles.tfce = 0;
        
        fileList = dir(filepath{i});
        fileList = {fileList.name};
        for fileIdx = 1:numel(fileList)
            FileName = fileList{fileIdx};
            PathName = filepath{i};
            
            found = 0;
            for samp = 1:numel(nameStrings)
                N = length(nameStrings{samp});
                if length(FileName) >= N
                    if strcmp(FileName(1:N), nameStrings{samp})
                        found = 1;
                        break
                    end
                end
            end
            
            if found
                handles.dir = PathName;
                display_limo_fig(FileName, PathName, handles);
                break
            end
        end
        
        cd(filepath{i});
        load LIMO
        LIMO.cache.fig.MCC
        times = LIMO.data.times;
        chanLabels = {LIMO.data.chanlocs.labels};
        
        stats{i} = LIMO.cache.fig.stats;
        mask{i} = LIMO.cache.fig.mask;
        
        figList{i}{type} = figure;
        pos = get(gcf, 'position');
        set(gcf, 'position', [pos(1) pos(2) figwidth 210]);
        
        chans = startCh:endCh;
        toPlot = stats{i}.*mask{i};
        
        image = imagesc([startCh endCh],[trim(1) trim(2)],toPlot');
        set(gca,'YDir','normal')
        if type == 1
            a = 1;
        else
            a = alpha;
        end
        set(image,'AlphaData',a*mask{i}');
        colormap(colors);
        colorbar('location', 'manual', 'position', [.1/chsize+.93-.1/chsize+.008*widthratio .18 .012/widthratio .75],...
            'units', 'normalized', 'linewidth', 0.01);
        
        maxvalue(i+(type-1)*2) = max(abs([min(toPlot(:)),max(toPlot(:))]));
        
        set(gca,'XTick', startCh:endCh);
        set(gca,'XTickLabel', chanLabels(startCh:endCh));
        set(gca,'TickLength',[0 1])
        
        %     set(gca,'YAxisLocation','right');
        
        ax = ancestor(image, 'axes');
        %     xrule = ax.XAxis;
        %     xrule.FontSize = 8;
        ax.XTickLabelRotation = 90;
        if zeroLine
            line(get(ax,'XLim'),[0 0],'Color','k', 'LineStyle', '--')
        end
        
        %     title(titles{i});
        if isBaseLine
            ylabel('Frequency [Hz]');
        else
            ylabel('Time (ms)');
        end
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
for type = flip(typeList)
    for i = 1:2
        c = max(maxvalue);
        ax = get(figList{i}{type},'children');
        caxis(ax(2), [-c c]);
        
        ax = get(figList{i}{type},'children');
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

text(ax(2), -0.09, 0.5, titles{1}, 'units', 'normalized', 'rotation', 90,...
    'horizontalalignment', 'center', 'fontsize', 14, 'fontweight', 'bold');
text(ax(1), -0.09, 0.5, titles{2}, 'units', 'normalized', 'rotation', 90,...
    'horizontalalignment', 'center', 'fontsize', 14, 'fontweight', 'bold');

if endCh == 62
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
    load([Dirs{topoIdx}, filesep, 'one_sample_ttest_parameter_', num2str(covParam)]);
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
