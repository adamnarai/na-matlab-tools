function struct_array = dh2struct(dh_struct)
% Conversion from data+header structure to structure array.
% Data+header structure is a matlab structure with the fields 'data' and
% 'header', where 'data' is a 2D matrix and 'header' is a cell array with
% the column labels for 'data'. The labels in 'header' correspond to
% structure array field names, and the 'data' row numbers correspond to
% structure array indexing.
%
% INPUT:
%           dh_struct = Structure with fields 'data' and 'header'
%               containing the 2D data matrix and column labels
%               respectively.
%
% OUTPUT:
%           classic_struct = Structure array with fileds corresponding to
%               dh_struct 'header' labels and indexing corresponding to
%               'data' rows.
%
% Adam Narai, RCNS HAS, 2018

data = dh_struct.data;
header = dh_struct.header;

for col = 1:size(data,2)
    for row = 1:size(data,1)
        if iscell(data)
            struct_array(row).(header{col}) = data{row,col};
        else
            struct_array(row).(header{col}) = data(row,col);
        end
    end
end