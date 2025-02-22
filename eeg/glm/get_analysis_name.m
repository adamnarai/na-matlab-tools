function analysis_name = get_analysis_name(cfg)

switch cfg.model
    case 0
        analysis_name = 'AVG_t';
    case 1
        N = numel(cfg.cov_names) + cfg.use_cont_vars + cfg.use_cat_vars;
        if cfg.use_cont_vars && ~cfg.use_cat_vars
            if isempty(cfg.spec_cond)
                analysis_name = ['MLR', num2str(N), '_t'];
            else
                analysis_name = ['MLR', num2str(N), '_', num2str(cfg.spec_cond), '_t'];
            end
        elseif ~cfg.use_cont_vars && cfg.use_cat_vars
            if isempty(cfg.spec_cond)
                analysis_name = ['ANCOVA', num2str(N), '_t'];
            else
                analysis_name = ['ANCOVA', num2str(N), '_', num2str(cfg.spec_cond), '_t'];
            end
        elseif isempty(cfg.cond_list)   % Only one condition present
            analysis_name = 'REGR_t';
        elseif ~isempty(cfg.spec_cond)
            analysis_name = ['REGR_cond_', num2str(cfg.spec_cond), '_t'];
        else
            error('What kind of analysis is this?');
        end
    case 2
        if isempty(cfg.cond_list)   % Only one condition present
            analysis_name = 'REGROUT_t';
        elseif ~isempty(cfg.spec_cond)
            analysis_name = ['REGROUT_cond_', num2str(cfg.spec_cond), '_t'];
        else
            error('What kind of analysis is this?');
        end
end
switch cfg.mode
    case 0  % Do nothing
    case 1
        analysis_name = [analysis_name, '_LI'];
    case 2
        analysis_name = [analysis_name, '_Lat'];
end
if ~isempty(cfg.baseline_mode)
    analysis_name = [analysis_name, '_', cfg.baseline_mode];
end
if ~isempty(cfg.movmean_time) && cfg.movmean_time ~= 0
    analysis_name = [analysis_name, '_movmean_', num2str(cfg.movmean_time), 'ms'];
end