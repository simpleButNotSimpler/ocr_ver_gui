function varargout = main_gui(varargin)
% MAIN_GUI MATLAB code for main_gui.fig
% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @main_gui_OutputFcn, ...
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


% --- Executes just before main_gui is made visible.
function main_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for main_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = main_gui_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in browse.
function browse_Callback(hObject, eventdata, handles)

% --- Executes on button press in nextbutton.
function nextbutton_Callback(hObject, eventdata, handles)

% --- Executes on button press in savelandmark_button.
function savelandmark_button_Callback(hObject, eventdata, handles)
handles.landmark_panel.Visible = 'off';
pos = handles.landmark_panel.Position;
posnew = handles.magview_panel.Position;
handles.magview_panel.Position = [pos(1) pos(2) posnew(3) posnew(4)];
handles.magview_panel.Visible = 'on';
