function testVSTiming(ex)

AssertOpenGL;
% Define response key mappings, unify the names of keys across operating
% systems:
KbName('UnifyKeyNames');
space = KbName('space');
escape = KbName('ESCAPE');

ex.setup.screenNum = max(Screen('Screens'));
Screen('Preference', 'SkipSyncTests', 1); % This can be commented out on a well-bahaved system.

% Prepare pipeline for configuration. This marks the start of a list of
% requirements/tasks to be met/executed in the pipeline:
PsychImaging('PrepareConfiguration');

% Tell PTB we want to display on a DataPixx device:
PsychImaging('AddTask', 'General', 'UseDataPixx');

% Enable DATAPixx blueline support, and VIEWPixx scanning backlight for optimal 3D
Datapixx('Open');
%Datapixx('EnableVideoScanningBacklight');       % Only required if a VIEWPixx.
Datapixx('EnableVideoStereoBlueline');
Datapixx('SetVideoStereoVesaWaveform', 2);      % If driving NVIDIA glasses
% Datapixx('SetVideoStereoVesaWaveform', 0);    % If driving 3rd party emitter
Datapixx('SetPropixxDlpSequenceProgram' , 1);  % 1: Cumming3D mode; 0 back to normal
Datapixx('RegWr');

% % % prepare dual CLUT 
%PsychImaging('AddTask', 'General', 'FloatingPoint32Bit');
% PsychImaging('AddTask', 'General', 'EnableDataPixxM16OutputWithOverlay');
%PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');


