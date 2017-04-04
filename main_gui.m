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
anchor_axes(2) = handles.landmark3_view;
anchor_axes(3) = handles.landmark5_view;
anchor_axes(4) = handles.landmark7_view;
anchor_axes(5) = handles.landmark2_view;
anchor_axes(6) = handles.landmark4_view;
anchor_axes(7) = handles.landmark6_view;
anchor_axes(8) = handles.landmark8_view;
handles.anchor_axes = anchor_axes;

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

%save and update the index file
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

input_folder_name = uigetdir('C:\');
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

%check whether the folders are valid
imcounter = length(src_im);
poscounter = length(src_anchor_pos);
if imcounter == 0 || poscounter == 0 || imcounter - poscounter ~= 0
    errordlg('Invalid folder or number of files', 'error', 'modal');
    set(handles.inputfolderbtn, 'Enable', 'on');
%     set(handles.outputfolderbtn, 'Enable', 'on');
    return;
end

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
set(handles.nextbtn, 'Enable', 'on');
handles = guidata(hObject);

guidata(hObject, handles);

function setView(hObject, handles)
%display the image at fileindex_current
index = handles.fileindex_current;
fname = fullfile(handles.input_folder_name, handles.src_im(index).name);
im = imread(fname);
handles.current_im = im;
h = imshow(im, 'Parent', handles.fullimage_axes);
h.HitTest = 'off';
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
refpoints = pointsFromFile(filepath);
im1 = handles.current_im;
im1 = getmorph(im1, refpoints);
centerpoints = getcenterpoints(im1, refpoints);

%set the position of the draggables on the main image
center_shift = 16.5; %distance of left corner from the center point
handles.center_shift = center_shift;
rect_width = 2*center_shift;
main_pos = centerpoints-center_shift;

%set the position of the draggables on the auxiliary views
axislimit = [centerpoints-50 centerpoints+50];
xlimit = axislimit(:, [1 3]);
ylimit = axislimit(:, [2 4]);

handles.main_pos = main_pos;
handles.centerpoints = centerpoints;
im = handles.current_im; %current image
h_axes = handles.anchor_axes; %anchor axes object array

%rectangle objects for the main gui and for the anchor_axes
main_anchors_rect = gobjects(1, 8);
single_anchor_rect = gobjects(1, 8);

%plot rectangle on main image
axes(handles.fullimage_axes);
for t=1:8
   %build the rectangle
   main_anchors_rect(t) = rectangle('Position', [main_pos(t, :) rect_width rect_width], 'FaceColor', 'r', 'Curvature', [1 1], 'EdgeColor', 'r');
    main_anchors_rect(t).HitTest = 'off';
end
% draggable(main_rect);
handles.main_anchors_rect = main_anchors_rect;

%plot on auxilliary axis
for t=1:8
   %build the rectangle
   axes(h_axes(t));
   cla
   imshow(im, 'Parent', h_axes(t)); %plot the image
   h_axes(t).XLim = xlimit(t, :);
   h_axes(t).YLim = ylimit(t, :);
   single_anchor_rect(t) = rectangle('Position', [main_pos(t, :) rect_width rect_width], 'FaceColor', 'r', 'EdgeColor', 'r', 'Curvature', [1 1]);
   set(ancestor(handles.anchor_axes(t), 'figure'),'KeyPressFcn', @move_rectangle);
end
handles.single_anchor_rect = single_anchor_rect;
draggable(single_anchor_rect);

% Update handles structure
guidata(hObject, handles);

function pos = pointsFromFile(filepath)
%extract the positions
fileid = fopen(filepath, 'r');
file = textscan(fileid, '%d %f %f','HeaderLines', 1, 'Whitespace',' \b\t:(,)');
pos = [file{1, 2} file{1, 3}];
fclose(fileid);

function savePosition(hObject, handles)
%get the anchor positions
pos = ones(8, 2);
for t=1:8
    temp = handles.single_anchor_rect(t).Position;
    pos(t, :) = [temp(1) temp(2)];
end

firstcol = 1:8;
pos = [firstcol' pos+handles.center_shift];

%verify that at least one anchor position has changed


%output the positions to a file in the output folder
filename = handles.src_anchor_pos(handles.fileindex_current).name;
filepath = fullfile(handles.output_folder_name, filename);
fileid = fopen(filepath, 'w');
fprintf(fileid, '%s\r\n', '[ Anchor Points ]');
fclose(fileid);
fileid = fopen(filepath, 'a');
fprintf(fileid, ' %d : (  %6.1f , %6.1f )\r\n', pos');
fclose(fileid);

function move_rectangle(hObject, eventdata)
%set(h_fig,'KeyPressFcn',@(h_obj,evt) disp(evt.Key));
% Figure keypressfcn
S = gco;
if ~strcmp(S.Type, 'rectangle')
    return;
end
P = get(S,'position');
step = 0.5;
switch eventdata.Key
    case 'rightarrow'
        set(S,'pos',P+[step 0 0 0])
    case 'leftarrow'
        set(S,'pos',P+[-step 0 0 0])
    case 'uparrow'
        set(S,'pos',P+[0 -step 0 0])
    case 'downarrow'
        set(S,'pos',P+[0 step 0 0])
    otherwise  
end
