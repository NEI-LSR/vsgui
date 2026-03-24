 function DatapixxImagingStereoDemo()
%
% Taken from the iconic PTB ImagingStereoDemo,
% slightly modified to drive DATAPixx/VIEWPixx/PROPixx.
% 07/09/14      hn: test Mario's 'CreateGreenOverlay' 
%
% Press any key to exit demo.
%

% This script calls Psychtoolbox commands available only in OpenGL-based
% versions of the Psychtoolbox. (So far, the OS X Psychtoolbox is the
% only OpenGL-base Psychtoolbox.)  The Psychtoolbox command
% AssertPsychOpenGL will issue
% an error message if someone tries to execute this script on a computer without
% an OpenGL Psychtoolbox
AssertOpenGL;

% Define response key mappings, unify the names of keys across operating
% systems:
KbName('UnifyKeyNames');
space = KbName('space');
escape = KbName('ESCAPE');

% Hardware stereo buffers are a great idea, but they just seem to be broken on so many systems.
% Set to 1 to try it out, or set to 0 to implement software frame-alternate buffers.
useHardwareStereo = 1;

try
% Get the list of Screens and choose the one with the highest screen number.
% Screen 0 is, by definition, the display with the menu bar. Often when
% two monitors are connected the one without the menu bar is used as
% the stimulus display.  Chosing the display with the highest dislay number is
% a best guess about where you want the stimulus displayed.
scrnNum = max(Screen('Screens'));

% Increase level of verbosity for debug purposes:
%Screen('Preference', 'Verbosity', 6);
Screen('Preference', 'SkipSyncTests', 1); % This can be commented out on a well-bahaved system.

% Prepare pipeline for configuration. This marks the start of a list of
% requirements/tasks to be met/executed in the pipeline:
PsychImaging('PrepareConfiguration');

% Tell PTB we want to display on a DataPixx device:
PsychImaging('AddTask', 'General', 'UseDataPixx');

% Decrease GPU workload
%PsychImaging('AddTask', 'AllViews', 'RestrictProcessing', CenterRect([0 0 512 512], Screen('Rect', scrnNum)));

% Enable DATAPixx blueline support, and VIEWPixx scanning backlight for optimal 3D
Datapixx('Open');
%Datapixx('EnableVideoScanningBacklight');       % Only required if a VIEWPixx.
Datapixx('EnableVideoStereoBlueline');
%Datapixx('SetVideoStereoVesaWaveform', 2);      % If driving NVIDIA glasses
% Datapixx('SetVideoStereoVesaWaveform', 0);    % If driving 3rd party emitter
Datapixx('SetPropixxDlpSequenceProgram' , 1);  % 1: Cumming3D mode; 0 back to normal

Datapixx('RegWr');

% Consolidate the list of requirements (error checking etc.), open a
% suitable onscreen window and configure the imaging pipeline for that
% window according to our specs. The syntax is the same as for
% Screen('OpenWindow'):

% use R/B anaglyph stereo-mode
[windowPtr, windowRect]=PsychImaging('OpenWindow', scrnNum, 0, [], [], [], 8); 

% get pinter to green overlay window to draw to this window directly
overlayPtr = SetAnaglyphStereoParameters('CreateGreenOverlay',windowPtr);
%overlayPtr = SetAnaglyphStereoParameters('CreateBlueOverlay',windowPtr);

% There seems to be a blueline generation bug on some OpenGL systems.
% SetStereoBlueLineSyncParameters(windowPtr, windowRect(4)) corrects the
% bug on some systems, but breaks on other systems.
% We'll just disable automatic blueline, and manually draw our own bluelines!
if useHardwareStereo == 1
    SetStereoBlueLineSyncParameters(windowPtr, windowRect(4)+10);
end
blueRectLeftOn   = [0,                 windowRect(4)-1, windowRect(3)/4,   windowRect(4)];
blueRectLeftOff  = [windowRect(3)/4,   windowRect(4)-1, windowRect(3),     windowRect(4)];
blueRectRightOn  = [0,                 windowRect(4)-1, windowRect(3)*3/4, windowRect(4)];
blueRectRightOff = [windowRect(3)*3/4, windowRect(4)-1, windowRect(3),     windowRect(4)];

% Stimulus settings:
numDots = 1000;
vel = 1;   % pix/frames
dotSize = 8;
dots = zeros(3, numDots);

xmax = RectWidth(windowRect)/2;
ymax = RectHeight(windowRect)/2;
xmax = min(xmax, ymax) / 2;
ymax = xmax;

f = 4*pi/xmax;
amp = 16;

