function ex=playRDS(ex,RDS)

% display RDS
% only works in stereomode
% history
% 2014      hn: wrote it
% 07/11/14  hn: -included field 'setup' and moved setup parameters into it
%               new parameter name          old parameter name
%               ex.setup.stereo             ex.stereo
%               ex.setup.window             ex.window
%               ex.setup.overlay            ex.overlay
% 07/31/14  hn: included option for monocular display
% 04/03/23  hn: update to display new RDS allowing for independent R/L dots

sv = ex.stim.vals; % stimulus values

if isfield(RDS,'L')  % new RDS, removing gaps
    if ex.Trials(ex.j).framecnt+1<=length(RDS.L)
        ex.Trials(ex.j).framecnt = ex.Trials(ex.j).framecnt+1;
    else
        ex.Trials(ex.j).framecnt = 1;
        ex.Trials(ex.j).framesComplete = ex.Trials(ex.j).framesComplete+1;
    end
    
    L       = (RDS.L{ex.Trials(ex.j).framecnt}(1:2,:));
    R       = (RDS.R{ex.Trials(ex.j).framecnt}(1:2,:));
    
    dotColL   = RDS.L{ex.Trials(ex.j).framecnt}(3,:)'*ones(1,3);
    dotColR   = RDS.R{ex.Trials(ex.j).framecnt}(3,:)'*ones(1,3);
    
    dotSzL    = RDS.L{ex.Trials(ex.j).framecnt}(4,:);
    dotSzR    = RDS.R{ex.Trials(ex.j).framecnt}(4,:);
    
else % old RDS for backwards compatibility
    

    if ex.Trials(ex.j).framecnt +1 <= length(RDS.dots)    % if enough frames prepared
        ex.Trials(ex.j).framecnt = ex.Trials(ex.j).framecnt+1;
    else
        ex.Trials(ex.j).framecnt = 1;  % otherwise start over with first frame
         ex.Trials(ex.j).framesComplete = ex.Trials(ex.j).framesComplete + 1;
    end
    n = ex.Trials(ex.j).framecnt;
    
    R = RDS.dots{n}(1:2,:)-[RDS.dots{n}(3,:)/2;zeros(1,size(RDS.dots{n},2))];
    L = RDS.dots{n}(1:2,:)+[RDS.dots{n}(3,:)/2;zeros(1,size(RDS.dots{n},2))];
    
    dotColL = RDS.dotCols{n}'*ones(1,3);
    dotColR = dotColL;
    
    dotSzL = RDS.dotSz{n};
    dotSzR = dotSzL;
end


if sv.st==0
    srcRect = [0 0 ones(1,2)*sv.visiblesize];
end
if sv.st ==0 % draw blank frame
        %%
        Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
        Screen('DrawTexture', ex.setup.window, sv.blanktex, srcRect, sv.dstRect);
    % Select right-eye image buffer for drawing:
elseif sv.me>=0
    Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
    % Draw right stim:
    %Screen('DrawDots', ex.setup.window,dots(1:2, :) - [dots(3, :)/2; zeros(1,size(dots,2))] , dotSz, dotCols');
    Screen('DrawDots', ex.setup.window,R, dotSzR, dotColR');
end
if sv.st ==0 % draw blank frame
        %%
        Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
        Screen('DrawTexture', ex.setup.window, sv.blanktex, srcRect, sv.dstRect);
elseif sv.me<=0
    % Select left-eye image buffer for drawing:
    Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
    % Draw left stim:
    % Screen('DrawDots', ex.setup.window, dots(1:2, :) + [dots(3, :)/2; zeros(1,size(dots,2))], dotSz, dotCols');
    Screen('DrawDots', ex.setup.window, L, dotSzL, dotColL');
     %Screen('Flip',ex.setup.window);
     %disp('drew now')
end
% else
%     Screen('Drawdots',ex.setup.overlay,[dots(1:2,:)],sv.dotSz,dotCols');
% end