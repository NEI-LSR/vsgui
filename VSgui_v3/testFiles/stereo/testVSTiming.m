function testVSTiming(ex)

% test why my display setup in VisStim is so much slower than the Datapixx
% stereodemo

nmax = 100000;

col1 = WhiteIndex(ex.screen_number);
%col1=3;
col2 = col1;
i = 1;
keyIsDown = 0;
center = [0 0];
sigma = 50;


% Stimulus settings:
numDots = 1000;
vel = 1;   % pix/frames
dotSize = 8;
dots = zeros(3, numDots);
xvel = 2*vel*rand(1,1)-vel;
yvel = 2*vel*rand(1,1)-vel;

xmax = RectWidth(ex.screenRect)/2;
ymax = RectHeight(ex.screenRect)/2;
xmax = min(xmax, ymax) / 2;
ymax = xmax;

f = 4*pi/xmax;
amp = 16;

dots(1, :) = 2*(xmax)*rand(1, numDots) - xmax;
dots(2, :) = 2*(ymax)*rand(1, numDots) - ymax;

gray_idx = ((BlackIndex(ex.screen_number)+WhiteIndex(ex.screen_number))/2)
Screen('SelectStereoDrawBuffer', ex.window, 0);
Screen('FillRect', ex.window, gray_idx);
Screen('FillRect', ex.window, [0 ] , ex.stereo.b_ROn);
Screen('FillRect', ex.window, [0] ,ex.stereo.b_ROff);

Screen('SelectStereoDrawBuffer', ex.window, 1);
Screen('FillRect', ex.window, gray_idx);
    Screen('FillRect', ex.window, [1 ], ex.stereo.b_LOn);
Screen('FillRect', ex.window, [0 ], ex.stereo.b_LOff);

Screen('Flip', ex.window);
pause(2)
t=[];
% Run until a key is pressed:
while length(t) < nmax
        %additional drawing commands to simulate my Trials
        Screen('FillRect', ex.overlay,0.5);
        Screen('FrameRect',ex.overlay,3,[500 300 700 800] );
        % draw FP
        Screen('Drawdots',ex.overlay,[700,200]',20,3);
    
    
    % Select left-eye image buffer for drawing:
    Screen('SelectStereoDrawBuffer', ex.window, 0);
    Screen('FillRect',ex.window,gray_idx);  % gray background to start
    % Draw left stim:
    %Screen('FillRect', ex.window, [0, 0,255], ex.stereo.b_LOn);
    Screen('DrawDots', ex.window, dots(1:2, :) + [dots(3, :)/2; zeros(1, numDots)], dotSize, col1, [ex.screenRect(3:4)/2], 1);
    %Screen('FrameRect', ex.overlay, [255 0 0], [], 5);
    Screen('FillRect', ex.window, [0 ] , ex.stereo.b_ROn);
    Screen('FillRect', ex.window, [0] ,ex.stereo.b_ROff);
    
    % Select right-eye image buffer for drawing:
    Screen('SelectStereoDrawBuffer', ex.window, 1);

    % Draw right stim:
    Screen('FillRect',ex.window,gray_idx);  % gray background to start
    Screen('DrawDots', ex.window, dots(1:2, :) - [dots(3, :)/2; zeros(1, numDots)], dotSize, col2, [ex.screenRect(3:4)/2], 1);
    %Screen('FrameRect', ex.overlay, [0 255 0], [], 5);
    Screen('FillRect', ex.window, [1 ], ex.stereo.b_LOn);
    Screen('FillRect', ex.window, [0 ], ex.stereo.b_LOff);

    % Flip stim to display and take timestamp of stimulus-onset after
    % displaying the new stimulus and record it in vector t:
    Screen('Drawdots',ex.overlay,[100 100],60,5)
    
    
    %Screen('DrawingFinished', ex.window);
    onset = Screen('Flip', ex.window);
    t = [t onset];
%pause(1)
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
