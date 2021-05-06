function glm_2nd_level_t(cfg, data)
% GLM_2nd_LEVEL_T  Space-time domain 2nd level LIMO GLM.
%
% INPUT:
%           cfg = config structure
%           data = Betas matrix [ch x times x vars x subj] or 
%               [ch x times x subj] for contrast
%
%   cfg fields:
%       cfg.out_dir: full path of output directory
%       cfg.model: 2nd level glm model (0: AVG, 1: One-sample T, 2: two-samples T)
%       cfg.contrast: applied contrast (empty if none)
%       cfg.gpcond: list of groups (integers)
%       cfg.gpcond_name: group names (strings)
%       cfg.covariates: variable indices to test (integers)
%       cfg.var_names: variable names (strings)
%
% Adam Narai, RCNS HAS, 2019
%

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
        
        % Save dummy LIMO struct for parameters
        LIMO = set_limo_2nd_lvl_def(cfg);
        save([cfg.out_dir, filesep, 'LIMO'], 'LIMO');
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
    case 3  % paired T
        LIMO = set_limo_2nd_lvl_def(cfg);
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
    otherwise
        error('Invalid model number');
end

function one_sample_t(LIMO, Yr, varNum)
cd(LIMO.dir);
save LIMO LIMO
limo_random_robust(1, Yr, varNum, LIMO.design.bootstrap, LIMO.design.tfce);

function paired_t(LIMO, Y1, Y2, varNum)
cd(LIMO.dir);
save LIMO LIMO
limo_random_robust(3, Y1, Y2, varNum, LIMO.design.bootstrap, LIMO.design.tfce);
