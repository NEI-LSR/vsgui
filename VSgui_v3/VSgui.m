function varargout = VSgui(varargin)
% VSGUI MATLAB code for VSgui.fig
%      VSGUI, by itself, creates a new VSGUI or raises the existing
%      singleton*.
%
%      H = VSGUI returns the handle to a new VSGUI or the handle to
%      the existing singleton*.
%
%      VSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VSGUI.M with the given input arguments.
%
%      VSGUI('Property','Value',...) creates a new VSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VSgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VSgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VSgui

% Last Modified by GUIDE v2.5 19-Sep-2025 18:34:45

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @VSgui_OpeningFcn, ...
                   'gui_OutputFcn',  @VSgui_OutputFcn, ...
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


% --- Executes just before VSgui is made visible.
function VSgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VSgui (see VARARGIN)

% Choose default command line output for VSgui
handles.output = hObject;

% Update handles structure
global ex myhandles
ex.setup.VSdirRoot = pwd;
addpath([ex.setup.VSdirRoot '/guiHelpers']);

guidata(hObject, handles);
updateStoredEyecalList(handles)
updateExptSetupFlist(handles)
initializeGui(handles)
updateStimParamsList(handles)
setGuiVariables(handles);
set(handles.figure1,'position',[0 37.3 195.3333   49.0833]);
guidata(hObject,handles); % get updated handles
myhandles = handles;


% --- Outputs from this function are returned to the command line.
function varargout = VSgui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in storedExperiments.
function storedExperiments_Callback(hObject, eventdata, handles)
global ex
exp_list = cellstr(get(hObject,'String')) ;% returns StoredExperiments_listbox contents as cell array
fname = exp_list{get(hObject,'Value')}; % returns selected item from StoredExperiments_listbox
idir = fileparts(ex.setup.VSdirRoot);
setupfile = fullfile(idir,'setupFiles','ExptSetupFiles',...
    sprintf('%s.setup',fname));
loadExptSetupFile(hObject,handles,setupfile);


function storedExperiments_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function exp_type_Callback(hObject, eventdata, handles)
global ex
eName = sprintf('e%d',eNumber(hObject.Tag));
exp_list = hObject.String;
etype = exp_list{hObject.Value};
if strcmpi(etype,'none')  % remove other input if no exp is selected
    handles.(sprintf('%s_min',eName)).String = [];
    handles.(sprintf('%s_inc',eName)).String = [];
    handles.(sprintf('%s_range',eName)).String = [];
    ex.exp = rmfield(ex.exp,eName);
else
    ex.exp.(eName).type = etype;
    %ex = getExptSettings(ex,etype);
    nex = getExptSettings(ex,etype);
    ex.exp.(eName) = nex.exp.e1;
    ex.stim.vals = nex.stim.vals; % hn hack to deal with loss of image folder
end
setGuiVariables(handles);

function exp_min_Callback(hObject, eventdata, handles)
global ex
eName = sprintf('e%d',eNumber(hObject.Tag));
ex.exp.(eName).min = str2double(get(hObject,'String'));
setGuiVariables(handles);

function exp_inc_Callback(hObject, eventdata, handles)
global ex
eName = sprintf('e%d',eNumber(hObject.Tag));
ex.exp.(eName).inc = str2double(get(hObject,'String'));
setGuiVariables(handles);

function exp_nsamples_Callback(hObject, eventdata, handles)
global ex
eName = sprintf('e%d',eNumber(hObject.Tag));
ex.exp.(eName).nsamples = str2double(hObject.String);
setGuiVariables(handles);

function exp_scale_Callback(hObject, eventdata, handles)
global ex
scale_list = cellstr(get(hObject,'String'));
eName = sprintf('e%d',eNumber(hObject.Tag));
ex.exp.(eName).scale = scale_list{get(hObject,'Value')};
setGuiVariables(handles);

function exp_range_Callback(hObject, eventdata, handles)
global ex
eName = sprintf('e%d',eNumber(hObject.Tag));
ex.exp.(eName).range = sort(str2num(hObject.String));
ex.exp.(eName).scale = 'range';
setGuiVariables(handles);


