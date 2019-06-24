function glm_1st_level_t(cfg, EEG, Cat, Cont)
% GLM_1ST_LEVEL_T  Space-time domain 1st level LIMO GLM.
%
% INPUT:
%           cfg = config structure
%           EEG = EEGLAB structure
%           Cat = Nx1 vector with categorical variables in one column
%           Cont = matrix with continuous variables in columns
%
%   cfg fields:
%       cfg.out_dir: full path of output directory
%       cfg.model: 1st level glm model (0: AVG, 1: GLM, 2: regr out)
%       cfg.mode: data mode (0: FRA, 1: LI, 2: Lat)
%       cfg.valid_trials: valid EEG trials (typically based on covariate
%               filtering)
%       cfg.baseline_mode: ''/none, rm_t_med, abs_div_t_med, rm_tri_avg_abs
%       cfg.cond_list: numeric vector of condition numbers (first col in cat)
%       cfg.movmean_time: movemean time in ms ([] and 0 means no movemean)
%
% Adam Narai, RCNS HAS, 2019
%

% Get chanlocs and create out dir
chanlocs = EEG.chanlocs;
create_dir(cfg.out_dir);

% Create chanlocs for lateralization
if cfg.mode == 1 || cfg.mode == 2
    locations = pair_channels(chanlocs, 0.1);
    chanlocs([locations.center, locations.left]) = [];
end

% Filter trials
Y = EEG.data(:,:,logical(cfg.valid_trials));
if ~isempty(Cat)
    Cat = Cat(logical(cfg.valid_trials),:);
end
if ~isempty(Cont)
    Cont = Cont(logical(cfg.valid_trials),:);
end

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
        for cond = cfg.cond_list
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
    if ~isempty(Cat)
        for cond = unique(Cat)'
            Betas(:,:,cond) = mean(Y(:,:,Cat == cond), 3);
        end
    else
        Betas = mean(Y, 3);
    end
    save([cfg.out_dir, filesep, 'Betas.mat'], 'Betas');
    
    % Save params in LIMO struct for 2nd level
    LIMO.data.chanlocs            = chanlocs;
    LIMO.data.sampling_rate       = EEG.srate;
    LIMO.data.timevect            = EEG.times;
    LIMO.data.trim1               = 1;
    LIMO.data.trim2               = length(EEG.times);
    LIMO.data.start               = EEG.times(1);
    LIMO.data.end                 = EEG.times(end);
    LIMO.dir                      = cfg.out_dir;
    LIMO.Type                     = 'Channels';
    LIMO.Level                    = 1;
    LIMO.Analysis                 = 'Time average';
    save([cfg.out_dir, filesep, 'LIMO.mat'], 'LIMO');
elseif cfg.model == 1     % GLM
    LIMO.data.data_dir            = 'not defined';
    LIMO.data.data                = 'not defined';
    LIMO.data.chanlocs            = chanlocs;
    LIMO.data.sampling_rate       = EEG.srate;
    LIMO.data.Cat                 = Cat;
    LIMO.data.Cont                = Cont;
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
    Res = nan(size(Y));
    X = [zscore(Cont) ones(size(Cont,1),1)];
    X_res = [zscore(Cont) zeros(size(Cont,1),1)];
    for e = 1:size(Y,1)
        for t = 1:size(Y,2)
            Res(e,t,:) = squeeze(Y(e,t,:)) - X_res*regress(squeeze(Y(e,t,:)), X);
        end
    end
    Betas = mean(Res, 3);
    save([cfg.out_dir, filesep, 'Betas.mat'], 'Betas');
    
    % Save params in LIMO struct for 2nd level
    LIMO.data.chanlocs            = chanlocs;
    LIMO.data.sampling_rate       = EEG.srate;
    LIMO.data.timevect            = EEG.times;
    LIMO.data.trim1               = 1;
    LIMO.data.trim2               = length(EEG.times);
    LIMO.data.start               = EEG.times(1);
    LIMO.data.end                 = EEG.times(end);
    LIMO.dir                      = cfg.out_dir;
    LIMO.Type                     = 'Channels';
    LIMO.Level                    = 1;
    LIMO.Analysis                 = 'Time, manual regr out';
    save([cfg.out_dir, filesep, 'LIMO.mat'], 'LIMO');
else
    error('Invalid model number');
end
