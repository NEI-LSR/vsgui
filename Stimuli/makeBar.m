function ex = makeBar(ex)
% creates an oriented bar as stimulus
% barwidth has to be <=64
%
% history
% a long time ago
% 04/30/24  hn: added stereo mode


dpp = atan(ex.setup.monitorWidth/2/ex.setup.viewingDistance)*180/pi/(ex.setup.screenRect(3)/2);  % degrees per pixes
ppd = 1/dpp;  % pixels per degree
%%
t = ex.stim.vals.or/180*pi; % orientation in radians
cs = [cos(t), sin(t)];
linesXY = cs'*[-ex.stim.vals.hi/2*ppd ex.stim.vals.hi/2*ppd];
linesXY = linesXY + [ex.stim.vals.x0*ppd+ex.fix.PCtr(1); ex.stim.vals.y0*ppd+ex.fix.PCtr(2)]*ones(1,2);
width = min([ex.stim.vals.wi*ppd,64]);  % barwidth has to be <=64
%%


if ex.setup.stereo.Display
    %disp('in stereodisplay')
    % Select right-eye image buffer for drawing:
    Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
     Screen('FillRect',ex.setup.window,ex.idx.bg);  % background to start 
    % Draw right stim:
    
    Screen('DrawLines', ex.setup.window, linesXY, width, ex.idx.white);
        Screen('FillRect', ex.setup.window, [0] , ex.setup.stereo.b_ROn);
    Screen('FillRect', ex.setup.window, [0] ,ex.setup.stereo.b_ROff);

%     
%     % Select left-eye image buffer for drawing:
    Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
    % Draw left stim:
    Screen('FillRect',ex.setup.window,ex.idx.bg);  % background to start
    Screen('DrawLines', ex.setup.window, linesXY, width, ex.idx.white) ;
    Screen('FillRect', ex.setup.window, [1] , ex.setup.stereo.b_LOn);
    Screen('FillRect', ex.setup.window, [0] ,ex.setup.stereo.b_LOff);
else
     Screen('FillRect',ex.setup.window,ex.idx.bg);  % background to start 
    Screen('DrawLines', ex.setup.window, linesXY, width, ex.idx.white);
end
%%
Screen('Flip', ex.setup.window);
