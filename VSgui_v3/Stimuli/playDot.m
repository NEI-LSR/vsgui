function ex = playDot(ex)

% change luminance of bar according to flickerTF
%dotCol = ex.stim.vals.col;
if ex.stim.vals.co == 1
    dotCol = 255;
elseif ex.stim.vals.co == -1
    dotCol = 0;
else
    error('unknown contrast')
end

%dotPos = round([deg2pixel(ex.stim.vals.x0,ex.setup) + ex.setup.screenRect(3)/2,...
%    deg2pixel(ex.stim.vals.y0,ex.setup) + ex.setup.screenRect(4)/2])';
dotPos = round([deg2pixel(ex.stim.vals.x0,ex.setup) + ex.fix.PCtr(1),...
    deg2pixel(ex.stim.vals.y0,ex.setup) + ex.fix.PCtr(2)])';

dotSz = round(deg2pixel(ex.stim.vals.sz,ex.setup));


if ex.setup.stereo.Display
    if ex.stim.vals.me>=0
        % Select right-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
        % Draw right stim:
        Screen('Drawdots',ex.setup.window,dotPos,dotSz,dotCol);
    end
    if ex.stim.vals.me<=0
    %     % Select left-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
        % Draw left stim:
        Screen('Drawdots',ex.setup.window,dotPos,dotSz,dotCol);
    end
end
