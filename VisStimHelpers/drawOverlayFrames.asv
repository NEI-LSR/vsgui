function drawOverlayFrames(ex,goodTPos,fpPos)
% function drawOverlayFrames(ex,goodTPos)
%
% draws frames that are fixed during the trial (e.g. RF pos, fixation
% window, correct target window) onto the overlay screen

% history
% 08/02/14  hn: wrote it
% 11/12/25  cmz: modifed to work in dome with geometry correction. Still
%               need to modify to handle non centered fixation locations
%               Right now fixation must be at screen center because in
%               ex.fix it is only specified in pixel coordinates and going
%               back to degrees from pixels is difficult

if nargin == 1
    goodTPos = [];
    % center of fixation window
    fpPos = ex.fix.PCtr;
    
elseif nargin == 2
    fpPos = ex.fix.PCtr;

else
    
end

%% adjust coordinates for dome warping?
geomCorrect = isfield(ex.setup,"scal");


% converting pixels to degrees (needed for RF, which is stored in degrees)
dpp = atan(ex.setup.monitorWidth/2/ex.setup.viewingDistance)*180/pi/(1920/2);  % degrees per pixes
ppd = 1/dpp;  % pixels per degree

% This does not work in the dome:
% RF center: x and y; width and height
RFx = ex.extras.rfx * ppd + ex.fix.PCtr(1);
RFy = ex.extras.rfy * ppd + ex.fix.PCtr(2);
RFW = ex.extras.rfW * ppd;
RFH = ex.extras.rfH * ppd;

fpWinCol = ex.idx.overlay;


if isempty(goodTPos) % we only have the fixation window and RF
        
    %Prepare single screen call for all frames (eye position, RF)

    if geomCorrect

        % compute pixel locations for fixation window in pixels. Fixation
        % location at (0,0) is currently hard coded
        winDeg = [-ex.fix.WinW -ex.fix.WinH ex.fix.WinW ex.fix.WinH];
        [winPix(1),~] = deg2pixelxy(winDeg(1),0,ex.setup);
        [~,winPix(2)] = deg2pixelxy(0,winDeg(2),ex.setup);
        [winPix(3),~] = deg2pixelxy(winDeg(3),0,ex.setup);
        [~,winPix(4)] = deg2pixelxy(0,winDeg(4),ex.setup);

        % now perform the screen warping on the pixels because the overaly
        % doesn't undergo geometry correction

        [winWarp(1),~] = geomCorrection(winPix(1),ex.fix.PCtr(2),ex.setup);
        [~,winWarp(2)] = geomCorrection(ex.fix.PCtr(1),winPix(2),ex.setup);
        [winWarp(3),~] = geomCorrection(winPix(3),ex.fix.PCtr(2),ex.setup);
        [~,winWarp(4)] = geomCorrection(ex.fix.PCtr(1),winPix(4),ex.setup);



        frRect = [winWarp; % fixation window
            [-RFW  -RFH  RFW  RFH] + ...      % RF window
            [RFx RFy RFx RFy]];
        frCol =   fpWinCol*ones(2,3);
    else
        % if no geometry correction, fix.Win is specified in pixels
        frRect = [[-ex.fix.WinW  -ex.fix.WinH  ex.fix.WinW  ex.fix.WinH] + ... % fixation window
            [fpPos                       fpPos]; ...
            [-RFW  -RFH  RFW  RFH] + ...      % RF window
        [RFx RFy RFx RFy]];
    frCol =   fpWinCol*ones(2,3);
    end

else  % we have a target window to display

    if geomCorrect

        % compute pixel locations for target window in pixels
        winDeg = [-ex.targ.WinW -ex.targ.WinH ex.targ.WinW ex.targ.WinH] + ...
            [ex.targ.PosDeg ex.targ.PosDeg];
        [winPix(1),~] = deg2pixelxy(winDeg(1),ex.targ.PosDeg(2),ex.setup);
        [~,winPix(2)] = deg2pixelxy(ex.targ.PosDeg(1),winDeg(2),ex.setup);
        [winPix(3),~] = deg2pixelxy(winDeg(3),ex.targ.PosDeg(2),ex.setup);
        [~,winPix(4)] = deg2pixelxy(ex.targ.PosDeg(1),winDeg(4),ex.setup);

        % now perform the screen warping on the pixels because the overaly
        % doesn't undergo geometry correction
        posScreenPix  = ex.fix.PCtr+ex.targ.Pos(1,:);

        [winWarp(1),~] = geomCorrection(winPix(1),posScreenPix(2),ex.setup);
        [~,winWarp(2)] = geomCorrection(posScreenPix(1),winPix(2),ex.setup);
        [winWarp(3),~] = geomCorrection(winPix(3),posScreenPix(2),ex.setup);
        [~,winWarp(4)] = geomCorrection(posScreenPix(1),winPix(4),ex.setup);


        % compute pixel locations for fixation window in pixels. Fixation
        % locatoin at (0,0) is currently hard coded
        fixWinDeg = [-ex.fix.WinW -ex.fix.WinH ex.fix.WinW ex.fix.WinH];
        [winPix(1),~] = deg2pixelxy(fixWinDeg(1),0,ex.setup);
        [~,winPix(2)] = deg2pixelxy(0,fixWinDeg(2),ex.setup);
        [winPix(3),~] = deg2pixelxy(fixWinDeg(3),0,ex.setup);
        [~,winPix(4)] = deg2pixelxy(0,fixWinDeg(4),ex.setup);

        % now perform the screen warping on the pixels because the overaly
        % doesn't undergo geometry correction

        [fixWinWarp(1),~] = geomCorrection(winPix(1),ex.fix.PCtr(2),ex.setup);
        [~,fixWinWarp(2)] = geomCorrection(ex.fix.PCtr(1),winPix(2),ex.setup);
        [fixWinWarp(3),~] = geomCorrection(winPix(3),ex.fix.PCtr(2),ex.setup);
        [~,fixWinWarp(4)] = geomCorrection(ex.fix.PCtr(1),winPix(4),ex.setup);

        frRect = [fixWinWarp; % fixation window
            winWarp; ... % correct target window
            [-RFW  -RFH  RFW  RFH] + ...                      % RF window
            [RFx RFy RFx RFy]];
    else
        %Prepare single screen call for all frames (eye position, target, RF)
        frRect = [[-ex.fix.WinW  -ex.fix.WinH  ex.fix.WinW  ex.fix.WinH] + ... % fixation window
            [fpPos                       fpPos]; ...
            [-ex.targ.WinW -ex.targ.WinH ex.targ.WinW ex.targ.WinH] + ... % correct target window
            [fpPos+goodTPos              fpPos+goodTPos]; ...
            [-RFW  -RFH  RFW  RFH] + ...                      % RF window
            [RFx RFy RFx RFy]];

    end
    frCol =   fpWinCol*ones(3,3);
end

if ~ex.setup.stereo.Display
    frCol = ex.idx.overlay;
end

%%% draw overlay frames 
Screen('FrameRect',ex.setup.overlay,frCol',frRect');



% keyboard
% dotPos  = ex.fix.PCtr+ex.targ.Pos(1,:);
% dotSz   = ex.fix.PSz; 
% dotCol  =  [ones(1,3)*ex.idx.white];
% Screen('Drawdots',ex.setup.window,dotPos',dotSz',dotCol');
% Screen('Flip', ex.setup.window)