function n = eNumber(tag)
    for i=1:5
        if contains(tag,sprintf('exp%d',i))
            n = i;
            break
        end
end


function exp1_type_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exp1_min_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exp1_inc_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exp1_scale_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exp1_nsamples_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exp1_range_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function exp2_type_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exp2_min_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function exp2_inc_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exp2_nsamples_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exp2_scale_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exp2_range_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exp3_type_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exp3_min_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exp3_inc_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exp3_nsamples_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exp3_scale_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exp3_range_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function exp4_type_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exp4_min_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exp4_inc_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exp4_nsamples_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exp4_scale_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exp4_range_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function exp5_type_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exp5_min_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exp5_inc_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exp5_scale_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exp5_nsamples_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exp5_range_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function afc_Callback(hObject, eventdata, handles)
global ex
ex.exp.afc = get(hObject,'Value');
setGuiVariables(handles);

function include_blank_Callback(hObject, eventdata, handles)
global ex
ex.exp.include_blank = get(hObject,'Value');
setGuiVariables(handles);

function stimulus_type_Callback(hObject, eventdata, handles)
global ex
stim_list = cellstr(get(hObject,'String'));
ex.stim.type = stim_list{get(hObject,'Value')};
setGuiVariables(handles);

function stimulus_type_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function mask_type_Callback(hObject, eventdata, handles)
global ex
mask_list = cellstr(get(hObject,'String'));
ex.stim.masktype = mask_list{get(hObject,'Value')};
setGuiVariables(handles);
function mask_type_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function include_monoc_Callback(hObject, eventdata, handles)
global ex
ex.exp.include_monoc = get(hObject,'Value');
setGuiVariables(handles);
function binoc_eyeSignals_Callback(hObject, eventdata, handles)
global ex
eye_list = cellstr(get(hObject,'String'));
ocularity = eye_list{get(hObject,'Value')};
switch ocularity
    case 'monocular'
        ex.setup.el.binoc = 0;
        ex.setup.adc.Channels = [0:2];  % channels 0 to 2 for monocular data
        ex.setup.adc.DiffChannels = [0,0,0]; % 0:= compute no differential voltages;
    case 'binocular'
        ex.setup.el.binoc = 1;
        ex.setup.adc.Channels = [0:5];  % channels 0 to 5 for binocular data
        ex.setup.adc.DiffChannels = [0,0,0,0,0,0]; % 0:= compute no differential voltages;
end
setGuiVariables(handles);

function binoc_eyeSignals_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function recording_Callback(hObject, eventdata, handles)
global ex
ex.setup.recording = get(hObject,'Value');
setGuiVariables(handles);

function iontophoresis_Callback(hObject, eventdata, handles)
global ex
ex.setup.iontophoresis.on = get(hObject,'Value');
% if we record the iontophoresis signals we need to open two additional
% analog channels
if ex.setup.iontophoresis.on
    ex.setup.adc.Channels = [ex.setup.adc.Channels, [1,2]+ ex.setup.adc.Channels(end)];
    ex.setup.adc.DiffChannels = [ex.setup.adc.DiffChannels, 0,0];
end
setGuiVariables(handles);

function nreps_Callback(hObject, eventdata, handles)
global ex;
ex.exp.nreps = str2double(get(hObject,'String'));  
setGuiVariables(handles);

function nreps_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function fixWinW_Callback(hObject, eventdata, handles)
global ex
ex.fix.WinW =  str2double(get(hObject,'String'));  
setGuiVariables(handles);

% --- Executes during object creation, after setting all properties.
function fixWinW_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function fixWinH_Callback(hObject, eventdata, handles)
global ex
ex.fix.WinH =  str2double(get(hObject,'String'));  
setGuiVariables(handles);

% --- Executes during object creation, after setting all properties.
function fixWinH_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function LeftHemisphere_Callback(hObject, eventdata, handles)
global ex
val = get(hObject,'Value');
ex.setup.leftHemisphereRecorded = val;

