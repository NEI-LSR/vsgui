function ex=makeGratingRC(ex)
%function ex=makeGrating(ex) 
% creates grating textures that can be used to show a
% drifing grating or an RC sequence.  During the trial only the xoffset of the texture will
% be re-computed on each frame, and the angle (ori) changed according to
% the RC sequence
% heavily based on makeGrating, replaces makeGrating
% based on DriftDemo2.m from ptb
%
% 8/1/14  hn created it
% 8/29/14 hn: included circle mask and fixed gaussian mask; size for
%         gaussian mask corresponds to fullwidth at half height
% 11/02/14  hn: include check to limit max size to screen size; 
% 09/28/15  hn: now include ex.fix.stimDuration
% 11/02/15  hn: now include option for varying orientation signal using the
%           Dc parameter
% 01/06/16  hn: now including or_seq = mod(or_seq,180) to make phases
%           equivalent(replicatable) for or <180 and >=180
% 02/14/16  hn: now start at framecnt=1, seqcnt=1, instead of framcnt = 0,
%           seqcnt = 0, to correct for bug with RC-period
% 10/18/16  hn: bug fix for seqcnt (it was still set to 0 at the beginning for
%           trial 2:n)
% 04/30/24  hn: hack to deal with luminance issues for monocular setup
% 05/05/24  hn: open new textures only if needed, and close existing
%           grating texture if it exists.
% 12/02/25  hn: removed ppd (now using pixel2deg function instead)
% 03/25/26  cmz: check for geometry correction in placing the stim center

% make sure we have all the parameters we need
if ~isfield(ex.stim.vals,'sf_range') || isempty(ex.stim.vals.sf_range)
    ex.stim.vals.sf_range = ex.stim.vals.sf;
end
if ~isfield(ex.stim.vals,'co_range') || isempty(ex.stim.vals.co_range) %|| ex.stim.vals.RC==0
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

%%
sv = ex.stim.vals;  % stimvals

%% adjust stimulus center for geometry correction?
geomCorrect = isfield(ex.setup,"scal");

%%
% include y_offset as a cue towards the correct target for the
% discrimination task, if we have it
if isfield(ex.stim.vals,'y_OffsetCue')
    y0 = sv.y0+ex.stim.vals.y_OffsetCue;
else y0 = sv.y0;
end

% generate the RC sequence if we are running an RC experiment-------------
if sv.RC
    ex.Trials(ex.j).rngState = rng;
    sf_seq = [];
    or_seq = [];
    co_seq = [];
    me_seq = [];
    st_seq = [];
    x0_seq = [];
    y0_seq = [];
    n_noiseF = ceil((ex.fix.stimDuration)*ex.setup.refreshRate+1); % number of noise frames
    
    % SPATIAL FREQUENCY sequence
    if length(sv.sf_range)>1
        % generate random sequence of indices 
        r_idx = floor(rand(1,n_noiseF)*length(sv.sf_range))+1;
        sf_seq = sv.sf_range(r_idx);
    end
    
    % CONTRAST sequence
    if length(sv.co_range)>1
        % generate random sequence of indices
        r_idx = floor(rand(1,n_noiseF)*length(sv.co_range))+1;
        co_seq = sv.co_range(r_idx);
    end
    
    % x0 sequence
    if length(sv.x0_range)>1
        r_idx = randi(length(sv.x0_range),1,n_noiseF);
        x0_seq = sv.x0_range(r_idx);
    end
    
    % y0 sequence
    if length(sv.y0_range)>1
        r_idx = randi(length(sv.y0_range),1,n_noiseF);
        y0_seq = sv.y0_range(r_idx);
    end

    % ORIENTATION sequence
    if length(sv.or_range)>1
        if isfield(sv,'Dc') && sv.Dc>0
            % make frames with orientation signal first
            or_seq = ones(1,ceil(n_noiseF*sv.Dc))*sv.or;
            n_noiseF_or = n_noiseF-length(or_seq);
            % now ad number of noise frames
            if n_noiseF_or>0
                % generate random sequence of indices
                r_idx = floor(rand(1,n_noiseF_or,1)*length(sv.or_range))+1;
                noise_seq = sv.or_range(r_idx);
                or_seq = [or_seq,noise_seq];
            end
            % now randomize the sequence
            rp = randperm(length(or_seq));
            or_seq = or_seq(rp);
        else
            % generate random sequence of indices
            r_idx = floor(rand(1,n_noiseF)*length(sv.or_range))+1;
            or_seq = sv.or_range(r_idx);
        end
    end
    % started after 01/06/15
    % since the phases differ between orientations (<180 and >180deg), make sure
    % we only use orientation values 0>=or< 180
    or_seq = mod(or_seq,180);
    
    
    % OCULARITY sequence
    if length(sv.me_range)>1
        %sv.me_range = [-1 1 0];
        % make sure that when we also include blanks in this case
        ex.stim.vals.st_range = [0,1];
        sv.st_range = [0,1];
        % how many different stimuli + 4 (i.e. +blank + R/L/B)
        nstim = length(sv.or_range)*length(sv.sf_range)*length(sv.co_range) + 4; 
        r_idx = floor(rand(1,n_noiseF)*nstim) +1;
        r_idx(find(r_idx>=3)) = 3;
        me_seq = sv.me_range(r_idx);
    end
    
    % BLANK sequence (if we interleave blank frames in the sequence)
    if length(sv.st_range)>1
        sv.st_range = [0 1];
        ex.stim.vals.st_range = [0 1];
        % how many different stimuli + 1 (i.e. +blank)
        nstim = length(sv.or_range)*length(sv.sf_range)*length(sv.co_range) + 1; 
        r_idx = floor(rand(1,n_noiseF)*nstim) +1;
        r_idx(find(r_idx>=2)) = 2;
        st_seq = sv.st_range(r_idx);
    end 
        
    % PHASE sequence; force it to be randomized with 4 phases
    % (0,pi/2,pi,3/2*pi)
    % generate random sequence of indices
    ex.Trials(ex.j).phase_seq = floor(rand(1,n_noiseF)*4)+1;

    ex.Trials(ex.j).st_seq = st_seq;
    ex.Trials(ex.j).me_seq = me_seq;
    ex.Trials(ex.j).sf_seq = sf_seq;
    ex.Trials(ex.j).or_seq = or_seq;
    ex.Trials(ex.j).co_seq = co_seq;
    ex.Trials(ex.j).x0_seq = x0_seq;
    ex.Trials(ex.j).y0_seq = y0_seq;
