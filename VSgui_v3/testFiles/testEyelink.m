function res = testEyelink

% based on Eyelink Toolbox Demofiles
clear all;
commandwindow;

try
    
    %% STEP 1
    % Open a graphics window on the main screen
    screenNumber=max(Screen('Screens'));
    [window, wRect]=Screen('OpenWindow', screenNumber);
    % STEP 2
    % Provide Eyelink with details about the graphics environment
    % and perform some initializations. The information is returned
    % in a structure that also contains useful defaults
    % and control codes (e.g. tracker state bit and Eyelink key values).
    el=EyelinkInitDefaults(window);
    % STEP 3
    % Initialization of the connection with the Eyelink Gazetracker.
    EyelinkInit()
    % open file for recording data
    edfFile='demo.edf';
    Eyelink('Openfile', edfFile);
    % Start Recording
    Eyelink('StartRecording');
    el.elstart = Eyelink('TrackerTime');

    el.hasSamples = true; el.hasEvents = true;
    eye_used = Eyelink('EyeAvailable');
    Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA,INPUT,HMARKER');
    Eyelink('command','inputword_is_window = ON')
    [samples, events, drained] = Eyelink('GetQueuedData',eye_used);
    %%

catch myerr
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if it's open.
    cleanup;
    myerr
    myerr.message
    myerr.stack
    
end
    
    
 % Cleanup routine:
function cleanup
% Shutdown Eyelink:
Eyelink('Shutdown');

commandwindow;
% Restore keyboard output to Matlab:
ListenChar(0);   