dots(1, :) = 2*(xmax)*rand(1, numDots) - xmax;
dots(2, :) = 2*(ymax)*rand(1, numDots) - ymax;
gray_idx = round((BlackIndex(scrnNum)+WhiteIndex(scrnNum))/2)
BlackIndex(scrnNum)
WhiteIndex(scrnNum)
% Initially fill left- and right-eye image buffer with gray background
% color:
if useHardwareStereo == 1
    Screen('SelectStereoDrawBuffer', windowPtr, 0);
    Screen('FillRect', windowPtr, gray_idx);
    Screen('SelectStereoDrawBuffer', windowPtr, 1);
    Screen('FillRect', windowPtr, gray_idx);
    Screen('Flip', windowPtr);
else
    Screen('FillRect', windowPtr, round((BlackIndex(scrnNum)+WhiteIndex(scrnNum))/2));
    Screen('Flip', windowPtr);
end



% Set up alpha-blending for smooth (anti-aliased) drawing of dots:
%Screen('BlendFunction', windowPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

col1 = WhiteIndex(scrnNum);
col2 = col1;
i = 1;
keyIsDown = 0;
center = [0 0];
sigma = 50;
xvel = 2*vel*rand(1,1)-vel;
yvel = 2*vel*rand(1,1)-vel;

Screen('Flip', windowPtr);

% Maximum number of animation frames to show:
nmax = 100000;

% Perform a flip to sync us to vbl and take start-timestamp in t:
t = Screen('Flip', windowPtr);

% Run until a key is pressed:
while length(t) < nmax

    % Select left-eye image buffer for drawing:
if useHardwareStereo == 1
    Screen('SelectStereoDrawBuffer', windowPtr, 0);
end

    % Draw left stim:
    Screen('DrawDots', windowPtr, dots(1:2, :) + [dots(3, :)/2; zeros(1, numDots)], dotSize, col1, [windowRect(3:4)/2], 1);
    Screen('FrameRect', windowPtr, [255 0 0], [], 5);
    Screen('FillRect', windowPtr, [0, 0, 255], blueRectLeftOn);
    Screen('FillRect', windowPtr, [0, 0, 0], blueRectLeftOff);

    % Select right-eye image buffer for drawing:
if useHardwareStereo == 1
    Screen('SelectStereoDrawBuffer', windowPtr, 1);
else
    Screen('DrawingFinished', windowPtr);
    onset = Screen('Flip', windowPtr);
    t = [t onset];
end

    % Draw right stim:
    Screen('DrawDots', windowPtr, dots(1:2, :) - [dots(3, :)/2; zeros(1, numDots)], dotSize, col2, [windowRect(3:4)/2], 1);
    Screen('FrameRect', windowPtr, [0 255 0], [], 5);
    Screen('FillRect', windowPtr, [0, 0, 255], blueRectRightOn);
    Screen('FillRect', windowPtr, [0, 0, 0], blueRectRightOff);
    
    %additional drawing commands to simulate my Trials
    %Screen('FillRect', overlayPtr,[0 0 0]);
    % Screen('FrameRect',overlayPtr,[1],[500 300 700 800] );
%     % draw FP
     Screen('Drawdots',overlayPtr,[200 200]',20,[255]);


    % Flip stim to display and take timestamp of stimulus-onset after
    % displaying the new stimulus and record it in vector t:
    Screen('DrawingFinished', windowPtr);
    onset = Screen('Flip', windowPtr);
    t = [t onset];

    % Now all non-drawing tasks:

    % Compute dot positions and offsets for next frame:
    center = center + [xvel yvel];
    if center(1) > xmax | center(1) < -xmax
        xvel = -xvel;
    end

    if center(2) > ymax | center(2) < -ymax
        yvel = -yvel;
    end

    dots(3, :) = -amp.*exp(-(dots(1, :) - center(1)).^2 / (2*sigma*sigma)).*exp(-(dots(2, :) - center(2)).^2 / (2*sigma*sigma));

    % Keypress ends demo
    [pressed dummy keycode] = KbCheck;
    if pressed
        figure; hist(diff(t))
        break;
    end
end

% Last Flip:
Screen('Flip', windowPtr);

% Done. Close the onscreen window:
Screen('CloseAll')
Datapixx('Close');

% Compute and show timing statistics:
dt = t(2:end) - t(1:end-1);
disp(sprintf('N.Dots\tMean (s)\tMax (s)\t%%>20ms\t%%>30ms\n'));
disp(sprintf('%d\t%5.3f\t%5.3f\t%5.2f\t%5.2f\n', numDots, mean(dt), max(dt), sum(dt > 0.020)/length(dt), sum(dt > 0.030)/length(dt)));

% We're done.
return;
catch
% Executes in case of an error: Closes onscreen window:
Screen('CloseAll');
Datapixx('Close');
psychrethrow(psychlasterror);
end;
