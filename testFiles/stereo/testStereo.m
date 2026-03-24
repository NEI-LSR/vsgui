function testStereo

% function testStereo
%
% helper function trying to figure out how to integrate the Stereosettings
% in DatapixxImagingStereoDemo with the dual CLUT setup
%
% ToDos:
% 
% history
% 11/15/13  hn:  wrote it

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% open PTB window:
AssertOpenGL; 
InitializeMatlabOpenGL; 
javaaddpath(which('MatlabGarbageCollector.jar'))
global ex

ex.screen_number = max(Screen('Screens'));
[ex.window, ex.screenRect] = Screen('OpenWindow',ex.screen_number,0);
ex.refreshrate = FrameRate(ex.window);

ex = getDefaultSettings(ex);

PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'UseDataPixx');
% PsychImaging('AddTask', 'General', 'FloatingPoint32Bit');
% PsychImaging('AddTask', 'General', 'EnableDataPixxM16OutputWithOverlay');
% PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
% [ex.window, ex.screenRect] = PsychImaging('OpenWindow', ex.window);
% 
% disp('set up CLUTs for Mac')
% 
% combinedClut = [ex.monkeyClut;ex.humanClut]; 
% ex.overlay = PsychImaging('GetOverlayWindow', ex.window);
% Screen('LoadNormalizedGammaTable', ex.window, combinedClut, 2);

% open Datapixx
Datapixx('Open');
Datapixx('StopAllSchedules');
Datapixx('EnableVideoStereoBlueline');
Datapixx('SetVideoStereoVesaWaveform', 2);      % If driving NVIDIA glasses
% Datapixx('SetVideoStereoVesaWaveform', 0);    % If driving 3rd party emitter
Datapixx('RegWrRd')



% We'll just disable automatic blueline, and manually draw our own bluelines!
blueRectLeftOn   = [0,                 ex.screenRect(4)-1, ex.screenRect(3)/4,   ex.screenRect(4)];
blueRectLeftOff  = [ex.screenRect(3)/4,   ex.screenRect(4)-1, ex.screenRect(3),     ex.screenRect(4)];
blueRectRightOn  = [0,                 ex.screenRect(4)-1, ex.screenRect(3)*3/4, ex.screenRect(4)];
blueRectRightOff = [ex.screenRect(3)*3/4, ex.screenRect(4)-1, ex.screenRect(3),     ex.screenRect(4)];


% Initially fill left- and right-eye image buffer with black background
% color:
Screen('FillRect', ex.window, ex.idx.bg);
Screen('Flip', ex.window);

% Set up alpha-blending for smooth (anti-aliased) drawing of dots:
Screen('BlendFunction', ex.window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
frametimestep = 1/ex.refreshrate;
trstart = GetSecs;  % start of trial time
ttime = GetSecs-trstart; %  trial time
stimduration = 10;


% Stimulus settings:
numDots = 1000;
vel = 1;   % pix/frames  % ??
dotSize = 8;
dots = zeros(3, numDots);

xmax = RectWidth(ex.screenRect)/2;
ymax = RectHeight(ex.screenRect)/2;
xmax = min(xmax, ymax) / 2;
ymax = xmax;

f = 4*pi/xmax;
amp = 16;

dots(1, :) = 2*(xmax)*rand(1, numDots) - xmax ; %+ ex.fixPCtr(1);  % dots to upper right quadrant
dots(2, :) = 2*(ymax)*rand(1, numDots) - ymax  ; %+ ex.fixPCtr(2);

center = [0 0];
sigma = 50;
xvel = 2*vel*rand(1,1)-vel;
yvel = 2*vel*rand(1,1)-vel;

col1 = WhiteIndex(ex.screen_number)
col2 = col1;
% col1 = 1;
% col2 = 1; 
t=[];

while ttime>0 && ttime<stimduration
    
    % Draw left stim:
    Screen('DrawDots', ex.window, dots(1:2, :) + [dots(3, :)/2; ...
        zeros(1, numDots)], dotSize, col1, [ex.screenRect(3:4)/2], 1);
%     Screen('FrameRect', ex.window, [255 0 0], [], 5);
%     Screen('FillRect', ex.window, [0, 0, 255], blueRectLeftOn);
%     Screen('FillRect', ex.window, [0, 0, 0], blueRectLeftOff);

    
%     % Draw FP
%     Screen('Drawdots',ex.overlay,ex.fixPCtr,2,ex.idx.white);
    
    Screen('DrawingFinished', ex.window);
    onset = Screen('Flip', ex.window);
    t = [t onset];
    
    % Draw right stim:
    Screen('DrawDots', ex.window, dots(1:2, :) - [dots(3, :)/2; ...
        zeros(1, numDots)], dotSize, col2, [ex.screenRect(3:4)/2], 1);
%     Screen('FrameRect', ex.window, [0 255 0], [], 5);
%     Screen('FillRect', ex.window, [0, 0, 255], blueRectRightOn);
%     Screen('FillRect', ex.window, [0, 0, 0], blueRectRightOff);
    
    % Draw fixation window on experimenter's screen
    Screen('FrameRect',ex.window,ex.idx.overlayRed,[-ex.fixWinW -ex.fixWinH ...
        ex.fixWinW ex.fixWinH] + [ex.fixPCtr ex.fixPCtr]);
    % Draw FP  (making sure FP is presented binocularly)
    Screen('Drawdots',ex.window,ex.fixPCtr,6',ex.idx.overlayRed);
    

    % Flip stim to display and take timestamp of stimulus-onset after
    % displaying the new stimulus and record it in vector t:
    Screen('DrawingFinished', ex.window);
    onset = Screen('Flip', ex.window);
    t = [t onset];

    % Compute dot positions and offsets for next frame:
    center = center + [xvel yvel];
    if center(1) > xmax | center(1) < -xmax
        xvel = -xvel;
    end

    if center(2) > ymax | center(2) < -ymax
        yvel = -yvel;
    end

    dots(3, :) = -amp.*exp(-(dots(1, :) - center(1)).^2 / ...
        (2*sigma*sigma)).*exp(-(dots(2, :) - center(2)).^2 / (2*sigma*sigma));
    
    ttime = GetSecs-trstart;
    
end

figure; 
hist(diff(t))