stereoMode = 8;  % anaglyph mode: L/R shown in red and blue channels; 
% Datapixx Cumming3D should work in stereoMode 8
[ex.setup.window, windowRect]=PsychImaging('OpenWindow', ex.setup.screenNum, 0, [], [], [], stereoMode);
ex.setup.overlay = SetAnaglyphStereoParameters('CreateGreenOverlay',ex.setup.window);
% % % % load dual CLUTs
% monkeyClut = [0,0,0;0.5,.5,.5;.5,.5,.5;linspace(0, 1, 253)' * [1, 1, 1]];
% humanClut = [0,0,0;0,0,0;1,0,0;linspace(0, 1, 253)' * [1, 1, 1]];
% combinedClut = [monkeyClut; humanClut]; 
% overlayPtr = PsychImaging('GetOverlayWindow', windowPtr);
% Screen('LoadNormalizedGammaTable', windowPtr, combinedClut, 2);

nmax = 100000;
col1 = WhiteIndex(ex.setup.screenNum);
col2 = col1;
i = 1;
t=[];
keyIsDown = 0; 
center = [0 0];
sigma = 50;

% PTB Stimulus settings:
numDots = 1000;
vel = 1;   % pix/frames
dotSize = 8;
dots = zeros(3, numDots);
xvel = 2*vel*rand(1,1)-vel;
yvel = 2*vel*rand(1,1)-vel;
xmax = RectWidth(ex.setup.screenRect)/2;
ymax = RectHeight(ex.setup.screenRect)/2;
xmax = min(xmax, ymax) / 2;
ymax = xmax;
f = 4*pi/xmax;
amp = 16;
dots(1, :) = 2*(xmax)*rand(1, numDots) - xmax;
dots(2, :) = 2*(ymax)*rand(1, numDots) - ymax;

gray_idx = ((BlackIndex(ex.setup.screenNum)+WhiteIndex(ex.setup.screenNum))/2)
black_idx = BlackIndex(ex.setup.screenNum)
white_idx = WhiteIndex(ex.setup.screenNum)

% blank screen to start
Screen('SelectStereoDrawBuffer', ex.setup.window, 0); % right eye screen
Screen('FillRect', ex.setup.window, gray_idx);
Screen('FillRect', ex.setup.window, [0 ] , ex.setup.stereo.b_ROn);
Screen('FillRect', ex.setup.window, [0] ,ex.setup.stereo.b_ROff);
Screen('SelectStereoDrawBuffer', ex.setup.window, 1); % left eye screen
Screen('FillRect', ex.setup.window,gray_idx);
    Screen('FillRect', ex.setup.window, [0, 0, 1], ex.setup.stereo.b_LOn);
Screen('FillRect', ex.setup.window, [0, 0, 0], ex.setup.stereo.b_LOff);
Screen('Flip', ex.setup.window);

pause(1)

% get my RDS stimulus using VisStim code 
ex.j=1;
ex.stim.seq.hdx=0.1
ex.stim.vals.x0=7;
[ex,RDS]=makeStimulus(ex);
ex.Trials(1).RDS = RDS.dots;
cnt = 1;
% Run until a key is pressed:
while length(t) < nmax
    % -----------------------------------------------------------
    %-------------------- my RDS----------------------------
    cnt = cnt+1;
    %if round(cnt/3) == cnt/3
     ex.Trials(ex.j).framecnt = ex.Trials(ex.j).framecnt +1;  
    n = max([mod(ex.Trials(ex.j).framecnt,length(ex.Trials(ex.j).RDS)),2]);
    %end
    ex.Trials(ex.j).framecnt = n;
    dotsR = [ex.Trials(ex.j).RDS{n}([1:3],:)];
    dotsL0 = [ex.Trials(ex.j).RDS{n-1}([1:3],:)];
    dotsL1 = [ex.Trials(ex.j).RDS{n}([1:3],:)];
    dotsL2 = [ex.Trials(ex.j).RDS{n+1}([1:3],:)];  
    
    % --------------------------------------------------------
    % ----------------draw left eye image
    % --------------------------------------------------------
    % ----------------select StereoBuffer 
     Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
    
    % ---- left PTB stimulus
     Screen('DrawDots', ex.setup.window, dots(1:2, :) + [dots(3, :)/2; ....
         zeros(1, numDots)], dotSize, col1, [ex.setup.screenRect(3:4)/2], 1);
     
    % Draw left stim (my RDS)
    Screen('DrawDots', ex.setup.window, dotsL0(1:2, :) + [dotsL0(3, :)/2; ...
        zeros(1,size(dotsL0,2))+400], ex.stim.vals.dotSz, col1);
    Screen('DrawDots', ex.setup.window, dotsL1(1:2, :) + [dotsL1(3, :)/2; ...
        zeros(1,size(dotsL1,2))], ex.stim.vals.dotSz, col1);
    Screen('DrawDots', ex.setup.window, dotsL2(1:2, :) + [dotsL2(3, :)/2; ...
        zeros(1,size(dotsL2,2))-400], ex.stim.vals.dotSz, col1);            
    
    % ----------------label the image 
    Screen('FillRect', ex.setup.window, [0, 0, 1] , ex.setup.stereo.b_ROn);
    Screen('FillRect', ex.setup.window, [0, 0, 0] ,ex.setup.stereo.b_ROff);
        
    
    % --------------------------------------------------------
    % ----------------draw ri eye image
    % --------------------------------------------------------
    % ----------------select StereoBuffer 
    Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
    % -----right PTB stimulus
     Screen('DrawDots', ex.setup.window, dots(1:2, :) - [dots(3, :)/2; ...
         zeros(1, numDots)], dotSize, col2, [ex.setup.screenRect(3:4)/2], 1);
    % -----Draw right stim (my RDS)
    Screen('DrawDots', ex.setup.window, dotsR(1:2, :) + [-dotsR(3, :)/2; ...
        zeros(1,size(dotsR,2))+400], ex.stim.vals.dotSz, col2);
    Screen('DrawDots', ex.setup.window, dotsR(1:2, :) + [-dotsR(3, :)/2; ...
        zeros(1,size(dotsR,2))], ex.stim.vals.dotSz, col2);
    Screen('DrawDots', ex.setup.window, dotsR(1:2, :) + [-dotsR(3, :)/2; ...
        zeros(1,size(dotsR,2))-400], ex.stim.vals.dotSz, col2);   
    % ----------------label the image 
    Screen('FillRect', ex.setup.window, [0, 1, 0 ], ex.setup.stereo.b_LOn);
    Screen('FillRect', ex.setup.window, [0, 0, 0], ex.setup.stereo.b_LOff);
    
        % --------------------------------------------------------
    % ----------------draw left eye image
    % --------------------------------------------------------
    % ----------------select StereoBuffer 
     Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
    
    % ---- left PTB stimulus
     Screen('DrawDots', ex.setup.window, dots(1:2, :) + [dots(3, :)/2; ....
         zeros(1, numDots)], dotSize, col1, [ex.setup.screenRect(3:4)/2], 1);
     
    % Draw left stim (my RDS)
    Screen('DrawDots', ex.setup.window, dotsL0(1:2, :) + [dotsL0(3, :)/2; ...
        zeros(1,size(dotsL0,2))+400], ex.stim.vals.dotSz, col1);
    Screen('DrawDots', ex.setup.window, dotsL1(1:2, :) + [dotsL1(3, :)/2; ...
        zeros(1,size(dotsL1,2))], ex.stim.vals.dotSz, col1);
    Screen('DrawDots', ex.setup.window, dotsL2(1:2, :) + [dotsL2(3, :)/2; ...
        zeros(1,size(dotsL2,2))-400], ex.stim.vals.dotSz, col1);            
    
    % ----------------label the image 
    Screen('FillRect', ex.setup.window, [0, 0, 1] , ex.setup.stereo.b_ROn);
    Screen('FillRect', ex.setup.window, [0, 0, 0] ,ex.setup.stereo.b_ROff);
        
    
    % --------------------------------------------------------
    % ----------------draw ri eye image
    % --------------------------------------------------------
    % ----------------select StereoBuffer 
    Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
    % -----right PTB stimulus
     Screen('DrawDots', ex.setup.window, dots(1:2, :) - [dots(3, :)/2; ...
         zeros(1, numDots)], dotSize, col2, [ex.setup.screenRect(3:4)/2], 1);
    % -----Draw right stim (my RDS)
    Screen('DrawDots', ex.setup.window, dotsR(1:2, :) + [-dotsR(3, :)/2; ...
        zeros(1,size(dotsR,2))+400], ex.stim.vals.dotSz, col2);
    Screen('DrawDots', ex.setup.window, dotsR(1:2, :) + [-dotsR(3, :)/2; ...
        zeros(1,size(dotsR,2))], ex.stim.vals.dotSz, col2);
    Screen('DrawDots', ex.setup.window, dotsR(1:2, :) + [-dotsR(3, :)/2; ...
        zeros(1,size(dotsR,2))-400], ex.stim.vals.dotSz, col2);   
    % ----------------label the image 
    Screen('FillRect', ex.setup.window, [0, 1, 0 ], ex.setup.stereo.b_LOn);
    Screen('FillRect', ex.setup.window, [0, 0, 0], ex.setup.stereo.b_LOff);
    

    

    % Flip stim to display and take timestamp of stimulus-onset after
    % displaying the new stimulus and record it in vector t:
    Screen('DrawingFinished', ex.setup.window);
    onset = Screen('Flip', ex.setup.window);
    t = [t onset];    
    
    %Screen('DrawingFinished', ex.setup.window);
    onset = Screen('Flip', ex.setup.window);
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
        break;
    end
end


% Compute and show timing statistics:
dt = t(2:end) - t(1:end-1);
disp(sprintf('N.Dots\tMean (s)\tMax (s)\t%%>20ms\t%%>30ms\n'));
disp(sprintf('%d\t%5.3f\t%5.3f\t%5.2f\t%5.2f\n', numDots, mean(dt), max(dt), sum(dt > 0.020)/length(dt), sum(dt > 0.030)/length(dt)));
figure; hist(diff(t))
