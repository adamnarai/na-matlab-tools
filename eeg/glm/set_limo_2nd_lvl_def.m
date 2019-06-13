function LIMO = set_limo_2nd_lvl_def(cfg)
LIMO.data.data_dir            = 'not specified';
LIMO.data.data                = 'not specified';
LIMO.data.chanlocs            = cfg.chanlocs;
LIMO.data.neighbouring_matrix = cfg.channeighbstructmat;
LIMO.data.sampling_rate       = cfg.srate;
LIMO.data.timevect            = cfg.times;
LIMO.data.trim1               = 1;
LIMO.data.trim2               = length(cfg.times);
LIMO.data.start               = cfg.times(1);
LIMO.data.end                 = cfg.times(end);

LIMO.design.bootstrap   = 1000;
LIMO.design.tfce        = 1;
LIMO.design.electrode	= [];
LIMO.design.X           = [];
LIMO.design.method      = 'Trimmed means';
LIMO.Level              = 2;
LIMO.Type               = 'Channels';
LIMO.Analysis           = 'Time';
switch cfg.model
    case 1
        LIMO.design.name        = 'one sample t-test all Channels';
    case 2
        LIMO.design.name        = 'two samples t-test all electrodes';
    case 3
        LIMO.design.name        = 'regression analysis';
    case 5
        LIMO.design.name        = 'paired t-test all Channels';
end