end


% we only need to make the textures for the RC sequence before the first--
% trial (unless we are running a discrimination task) ---------------------
if ex.exp.afc==0 && sv.RC && ex.j>1
    ex.stim.vals.seqcnt = 1;  % hn: changed from 0 to 1 (10/18/16)
    return
end

% MAKE GRATING TEXTURE(S)-------------------------------------------------
% close existing grating textures if they exist
if isfield(ex.stim.vals,'gratingtex') && ~isempty(ex.stim.vals.gratingtex)
    Screen('Close',ex.stim.vals.gratingtex);
end


% degrees per pixes
dpp = pixel2deg(1,ex.setup);  
ppd = 1/dpp;  % pixels per degree

% Define Half-Size of the grating image.
if strcmpi(ex.stim.masktype,'gauss')
    % define stimulus size as fullwidth at half height (fwhh):
    % fwhh = sv.sz = 2*sqrt(2*log(2)) * sd;
    if sv.sz>1000  %% placeholder code for blank stimulus
        sv.sz = 0;
    end
    sz = max([sv.sz,sv.wi,sv.hi]);
    sd = (sz/2*ppd)/(2*sqrt(2*log(2)));
    texsize = round(sd*3);
else 
    %%
    if max([sv.sz,sv.wi,sv.hi])>1000  % take care of placeholder code for blank stimulus
        isz = 0;
    else 
        isz = max([sv.sz,sv.wi,sv.hi]);
    end
    texsize=round(isz*ppd)/2;
end
% restrict texture to screensize
if texsize > max(ex.setup.screenRect)
    texsize = max(ex.setup.screenRect)
end
%%
% This is the visible size of the grating. It is twice the half-width
% of the texture plus one pixel to make sure it has an odd number of
% pixels and is therefore symmetric around the center of the texture:
visiblesize = 2*texsize+1;

% used for calculations with geometry correction
visiblesizeDeg = visiblesize*dpp;

white = ex.idx.white;
black = ex.idx.black; 

% this is a terrible hack to deal with the inconsistency in the luminance
% scaling in the monocular setup
if ex.setup.stereo.Display
    gray = ex.idx.bg;
else
    gray = (black+white)/2;
end

% When varying SF or CO we need to create one texture for each condition.
% now check whether we are varying contrast or SF in the RC sequence. 
% otherwise create just a single texture
for nf = 1: length(sv.sf_range)
    sf = sv.sf_range(nf);
    for nc = 1:length(sv.co_range)
        if sv.RC
            co = sv.co_range(nc);
        else co = sv.co;
        end

        % Contrast 'inc'rement range for given white and gray values:
        inc=(white-gray)*co;

        % Calculate parameters of the grating:
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

        % Compute actual cosine grating:
        grating=gray + inc*cos(fr*x);

        % Store 1-D single row grating in texture:
        ex.stim.vals.gratingtex(nf,nc)=Screen('MakeTexture', ex.setup.window, grating);
    end
