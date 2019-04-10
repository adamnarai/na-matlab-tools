function varargout = set_EOG_blink_th(varargin)
% SET_EOG_BLINK_TH  Interactive GUI for setting EOG blink thresshold.
% Threshold is based on max amplitude within epoch.
% USAGE: th = set_EOG_blink_th(data, th)
%
% INPUTS:
%           data (varargin{1}) = epoched bipolar EOG channel EEGLAB data
%           Th (varargin{2}) = initial threshold in [uV]
% OUTPUTS:
%           Th (varargout) = modified threshold
%
% Adam Narai, RCNS HAS, 2018
%
% See also mark_EOG_blink

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @set_EOG_blink_th_OpeningFcn, ...
                   'gui_OutputFcn',  @set_EOG_blink_th_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before set_EOG_blink_th is made visible.
function set_EOG_blink_th_OpeningFcn(hObject, eventdata, handles, varargin)
% Get inputs
data = varargin{1};
handles.th = varargin{2};

% Set textbox to Th
set(handles.thTextbox,'String', num2str(handles.th));

% Calculate max of epochs
handles.M = max(data,[], 1);

% Calculate SD of epochs
handles.SD = std(data,1);

% Sort variables
[handles.Msorted, handles.Mi] = sort(handles.M);
[handles.SDsorted, handles.SDi] = sort(handles.SD);

% Redraw/refresh
redrawPlots(handles);
refreshStats(handles)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes set_EOG_blink_th wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = set_EOG_blink_th_OutputFcn(hObject, eventdata, handles) 
% Return value
varargout{1} = handles.th;
disp(['Threshold was set to ', num2str(handles.th), ' [uV]']);
% The figure can be deleted now
delete(handles.figure1);


function thTextbox_Callback(hObject, eventdata, handles)
% Get Th value from textbox and pass to handles
th = str2double(get(hObject,'String'));
if ~isnan(th)
    handles.th = th;
end

% Redraw/refresh
redrawPlots(handles);
refreshStats(handles)

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function thTextbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end


% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(handles.figure1);
else
    % The GUI is no longer waiting, just close it
    delete(handles.figure1);
end

% Redraw function
function redrawPlots(handles)
% Calculate threshold index
[~, th] = min(abs(handles.Msorted - handles.th));

% Line plot
ax = handles.linePlot;
cla(ax);

hold(ax, 'on');
plot(ax, handles.Msorted, 'color', 'b', 'linewidth', 1);
plot(ax, handles.SDsorted, 'color', 'g', 'linewidth', 1);
line(ax, [th th], [handles.Msorted(1) handles.Msorted(end)], 'Color', 'r');
xlim(ax, [1 numel(handles.Msorted)]); ylim(ax, [handles.Msorted(1) handles.Msorted(end)]);
hold(ax, 'off');

title(ax, 'Threshold');
xlabel(ax, 'Epocs (reordered based on max amplitude)');
ylabel(ax, 'Max amplitude/SD [uV]');
legend(ax, {'max', 'SD'}, 'Location','northwest');

% Max plot
ax = handles.maxPlot;
cla(ax);

hold(ax, 'on');
scatter(ax, handles.Mi(1:th-1),handles.M(handles.Mi(1:th-1)),2,'b')
scatter(ax, handles.Mi(th:end),handles.M(handles.Mi(th:end)),2,'r')
line(ax, [1 numel(handles.Msorted)], [handles.th handles.th], 'Color', 'r');
xlim(ax, [1 numel(handles.Msorted)]); 
ylim(ax, [handles.Msorted(1) handles.Msorted(end)]);
hold(ax, 'off');

title(ax, 'Max amplitudes');
xlabel(ax, 'Epocs (original order)');
ylabel(ax, 'Max amplitude [uV]');

% SD plot
ax = handles.sdPlot;
cla(ax);

hold(ax, 'on');
scatter(ax, handles.Mi(1:th-1),handles.SD(handles.Mi(1:th-1)),2,'b')
scatter(ax, handles.Mi(th:end),handles.SD(handles.Mi(th:end)),2,'r')
xlim(ax, [1 numel(handles.SDsorted)]); 
ylim(ax, [handles.SDsorted(1) handles.SDsorted(end)]);
hold(ax, 'off');

title(ax, 'Standard deviation (SD)');
xlabel(ax, 'Epocs (original order)');
ylabel(ax, 'SD [uV]');

% Refresh function
function refreshStats(handles)
% Calc stats
[~, th] = min(abs(handles.Msorted - handles.th));
N = numel(handles.M);
cleanN = numel(handles.Mi(1:th-1));
blinkN = N-cleanN;

% Create string
stats = [num2str(N), char(10),...
    num2str(cleanN), '  (', num2str(round(100*cleanN/N),2),' %)', char(10),...
    num2str(blinkN)];

% Set string
set(handles.statsTextbox, 'String', stats);
