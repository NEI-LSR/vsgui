function [ex,RDS]=makeRDS(ex)
%function ex=makeRDS(ex) 
% creates the dot positions of a RDS for one trial
% create    dots(4,ndots): 1,2: x,y; 3,4: hor/vert dx
% then make dots for each frame

% history
% 07/11/14  hn: -included field 'setup' and moved setup parameters into it
%               new parameter name          old parameter name
%               ex.setup.stereo             ex.stereo
%               ex.setup.window             ex.window
%               ex.setup.overlay            ex.overlay
% 07/26/14  hn: -modified the noise generation for Dc to increase the
%               variance; now draw each dx in sequence from uniform
%               distribution;
%               previously I generated an equal number of repeats for each
%               dx, and then re-shuffled these until all frames were
%               filled. The variance of this was small
% 10/14/14  hn: -changed to include pre-stim duration
% 11/11/14  hn: -changed to include second RDS for spatial attention
%               task
% 12/10/14  hn: -changed to allow for different contrast of second RDS
% 10/27/15  hn: -add flashed cue above stimulus on instruction trials
%               TODOs: add cue to RDS, dotSz, dotColl
% 11/17/16  hn: -add code for interocular correlation of RDS
% 12/07/16  hn: -allow for blank and monocular stimuli
% 12/09/16  hn: included two-pass of random sequence 
% 01/30/19  hn: included option for fixed seed

%sv.dd: dot density
%sv.swi: surround width
%sv.shi: surround height
%sv.hdx: horizontal dx of center patch
%sv.vdx: vertical dx of center
%sv.shdx: horizontal dx of surround
%sv.svdx: vertical dx of surround
%sv.square: aperture square (1) or circular (0)
%sv.ce:  interocular correlation

% TODOs
% include uncorrelated RDS
% include anticorrelated RDS
% fill gaps
% allow for coherently moving dots with disparity

sv = ex.stim.vals;

dpp = atan(ex.setup.monitorWidth/2/ex.setup.viewingDistance)*180/pi/(ex.setup.screenRect(3)/2);  % degrees per pixes
ppd = 1/dpp;  % pixels per degree
fd = 1/ex.setup.refreshRate;  % frame duration (in sec)

aperture = max(sv.swi,sv.shi);  % in degrees
c_aperture = max(sv.wi,sv.hi); % aperture of center
ndots = round(sv.dd*sv.swi*sv.shi/min([sv.dotSz,sv.swi,sv.shi]));
if sv.rds2 % two rds of same size for the spatial attention task
    ndots = ndots*2;
    % default position of second stimulus is mirror image of first
    if ~isfield(sv,'x02');
        sv.x02 = -sv.x0;
    end
    if ~isfield(sv,'y02')
        sv.y02 = sv.y0;
    end
    % default hdx for second stimulus is 0
    if ~isfield(sv,'hdx2')
        sv.hdx2 = 0;
    end
end

% include y_offset as a cue towards the correct target for the
% discrimination task, if we have it
if isfield(ex.stim.vals,'y_OffsetCue')
    y0 = sv.y0+ex.stim.vals.y_OffsetCue;
else y0 = sv.y0;
end

% fixed seed for noise correlation measurement
if isfield(ex.stim.vals,'fixedSeed') && ex.stim.vals.fixedSeed==1
    rng(datenum(date));
end

% for repeatability
ex.Trials(ex.j).rngState = rng;
ex.Trials(ex.j).ndots = ndots;

if sv.dyn % dynamic RDS
    
    for n = 1 : ceil((ex.fix.stimDuration)*ex.setup.refreshRate)  
        % make dots
        dots{n} = ceil(rand(2,ndots)*aperture*ppd);
        ucdots{n} = ceil(rand(2,2*ndots)*aperture*ppd); % dots not correlated between the eyes 
    end
else % static RDS
    dots{1} = ceil(rand(2,ndots)*aperture*ppd);
    ucdots{1} = ceil(rand(2,2*ndots)*aperture*ppd); % dots not correlated between the eyes

end


% add disparities and x/y center positions, dot colors--------------------
% get dot colors
if ~ex.setup.stereo.Display
    disp('in nonstereo display')
    % dot colors, accounting for contrast
    black = ex.idx.black;  %account for overlay indices
    white = ex.idx.white;
    gray = round((white+black)/2);
    inc=(white-gray)*sv.co;
    white = round(gray+inc); 
    black = round(gray-inc);  %account for overlay indices
else white = WhiteIndex(ex.setup.window);
    black = BlackIndex(ex.setup.window);
    gray = (white+black)/2;
    inc=(white-gray)*sv.co;
    white = (gray+inc); 
    black = (gray-inc); 
    if sv.rds2
        inc2 = (white-gray)*sv.co2;
        white2 = gray+inc2;
        black2 = gray-inc2;
    end
