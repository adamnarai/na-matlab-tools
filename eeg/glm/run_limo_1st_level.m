function run_limo_1st_level(LIMO, Y)
% RUN_LIMO_1ST_LEVEL  Running 1st level LIMO modeling.
% Results are saved in LIMO.dir.
%
% INPUT:
%           LIMO = LIMO parameter structure
%           Y = data matrix for one subject [ch x times x trials]
%
% Adam Narai, RCNS HAS, 2019
%

create_dir(LIMO.dir);
cd(LIMO.dir);

% Create design matrix
[LIMO.design.X, LIMO.design.nb_conditions, LIMO.design.nb_interactions,...
    LIMO.design.nb_continuous] = limo_design_matrix(Y, LIMO, 0);

% Set the LIMO struct
LIMO.design.status = 'to do';
save LIMO LIMO; clear Y

% Run GLM estimation
load LIMO LIMO
limo_eeg(4);

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