function RightHemisphere_Callback(hObject, eventdata, handles)
global ex
val = get(hObject,'Value');
ex.setup.rightHemisphereRecorded = val;


function Left_Hemisphere_gridX_Callback(hObject, eventdata, handles)
global ex
ex.setup.Left_Hemisphere_gridX =  str2double(get(hObject,'String'));  
setGuiVariables(handles);



% --- Executes during object creation, after setting all properties.
function Left_Hemisphere_gridX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Left_Hemisphere_gridY_Callback(hObject, eventdata, handles)
global ex
ex.setup.Left_Hemisphere_gridY =  str2double(get(hObject,'String'));  
setGuiVariables(handles);


% --- Executes during object creation, after setting all properties.
function Left_Hemisphere_gridY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Left_Hemisphere_gridY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Right_Hemisphere_gridX_Callback(hObject, eventdata, handles)
global ex
ex.setup.Right_Hemisphere_gridX =  str2double(get(hObject,'String'));  
setGuiVariables(handles);


% --- Executes during object creation, after setting all properties.
function Right_Hemisphere_gridX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Right_Hemisphere_gridY_Callback(hObject, eventdata, handles)
global ex
ex.setup.Right_Hemisphere_gridY =  str2double(get(hObject,'String'));  
setGuiVariables(handles);

function Right_Hemisphere_gridY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function reward_time_Callback(hObject, eventdata, handles)
global ex
ex.reward.time = str2double(get(hObject,'String'));

function reward_time_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in runExpt.
function runExpt_Callback(hObject, eventdata, handles)
global ex

runExpt

function openDisplay_Callback(hObject, eventdata, handles)
global ex
initDatapixx(ex);
ex = initDisplay(ex);

% --- Executes on button press in closeDisplay.
function closeDisplay_Callback(hObject, eventdata, handles)
global ex
closeVS(ex)  % need to change

% --- Executes on button press in runTrial.
function runTrial_Callback(hObject, eventdata, handles)
global ex
if ex.exp.afc
    ex = runTrialTask(ex);
else
    ex = runTrialStim(ex);
end

function fix_duration_Callback(hObject, eventdata, handles)
global ex
ex.fix.duration = str2double(get(hObject,'String'));
if isfield(ex.exp,'blockedFreeViewing') && ex.exp.blockedFreeViewing
    ex.fix.blockedFreeViewing.duration(ex.freeViewing+1) = ex.fix.duration;
end
setGuiVariables(handles);


function fix_duration_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function calibrateEye_Callback(hObject, eventdata, handles)
global ex
persistent inProgress % avoid multiple calls to this function after buttonpress
if isempty(inProgress)
    inProgress = 1; 
else return
end

try
    types_cal = cellstr(get(handles.typeEyeCalibration,'String'));
    type_calibration = types_cal{get(handles.typeEyeCalibration,'Value')};
    switch type_calibration
        case 'short'
            disp('in short eye calibration rev')
            ex = calibrateEye(ex);
        case 'long'
            ex = calibrateEye_long(ex);
    end
catch
    % ignore errors
end
inProgress = [];


function typeEyeCalibration_Callback(hObject, eventdata, handles)


function typeEyeCalibration_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function sf_Callback(hObject, eventdata, handles)
global ex
ex.stim.vals.sf = str2num(get(hObject,'String'));
setGuiVariables(handles);

function sf_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function tf_Callback(hObject, eventdata, handles)
global ex
ex.stim.vals.tf = str2num(get(hObject,'String'));
setGuiVariables(handles);

function tf_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function or_Callback(hObject, eventdata, handles)
global ex
ex.stim.vals.or = str2num(get(hObject,'String'));
setGuiVariables(handles);

function or_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function x0_Callback(hObject, eventdata, handles)
global ex
ex.stim.vals.x0 = str2num(get(hObject,'String'));
setGuiVariables(handles);

function x0_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function nStimPerTrial_Callback(hObject, eventdata, handles)
global ex
ex.exp.StimPerTrial = str2num(get(hObject,'String'));
setGuiVariables(handles);

