function ex=playImage(ex,stimOnDur)
% display selected image

% history
% 08/13/24      hn: wrote it
% 11/19/24      cmz: modifed to work with dome
% 05/16/25      hn: renamed ID to imID
sv = ex.stim.vals; % stimulus values

%disp('in play image')

% GET PARAMETERS OF THE CURRENT IMAGE----------------------------------
% POSITION

% Convert image center in deg to pixels
[pixelX0 pixelY0] = deg2pixelflex(sv.x0,sv.y0,ex.setup);

% we use the same image size for the blank as for imID = 1;
if sv.st == 0
    sv.imID = 1;
end

% Get eccentricity
eccCen = sqrt(sv.y0^2 + sv.x0^2);

% The scaling value of image diameter with eccentricity
% SET TO 0 IF NO SCALING IS DESIRED
eccScal = 0%0.5;

% Get image size values in DVA based on pixels per degree
imW_DVA = 1.2*sv.imSize(sv.imID,1)./sv.ppd;
imH_DVA = 1.2*sv.imSize(sv.imID,1)./sv.ppd;

% % Overwite image size values in DVA with desired values. If eccScal is 0
% % size will be constant across the screen. If not, size will be the minimum
% % scalar value below in the central portion of visual field and scale with
% % eccentricity outside.
% imH_DVA = max(8,eccScal*eccCen);
% imW_DVA = max(8,eccScal*eccCen);


% Find all image rectangle coordinates in DVA
[left,~]    = deg2pixelflex(sv.x0 - imW_DVA/2, sv.y0, ex.setup);
[right,~]   = deg2pixelflex(sv.x0 + imW_DVA/2, sv.y0, ex.setup);
[~,bottom]  = deg2pixelflex(sv.x0, sv.y0 - imH_DVA/2, ex.setup);
[~,top]     = deg2pixelflex(sv.x0, sv.y0 + imH_DVA/2, ex.setup);

dstRect     = [left, bottom, right, top];

% This is not used - cmz 11/19/2024
srcRect = ex.stim.vals.imCntrRect(sv.imID,:); % source rectangle, centered on screen

% Make sure Rect is valid and max eccentricity is on the dome
eccMax = sqrt((abs(sv.y0)+imH_DVA/2)^2 + (abs(sv.x0)+imW_DVA/2)^2);

if eccMax > 87.5 || isnan(sum(dstRect))
    warning('Portion of image is presented outside of view');
    %keyboard
end


% ORIENTATION
if ~isfield(ex.Trials(ex.j),'or') || isempty(ex.Trials(ex.j).or)
    or = 0;
else
    or = sv.or;
end

ex.stim.vals.framecnt = sv.framecnt+1;

% Draw image texture, rotated by "angle":
if ex.setup.stereo.Display
    
    if sv.st ==0 % draw blank frame
        %disp('blank')
        %%
        %Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
        Screen('FillRect',ex.setup.window,ex.idx.bg_lum);
        %Screen('DrawTexture', ex.setup.window, sv.blanktex, srcRect, dstRect);
    
    % check ocularity for right eye image: me: 1:= R, 0:= binoc
    elseif sv.me >=0  
        % draw right eye image
        %%
        Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
        %%
        % Screen('DrawTexture', ex.setup.window, sv.imtex(sv.ID), srcRect, dstRect,or);
        Screen('DrawTexture', ex.setup.window, sv.imtex(sv.imID), [], dstRect,or);
        %% currently not implemented
        %{  
        if ex.stim.drawmask==1
            % Draw gaussian mask over grating:
            Screen('DrawTexture', ex.setup.window, sv.masktex, [0 0 imW imH], dstRect);
        end;
        %}
    end  
    
    if sv.st ==0 % draw blank frame
        %Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
        Screen('FillRect',ex.setup.window,ex.idx.bg_lum);
        %Screen('DrawTexture', ex.setup.window, sv.blanktex, srcRect, dstRect);

    % check ocularity for left eye image: me -1:=L, 0 :=binoc
    elseif sv.me <=0 
        % draw left eye image
        Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
        %%
        % Screen('DrawTexture', ex.setup.window, sv.imtex(sv.ID), srcRect, dstRect,or);
        Screen('DrawTexture', ex.setup.window, sv.imtex(sv.imID), [], dstRect,or);
        %% currently not implemented
        %{  
        if ex.stim.drawmask==1
            % Draw gaussian mask over grating:
            Screen('DrawTexture', ex.setup.window, sv.masktex, [0 0 imW imH], dstRect);
        end;
        %}

    end
else
    if sv.st==0 % draw blank frame
        %Screen('DrawTexture', ex.setup.window, sv.blanktex, srcRect, dstRect);
        Screen('FillRect',ex.setup.window,ex.idx.bg_lum);
    else
        %%
        % Screen('DrawTexture', ex.setup.window, sv.imtex(sv.ID), srcRect, dstRect,or);
        Screen('DrawTexture', ex.setup.window, sv.imtex(sv.imID), [], dstRect,or);
        %% currently not implemented
        %{  
        if ex.stim.drawmask==1
            % Draw gaussian mask over grating:
            Screen('DrawTexture', ex.setup.window, sv.masktex, [0 0 imW imH], dstRect);
        end;
        %}    
    end
end