end

% if disparity is changing over time (0<Dc<1) generate the disparity
% sequence; otherwise assume constant disparity
% get disparities
seq = [];
seq2 = [];
if isfield(sv,'Dc')
    % make frames with disparity signal first
    seq = ones(1,ceil(length(dots)*sv.Dc))*sv.hdx;
    n_noiseF = length(dots)-length(seq); % number of noise frames
    % now add number of noise frames
    if n_noiseF>0
        % generate random sequence of indices
        r_idx = floor(rand(1,n_noiseF)*length(sv.hdx_range))+1;
        noise_seq = sv.hdx_range(r_idx);
        seq = [seq,noise_seq]; 
    end
    % now randomize the sequence
    rp = randperm(length(dots));
    seq = seq(rp);
    
    if sv.rds2  
        % make frames with disparity signal first
        seq2 = ones(1,ceil(length(dots)*sv.Dc2))*sv.hdx2;
        n_noiseF = length(dots)-length(seq2); % number of noise frames
        % now add number of noise frames
        if n_noiseF>0
            % generate random sequence of indices
            r_idx = floor(rand(1,n_noiseF)*length(sv.hdx_range))+1;
            noise_seq = sv.hdx_range(r_idx);
            seq2 = [seq2,noise_seq]; 
        end
        % now randomize the sequence
        rp = randperm(length(dots));
        seq2 = seq2(rp);

    end 
end 


for n = 1:length(dots)  % n: each video frame of the RDS
    if ~isempty(strcmpi(ex.stim.vals,'circle'))        % round the edges
        edges = find(sqrt((dots{n}(1,:)-aperture*ppd/2).^2 + (dots{n}(2,:)-aperture*ppd/2).^2)  > (aperture*ppd/2));
        if ~isempty(edges)
                dots{n}(:,edges) = [];
        end
    end
    % find centerdots and surrounddots
    xc = abs(sv.swi-sv.wi);
    yc = abs(sv.shi-sv.hi);
    cdots = find(sqrt((dots{n}(1,:)-(xc+c_aperture)*ppd/2).^2 + (dots{n}(2,:)-(yc+c_aperture)*ppd/2).^2)  < (c_aperture*ppd/2));    
    
    % correct dot positions relative to FP and center of stimulus
    if sv.rds2 
        % if we have 2 rds we need different x0,y0 positions for first and second half of dots
        % first half of dots corresponds to target stimulus, second half of
        % dots to distractor
        hdots =round(size(dots{n},2)/2);
        
        dots{n}(1,1:hdots) = dots{n}(1,1:hdots)+round((sv.x0-sv.swi/2)*ppd)+ex.fix.PCtr(1); % x-position
        dots{n}(2,1:hdots) = dots{n}(2,1:hdots)+round((y0-sv.shi/2)*ppd)+ex.fix.PCtr(2); % y-position
        dots{n}(1,hdots+1:end) = dots{n}(1,hdots+1:end)+round((sv.x02-sv.swi/2)*ppd)+ex.fix.PCtr(1);
        dots{n}(2,hdots+1:end) = dots{n}(2,hdots+1:end)+round((sv.y02-sv.shi/2)*ppd)+ex.fix.PCtr(2); 
    else
        dots{n}(1,:) = dots{n}(1,:)+round((sv.x0-sv.swi/2)*ppd)+ex.fix.PCtr(1); % x-position of dots
        dots{n}(2,:) = dots{n}(2,:)+round((y0-sv.shi/2)*ppd)+ex.fix.PCtr(2); % y-position of dots
    end
    
    % add disparities for each frame
    % add horizontal disparity
    % set disparity for monocular & blank stimuli to 0
    if sv.shdx>995
        shdx=0;
    else shdx=sv.shdx;
    end
    dots{n}(3,:) = round(shdx*ppd);
    if sv.rds2 
        % if we have 2 rds we need different disparities for first and
        % second half of dots.
        % first half of dots corresponds to target stimulus, second half of
        % dots to distractor
        first_half = find(cdots<=hdots);
        second_half = find(cdots>hdots);
        if ~isempty(seq) % do we need to vary disparity during the trial?
            dots{n}(3,cdots(first_half)) = round(seq(n)*ppd);
            dots{n}(3,cdots(second_half)) = round(seq2(n)*ppd);
        else % otherwise use constant horizontal disparity
            % set disparity for monocular & blank stimuli to 0
            if sv.hdx>995
                hdx=0;
            else hdx=sv.hdx;
            end
            if sv.hdx2>995
                hdx2=0;
            else hdx2=sv.hdx2;
            end
            dots{n}(3,cdots(first_half)) = round(hdx*ppd);
            dots{n}(3,cdots(second_half)) = round(hdx2*ppd);
        end
    else
        if ~isempty(seq) % do we need to vary disparity during the trial?
            dots{n}(3,cdots) = round(seq(n)*ppd);
        else % otherwise use constant horizontal disparity
            % set disparity for monocular & blank stimuli to 0
            if sv.hdx>995
                hdx=0;
            else hdx=sv.hdx;
            end
            dots{n}(3,cdots) = round(hdx*ppd);
        end
    end
    % add vertical disparity
    dots{n}(4,:) = round(sv.svdx*ppd);
    dots{n}(4,cdots) = round(sv.vdx*ppd);
            
    switch sv.dcol
        case 'blwi'
            if sv.rds2
                black_dots = round(hdots/2);
                white_dots = hdots-black_dots;
                shdots = size(dots{n},2)-hdots;  % number of dots for distractor
                black_dots2 =  round(shdots/2);
                white_dots2 = shdots-black_dots2;
                icols = [ones(1,black_dots)*black,ones(1,white_dots)*white];
                rds_cols = icols(randperm(length(icols)));
                icols = [ones(1,black_dots2)*black2,ones(1,white_dots2)*white2];
                rds_cols2 = icols(randperm(length(icols)));
                dotCols{n} = [rds_cols,rds_cols2];
            else
                hndots = round(size(dots{n},2)/2);
                indots = size(dots{n},2);
                icols = [ones(1,hndots)*black,ones(1,indots-hndots)*white];
                dotCols{n} = icols(randperm(length(icols)));
            end
                
        case 'bl'
            if sv.rds2
                dotCols{n} = [ones(1,hdots)*black,ones(size(dots{n},2)-hdots)*black2];
            else
                dotCols = black;
            end
        case 'wi' 
            if sv.rds2
                dotCols{n} = [ones(1,hdots)*white,ones(size(dots{n},2)-hdots)*white2];
            else
                dotCols = white;
            end
    end
    dotSz{n}(1:length(dotCols{n})) = sv.dotSz;
    
    % make the spatial attention cue
    if sv.flashCue 
        dots{n}(1,end+1) = round(sv.x0*ppd)+ex.fix.PCtr(1);
        dots{n}(2,end) = round((y0+sv.flashCueYoffset)*ppd)+ex.fix.PCtr(2);
        dots{n}(3,end) = 0;
        dots{n}(4,end) = 0;
        % flash this cue on only for flashCueDuration
        if n*fd>sv.flashCueOnsetTime && n*fd<sv.flashCueOnsetTime+sv.flashCueDur
            dotCols{n}(end+1) = white;
        else
            dotCols{n}(end+1) = gray;
        end
        dotSz{n}(end+1) = sv.flashCueDotSz;
    end

