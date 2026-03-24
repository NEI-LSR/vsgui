function ex=playGrating(ex,stimOnDur)
% display drifting grating

% history

%2014       hn: wrote it
% 07/11/14  hn: -included field 'setup' and moved setup parameters into it
%               new parameter name          old parameter name
%               ex.setup.stereo             ex.stereo
%               ex.setup.window             ex.window
%               ex.setup.overlay            ex.overlay
% 07/31/14  hn: included option for monocular display
% 08/27/14  hn: included adaptation option
% 08/28/14  hn: included blank/monocular stimulus options
% 02/14/16  hn: we now start on framecnt = 1 to simplify things for the RC
%           stimulus. We need to accommodate this change here.
%           To compute xoffset here, I now use (sv.framecnt -1) instead of
%           sv.framecnt
% 08/06/18  hn: added option to display 2nd stimulus

sv = ex.stim.vals; % stimulus values
or = sv.or;
st = sv.st;
me = sv.me;
if sv.adaptation && stimOnDur<sv.adaptationDur
    or = sv.adaptationOr;
    me = sv.adaptationMe;
    st = 1;  % make sure we are always displaying the adapter
end
xoffset = mod(sv.period/sv.phase+(sv.framecnt-1)*sv.shiftperframe,sv.period);
ex.stim.vals.framecnt = sv.framecnt+1;

% Define shifted srcRect that cuts out the properly shifted rectangular
% area from the texture: We cut out the range 0 to visiblesize i
% the vertical direction although the texture is only 1 pixel in
% height! This works because the hardware will automatically
% replicate pixels in one dimension if we exceed the real borders
% of the stored texture. This allows us to save storage space here,
% as our 2-D grating is essentially only defined in 1-D:
srcRect=[xoffset 0 xoffset + sv.visiblesize sv.visiblesize];


% Draw grating texture, rotated by "angle":
if ex.setup.stereo.Display
    if st ==0 % draw blank frame
        %%
        Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
        Screen('DrawTexture', ex.setup.window, sv.blanktex, srcRect, sv.dstRect);
    % check ocularity for right eye image: me: 1:= R, 0:= binoc
    elseif me >=0  
        % draw right eye image
        Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
        Screen('DrawTexture', ex.setup.window, sv.gratingtex, srcRect, sv.dstRect, or);
        if ex.stim.drawmask==1
            % Draw gaussian mask over grating:
            Screen('DrawTexture', ex.setup.window, sv.masktex, [0 0 sv.visiblesize sv.visiblesize], sv.dstRect, or);
        end;
        if sv.stim2
    
            Screen('DrawTexture', ex.setup.window, sv.gratingtex,srcRect, sv.dstRect2, or);
            if ex.stim.drawmask==1
                % Draw gaussian mask over grating:
                Screen('DrawTexture', ex.setup.window, sv.masktex, [0 0 sv.visiblesize sv.visiblesize], sv.dstRect2, or);
            end;
        end

    end   
    if st ==0 % draw blank frame
        %%
        Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
        Screen('DrawTexture', ex.setup.window, sv.blanktex, srcRect, sv.dstRect);
    % check ocularity for left eye image: me -1:=L, 0 :=binoc
    elseif me <=0 
        % draw left eye image
        Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
        Screen('DrawTexture', ex.setup.window, sv.gratingtex, srcRect, sv.dstRect, or);
        if ex.stim.drawmask==1
            % Draw gaussian mask over grating:
            Screen('DrawTexture', ex.setup.window, sv.masktex, [0 0 sv.visiblesize sv.visiblesize], sv.dstRect, or);
        end;
        if sv.stim2
            Screen('DrawTexture', ex.setup.window, sv.gratingtex,srcRect, sv.dstRect2, or);
            if ex.stim.drawmask==1
                % Draw gaussian mask over grating:
                Screen('DrawTexture', ex.setup.window, sv.masktex, [0 0 sv.visiblesize sv.visiblesize], sv.dstRect2, or);
            end;
        end
    end
else
    %Screen('DrawTexture', ex.setup.window, sv.gratingtex, srcRect, sv.dstRect, or,[], .5);
    Screen('DrawTexture', ex.setup.window, sv.gratingtex, srcRect, sv.dstRect, or);
    if ex.stim.drawmask==1
        % Draw gaussian mask over grating:
        %Screen('DrawTexture', ex.setup.window, sv.masktex, [0 0 sv.visiblesize sv.visiblesize], sv.dstRect, or,[],.5);
        Screen('DrawTexture', ex.setup.window, sv.masktex, [0 0 sv.visiblesize sv.visiblesize], sv.dstRect, or);
    end;
    if sv.stim2
        Screen('DrawTexture', ex.setup.window, sv.gratingtex, srcRect, sv.dstRect2, or);
        if ex.stim.drawmask==1
            % Draw gaussian mask over grating:
            Screen('DrawTexture', ex.setup.window, sv.masktex, [0 0 sv.visiblesize sv.visiblesize], sv.dstRect2, or);
        end;
    end
    
end