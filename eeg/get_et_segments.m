function [segments, run_nums] = get_et_segments(ETALL, start_event, end_event, y_max)
% GET_ET_SEGMENTS  Get all ET segments between start/end events.
%
% INPUTS:
%           ETALL = ET data struct array
%           start_event = segment start event string
%           end_event = segment end event string
%           y_max = maximal y coordinate (used to calculate y values in 
%               "real" direction), default: 1080 px
% OUTPUTS:
%           segments = struct array of segments with fields: t, X, Y, direction
%           run_nums = run number for each segment
%
% Adam Narai, RCNS HAS, 2019
%

% Defaults
if nargin < 4
    y_max = 1080;
end

line = 0;
% Loop for runs
for n = 1:numel(ETALL)
    % Get trigger messages
    et_messages = {ETALL(n).FEVENT.message};
    valid_et_messages = cellfun(@(x) ~isempty(x), et_messages);
    et_messages = et_messages(valid_et_messages);
    events = ETALL(n).FEVENT(valid_et_messages);
    
    % Get the line on/off numbers
    line_on_nums = cellfun(@(x) sscanf(x, start_event), et_messages, 'UniformOutput', 0);
    line_off_nums = cellfun(@(x) sscanf(x, end_event), et_messages, 'UniformOutput', 0);
    
    % Check line on/off match
    if ~isequal(cell2mat(line_on_nums), cell2mat(line_off_nums))
        error('Mismatch between line_on and line_off indices.');
    end
    
    % Get the line on/off times and numbers
    clear line_times
    line_times(:,1) = [events(cellfun(@(x) ~isempty(x), line_on_nums)).sttime]';
    line_times(:,3) = cell2mat(line_on_nums);
    line_times(:,2) = [events(cellfun(@(x) ~isempty(x), line_off_nums)).sttime]';
    line_times(:,4) = cell2mat(line_off_nums);
    
    % Get raw ET data
    t = ETALL(n).FSAMPLE.time;
    X = ETALL(n).FSAMPLE.gx(1,:);
    Y = ETALL(n).FSAMPLE.gy(1,:);
    
    % Set 1E8 Eyelink blink values to 0
    X(X == 1E8) = 0;
    Y(Y == 1E8) = 0;
    
    % Get segments
    for sub_line = 1:size(line_times, 1)
        line = line + 1;
        start_idx = find(ETALL(n).FSAMPLE.time == line_times(sub_line, 1));
        end_idx = find(ETALL(n).FSAMPLE.time == line_times(sub_line, 2));
        
        % Create segments structure
        segments(1,line).t = t(1,start_idx:end_idx);
        segments(1,line).X = X(1,start_idx:end_idx);
        segments(1,line).Y = y_max - Y(1,start_idx:end_idx);
        segments(1,line).direction = 'left-to-right';
        run_nums(1,line) = n;
    end
end

