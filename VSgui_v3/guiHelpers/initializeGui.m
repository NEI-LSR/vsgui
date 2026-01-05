function initializeGui(handles)
% called by VSgui 
% initiates the VisStim program:
%       -sets the paths for VisStim
%       -opens the PTB screen
%       -opens Datapixx connection
%       -initates the experimental structure (ex)
%       -initiates Eyelink connection 
% heavily based on VisStim.m but adapted for my gui version of VisStim


% history
% 11/04/14  hn: wrote it
% 04.06/23  ik: deactivated loading of a default setup file because
%               it disrupts initializations by getDefaultSetting
% 04/20/23  ik: made eye calibration optional
% 08/15/25  hn: removed testFilesfolder with subfolders from matlab path


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% initial cleanup
AssertOpenGL; 
InitializeMatlabOpenGL; 
javaaddpath(which('MatlabGarbageCollector.jar'))

global ex myhandles
%clear ex
ex=[];

%% %%%%%%%%%%%%%%%%%%%%%%%%%%% set paths
r_dir = pwd;  %% assumes that VSgui is called from the VisStim root dir
addpath(genpath(r_dir));
rmpath(genpath (fullfile(r_dir,'testFiles')));

ex.setup.VSdirRoot = r_dir;
%% %%%%%%% initialize DataPix; (needs to be done before getDefaultSettings)
initDatapixx(ex);


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%% initialize experiment structure
ex = getDefaultSettings(ex);  

updateStoredEyecalList(handles)
updateExptSetupFlist(handles)
updateStimParamsList(handles)

% deactivate by ik, 2023.04.06. (fixed and reversed by hn 08/15/25)
cd ../setupFiles/ExptSetupFiles
default_setup = dir('default*.setup');
if  ~isempty(default_setup)
	neF = load(default_setup(1).name,'-mat')
else
	warndlg('default setup file does not exist')
    neF = ex;
end
neF.ex.fix.stimDuration = 1.5;

ex.stim = neF.ex.stim;
ex.exp = neF.ex.exp;
ex.fix = neF.ex.fix;



% get VisStim verstion
ex.Header.VisStimVersion = getVisStimVersion;

% get Matlab version
[ver, datestr] = version;
ex.Header.MatlabVersion.version = ver;
ex.Header.MatlabVersion.releaseDate = datestr;

myhandles = handles;
evalin('base','global ex');
evalin('base','global myhandles');

cd(r_dir)


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%% initialize the display 
ex=initDisplay(ex); %
pause(1)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%% initialize Eyelink 
ex = initEyelink(ex,handles)
   
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% calibrate EyeSignals comment out later
prompt = 'Do you want to calibrate eye signals? Y/N/L(Load calibration file) [Y]?';
str = input(prompt,'s');
if isempty(str)
    str = 'y';
end
switch lower(str)
    
    case 'y'
        ex = calibrateEye_rev(ex)
        disp('eye calibration done')
        
    case 'l'
        p = fileparts(ex.setup.VSdirRoot);
        [fn,pth] = uigetfile(p);
        load(fullfile(pth,fn),'eyeCal');
        ex.eyeCal = eyeCal;
        
    otherwise
end

cur_dir = cd([r_dir '/plotGui']);
disp('starting plotGui')
plotGui
cd(cur_dir);
disp(' plot random lines')
playRandomLines(ex)
disp('initializeGui done')