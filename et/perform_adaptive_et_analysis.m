function ET_fetures = perform_adaptive_et_analysis(segments, params)
% PERFORM_ADAPTIVE_ET_ANALYSIS  Helper function for the adaptive ET algorithm.
% See more in: 
%     Nyström, M., Holmqvist, K., 2010. An adaptive algorithm for fixation, 
%     saccade, and glissade detection in eyetracking data. 
%     Behavior Research Methods 42, 188–204. 
%     https://doi.org/10.3758/BRM.42.1.188
%
% INPUTS:
%           segments = struct array of ET data segments with fields: X, Y, direction
%           params = adaptive ET algorithm parameter structure
% OUTPUTS:
%           ET_fetures = adaptive ET algorithm results
%
% Adam Narai, RCNS HAS, 2019
%

global ETparams

% Adaptive ET analysis on all segments
ETparams = params;
ETparams.data = segments;
eventDetection
ET_fetures = ETparams;