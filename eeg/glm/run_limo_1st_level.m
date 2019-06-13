function run_limo_1st_level(LIMO, Y, contr)
if nargin < 3
    contr = [];
end

create_dir(LIMO.dir);
cd(LIMO.dir);

% Create design matrix
[LIMO.design.X, LIMO.design.nb_conditions, LIMO.design.nb_interactions,...
    LIMO.design.nb_continuous] = limo_design_matrix(Y, LIMO,0);

LIMO.design.status = 'to do';
save LIMO LIMO; clear Y

% Run GLM estimation
load LIMO LIMO
limo_eeg_nofigure(4);

% Compute contrasts
if ~isempty(contr)
    disp('Computing contrasts');
    load LIMO
    load Yr
    load Betas
    
    if isfield(LIMO, 'contrast')
        LIMO = rmfield(LIMO, 'contrast');
    end
    
    % Create contrast
    if iscell(contr)
        for contrIdx = idx
            currContr = contr{contrIdx};
            LIMO = run_contrast(LIMO, Yr, Betas, currContr, contrIdx);
        end
    else
        LIMO = run_contrast(LIMO, Yr, Betas, contr);
    end
end
save LIMO LIMO

% Delete Yr, Yhat and Res files
if exist('Yr.mat', 'file')
    delete('Yr.mat');
end
if exist('Yhat.mat', 'file')
    delete('Yhat.mat');
end
if exist('Res.mat', 'file')
    delete('Res.mat');
end

function LIMO = run_contrast(LIMO, Yr, Betas, contr, idx)
if nargin < 5
    idx = 1;
end
C = limo_contrast_checking(LIMO.dir, LIMO.design.X, contr);
LIMO.contrast{idx}.C = C;
LIMO.contrast{idx}.V = 'T';
% T test, results saved as con_x.mat
limo_contrast(Yr, Betas, LIMO, 0, 1);