end

ex.Trials(ex.j).framecnt = 0;
ex.Trials(ex.j).framesComplete = 0;
if ~isempty(seq)
    ex.Trials(ex.j).hdx_seq = seq;
end
if ~isempty(seq2)
    ex.Trials(ex.j).hdx_seq2 = seq2;
    ex.Trials(ex.j).Dc2 = sv.Dc2;
    ex.Trials(ex.j).hdx2 = sv.hdx2;
end
%ex.Trials(ex.j).RDS = dots;
RDS.dots = dots;
RDS.dotSz = dotSz;
if strcmpi(sv.dcol,'blwi')
    %ex.Trials(ex.j).dotCols = dotCols;
    RDS.dotCols = dotCols;
else ex.stim.vals.dotCols = dotCols;
end
%disp([sprintf('hdx: %1.2f  hdx2: %1.2f', sv.hdx, sv.hdx2)])

% MAKE BLANK TEXTURE ----------------------------------------------------
% this should extend exactly over the RDS area
gray = ex.idx.bg;
blank = gray+ zeros(1,ceil(aperture*ppd));
ex.stim.vals.blanktex = Screen('MakeTexture',ex.setup.window,blank);

texsize=ceil(aperture*ppd)/2;
%%
% This is the visible size of the RDS. It is twice the half-width
% of the texture plus one pixel to make sure it has an odd number of
% pixels and is therefore symmetric around the center of the texture:
visiblesize = 2*texsize+1;

left = ppd*sv.x0+ex.fix.PCtr(1)-visiblesize/2;
bottom = ppd*y0+ex.fix.PCtr(2)-visiblesize/2;
dstRect=[left bottom left+visiblesize bottom+visiblesize]; 

ex.stim.vals.visiblesize = visiblesize;
ex.stim.vals.dstRect = dstRect;