end

% MAKE BLANK TEXTURE ----------------------------------------------------
% this should extend exactly over the grating texture area
% open texture only if not yet available
if ~isfield(ex.stim.vals,'blanktex') || isempty(ex.stim.vals.blanktex)
    blank = gray+ zeros(size(x));
    ex.stim.vals.blanktex = Screen('MakeTexture',ex.setup.window,blank);
end

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
% open mask only if not yet available
if ~isfield(ex.stim.vals,'masktex') || isempty(ex.stim.vals.masktex)
    %%
    mask=ones(2*texsize+1, 2*texsize+1, 2) * gray;
    %%
    [x,y]=meshgrid(-1*texsize:1*texsize,-1*texsize:1*texsize);
    %%
    switch ex.stim.masktype
        case 'circle'
            edges = sqrt((x).^2 +(y).^2)>texsize;
            mask(:,:,2) = edges*white;
        case 'gauss'
            mask(:, :, 2)=white * (1 - exp(-(0.5*(x/sd).^2)-(0.5*(y/sd).^2)));
        otherwise
           mask(:,:,2) = white;
           mask(max([1,round(texsize-sv.wi*ppd/2)]):round(texsize+sv.wi*ppd/2),...
               max([1,round(texsize-sv.hi*ppd/2)]):round(texsize+sv.hi*ppd/2),2) = 0; 
    end
    %%
    
    ex.stim.vals.masktex=Screen('MakeTexture', ex.setup.window, mask);

end


% COMPUTE REMAINING GRATING PARAMETERS AND STORE THESE --------------------
% Definition of the drawn rectangle on the screen:
% Compute it to  be the visible size of the grating, centered on the
% defined stimulus center

if ~geomCorrect
    left = ppd*sv.x0+ex.fix.PCtr(1)-visiblesize/2;
    bottom = ppd*y0+ex.fix.PCtr(2)-visiblesize/2;
    dstRect=[left bottom left+visiblesize bottom+visiblesize];
else
    % Find image center and place pixel-defined mask there
    [x0Pix,y0Pix]   = deg2pixelxy(sv.x0,sv.y0,ex.setup);
    left    = x0Pix-visiblesize/2;
    bottom  = y0Pix-visiblesize/2;
    dstRect = round([left bottom left+visiblesize bottom+visiblesize]);
end

% compute dstRect if we have a second stimulus
dstRect2 = [];
if isfield(ex.stim.vals,'stim2') & ex.stim.vals.stim2
    left = ppd*sv.x02+ex.fix.PCtr(1)-visiblesize/2;
    bottom = ppd*sv.y02+ex.fix.PCtr(2)-visiblesize/2;
    dstRect2=[left bottom left+visiblesize bottom+visiblesize];
else ex.stim.vals.stim2 = 0;
end

% duration of one monitor refresh interval:
ifi=1/ex.setup.refreshRate;

% Recompute p, this time without the ceil() peration from above.
% Otherwise we will get wrong drift speed due to rounding errors!
p=ppd/sv.sf;  % pixels/cycle    

% FOR DRIFITNG GRATING, COMPUTE THE DRIFT SPEED AND RANDOMIZE PHASE
% Translate requested speed of the grating (in cycles per second) into
% a shift value in "pixels per frame", for given waitduration: This is
% the amount of pixels to shift our srcRect "aperture" in horizontal
% directionat each redraw:

% for RC sequence we force shiftperframe to be 0.  But we need it if we
% combine the RC sequence with a drifting adapter stimulus
ex.stim.vals.shiftperframe= sv.tf * p * ifi;  
phase = randperm(4); % randomize phase, 
%                     (4 phases:    1:=0, 
%                                   2:= pi/2, 
%                                   3:= pi
%                                   4:= 3/2*pi
ex.Trials(ex.j).phase = phase(1);

ex.stim.vals.period = p;

ex.stim.vals.framecnt = 1;
ex.stim.vals.seqcnt = 1;
ex.stim.vals.visiblesize = visiblesize;
ex.stim.vals.dstRect = dstRect;
ex.stim.vals.ppd = ppd;
if ~isempty(dstRect2)
    ex.stim.vals.dstRect2 = dstRect2;
end

%{
% for debugging:
if ex.j == 1
    figure;
    imagesc(grating)
    colorbar
end
%}