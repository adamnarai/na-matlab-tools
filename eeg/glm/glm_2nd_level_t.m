function glm_2nd_level_t(cfg, data)
if cfg.model == 0
    if isempty(cfg.contrast)
        Y{1} = squeeze(mean(data{1},4));
        Y{2} = squeeze(mean(data{2},4));
    else
        cfg.out_dir = [cfg.out_dir, 'contrast_', mat2str(cfg.contrast)];
        Y{1} = mean(data{1},3);
        Y{2} = mean(data{2},3);
    end
    create_dir(cfg.out_dir);
    save([cfg.out_dir, filesep, 'Y'], 'Y');
    save([cfg.out_dir, filesep, 'chanlocs'], 'chanlocs');
elseif cfg.model == 1
    LIMO = set_limo_2nd_lvl_def(cfg);
    for gpcond = cfg.gpcond
        for var_num = cfg.covariates
            if isempty(cfg.contrast)
                Y{gpcond} = squeeze(data{gpcond}(:,:,var_num,:));
                LIMO.dir = [cfg.out_dir, filesep, cfg.gpcond_name{gpcond}, filesep, cfg.var_names{var_num}];
            else
                Y{gpcond} = squeeze(data{gpcond});
                LIMO.dir = [cfg.out_dir, filesep, cfg.gpcond_name{gpcond}, filesep, 'contrast_', mat2str(cfg.contrast)];
            end
            create_dir(LIMO.dir);
            one_sample_t(LIMO, Y{gpcond}, var_num);
            save_p(cfg, LIMO.dir);
        end
    end
elseif cfg.model == 2
    LIMO = set_limo_2nd_lvl_def(EEG, chanlocs, channeighbstructmat, cfg.model);
    clear EEG
    for var_num = cfg.covariates
        if isempty(cfg.contrast)
            Y{1} = squeeze(data{1}(:,:,var_num,:));
            Y{2} = squeeze(data{2}(:,:,var_num,:));
            LIMO.dir = [cfg.out_dir, filesep, cfg.var_names{var_num}];
        else
            Y{1} = squeeze(data{1});
            Y{2} = squeeze(data{2});
            LIMO.dir = [cfg.out_dir, filesep, 'contrast_', mat2str(cfg.contrast)];
        end
        create_dir(LIMO.dir);
        two_samples_t(LIMO, Y{1}, Y{2}, var_num);
        save_p(cfg, LIMO.dir);
    end
elseif cfg.model == 3
    LIMO = set_limo_2nd_lvl_def(EEG, chanlocs, channeighbstructmat, cfg.model);
    clear EEG
    for gpcond = cfg.gpcond
        for var_num = cfg.covariates
            if isempty(cfg.contrast)
                Y{gpcond} = squeeze(data{gpcond}(:,:,var_num,:));
                LIMO.dir = [cfg.out_dir, filesep, cfg.gpcond_name{gpcond}, filesep,...
                    cfg.var_names{var_num}, filesep, regressorName];
            else
                Y{gpcond} = squeeze(data{gpcond});
                LIMO.dir = [cfg.out_dir, filesep, cfg.gpcond_name{gpcond}, filesep,...
                    'contrast_', mat2str(cfg.contrast), filesep, regressorName];
            end
            create_dir(LIMO.dir);
            regression_t(LIMO, Y{gpcond}, Cont{gpcond}, var_num);
            save_p(cfg, LIMO.dir);
        end
    end
