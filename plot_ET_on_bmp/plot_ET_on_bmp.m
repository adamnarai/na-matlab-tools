function varargout = plot_ET_on_bmp(varargin)
% PLOT_ET_ON_BMP MATLAB code for plot_ET_on_bmp.fig
% varargin{1} = cell array of subject code strings
% varargin{2} = adaptive ET data loader function handle
%               ET_results = @(subj_code, work_path)
% varargin{3} = stim bmp loader function handle
%               img = @(subj_code, stim_num, work_path)
% varargin{4} = work path string

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plot_ET_on_bmp_OpeningFcn, ...
                   'gui_OutputFcn',  @plot_ET_on_bmp_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


% Executes just before plot_ET_on_bmp is made visible.
function plot_ET_on_bmp_OpeningFcn(hObject, eventdata, handles, varargin)
% Parameters
handles.subj_names = varargin{1};
handles.et_load_func = varargin{2};
handles.stim_load_func = varargin{3};
handles.work_path = varargin{4};

% Init
handles.curr_subj = handles.subj_names{1};
handles.stim_idx = 1;
handles.ET_results = feval(handles.et_load_func, handles.curr_subj, handles.work_path);
handles.stim_num = numel(handles.ET_results.fixationIdx);

% Set subj list to popup
set(handles.subjPopup, 'string', handles.subj_names);

% Replot and update
handles = replot_all(handles);
guidata(hObject, handles);


% Outputs from this function are returned to the command line.
function varargout = plot_ET_on_bmp_OutputFcn(hObject, eventdata, handles) 
varargout{1} = '';


% Executes on button press in nextButton.
function nextButton_Callback(hObject, eventdata, handles)
if handles.stim_idx < handles.stim_num
    handles.stim_idx = handles.stim_idx + 1;
    
    % Replot and update
    handles = replot_all(handles);
    guidata(hObject, handles);
end


% Executes on button press in prevButton.
function prevButton_Callback(hObject, eventdata, handles)
if handles.stim_idx > 1
    handles.stim_idx = handles.stim_idx - 1;
    
    % Replot and update
    handles = replot_all(handles);
    guidata(hObject, handles);
end


% Executes on selection change in subjPopup.
function subjPopup_Callback(hObject, eventdata, handles)
contents = cellstr(get(hObject,'String'));
handles.curr_subj = contents{get(hObject,'Value')};
handles.stim_idx = 1;

% Load ET data
handles.ET_results = feval(handles.et_load_func, handles.curr_subj, handles.work_path);
handles.stim_num = numel(handles.ET_results.fixationIdx);

% Replot and update
handles = replot_all(handles);
guidata(hObject, handles);


% Executes during object creation, after setting all properties.
function subjPopup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function img_size = plot_stim(handles)
% Load stim image
img = feval(handles.stim_load_func, handles.curr_subj, handles.stim_idx, handles.work_path);
img = ind2rgb(img, gray);

% Get fixation idx list
fix_idx = round([handles.ET_results.fixationInfo(1,handles.stim_idx,:).X]-199);

% Remove before stim fixations
fix_idx(fix_idx < 0) = [];

% Mark fixations
if ~isnan(fix_idx)
    img(:,fix_idx,1) = 1;
    img(:,fix_idx,2:3) = 0;
end
ax = handles.stimAxes;
cla(ax);
image(ax, img);
set(ax, 'ticklength', [0 0]);
set(ax,'YTickLabel',[]);
set(ax,'XTickLabel',[]);

% Return image size
img_size = size(img, 2);

function plot_gaze(handles, img_size)
data = handles.ET_results.data(1, handles.stim_idx, 1).X - 199;
data_fix = data;
data_fix(~logical(handles.ET_results.fixationIdx(handles.stim_idx).Idx)) = NaN;
data_sacc = data;
data_sacc(~logical(handles.ET_results.saccadeIdx(handles.stim_idx).Idx)) = NaN;

% X data
samples = numel(data);
T = 1/handles.ET_results.samplingFreq;
endTime = (samples-1)*T;
time = 0:T:endTime;

ax = handles.gazeAxes;
cla(ax);
hold(ax, 'on');
plot(ax, data, time, 'g');
plot(ax, data_fix, time, 'r');
plot(ax, data_sacc, time, 'b');
hold(ax, 'off');
xlim(ax, [0 img_size]);
xlabel(ax, 'X position [px]');
ylabel(ax, 'Time [s]');
legend({'other','fix','sacc'}, 'location', 'southeast');

% Replot image and ET data
function handles = replot_all(handles)
img_size = plot_stim(handles);
plot_gaze(handles, img_size);
set(handles.rowTextbox, 'string', num2str(handles.stim_idx));


% Executes on button press in crosshairCheckbox.
function crosshairCheckbox_Callback(hObject, eventdata, handles)
while get(hObject,'Value')
    [x, y] = ginput(1);
    set(handles.xTextbox, 'string', num2str(round(x)));
    set(handles.yTextbox, 'string', num2str(round(y,3)));
end
