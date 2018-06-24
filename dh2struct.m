function struct_array = dh2struct(dh_struct)
% Conversion from data + header structure to structure array.
% Data+header structure is a matlab structure with the fields D and
% H, where D is a 2D matrix and H is a cell array with
% the column labels for D. The labels in H correspond to
% structure array field names, and the D row numbers correspond to
% structure array indexing.
%
% INPUT:
%           dh_struct = Structure with fields D and H
%               containing the 2D data matrix and column labels
%               respectively.
%
% OUTPUT:
%           classic_struct = Structure array with fileds corresponding to
%               dh_struct H labels and indexing corresponding to
%               D rows.
%
% Adam Narai, RCNS HAS, 2018

data = dh_struct.D;
header = dh_struct.H;

for col = 1:size(data,2)
    for row = 1:size(data,1)
        if iscell(data)
            struct_array(row).(header{col}) = data{row,col};
        else
            struct_array(row).(header{col}) = data(row,col);
        end
    end
end