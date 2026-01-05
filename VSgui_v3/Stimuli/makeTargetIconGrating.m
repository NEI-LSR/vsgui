function ex=makeTargetIconGrating(ex)

%function ex=makeTargetIconGrating(ex) 
% creates the positions and orientations of a Grating for one experiment for the two
% alternative choices


% history
% 11/02/15  hn: wrote it

% make sure we have all the parameters we need
if ~isfield(ex.stim.vals,'sf_range') || isempty(ex.stim.vals.sf_range)
    ex.stim.vals.sf_range = ex.stim.vals.sf;
end
if ~isfield(ex.stim.vals,'co_range') || isempty(ex.stim.vals.co_range)
    ex.stim.vals.co_range = ex.stim.vals.co;
end
if ~isfield(ex.stim.vals,'st_range') || isempty(ex.stim.vals.st_range)
    ex.stim.vals.st_range = ex.stim.vals.st;
end
if ~isfield(ex.stim.vals,'me_range') || isempty(ex.stim.vals.me_range)
    ex.stim.vals.me_range = ex.stim.vals.me;
end
if ~isfield(ex.stim.vals,'or_range') || isempty(ex.stim.vals.or_range)
    ex.stim.vals.or_range = ex.stim.vals.or;
end

% assign target positions based on ex.targ.Pos, then target orientation
% based on the correct target

%%
sv = ex.stim.vals;  % stimvals
tv = ex.targ.icon;
%
% ex.targ.duration = .5;
% ex.targ.freeduration = 0; 
% ex.targ.icon.type='dot';
% ex.targ.WinW = 100;  % target window width in pixels
% ex.targ.WinH = 100;  % target window hight in pixels
% ex.targ.PSz = 8;  % targ point size
% ex.targ.Pos = [ 0 300;  0 -300];  % targ position in pixels relative to fixation point 
% ex.targ.T1Col = ex.idx.white;  %correct targ color
% ex.targ.T2Col = ex.idx.bg; % error target color
% ex.targ.go_delay = 0.05; % delay until monkey can choose a target
% ex.targ.RT_delay = 0.05;  % if one wants to include a delay to prevent early choices
% ex.targ.hold = .1;
% ex.targ.icon.sz = 2; % center size of target icon
% ex.targ.icon.ssz = 2.5; % surround size of target icon
% ex.targ.icon.or = [0 90];  % horizontal disparities t-iconol center
% ex.targ.icon.T1co = 1;
% ex.targ.icon.T2co = 0;


% MAKE GRATING TEXTURE(S)-------------------------------------------------
% degrees per pixes
%
dpp = atan(ex.setup.monitorWidth/2/ex.setup.viewingDistance)*180/pi/(ex.setup.screenRect(3)/2);  
ppd = 1/dpp;  % pixels per degree

% Define Half-Size of the grating image.
if strcmpi(ex.stim.masktype,'gauss')
    % define stimulus size as fullwidth at half height (fwhh):
    % fwhh = sv.sz = 2*sqrt(2*log(2)) * sd;
    if tv.sz>1000  %% placeholder code for blank stimulus
        tv.sz = 0;
    end
    sd = (tv.sz/2*ppd)/(2*sqrt(2*log(2)));
    texsize = round(sd*3);
else 
    %%
    if max([tv.sz])>1000  % take care of placeholder code for blank stimulus
        isz = 0;
    else 
        isz = max([tv.sz]);
    end
    texsize=round(isz*ppd)/2;
end
% restrict texture to screensize
if texsize > max(ex.setup.screenRect)
    texsize = max(ex.setup.screenRect)
end
% This is the visible size of the grating. It is twice the half-width
% of the texture plus one pixel to make sure it has an odd number of
% pixels and is therefore symmetric around the center of the texture:
visiblesize = 2*texsize+1;

white = ex.idx.white;
black = ex.idx.black;  
gray = ex.idx.bg;

 
%  create just a single texture for each target
% Contrast 'inc'rement range for given white and gray values: for Targ1
inc1=(white-gray)*tv.T1co;
% Contrast 'inc'rement range for given white and gray values: for Targ2
inc2=(white-gray)*tv.T2co;


