function ex = playCalibrationLines(ex,spacing)
% function ex = playCalibrationLines(ex)
%
% displays vertical and horizontal lines with spacing pixels between them
% on left and right eye images to align projectors with
%%
vert =[];
for n = ex.setup.screenRect(3)/2:-spacing:0
    vert = [vert,[n n;ex.setup.screenRect(4) 0]];
end
for n = ex.setup.screenRect(3)/2:spacing:ex.setup.screenRect(3)
    vert = [vert,[n n;ex.setup.screenRect(4) 0]];
end
    
hor = [];
for n = ex.setup.screenRect(4)/2:-spacing:0
    hor = [hor, [0 ex.setup.screenRect(3);n n]];
end
for n = ex.setup.screenRect(4)/2:spacing:ex.setup.screenRect(4)
    hor = [hor, [0 ex.setup.screenRect(3);n n]];
end

%%
linesXY = [hor,vert];
midLines = [ex.setup.screenRect(3)/2*ones(1,2); ex.setup.screenRect(4) 0];
midLines =[midLines,[0 ex.setup.screenRect(3); ex.setup.screenRect(4)/2*ones(1,2)]];
%%

if ex.setup.stereo.Display
    %disp('in stereodisplay')
    % Select right-eye image buffer for drawing:
    Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
     Screen('FillRect',ex.setup.window,ex.idx.bg);  % background to start 
    % Draw right stim:
    
    Screen('DrawLines', ex.setup.window, linesXY, 1, ex.idx.white);
    Screen('DrawLines', ex.setup.window, midLines, 1, ex.idx.black);
    
    % Select left-eye image buffer for drawing:
    Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
    % Draw left stim:
    Screen('FillRect',ex.setup.window,ex.idx.bg);  % background to start
    Screen('DrawLines', ex.setup.window, linesXY, 1, ex.idx.white) ;
    Screen('DrawLines', ex.setup.window, midLines, 1, ex.idx.black);
else
    Screen('FillRect',ex.setup.window,ex.idx.bg);  % background to start 
    Screen('DrawLines', ex.setup.window, linesXY, 1, ex.idx.white);
    Screen('DrawLines', ex.setup.window, midLines, 1, ex.idx.black);

end
%%
Screen('Flip', ex.setup.window);

