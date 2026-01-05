function to
% function tout (time out)
% time out from command line in VisStim withouth Expt running

% history
%           hn: wrote it
% 07/14/14  hn: -included field 'setup' and moved setup parameters into it
%               new parameter name          old parameter name
%               ex.setup.stereo             ex.stereo
%               ex.setup.window             ex.window
%               ex.setup.overlay            ex.overlay


global ex

if ex.setup.stereo.Display
    
    Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
    Screen('FillRect',ex.setup.window,0);  % black background
    % Select left-eye image buffer for drawing:
    Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
    % Draw left stim:
    Screen('FillRect',ex.setup.window,0);  % black background

else
    
    Screen('FillRect', ex.setup.overlay,ex.idx.black);
    Screen('FillRect',ex.setup.window,0);
    Screen('Flip', ex.setup.window);
end
