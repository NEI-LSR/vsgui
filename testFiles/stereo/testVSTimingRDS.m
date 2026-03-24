function testVSTiming(ex)

% test why my display setup in VisStim is so much slower than the Datapixx
% stereodemo


nmax = 100000;

col1 = WhiteIndex(ex.screen_number);
%col1=3;
col2 = BlackIndex(ex.screen_number);
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
ns=[];
ex.j=1;
ex.stim.seq=0.1;
ex.stim.vals.x0 = 7;

ex=makeStimulus(ex);
% Run until a key is pressed:
cnt = 1;
n=2;
while length(t) < nmax
    %additional drawing commands to simulate my Trials
    Screen('FillRect', ex.overlay,0.5);
    Screen('FrameRect',ex.overlay,3,[500 300 700 800] );
    % draw FP
    Screen('Drawdots',ex.overlay,[700,200]',20,3);
    Screen('Drawdots',ex.overlay,[100 100],60,5)
     ex.Trials(ex.j).framecnt = ex.Trials(ex.j).framecnt +1;
         
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
     Screen('SelectStereoDrawBuffer', ex.window, 0);
    
    % ---- left PTB stimulus
     Screen('DrawDots', ex.window, dots(1:2, :) + [dots(3, :)/2; ....
         zeros(1, numDots)], dotSize, col1, [ex.screenRect(3:4)/2], 1);
     
    % Draw left stim (my RDS)
%     Screen('DrawDots', ex.window, dotsL0(1:2, :) + [dotsL0(3, :)/2; ...
%         zeros(1,size(dotsL0,2))+400], ex.stim.vals.dotSz, col1);
    Screen('DrawDots', ex.window, dotsL1(1:2, :) + [dotsL1(3, :)/2; ...
        zeros(1,size(dotsL1,2))], ex.stim.vals.dotSz, col1);
%     Screen('DrawDots', ex.window, dotsL2(1:2, :) + [dotsL2(3, :)/2; ...
%         zeros(1,size(dotsL2,2))-400], ex.stim.vals.dotSz, col1);            
    
    % ----------------label the image 
    Screen('FillRect', ex.window, [0] , ex.stereo.b_ROn);
    Screen('FillRect', ex.window, [0] ,ex.stereo.b_ROff);
        
    
    % --------------------------------------------------------
    % ----------------draw ri eye image
    % --------------------------------------------------------
    % ----------------select StereoBuffer 
    Screen('SelectStereoDrawBuffer', ex.window, 1);
    % -----right PTB stimulus
     Screen('DrawDots', ex.window, dots(1:2, :) - [dots(3, :)/2; ...
         zeros(1, numDots)], dotSize, col2, [ex.screenRect(3:4)/2], 1);
    % -----Draw right stim (my RDS)
%     Screen('DrawDots', ex.window, dotsR(1:2, :) + [-dotsR(3, :)/2; ...
%         zeros(1,size(dotsR,2))+400], ex.stim.vals.dotSz, col2);
    Screen('DrawDots', ex.window, dotsR(1:2, :) + [-dotsR(3, :)/2; ...
        zeros(1,size(dotsR,2))], ex.stim.vals.dotSz, col2);
%     Screen('DrawDots', ex.window, dotsR(1:2, :) + [-dotsR(3, :)/2; ...
%         zeros(1,size(dotsR,2))-400], ex.stim.vals.dotSz, col2);   
    % ----------------label the image 
    Screen('FillRect', ex.window, [1 ], ex.stereo.b_LOn);
    Screen('FillRect', ex.window, [0 ], ex.stereo.b_LOff);
    

    % Flip stim to display and take timestamp of stimulus-onset after
    % displaying the new stimulus and record it in vector t:
    Screen('DrawingFinished', ex.window);
    onset = Screen('Flip', ex.window);
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