elseif cfg.model == 4
    for gpcond = cfg.gpcond
        for var_num = cfg.covariates
            
            % Filter subjects
            if cfg.regr_filter.filter
                keep = cfg.regr_filter.values{gpcond} > cfg.regr_filter.lower &...
                    cfg.regr_filter.values{gpcond} < cfg.regr_filter.upper;
                
                Cont{gpcond}(~keep) = [];
                if isempty(cfg.contrast)
                    data{gpcond}(:,:,:,~keep) = [];
                else
                    data{gpcond}(:,:,~keep) = [];
                end
                filtStr = ['_', cfg.regr_filter.name, '_', num2str(cfg.regr_filter.lower), '_', num2str(cfg.regr_filter.upper)];
            end
            if isempty(cfg.contrast)
                Y{gpcond} = squeeze(mean(mean(squeeze(data{gpcond}(:,:,var_num,:)))));
                SubOutDir = [cfg.out_dir, filesep, regressorName, filesep, cfg.var_names{var_num}];
            else
                Y{gpcond} = squeeze(mean(mean(data{gpcond})));
                contrStr = mat2str(cfg.contrast);
                SubOutDir = [cfg.out_dir, filesep, regressorName, filesep, 'contrast_', contrStr(2:end-1)];
            end
            
            if cfg.regr_filter.filter
                SubOutDir = [SubOutDir, filtStr];
            end
            TablePath = [SubOutDir, filesep, 'clustRegTable.xls'];
            ScatterDir = [SubOutDir, filesep, 'scatterplots'];
            create_dir(ScatterDir);
            
            Group = {cfg.gpcond_name{gpcond}};
            Regressor = {regressorName};
            Channels = {[cfg.channels{:}]};
            TimeStart = cfg.trim_time(1);
            TimeEnd = cfg.trim_time(2);
            
            % Remove NaN samples
            nanIdx = isnan(Cont{gpcond});
            nanIdx = sum(nanIdx, 2) > 0;
            Cont{gpcond}(nanIdx,:) = [];
            Y{gpcond}(nanIdx,:) = [];
            [r, ~, ~, outid, hboot, CI] = skipped_correlation(Cont{gpcond}, Y{gpcond}, 0);
            
            R_P = r.Pearson;
            R_S = r.Spearman;
            h_P = hboot.Pearson;
            h_S = hboot.Spearman;
            CI_P1 =  CI.Pearson(1);
            CI_P2 =  CI.Pearson(2);
            CI_S1 =  CI.Spearman(1);
            CI_S2 =  CI.Spearman(2);
            outliers = {num2str(outid{:})};
            
            if exist(TablePath, 'file')
                clustRegTable = readtable(TablePath);
                figNum = size(clustRegTable, 1)+1;
            else
                figNum = 1;
            end
            figName = {['scatter_', num2str(figNum)]};
            subjNum = numel(Cont{gpcond});
            T = table(Group, Regressor, Channels, TimeStart, TimeEnd,...
                R_P, CI_P1, CI_P2, h_P, R_S, CI_S1, CI_S2, h_S, outliers, figName, subjNum);
            
            if exist(TablePath, 'file')
                clustRegTable = [clustRegTable; T];
            else
                create_dir(SubOutDir);
                T.outliers{1} = ['0 0 ', T.outliers{1}];    % bugfix
                clustRegTable = T;
            end
            
            fig = figure(figNum);
            scatter(Cont{gpcond}, Y{gpcond});
            lsline
            savefig(fig, [ScatterDir, filesep, figName{1}]);
            close(fig);
            
            writetable(clustRegTable, TablePath);
            save_p(cfg, SubOutDir);
        end
    end
    elseif cfg.model == 5
        LIMO = set_limo_2nd_lvl_def(EEG, chanlocs, channeighbstructmat, cfg.model);
        clear EEG
        for gpcond = cfg.gpcond
            if isempty(cfg.contrast)
                Y{1} = squeeze(data{gpcond}(:,:,cfg.covariate_pair(1),:));
                Y{2} = squeeze(data{gpcond}(:,:,cfg.covariate_pair(2),:));
                LIMO.dir = [cfg.out_dir, filesep, cfg.gpcond_name{gpcond}, filesep, 'pair_', num2str(cfg.covariate_pair)];
            else
                error('No contrast paired t test implemented.');
            end
            create_dir(LIMO.dir);
            paired_t(LIMO, Y{1}, Y{2}, 1);
            save_p(cfg, LIMO.dir);
        end
else
    error('Invalid model number');
end
end_script();

function one_sample_t(LIMO, Yr, varNum)
cd(LIMO.dir);
save LIMO LIMO
limo_random_robust_noquest(1, Yr, varNum, LIMO.design.bootstrap, LIMO.design.tfce);

function two_samples_t(LIMO, Y1, Y2, varNum)
cd(LIMO.dir);
save LIMO LIMO
limo_random_robust_noquest(2, Y1, Y2, varNum, LIMO.design.bootstrap, LIMO.design.tfce);

function paired_t(LIMO, Y1, Y2, varNum)
cd(LIMO.dir);
save LIMO LIMO
limo_random_robust_noquest(3, Y1, Y2, varNum, LIMO.design.bootstrap, LIMO.design.tfce);

function regression_t(LIMO, Yr, X, varNum)
cd(LIMO.dir);
save LIMO LIMO
limo_random_robust_noquest(4, Yr, X, varNum, LIMO.design.bootstrap, LIMO.design.tfce);