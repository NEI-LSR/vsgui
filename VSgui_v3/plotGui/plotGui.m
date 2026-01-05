function varargout = plotGui(varargin)
% PLOTGUI MATLAB code for plotGui.fig
%      PLOTGUI, by itself, creates a new PLOTGUI or raises the existing
%      singleton*.
%
%      H = PLOTGUI returns the handle to a new PLOTGUI or the handle to
%      the existing singleton*.
%
%      PLOTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTGUI.M with the given input arguments.
%
%      PLOTGUI('Property','Value',...) creates a new PLOTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plotGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plotGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help plotGui

% Last Modified by GUIDE v2.5 15-Jan-2015 08:22:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plotGui_OpeningFcn, ...
                   'gui_OutputFcn',  @plotGui_OutputFcn, ...
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


% --- Executes just before plotGui is made visible.
function plotGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to plotGui (see VARARGIN)

% Choose default command line output for plotGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

set(handles.figure1,'position',[0 0  52.5000   32.8333]);
addpath(pwd);
addpath([pwd '/plotGuiHelpers'])
cur_dir = pwd;
idx = findstr(cur_dir,'plotGui');
addpath([cur_dir(1:idx-1) '/VisStimHelpers'])

% UIWAIT makes plotGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = plotGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in updateExFileList.
function plotFiles_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
set(handles.statusMessage,'String','...busy plotting files...');
pause(0.1)
handles = plotFiles(handles);
%concatenateFiles(handles,allts,gv);
pause(0.2)
set(handles.statusMessage,'String','');
guidata(hObject, handles);


% --- Executes on button press in updateExFileList.
function updateExFileList_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
idir = get(handles.exFileDir,'String');
cur_dir = cd(idir);
dir_content = dir('*.mat');
handles.exFnames = {dir_content.name};
handles.exFindex = [1:size(dir_content,1)];
set(handles.exFileList,'String',handles.exFnames,'Value',1);
guidata(hObject, handles);
cd(cur_dir)

% --- Executes on selection change in exFileList.
function exFileList_Callback(hObject, eventdata, handles)
str = cellstr(get(hObject,'String'));
val = get(hObject,'Value');
selectedExFiles = {};
for n = 1:length(val)
    selectedExFiles{n} = str{val(n)};
end
handles.selectedExFiles = selectedExFiles;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function exFileList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global ex
if ~isempty(ex) && isfield(ex,'dirName')
    cur_dir = cd(ex.dirName);
else cur_dir = pwd;
end
dir_content = dir('*.mat');
set(hObject,'String',{dir_content.name},'Value',1);
cd(cur_dir)


function exFileDir_Callback(hObject, eventdata, handles)
idir = get(hObject,'String');
idir = uigetdir(idir,'select directory for ex files');
handles.exFileDirname = idir;
cur_dir = cd(idir);
dir_content = dir('*.mat');
handles.exFnames = {dir_content.name};
handles.exFindex = [1:size(dir_content,1)];
set(handles.exFileDir,'String',idir);
set(handles.exFileList,'String',handles.exFnames,'Value',1);
cd(cur_dir);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function exFileDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exFileDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global ex
if ~isempty(ex) && isfield(ex,'dirName')    
    set(hObject,'String',ex.dirName);
else
    idir = pwd;
    set(hObject,'string',idir);
end
    


% --- Executes on button press in superimpose.
function superimpose_Callback(hObject, eventdata, handles)
% hObject    handle to superimpose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of superimpose


% --- Executes on button press in plotppRC.
function plotppRC_Callback(hObject, eventdata, handles)
% hObject    handle to plotppRC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plotppRC