function nStimPerTrial_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function y0_Callback(hObject, eventdata, handles)
global ex
ex.stim.vals.y0 = str2num(get(hObject,'String'));
setGuiVariables(handles);

function y0_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hdx_Callback(hObject, eventdata, handles)
global ex
ex.stim.vals.hdx = str2num(get(hObject,'String'));
setGuiVariables(handles);

function hdx_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function wi_Callback(hObject, eventdata, handles)
global ex
ex.stim.vals.wi = str2num(get(hObject,'String'));
setGuiVariables(handles);

function wi_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function hi_Callback(hObject, eventdata, handles)
global ex
ex.stim.vals.hi = str2num(get(hObject,'String'));
setGuiVariables(handles);

function hi_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function stimParams_Callback(hObject, eventdata, handles)
global ex
setGuiVariables(handles);
guidata(hObject,handles);

function stimParams_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function stimVals_Callback(hObject, eventdata, handles)
global ex
% get selected parameter from stimParams listbox
param_list = cellstr(get(handles.stimParams,'String'));
param_selected = param_list{get(handles.stimParams,'Value')};
param  = strtok(param_selected,' ');
%get stimulus value from user input
val = (get(hObject,'String'));
switch param
    case 'dcol'
        eval(['ex.stim.vals.' param ' = val;']);
    otherwise
        val_num = eval(['[' val '];']);
        eval(['ex.stim.vals.' param ' = val_num;']);
end
setGuiVariables(handles);

function stimVals_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Animal_Callback(hObject, eventdata, handles)
global ex
name_list = cellstr(get(hObject,'String')); 
animal = name_list{get(hObject,'Value')} ;
ex.Header.animal = animal;
switch animal
    case 'kiwi'
        ex.setup.filePrefix = 'ki';
    case 'mango' 
        ex.setup.filePrefix = 'ma';
    case 'lemieux' 
        ex.setup.filePrefix = 'le';
    case 'barnum' 
        ex.setup.filePrefix = 'ba';
    case 'hummus' 
        ex.setup.filePrefix = 'hu';
    case 'tempura'
        ex.setup.filePrefix = 'te';
    case 'jocamo'
        ex.setup.filePrefix = 'jo';
    case 'tamago'
        ex.setup.filePrefix = 'ta';
    case 'kaki'
        ex.setup.filePrefix = 'ka';
    case 'lychee'
        ex.setup.filePrefix = 'ly';
        
    otherwise
        ex.setup.filePrefix = animal;
end

function Animal_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Comment_Callback(hObject, eventdata, handles)
global ex
comment =  get(hObject,'String');
if isfield(ex,'comment')
    ex.comment(length(ex.comment)+1).text = comment;
else
    ex.comment(1).text = comment;
end
if isfield(ex,'j')
    ex.comment(length(ex.comment)).trialNum = ex.j;
else ex.comment(length(ex.comment)).trialNum = NaN;
end
set(hObject,'String','');



function Comment_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function storedEyeCalibrations_Callback(hObject, eventdata, handles)
global ex
stored_eyeCals = cellstr(get(hObject,'String'));
fname = stored_eyeCals{get(hObject,'Value')} ;
cur_dir = pwd;
cd (ex.setup.VSdirRoot)
cd ..
idir = pwd;
cd(cur_dir);
eyeCalfile = [idir '/setupFiles/EyecalibrationSetupFiles/' fname '.eyeCal'] 
loadStoredEyecal(hObject,handles,eyeCalfile)


function storedEyeCalibrations_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function saveEyeCalibration_Callback(hObject, eventdata, handles)
global ex
curr_dir = pwd;
cd ([ex.setup.VSdirRoot ]);
cd ../setupFiles/EyeCalibrationSetupFiles
[file path] = uiputfile('*.eyeCal','Save as');
if file  %if 'cancel' was not pressed
    file = [path file];
    eyeCal = ex.eyeCal;
    save(file,'eyeCal')
