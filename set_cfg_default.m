function cfg = set_cfg_default(cfg, field_name, field_value)
% SET_CFG_DEFAULT  Setting default cfg.field_name.
% Only applied if cfg.field_name is empty, or the field does not exist.
%
% INPUT:
%           cfg = cfg structure
%           field_name = field name to check
%           value = default field value
% OUTPUT:
%           cfg = modified cfg structure
%
% Adam Narai, RCNS HAS, 2019
%

if ~isfield(cfg, field_name) || isempty(cfg.(field_name))
    cfg.(field_name) = field_value;
end