function ex = playBar(ex)
% creates and displays an oriented bar as stimulus
% 
% history
% 07/28/14  hn: wrote it
% 07/29/14  hn: improved timing; note: isfield(x,'y') is slow and should be
%           avoided; 
% 07/31/14  hn: included option for monocular display
%
tic
dpp = atan(ex.setup.monitorWidth/2/ex.setup.viewingDistance)*180/pi/(1920/2);  % degrees per pixes
ppd = 1/dpp;  % pixels per degree

t = -ex.stim.vals.or/180*pi; % orientation in radians; counter-clockwise: 
cs = [cos(t), sin(t)];

% if moving bar add offset to x and y pos
shiftX = 0;
shiftY = 0;

if  ex.stim.vals.sf>0 
    shiftX = sin(2*pi *ex.stim.vals.framecnt/ex.setup.refreshRate*ex.stim.vals.tf) * sin(-t) * ppd/ex.stim.vals.sf;
    shiftY = sin(2*pi * ex.stim.vals.framecnt/ex.setup.refreshRate*ex.stim.vals.tf) * cos(-t) * ppd/ex.stim.vals.sf;   
end

% change luminance of bar according to flickerTF
col = ex.stim.vals.col;
if ex.stim.vals.flickerTF>0 && ex.stim.vals.flickerTF<ex.setup.refreshRate/2
    p = sin(2*pi*ex.stim.vals.framecnt/ex.setup.refreshRate*ex.stim.vals.flickerTF);
    if p>=0
        col = ex.stim.vals.col;
    else col = ex.idx.bg;
    end
    
end


% keep track of framecnt
ex.stim.vals.framecnt = ex.stim.vals.framecnt+1;

linesXY = cs'*[-ex.stim.vals.hi/2*ppd ex.stim.vals.hi/2*ppd];
linesXY = linesXY + [ex.stim.vals.x0*ppd+ex.fix.PCtr(1)+shiftX; ex.stim.vals.y0*ppd+ex.fix.PCtr(2)+shiftY]*ones(1,2);

%% CMZ 20260206 - trying to make this compatible with dome
% now this first line will stay in degrees
linesXYdeg = cs'*[-ex.stim.vals.hi/2 ex.stim.vals.hi/2];
linesXYdeg = linesXYdeg + [ex.stim.vals.x0; ex.stim.vals.y0]*ones(1,2);

[linesXY(1),linesXY(2)] = deg2pixelxy(linesXYdeg(1),linesXYdeg(2),ex.setup);
[linesXY(3),linesXY(4)] = deg2pixelxy(linesXYdeg(3),linesXYdeg(4),ex.setup)

%%
% barwidth has to be 1<= width <=10
width = min([ex.stim.vals.wi*ppd,10]);  
width = max([1, width]);

%ex.tocsBAR{ex.j} = [ex.tocsBAR{ex.j} toc];
%%

if ex.setup.stereo.Display
    if ex.stim.vals.me>=0
        % Select right-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
        % Draw right stim:    
        Screen('DrawLines', ex.setup.window, linesXY, width, col); 
    end
    if ex.stim.vals.me<=0
    %     % Select left-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
        % Draw left stim:
        Screen('DrawLines', ex.setup.window, linesXY, width, col) ;
    end
else
    Screen('DrawLines', ex.setup.window, linesXY, width, col); 
end
%%

