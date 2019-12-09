function glm_2nd_level_t(cfg, data)
switch cfg.model
    case 0 % Average
        for gpcond = cfg.gpcond
            if isempty(cfg.contrast)
                Y{gpcond} = squeeze(mean(data{gpcond},4));
            else
                cfg.out_dir = [cfg.out_dir, 'contrast_', mat2str(cfg.contrast)];
                Y{gpcond} = mean(data{gpcond},3);
            end
        end
        create_dir(cfg.out_dir);
        save([cfg.out_dir, filesep, 'Y'], 'Y');
        save([cfg.out_dir, filesep, 'chanlocs'], 'chanlocs');
    case 1 % One-sample T
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
    otherwise
        error('Invalid model number');
end

function one_sample_t(LIMO, Yr, varNum)
cd(LIMO.dir);
save LIMO LIMO
limo_random_robust_noquest(1, Yr, varNum, LIMO.design.bootstrap, LIMO.design.tfce);
