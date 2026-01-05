function ex = playFullField(ex)
% creates a full field stimulus 
% 
%history
%
% 06/30/22  wrote it

if isempty(ex.stim.vals.lu_seq)
    % compute luminance of fullfield flash within allowed range
    lu = round(ex.idx.white*ex.Trials(ex.j).co);
    if lu<ex.idx.black
        lu = ex.idx.black;
    end
    if lu>ex.idx.white
        lu = ex.idx.white;
    end
else
    % ik: to avoid an error when framecnt > length(lu_seq), 2023.01.06
    framecnt = min([length(ex.stim.vals.lu_seq),ex.stim.vals.framecnt]);
    lu = ex.stim.vals.lu_seq(framecnt);
    %lu = ex.stim.vals.lu_seq(ex.stim.vals.framecnt);
    ex.stim.vals.framecnt = ex.stim.vals.framecnt+1;
end
    

%sprintf('lu: %d',lu)
if ex.setup.stereo.Display
    %disp('in stereodisplay')
    % Select right-eye image buffer for drawing:
    Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
     Screen('FillRect',ex.setup.window,lu);

%     
%     % Select left-eye image buffer for drawing:
    Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
    % Draw left stim:
    Screen('FillRect',ex.setup.window,lu);  
else
    Screen('FillRect',ex.setup.window,lu);  
end

%%
%Screen('Flip', ex.setup.window);