end
updateStoredEyecalList(handles)
cd (curr_dir)

function saveExptSetup_Callback(hObject, eventdata, handles)
global ex
curr_dir = pwd;
cd ([ex.setup.VSdirRoot ]);
cd ../setupFiles/ExptSetupFiles
[file path] = uiputfile('*.setup','Save as');
if file  %if 'cancel' was not pressed
    file = [path file];
    save(file,'ex')
end
cd (curr_dir)
updateExptSetupFlist(handles)



function openEyelink_Callback(hObject, eventdata, handles)
global ex
ex = initEyelink(ex,handles);

function closeEyelink_Callback(hObject, eventdata, handles)
global ex
closeEyelink(ex);
ex.setup.el.elstart = [];
ex.setup.el.hasSamples = 0;


function SessionID_Callback(hObject, eventdata, handles)
global ex
ex.Header.SessionID = get(hObject,'String');
setGuiVariables(handles);


function SessionID_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function earlyReward_Callback(hObject, eventdata, handles)
global ex
ex.reward.earlyRewardTime = str2double(get(hObject,'String'));
if ex.exp.blockedFreeViewing
    ex.reward.blockedFreeViewing.earlyRewardTime(ex.freeViewing+1) = ...
        ex.reward.earlyRewardTime;
end
setGuiVariables(handles);


function earlyReward_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function duration_forEarlyReward_Callback(hObject, eventdata, handles)
global ex
ex.fix.duration_forEarlyReward = eval(['[' get(hObject,'String') ']']);
setGuiVariables(handles);

function duration_forEarlyReward_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function fixPCtr_Callback(hObject, eventdata, handles)
global ex
ex.fix.PCtr = eval(['[' get(hObject,'String') ']']);
setGuiVariables(handles);

function fixPCtr_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in storeNeuralData.
function storeNeuralData_Callback(hObject, eventdata, handles)
recording = get(hObject,'Value')

global ex
ex.setup.gv.recording = recording;

% --- Executes on selection change in targIconType.
function targIconType_Callback(hObject, eventdata, handles)
global ex
targ_list = cellstr(get(hObject,'String'));
ex.targ.icon.type = targ_list{get(hObject,'Value')};
setGuiVariables(handles);



function targIconType_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in targIconParamList.
function targIconParamList_Callback(hObject, eventdata, handles)
global ex
param_list = cellstr(get(hObject,'String'));
param_selected = param_list{get(hObject,'Value')};
param  = strtok(param_selected,' ');
val = eval(['ex.targ.icon.' param ';']);
% display the value of the selected stimulus parameter for editing
if ischar(val)
    set(handles.targIconVals,'String',val);
else set(handles.targIconVals,'String',num2str(val));
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function targIconParamList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to targIconParamList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function targIconVals_Callback(hObject, eventdata, handles)
global ex
% get selected parameter from stimParams listbox
param_list = cellstr(get(handles.targIconParamList,'String'));
param_selected = param_list{get(handles.targIconParamList,'Value')};

%get stimulus value from user input
val = (get(hObject,'String'));
eval(['ex.targ.icon.' param_selected ' = str2num(val);']);



% --- Executes during object creation, after setting all properties.
function targIconVals_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function spatialAttention_Callback(hObject, eventdata, handles)
global ex
SA = get(hObject,'Value');
ex.exp.spatialAttention = SA;


function nInstructionTrials_Callback(hObject, eventdata, handles)

global ex
nInst = str2num(get(hObject,'String'));
ex.exp.nInstructionTrials = nInst;

% make sure that nInstructionTrials doesn't exceed blocksize
if ex.exp.nInstructionTrials>= ex.exp.nTrialsInBlock
    ex.exp.nTrialsInBlock = ex.exp.nInstructionTrials + 1;
end
setGuiVariables(handles);



% --- Executes during object creation, after setting all properties.
function nInstructionTrials_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sz_Callback(hObject, eventdata, handles)
global ex
ex.stim.vals.sz = str2num(get(hObject,'String'));
setGuiVariables(handles);

