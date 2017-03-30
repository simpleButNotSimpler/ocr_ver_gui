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

function pos = getPosition(h)
row = 8;
pos = ones(8, 4);

for t=1:row
   pos(t, :) = h(t).Position; 
end

    
  


% --- Executes on button press in nextbtn.
function nextbtn_Callback(hObject, eventdata, handles)
% hObject    handle to nextbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%check whether or not the current image is the last
index = handles.fileindex_current + 1;
if index > handles.fileindex_max
   set(handles.nextbtn, 'Enable', 'off');
   return; 
end
handles.fileindex_current = index;

%diplay the next image
setView(hObject, handles);

guidata(hObject, handles);



% --- Executes on button press in outputfolderbtn.
function outputfolderbtn_Callback(hObject, eventdata, handles)
% hObject    handle to outputfolderbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

output_folder_name = uigetdir('C:\');
%stop if the user press cancel or close the dialog box
if output_folder_name == 0
    return;
end

handles.output_folder_name = output_folder_name;
set(handles.outputfolderbtn, 'Enable', 'off');

initView(hObject, handles);
handles = guidata(hObject);


guidata(hObject, handles);


% --- Executes on button press in inputfolderbtn.
function inputfolderbtn_Callback(hObject, eventdata, handles)
% hObject    handle to inputfolderbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

input_folder_name = uigetdir('C:\Users\kkmlover\Documents\DJIMY\WORK\temp');
%stop if the user press cancel or close the dialog box
if input_folder_name == 0
    return;
end

handles.input_folder_name = input_folder_name;

set(handles.inputfolderbtn, 'Enable', 'off');
set(handles.outputfolderbtn, 'Enable', 'on');
guidata(hObject, handles);

%function to initialize the parameters
function initView(hObject, handles)
src_im = dir(strcat(handles.input_folder_name, '\*_bw.bmp'));  % the folder in which ur images exists
src_anchor = dir(strcat(handles.input_folder_name, '\*_info.txt'));

handles.src_im = src_im;
handles.src_anchor = src_anchor;
handles.fileindex_max = length(src_im);
handles.fileindex_current = 1;

setView(hObject, handles);
handles = guidata(hObject);

guidata(hObject, handles);

function setView(hObject, handles)
%display the image at fileindex_current
index = handles.fileindex_current;
fname = fullfile(handles.input_folder_name, handles.src_im(index).name);
im = imread(fname);
imshow(im, 'Parent', handles.fullimage_axes);

%increment the current file position
guidata(hObject, handles);


