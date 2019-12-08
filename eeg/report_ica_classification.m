function EEG = report_ica_classification(EEG, path, run, cfg)
% REPORT_ICA_CLASSIFICATION  Run IC labeling algorithms and create xls report.
% Used algorithms:
%       ICLabels
%       SASICA (Includes: MARA, ADJUST, FASTER)
%       Saccade/fixation variance ratio
%           
% INPUTS:
%           EEG = eeglab struct
%           path = Path for saving xls report
%           run = 1:run classifications (default)
%           cfg = SASICA cfg structure
% OUTPUTS:
%           EEG = modified eeglab struct
%
% Adam Narai, RCNS HAS, 2018
%
% See also

% Defines
if nargin < 4
    cfg = define_SASICA_cfg();
end
if nargin < 3
    run = 1;
end
if nargin < 2
    path = [];
end

header = {'IC', 'SUM', 'ICLabel', 'ICLabelName', 'MARA',...
    'SASICA', 'ADJUST', 'FASTER'};

% Add ch numbers
report(:,1) = num2cell(1:EEG.nbchan);

% Add ICLabels
if run
    EEG = iclabel(EEG);
end
classes = EEG.etc.ic_classification.ICLabel.classes;
[~, idx] = max(EEG.etc.ic_classification.ICLabel.classifications,[],2);
for ch = 1:EEG.nbchan
    report{ch,3} = double(~strcmp(classes{idx(ch)}, 'Brain'));
    report{ch,4} = classes{idx(ch)};
end

% Run SASICA
if run
    EEG = eeg_SASICA(EEG, cfg);
end
report(:,5) = num2cell(double(EEG.reject.SASICA.icarejMARA'));
report(:,6) = num2cell(double((EEG.reject.SASICA.icarejautocorr)) +...
    double((EEG.reject.SASICA.icarejfocalcomp)) +...
    double((EEG.reject.SASICA.icarejtrialfoc)) +...
    double((EEG.reject.SASICA.icarejSNR)) +...
    double((EEG.reject.SASICA.icarejchancorr)));
report(:,7) = num2cell(double(EEG.reject.SASICA.icarejADJUST'));
report(:,8) = num2cell(double(EEG.reject.SASICA.icarejFASTER'));

% SUM
report(:,2) = num2cell(sum(cell2mat(report(:,[3 5:7])),2));

% Add header
report = [header(:)'; report(:,:)];

% Save xls file
if ~isempty(path)
    if ~isdir(path)
        mkdir(path);
    end
    xlswrite([path, filesep, 'ICA_labeling'], report);
end

%% Functions
function cfg = define_SASICA_cfg()
cfg.MARA.enable = 1;

cfg.FASTER.enable = 1;
cfg.FASTER.blinkchanname = 'AF3';

cfg.ADJUST.enable = 1;

cfg.chancorr.enable = 0;
cfg.chancorr.channames = 'No channel';
cfg.chancorr.corthresh = 'auto 4';

cfg.EOGcorr.enable = 1;
cfg.EOGcorr.Heogchannames = 'No channel';
cfg.EOGcorr.corthreshH = 'auto 4';
cfg.EOGcorr.Veogchannames = 'AF3';
cfg.EOGcorr.corthreshV = 'auto 4';

cfg.resvar.enable = 0;
cfg.resvar.thresh = 15;

cfg.SNR.enable = 1;
cfg.SNR.snrcut = 1;
cfg.SNR.snrBL = [-40, 0];
cfg.SNR.snrPOI = [50, 250];

cfg.trialfoc.enable = 1;
cfg.trialfoc.focaltrialout = 'auto';

cfg.focalcomp.enable = 1;
cfg.focalcomp.focallCAout = 'auto';

cfg.autocorr.enable = 1;
cfg.autocorr.autocorrint = 20;
cfg.autocorr.dropautocorr = 'auto';

cfg.opts.noplot = 1;
cfg.opts.nocompute = 0;
cfg.opts.FontSize = 14;
