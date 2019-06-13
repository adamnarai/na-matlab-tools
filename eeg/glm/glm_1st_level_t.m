function cfg = glm_1st_level_t(cfg, EEG, cat, cont, cov)

% Get chanlocs
chanlocs = EEG.chanlocs;

% Create dir
create_dir(cfg.out_dir);

% Create chanlocs for lateralization
if cfg.mode == 1 || cfg.mode == 2
    locations = pair_channels(chanlocs, 0.1);
    chanlocs([locations.center, locations.left]) = [];
end

% Filter trials
Y = EEG.data(:,:,cfg.valid_trials);
if ~isempty(cat)
    cat = cat(cfg.valid_trials,:);
end
if ~isempty(cont)
    cont = cont(cfg.valid_trials,:);
end
if ~isempty(cov)
    cov = cov(cfg.valid_trials, :);
end
cont = [cont, cov];



%% Preproc
% Baseline (used for alpha)
switch cfg.baseline_mode
    case {'', 'none'}       % no baseline
    case 'rm_t_med'         % full epoch median
        sub_med = nanmedian(Y,2);
        Y = Y-repmat(sub_med, [1 EEG.pnts 1]);
    case 'abs_div_t_med'    % abs + full epoch median
        Y = abs(Y);
        sub_med = nanmedian(Y,2);
        Y = Y./repmat(sub_med, [1 EEG.pnts 1]);
    case 'rm_tri_avg_abs'   % cond avg removed + abs (induced power)
        for cond = cfg.condList
            cond_avg = mean(Y(:,:,condNums == cond),3);
            Y(:,:,condNums == cond) =...
                Y(:,:,condNums == cond) - repmat(cond_avg, [1 1 sum(condNums == cond)]);
        end
        Y = abs(Y);
end

% Moving average (used for alpha)
if ~isempty(cfg.movmean_time) && cfg.movmean_time ~= 0
    Y = movmean(Y, cfg.movmean_time*(EEG.srate/1000), 2);
end

% Lateralization index (LI)
switch cfg.mode
    case 0      % Normal EEG
    case 1      % LI (normalized lateralization)
        right_data = Y(locations.right,:,:);
        Y(locations.right,:,:) = (right_data - Y(locations.left,:,:))...
            ./(abs(right_data) + abs(Y(locations.left,:,:)));
        Y([locations.center, locations.left],:,:) = [];
    case 2      % Lat (lateralization)
        right_data = Y(locations.right,:,:);
        Y(locations.right,:,:) =...
            (right_data - Y(locations.left,:,:));
        Y([locations.center, locations.left],:,:) = [];
    otherwise
        error('Invalid mode number.');
end

%% EEG modeling
if cfg.model == 0         % Average
    create_dir(analysis_path);
    cat = fix_nfo(subjIdx).spacing(validIdx);
    for cond = unique(cat)'
        Betas(:,:,cond) = mean(Y(:,:,cat == cond), 3);
    end
    save([analysis_path, filesep, 'Betas.mat'], 'Betas');
elseif cfg.model == 1     % GLM
    LIMO.data.data_dir            = 'not defined';
    LIMO.data.data                = 'not defined';
    LIMO.data.chanlocs            = chanlocs;
    LIMO.data.sampling_rate       = EEG.srate;
    LIMO.data.Cat                 = cat;
    LIMO.data.Cont                = cont;
    LIMO.data.timevect            = EEG.times;
    LIMO.data.trim1               = 1;
    LIMO.data.trim2               = length(EEG.times);
    LIMO.data.start               = EEG.times(1);
    LIMO.data.end                 = EEG.times(end);
    LIMO.dir                      = cfg.out_dir;
    
    LIMO.Type                     = 'Channels';
    LIMO.design.fullfactorial     = 0;
    LIMO.design.zscore            = 1;
    LIMO.design.method            = 'OLS';
    LIMO.design.type_of_analysis  = 'Mass-univariate';
    LIMO.design.bootstrap         = 0;
    LIMO.design.tfce              = 0;
    LIMO.Level                    = 1;
    LIMO.Analysis                 = 'Time';
    
    run_limo_1st_level(LIMO, Y);
elseif cfg.model == 2     % Residuals of covariate regression
    create_dir(analysis_path);
    Res = nan(size(Y));
    X = [zscore(cont) ones(size(cont,1),1)];
    X_res = [zscore(cont) zeros(size(cont,1),1)];
    for e = 1:size(Y,1)
        for t = 1:size(Y,2)
            Res(e,t,:) = squeeze(Y(e,t,:)) - X_res*regress(squeeze(Y(e,t,:)), X);
        end
    end
    Betas = mean(Res, 3);
    save([analysis_path, filesep, 'Betas.mat'], 'Betas');
else
    error('Invalid model number');
end
