function dh_struct = struct2dh(struct_array)
% Conversion from structure array to data + header structure.
% Data+header structure is a matlab structure with the fields D and
% H, where D is a 2D matrix and H is a cell array with
% the column labels for D. The labels in H correspond to
% structure array field names, and the D row numbers correspond to
% structure array indexing.
%
% INPUT:
%           classic_struct = Structure array with fileds corresponding to
%               dh_struct H labels and indexing corresponding to
%               D rows.
%
% OUTPUT:
%           dh_struct = Structure with D field containing the
%               structura array data in 2D data matrix form  where rows
%               correspond to structure array indexing and H field
%               with structure array field names in a cell array.
%
% Adam Narai, RCNS HAS, 2018

header = fieldnames(struct_array)';
rowN = numel({struct_array.(header{1})});
colN = numel(header);

for col = 1:colN
    isNum = isnumeric([struct_array.(header{col})]);
    if ~isNum
        data = cell(rowN,colN);
        break;
    end
end
if isNum
    data = nan(rowN,colN);
end

for col = 1:colN
    if isNum
        data(:,col) = [struct_array.(header{col})];
    else
        data(:,col) = {struct_array.(header{col})};
    end
end

dh_struct.D = data;
dh_struct.H = header;