% Calculate parameters of the grating, use same as for stimulus
% First we compute pixels per cycle, rounded up to full pixels, as we
% need this to create a grating of proper size below:
if sv.sf==0
    errordlg(['ex.stim.vals.sf = 0; set to value >0'])
else 
    p=ceil(ppd/sv.sf);  % period in pixels
end

% Also need frequency in radians:
fr=sv.sf*2*pi/ppd;

% Create one single static grating image:
%
% We only need a texture with a single row of pixels(i.e. 1 pixel in height) to
% define the whole grating! If the 'srcRect' in the 'Drawtexture' call
% below is "higher" than that (i.e. visibleSize >> 1), the GPU will
% automatically replicate pixel rows. This 1 pixel height saves memory
% and memory bandwith, ie. it is potentially faster on some GPUs.
%
% However it does need 2 * texsize + p columns, i.e. the visible size
% of the grating extended by the length of 1 period (repetition) of the
% sine-wave in pixels 'p':
x = meshgrid(-texsize:texsize + p, 1);

% Compute actual cosine gratings:
grating1=gray + inc1*cos(fr*x); % make sure that we center the visible part of the grating
grating2=gray + inc2*cos(fr*x); % make sure that we center the visible part of the grating

% Store 1-D single row grating in texture:
ex.targ.icon.RDS(1)=Screen('MakeTexture', ex.setup.window, grating1);
ex.targ.icon.RDS(2)=Screen('MakeTexture', ex.setup.window, grating2);
%%
% MAKE MASK---------------------------------------------------------------
% Create a single gaussqian transparency mask and store it to a texture:
% The mask must have the same size as the visible size of the grating
% to fully cover it. Here we must define it in 2 dimensions and can't
% get easily away with one single row of pixels.
%
% We create a  two-layer texture: One unused luminance channel which we
% just fill with the same color as the background color of the screen
% 'gray'. The transparency (aka alpha) channel is filled with a
% gaussian (exp()) aperture mask:
%%
mask=ones(2*texsize+1, 2*texsize+1, 2) * gray;
%%
[x,y]=meshgrid(-(texsize):(texsize),-(texsize):texsize);
%%
switch ex.stim.masktype
    case 'circle'
        edges = sqrt((x).^2 +(y).^2)>texsize;
        mask(:,:,2) = edges*white;
    case 'gauss'
        mask(:, :, 2)=white * (1 - exp(-(0.5*(x/sd).^2)-(0.5*(y/sd).^2)));
    otherwise
       mask(:,:,2) = white;
       mask(max([1,round(texsize-tv.wi*ppd/2)]):round(texsize+tv.wi*ppd/2),...
           max([1,round(texsize-tv.hi*ppd/2)]):round(texsize+tv.hi*ppd/2),2) = 0; 
end
%%
ex.targ.icon.masktex=Screen('MakeTexture', ex.setup.window, mask);


% COMPUTE REMAINING GRATING PARAMETERS AND STORE THESE --------------------
% Definition of the drawn rectangle on the screen:
% Compute it to  be the visible size of the grating, centered on the
% defined stimulus center
% target 1 (lower target)
left = ex.targ.Pos(1,1)+ex.fix.PCtr(1)-visiblesize/2;
bottom = ex.targ.Pos(1,2)+ex.fix.PCtr(2)-visiblesize/2;
dstRect1=[left bottom left+visiblesize bottom+visiblesize];
% target 2 (upper target)
left = ex.targ.Pos(2,1)+ex.fix.PCtr(1)-visiblesize/2;
bottom = ex.targ.Pos(2,2)+ex.fix.PCtr(2)-visiblesize/2;
dstRect2=[left bottom left+visiblesize bottom+visiblesize];


ex.targ.icon.visiblesize = visiblesize;
ex.targ.icon.dstRect(1,:) = dstRect1;  % lower target
ex.targ.icon.dstRect(2,:) = dstRect2;  % upper target