% --- Executes during object creation, after setting all properties.
function sz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cornealReflexOff.
function cornealReflexOff_Callback(hObject, eventdata, handles)
% hObject    handle to cornealReflexOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cornealReflexOff



function nTrialsInBlock_Callback(hObject, eventdata, handles)
global ex
nTrialsBlock = str2num(get(hObject,'String'));
ex.exp.nTrialsInBlock = str2num(get(hObject,'String'));
setGuiVariables(handles);

% --- Executes during object creation, after setting all properties.
function nTrialsInBlock_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nTrialsInBlock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function preStimDuration_Callback(hObject, eventdata, handles)
global ex
ex.fix.preStimDuration = str2double(get(hObject,'String'));
setGuiVariables(handles);

% --- Executes during object creation, after setting all properties.
function preStimDuration_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in includeBigReward.
function includeBigReward_Callback(hObject, eventdata, handles)
global ex
ex.reward.includeBigReward = get(hObject,'Value');
setGuiVariables(handles);



function stimDuration_Callback(hObject, eventdata, handles)
global ex
ex.fix.stimDuration = str2double(get(hObject,'String'));
setGuiVariables(handles);


% --- Executes during object creation, after setting all properties.
function stimDuration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stimDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Experimenter.
function Experimenter_Callback(hObject, eventdata, handles)

global ex
name_list = cellstr(get(hObject,'String')); 
experimenter = name_list{get(hObject,'Value')} ;
ex.Header.experimenter = experimenter;


% --- Executes during object creation, after setting all properties.
function Experimenter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Experimenter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in flashCue.
function flashCue_Callback(hObject, eventdata, handles)
global ex
FC = get(hObject,'Value');
ex.exp.flashCue = FC;


% --- Executes on button press in AC.
function AC_Callback(hObject, eventdata, handles)
global ex
AC = get(hObject,'Value');
ex.exp.cuedUncuedAntiCorrelated = AC;


% --- Executes on button press in sleepOn.
function sleepOn_Callback(hObject, eventdata, handles)
global ex
ex=sendSleepStrobe(ex,ex.strobe.SLEEP_ON);


% --- Executes on button press in sleepOff.
function sleepOff_Callback(hObject, eventdata, handles)
global ex
ex=sendSleepStrobe(ex,ex.strobe.SLEEP_OFF);


% --- Executes on button press in optoStimCheckbox.
function optoStimCheckbox_Callback(hObject, eventdata, handles)
global ex
ex.setup.optoStim.flag = get(hObject,'Value');
setGuiVariables(handles);




function optoStimOnsetTimes_Callback(hObject, eventdata, handles)
% hObject    handle to optoStimOnsetTimes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of optoStimOnsetTimes as text
%        str2double(get(hObject,'String')) returns contents of optoStimOnsetTimes as a double
global ex
ex.setup.optoStim.onsetTimes = eval(['[' get(hObject,'String') ']']);
setGuiVariables(handles);



% --- Executes during object creation, after setting all properties.
function optoStimOnsetTimes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to optoStimOnsetTimes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function optoStimDurations_Callback(hObject, eventdata, handles)
% hObject    handle to optoStimDurations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of optoStimDurations as text
%        str2double(get(hObject,'String')) returns contents of optoStimDurations as a double

global ex
ex.setup.optoStim.durations = eval(['[' get(hObject,'String') ']']);
setGuiVariables(handles);



% --- Executes during object creation, after setting all properties.
function optoStimDurations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to optoStimDurations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in fUSTriggers.
function fUSTriggers_Callback(hObject, eventdata, handles)
global ex
ex.setup.fUS.flag = get(hObject,'Value');
setGuiVariables(handles);


function fUSTriggerLag_Callback(hObject, eventdata, handles)
% hObject    handle to fUSTriggerLag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global ex
ex.setup.fUS.triggerOnsetLag = eval(['[' get(hObject,'String') ']']);
setGuiVariables(handles);


% --- Executes during object creation, after setting all properties.
function fUSTriggerLag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fUSTriggerLag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
