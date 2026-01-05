function ex = playORnoise(ex)


stimPos = repmat(ex.fix.PCtr + ...
    deg2pixel([ex.stim.vals.x0, ex.stim.vals.y0],ex.setup),1,2);

objectRect = round(stimPos) + ...
    [-1, -1, 1, 1] * ex.stim.vals.figureSize/2;

if ex.setup.stereo.Display
    Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
    Screen('Blendfunction', ex.setup.window, GL_SRC_ALPHA, GL_ZERO);
    Screen('DrawTexture',ex.setup.window, ex.stim.vals.groundTexture,...
        [], ex.setup.screenRect, [], 0);
    
    
    if ex.Trials(ex.j).bvo == 1
        Screen('Blendfunction', ex.setup.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        Screen('DrawTexture',ex.setup.window, ex.stim.vals.figureTexture,...
            [], objectRect, [], 0);
    end

    
    Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
    Screen('Blendfunction', ex.setup.window, GL_SRC_ALPHA, GL_ZERO);
    Screen('DrawTexture',ex.setup.window, ex.stim.vals.groundTexture,...
        [], ex.setup.screenRect, [], 0);

    if ex.Trials(ex.j).bvo == 1
        Screen('Blendfunction', ex.setup.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        Screen('DrawTexture',ex.setup.window, ex.stim.vals.figureTexture,...
            [], objectRect, [], 0);
    end
    
else
    Screen('Blendfunction', ex.setup.window, GL_SRC_ALPHA, GL_ZERO);
    Screen('DrawTexture',ex.setup.window, ex.stim.vals.groundTexture,...
        [], ex.setup.screenRect, [], 0);
    if ex.Trials(ex.j).bvo == 1
        Screen('Blendfunction', ex.setup.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        Screen('DrawTexture',ex.setup.window, ex.stim.vals.figureTexture,...
            [], objectRect, [], 0);
    end

end
