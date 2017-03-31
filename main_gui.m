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

%create array of handles for the landmark views
anchor_axes = gobjects(1, 8);
anchor_axes(1) = handles.landmark1_view;
anchor_axes(2) = handles.landmark2_view;
anchor_axes(3) = handles.landmark3_view;
anchor_axes(4) = handles.landmark4_view;
anchor_axes(5) = handles.landmark5_view;
anchor_axes(6) = handles.landmark6_view;
anchor_axes(7) = handles.landmark7_view;
anchor_axes(8) = handles.landmark8_view;
handles.anchor_axes = anchor_axes;

%rectangle objects for the main gui and for the anchor_axes
handles.main_anchors_rect = gobjects(1, 8);
handles.single_anchor_rect = gobjects(1, 8);

handles.crop_pos = ones(8, 4);
handles.main_pos = ones(8, 4);

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = main_gui_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;   


% --- Executes on button press in nextbtn.
function nextbtn_Callback(hObject, eventdata, handles)
% hObject    handle to nextbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%save the anchors positions
savePosition(hObject, handles);

%check whether or not the current image is the last
index = handles.fileindex_current + 1;
if index > handles.fileindex_max
   set(handles.nextbtn, 'Enable', 'off');
   return; 
end
handles.fileindex_current = index;

%save update the index file
fileid = fopen(fullfile(handles.input_folder_name, 'config.txt'), 'w');
fprintf(fileid, '%d', index);
fclose(fileid);

%diplay the next image
setView(hObject, handles);
handles = guidata(hObject);

guidata(hObject, handles);



% --- Executes on button press in outputfolderbtn.
function outputfolderbtn_Callback(hObject, eventdata, handles)
% hObject    handle to outputfolderbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

output_folder_name = uigetdir('C:\Users\kkmlover\Documents\DJIMY\WORK\templog');
%stop if the user press cancel or close the dialog box
if output_folder_name == 0
    return;
end

handles.output_folder_name = output_folder_name;
set(handles.outputfolderbtn, 'Enable', 'off');

initView(hObject, handles);
set(handles.nextbtn, 'Enable', 'on');
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
src_anchor_pos = dir(strcat(handles.input_folder_name, '\*_info.txt'));

%get initial fileindex
fileid = fopen(fullfile(handles.input_folder_name, 'config.txt'), 'r');
if fileid == -1
   index = 1; 
else
   index = fscanf(fileid, '%d');
   fclose(fileid);
end


%initialize some gui objects
handles.src_im = src_im;
handles.src_anchor_pos = src_anchor_pos;
handles.fileindex_max = length(src_im);
handles.fileindex_current = index;

setView(hObject, handles);
handles = guidata(hObject);

guidata(hObject, handles);

function setView(hObject, handles)
%display the image at fileindex_current
index = handles.fileindex_current;
fname = fullfile(handles.input_folder_name, handles.src_im(index).name);
im = imread(fname);
handles.current_im = im;
imshow(im, 'Parent', handles.fullimage_axes);
set(handles.imfile, 'String', handles.src_im(index).name);
counter = strcat(num2str(index), '/', num2str(handles.fileindex_max));
set(handles.filecounter, 'String', counter);

%display the draggable rectangles
setDraggables(hObject, handles);
handles = guidata(hObject);

%increment the current file position
guidata(hObject, handles);

%function to plot the draggable elements on the axis
function setDraggables(hObject, handles)
%read the file
filename = handles.src_anchor_pos(handles.fileindex_current).name;
filepath = fullfile(handles.input_folder_name, filename);
set(handles.posfile, 'String', filename);
%center points of the anchors
centerpoints = pointsFromFile(filepath);
%set the position of the draggables on the main image
main_pos = [centerpoints-16 ones(8, 1)*32 ones(8, 1)*32];
%set the position of the draggables on the auxiliary views
crop_pos = [centerpoints-50 ones(8, 1)*100 ones(8, 1)*100];

handles.rect_pos = crop_pos;
handles.main_pos = main_pos;

im = handles.current_im; %current image
h_axes = handles.anchor_axes; %anchor axes object array
main_rect = handles.main_anchors_rect; %main anchor rect object array
aux_rect = handles.single_anchor_rect; % auxilliary anchor rect object array


for t=1:8
   %build the rectangle
   imshow(imcrop(im, crop_pos(t, :)), 'Parent', h_axes(t));
   axes(h_axes(t));
   aux_rect(t) = rectangle('Position', [36 36 32 32], 'FaceColor', 'r', 'Curvature', [1 1], 'EdgeColor', 'r');
end
draggable(aux_rect);
handles.single_anchor_rect = aux_rect;

% Update handles structure
guidata(hObject, handles);

function pos = pointsFromFile(filepath)
%extract the positions
fileid = fopen(filepath, 'r');
file = textscan(fileid, '%d %f %f','HeaderLines', 1, 'Whitespace',' \b\t:(,)');
pos = [file{1, 2} file{1, 3}];
fclose(fileid);

function savePosition(hObject, handles)
%verify that at least one anchor position has changed

%get the anchor positions
pos = ones(8, 3);
for t=1:8
    temp = handles.single_anchor_rect(t).Position;
    pos(t, :) = [t temp(1) temp(2)];
end
%output the positions to a file in the output folder
filename = handles.src_anchor_pos(handles.fileindex_current).name;
filepath = fullfile(handles.output_folder_name, filename);
fileid = fopen(filepath, 'a');
fprintf(fileid, '%s\r\n', '[ Anchor Points ]');
fprintf(fileid, ' %d : (  %.1f ,  %.1f )\r\n', pos(:, 1), pos(:, 2), pos(:, 3));
fclose(fileid);