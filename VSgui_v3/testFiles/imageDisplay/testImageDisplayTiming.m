
%% PTB-3 properly installed and working?
AssertOpenGL;

% Select display with max id for our onscreen window:
screenid = max(Screen('Screens'));

% get image names
cd /home/lab/Desktop/VisStim/NIHRigC/VSgui_v1_dev/Stimuli/SynthFace_PilotIms/
ims = dir('Cat*.png');

% Open onscreen window with black background clear color:
[win, winRect] = Screen('OpenWindow', screenid, 0);
[xp, yp] = RectCenter(winRect);
%%
%ex.setup.screenNum = win;
ex.setup.screenRect = winRect;
ex.setup.window = win;
%%
tic
for n = 1:length(ims)
    myim=imread(fullfile(ims(n).folder, ims(n).name));
    imtex(n) = Screen('MakeTexture',win,myim);
end
toc

%%
tic
for n = 1%:length(imtex)
    myRect(n,:) = CenterRect(Screen('Rect', imtex(n)), winRect);
    Screen('DrawTexture', win, imtex(n));
    Screen('Flip', win);
end
toc

%%
% make texture for each image
ex.stim.vals.imCntrRect=[];
for n = 1:length(ex.stim.vals.imageNames)
    n
    myim=imread(fullfile(ex.stim.vals.imageFolder, ex.stim.vals.imageNames{n}));
    imtex = Screen('MakeTexture',ex.setup.window,myim);
    ex.stim.vals.imSize(n,:) = size(myim'); %WxH in pixels
    myRect = CenterRect(Screen('Rect',imtex),ex.setup.screenRect)
    ex.stim.vals.imCntrRect(n,:) = myRect;
    ex.stim.vals.imtex(n) = imtex;
 end


%%

% degrees per pixes
dpp = atan(ex.setup.monitorWidth/2/ex.setup.viewingDistance)*180/pi/(ex.setup.screenRect(3)/2);  
ppd = 1/dpp; 
ex.stim.vals.ppd = ppd;

sv = ex.stim.vals; % stimulus values
% GET PARAMETERS OF THE CURRENT IMAGE----------------------------------
% POSITION
imW = sv.imSize(sv.ID,1);
imH = sv.imSize(sv.ID,2)
left = sv.ppd*sv.x0+ex.fix.PCtr(1)-round(imW/2);
bottom = sv.ppd*sv.y0+ex.fix.PCtr(2)-round(imH/2);

srcRect = ex.stim.vals.imCntrRect(sv.ID,:); % source rectangle, centered on screen
dstRect = [left, bottom left+imW bottom+imH];

% ORIENTATION
or =180;

Screen('DrawTexture', ex.setup.window, sv.imtex(sv.ID),[],dstRect,or);%, srcRect, dstRect);
Screen('Flip', ex.setup.window);

%%
try
    % Open onscreen window with black background clear color:
    [win, winRect] = Screen('OpenWindow', screenid, 0);
    [xp, yp] = RectCenter(winRect);
    SetMouse(xp, yp, win);
    
    % Read our beloved bunny image from filesystem:
    bunnyimg = imread([PsychtoolboxRoot 'PsychDemos/konijntjes1024x768.jpg']);
    bunnytex = Screen('MakeTexture', win, bunnyimg);
    
    bunnyRect = CenterRect(Screen('Rect', bunnytex), winRect);
    xoffset = bunnyRect(RectLeft);
    yoffset = bunnyRect(RectTop);
    
    
    w = floor(size(bunnyimg,2)/5);
    h = floor(size(bunnyimg,1)/5);
    [x,y]=meshgrid(-w/2:w/2,-h/2:h/2);


    while ~KbCheck
        % Update framecounter: This is also used as our "simulation time":
        count = count + 1;

        % Query mouse to find out where to place the "warp map":
        [xp, yp] = GetMouse(win);
        xp = xp - xoffset;
        yp = yp + yoffset;

        % Compute a texture that contains the distortion vectors:
        % Red channel encodes x offset components, Green encodes y offsets:

        % Here we apply some sinusoidal modulation:
        warpimage(:,:,1) = (sin(sqrt((x/10).^2 + (y/10).^2) + count/10) + 1) * 6;
        warpimage(:,:,2) = (cos(sqrt((x/10).^2 + (y/10).^2) + count/10) + 1) * 6;

        % Its important to create a floating point texture, so we can
        % define fractional offsets that are bigger than 1.0 and negative
        % as well:
        modtex = Screen('MakeTexture', win, warpimage, [], [], 1);

        % Update the warpmap. First clear it out to zero offset, then draw
        % our texture into it at the mouse position:
        Screen('FillRect', warpmap, 0);
        Screen('DrawTexture', warpmap, modtex, [], CenterRectOnPoint(Screen('Rect', modtex), xp, yp));
        
        % Delete texture, it will be recreated at next iteration:
        Screen('Close', modtex);
        
        % Apply image warpmap to our bunny image:
        warpedtex = Screen('TransformTexture', bunnytex, warpoperator, warpmap, warpedtex);

        % Draw and show the warped bunny:
        Screen('DrawTexture', win, warpedtex);
        Screen('Flip', win);
    end
        
    % Done. Close display and return:
    sca;
    return;
    
catch
    sca;
    psychrethrow(psychlasterror);
end
