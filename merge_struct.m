function A = merge_struct(A, B)
% Merging struct B into struct A
% Default mode: overwrite
%
% INPUT:
%           A = main structure
%           B = structure to merge into A
% OUTPUT:
%           A = merged structure
%
% Adam Narai, RCNS HAS, 2018

 fields = fieldnames(B);
 for i = 1:numel(fields)
    A.(fields{i}) = B.(fields{i});
 end