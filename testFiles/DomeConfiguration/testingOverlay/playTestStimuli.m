function ex = playTestStimuli(ex)
% taken from:
% function ex = playCalibrationLines(ex)
%
% displays lines of random orientations with spacing pixels between them
% on left and right eye images to align projectors with
%%
xposb = round(rand(1,100)*ex.setup.screenRect(3));
yposb = round(rand(1,100)*ex.setup.screenRect(4));

xposw = round(rand(1,100)*ex.setup.screenRect(3));
yposw = round(rand(1,100)*ex.setup.screenRect(4));

widths = round(rand(1,100)*10)+1;
widths(find(widths>10)) = deal(10);


%%
linesXY_black = [xposb;yposb];
linesXY_white = [xposw;yposw];

if ex.setup.stereo.Display
    %disp('in stereodisplay')
    % Select right-eye image buffer for drawing:
    Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
     Screen('FillRect',ex.setup.window,ex.idx.bg);  % background to start 
    % Draw right stim:
    
    Screen('DrawLines', ex.setup.window, linesXY_white, widths, ex.idx.white);
    Screen('DrawLines', ex.setup.window, linesXY_black, widths, ex.idx.black);
    
    % Select left-eye image buffer for drawing:
    Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
    % Draw left stim:
    Screen('FillRect',ex.setup.window,ex.idx.bg);  % background to start
    Screen('DrawLines', ex.setup.window, linesXY_white, widths, ex.idx.white);
    Screen('DrawLines', ex.setup.window, linesXY_black, widths, ex.idx.black);
else
    Screen('FillRect',ex.setup.window,ex.idx.bg);  % background to start 
    
    % A) lines
    linesx = reshape(ones(2,1)*[round(ex.setup.screenRect(3)/2):10:round(ex.setup.screenRect(3)/2)+200],1,42);
    linesy = repmat([round(ex.setup.screenRect(4)/2),100],1,21);
    linesXY = [linesx;linesy];

    %cols = [-1:.1:1]; 
    % drawlines: colors go from -1 to 1 
    %cols = reshape(ones(6,1)*[-1:.1:1],3,42);
    cols = repmat([-1*ones(3,1),ones(3,1)],1,21)
    Screen('DrawLines', ex.setup.window, linesXY, 5,cols);

    % B) rect
    % fillrect: colors go from -1 to 1 but need to be given as 3-by-n
    % column matrix (same scalar color for each RGB row works)
    rect = repmat([0 0 20 20]',1,21) + ones(4,1)*[400:20:800];
    cols = reshape(ones(3,1)*[-1:.1:1],3,21);
    Screen('FillRect',ex.setup.window,cols,rect);
    
    rect1 = round(ex.setup.screenRect/2);
    Screen('FillRect',ex.setup.window,.5,rect1);
    
    % Draw right stim
    Screen('DrawLines', ex.setup.window, linesXY_white, widths, ex.idx.white);
    %Screen('DrawLines', ex.setup.window, linesXY_black, widths, ex.idx.black);
    
end



%%
Screen('Flip', ex.setup.window);

