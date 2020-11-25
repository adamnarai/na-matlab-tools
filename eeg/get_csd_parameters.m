function CSD_parameters = get_csd_parameters(ch_labels)
% GET_CSD_PARAMETERS  Generate G and H matrices for CSD.
% CSDtoolbox/func should be added to Matlab path.
% Note: O9 and O10 must be I1 and I2, respectively
%
% INPUTS:
%           ch_labels = channel labels in [chnum x 1] cell array
%               corresponding to EEGLAB data (do not include reference ch!)
% OUTPUTS:
%           CSD_parameters = structure of CSD parameters, especially the G
%               and H matrices
%
% Based on cl_CSD.m, provided by Bela Weiss, RCNS HAS
% Adam Narai, RCNS HAS, 2019
%
% See also: run_csd()

% Add labels to params
CSD_parameters.clab = ch_labels;

% Add the reference channel if needed (currently work for a single monopolar reference)
prompt              = {'Reference channel label:'};
name                = 'Provide reference channel label';
numlines            = 1;
defaultanswer       = {''};
options.Resize      = 'on';
options.WindowStyle = 'normal';
answer = inputdlg(prompt,name,numlines,defaultanswer,options);
if ~isempty(answer)
    CSD_parameters.reference_label = answer{1};
    ch_labels{end+1} = CSD_parameters.reference_label;
else
    CSD_parameters.reference_label = '';
end

% Extract the corresponding electrode position information
% Note that electrode positions differ between
% 10-5-System_Mastoids_EGI129.csd and EEGLAB
[filename, pathname] = uigetfile({'*.csd','CSD transform file (*.csd)'},...
    'Pick a CSD transform file, hint: CSDtoolbox\resource\10-5-System_Mastoids_EGI129.csd');
if ~filename
    error('No file selected.');
end
CSD_parameters.montagefile = [pathname, filename];
M = ExtractMontage(CSD_parameters.montagefile, ch_labels);
if ~isstruct(M)
    uiwait(msgbox('Channel location information could not be found!', 'Warning', 'warn', 'modal'))
    error('Channel location information could not be found.');
end

% Check and accept the current montage
MapMontage(M)
decision = true;
disp('Press Y to accept and N to reject montage.');
while decision
    kp = waitforbuttonpress;
    if kp == 1
        accepting = get(gcf, 'CurrentKey');
        switch accepting
            case {'y'; 'Y'}
                approved = true;
                delete(gcf)
                decision = false;
            case {'n'; 'N'}
                approved = false;
                delete(gcf)
                decision = false;
        end
    end
end
if ~approved
    error('Montage was not approved.');
end

% Provide the needed parameters
prompt              = {'Order of splines:',...
    'Maximum degree of Legendre polynomials:', ...
    'Lambda approximation parameter:'};
name                = 'Provide CSD parameters';
numlines            = 1;
defaultanswer       = {'4','10', '0.00001'};
options.Resize      = 'on';
options.WindowStyle = 'normal';
answer = inputdlg(prompt, name, numlines, defaultanswer, options);
if isempty(answer)
    error('Paramaters were not provided.');
end
CSD_parameters.m      = str2num(answer{1});   % Order of splines
CSD_parameters.MDLP   = str2num(answer{2});   % Maximum degree of Legendre polynomials
CSD_parameters.lambda = str2num(answer{3});   % Lambda approximation parameter

% Get G and H matrices
[CSD_parameters.G, CSD_parameters.H] = GetGH(M, CSD_parameters.m, CSD_parameters.MDLP);
