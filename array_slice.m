function out = array_slice(in, dim, idx)
% GET_ARRAY_SLICE Get ndim array slice by indexing along one dimension only.
% Instead of B = A(:,[1 2 3],:,:) use B = array_slice(A, 2, [1 2 3])
% The advantage is no assumptions about the number of dimensions.
%          
% INPUTS:
%           in = ndim numeric array
%           dim = dimension of indexing
%           idx = integer array of indices
% OUTPUTS:
%           out = sliced array
%
% Adam Narai, RCNS HAS, 2019

% Validate inputs
validateattributes(dim, {'numeric'}, {'scalar', 'positive', '<=', ndims(in)});
validateattributes(max(idx), {'numeric'}, {'scalar', 'positive', '<=', size(in, dim)});

% Create full index xtructure
all_value_idx = arrayfun(@(x) 1:x, size(in), 'UniformOutput', false);

% Change the specified dimension index
all_value_idx{dim} = idx;

% Get slice of array
out = in(all_value_idx{:});