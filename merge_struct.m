function A = merge_struct(A, B)
% MERGE_STRUCT  Merging struct B into struct A with overwrite.
%
% INPUT:
%           A = main structure
%           B = structure to merge into A
% OUTPUT:
%           A = merged structure
%
% Adam Narai, RCNS HAS, 2018
%

% Get B fields
fields = fieldnames(B);

% Loop for B fields
for i = 1:numel(fields)
    A.(fields{i}) = B.(fields{i});
end