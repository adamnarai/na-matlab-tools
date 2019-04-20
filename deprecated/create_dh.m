function dh_struct = create_dh(data, header)
% Creating data + header structure.
% Data+header structure is a matlab structure with the fields D and
% H, where D is a 2D matrix and H is a cell array with
% the column labels for D.
%
% INPUT:
%           data = 2D data matrix
%           header = cell array of column labels for data
%
% OUTPUT:
%           dh_struct = Structure with fields D and H
%               containing the 2D data matrix and column labels
%               respectively.
%
% Adam Narai, RCNS HAS, 2018

% Check data validity
for i = 1:numel(header)
    if isempty(header{i}) || ~ischar(header{i})
        error([num2str(i), '. element of header is not a non-empty string.']);
    end
end

if size(data,2) ~= numel(header)
    error('Number of columns in data must equal to header size.');
end

dh_struct.D = data;
dh_struct.H = header;
