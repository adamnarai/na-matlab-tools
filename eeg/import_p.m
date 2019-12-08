function p = import_p(p, p_path)
% IMPORT_P  Import previous p struct.
%
% INPUT:
%           p = new p struct (containing session data like date, log info)
%           p_path = path to data p structure with the main params
% OUTPUT:
%           p = merged structure
%
% Adam Narai, RCNS HAS, 2019
%

% Load the main p structure
main = load(p_path);

% Merge the new struct into the main one
p = merge_struct(main.p, p);