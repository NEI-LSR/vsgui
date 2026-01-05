function ex = getDefaultEyelinkSettings(ex)
% function ex = getDefaultEyelinkSettings(ex)
% here we define the default eyelink parameters when VS is started.
% Datapixx AdcChannel settings are also defined (ADC channels used for eye
% data)
%
% These definitions were previously included in 'getDefaultSettings.m' but
% I moved them here for better readability of the code.
% This function is called by 'getDefaultSettings.m'.
% Parameters are stored in ex.setup.el.XX and ex.setup.adc.XX

% history
% 08/18/25  hn: wrote it; 

%% Eyelink 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% monocular or binocular eye signals %%%%
button = questdlg('are we recording monocular or binocular eye signals?' ...
    ,'','monocular','binocular','binocular');
switch button
    case 'monocular'
        ex.setup.el.binoc = 0;
    case 'binocular'
        ex.setup.el.binoc = 1;
    case 'cancel'
        disp('forced exit: please respond whether you want to record monocular or binocular eye signals');
        return
end

ex.setup.el.edfFileName = 'tmp.edf';
ex.setup.el.Cmd_SampleData = 'link_sample_data = LEFT,RIGHT,GAZE,AREA,INPUT,HTARGET';
% added by IK, 2024.07.10. % hn: doesn't appear to be used
ex.setup.eyeToCheck = 0;  

%% Datapixx AdcChannel settings  (Adc channels used for eye data)
ex.setup.adc.Rate = 500; % 500/sec is the max rate for binocular data in Eyelink
if ex.setup.el.binoc
    ex.setup.adc.Channels = 0:5;  % channels 0 to 5 for binocular data
    ex.setup.adc.DiffChannels = [0,0,0,0,0,0]; % 0:= compute no differential voltages;
    % the last channel labeled 'ST' from the analog breakout box is also
    % stored as adc channel 7
    ex.setup.adc.Channels = [ex.setup.adc.Channels, 6];
    ex.setup.adc.DiffChannels = [ex.setup.adc.DiffChannels, 0];
else
    ex.setup.adc.Channels = 0:2;  % channels 0 to 2 for monocular data
    ex.setup.adc.DiffChannels = [0,0,0]; % 0:= compute no differential voltages;
end
% for more information: http://docs.psychtoolbox.org/SetAdcSchedule
ex.setup.adc.BufferBaseAddress = 0;  % our default AdcBufferAddress

% %% initialize Adc Channels to make sure it works  % need to include some checks
resetAdcBuffer(ex)  