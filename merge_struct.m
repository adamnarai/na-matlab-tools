function A = merge_struct(A, B, overwrite)
% MERGE_STRUCT  Merging struct B into struct A with overwrite.
%
% INPUT:
%           A = main structure
%           B = structure to merge into A
%           overwrite = 1: overwrite fields in A (default), 0: no overwrite
% OUTPUT:
%           A = merged structure
%
% Adam Narai, RCNS HAS, 2019
%

% Default
if nargin < 3
    overwrite = 1;
end

% Get B fields
fields = fieldnames(B);

% Loop for B fields
for i = 1:numel(fields)
    if overwrite || ~isfield(A, fields{i})
        A.(fields{i}) = B.(fields{i});
    end
end