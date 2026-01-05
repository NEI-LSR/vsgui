function [ex,RDS]=makeRDS(ex)
%function ex=makeRDS(ex) 
% creates the dot positions of a RDS for one trial
% create    dots(4,ndots): 1,2: x,y; 3,4: hor/vert dx
% then make dots for each frame
%
% 
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
% 04/04/23  hn: allow for uncorrelated and anticorrelated RDS
% 05/02/23  hn: fixed bug for uncorrelated RDS
% 05/05/23  hn: fixed bug with aperture
% 11/24/23  hn: fixed new way of RDS presentation for 2nd stimulus
% 12/06/24  ik: full-field RDS is set when aperture is set to Inf, which in
%               turn is set to Inf when exceeds a certain value.  This will
%               not be centered around the stimulus position, instead will
%               cover the exact display dimension.

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
% include uncorrelated RDS DONE
% include anticorrelated RDS DONE
% fill gaps DONE
% allow for coherently moving dots with disparity
% chck sv.ce (how anticorrelation is defined) DONE (both center and
% surround are uncorrelated)

sv = ex.stim.vals;

% degrees per pixes
dpp = pixel2deg(1,ex.setup);  
ppd = 1/dpp;  % pixels per degree

fd = 1/ex.setup.refreshRate;  % frame duration (in sec)

% default is correlated RDS
if ~isfield(sv,'ce')
    sv.ce = 1; 
end

% get dot colors
black = []; black2 = []; white = []; white2 = []; gray = [];
if ~ex.setup.stereo.Display
    disp('in nonstereo display')
    % dot colors, accounting for contrast
    black = ex.idx.black;  %account for overlay indices
    white = ex.idx.white;
    gray = round((white+black)/2);
    inc=(white-gray)*sv.co;
    white = round(gray+inc); 
    black = round(gray-inc);  %account for overlay indices
else
    white = WhiteIndex(ex.setup.window);
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

% max disparity
md = 0;
varNames = {'hdx_range','hdx_range2','hdx','hdx2'};
for n = 1:length(varNames)
    if isfield(sv,varNames{n})
        md = max([md,eval(['abs(sv.',varNames{n} ')'])]);
        md(md>995) = deal(0);
    end
end
% % surround disparity  hn: 04/03/23 forcing surround to 0
% if sv.shdx>995
%     shdx=0;
% else
%     shdx=sv.shdx;
% end

aperture = max(sv.swi,sv.shi);  % in degrees
c_aperture = max(sv.wi,sv.hi); % aperture of center 
cd_aperture = max(sv.wi,sv.hi)+md; % aperture of center+maximal disparity

aperture = max(aperture,c_aperture); % make sure surround covers center

if aperture > pixel2deg(ex.setup.screenRect(3)/2,ex.setup) * 2
    aperture = Inf;
end
    


% ik - number of dots should be based on area not diameter, should be fixed

% old version:ndots = round(sv.dd*sv.swi*sv.shi/min([sv.dotSz,sv.swi,sv.shi]));
%ndots = round(aperture*ppd*sv.dd/sv.dotSz); % in pixels
%ncdots = round(cd_aperture*ppd*sv.dd/sv.dotSz); % in pixels

% ik - 2023.05.07
if isinf(aperture)
    ndots = round(pixel2deg(ex.setup.screenRect(3)/2,ex.setup) * ...
        pixel2deg(ex.setup.screenRect(4)/2,ex.setup) * 4 * sv.dd);
else
    ndots = round(aperture^2*sv.dd);
end

ncdots = round(cd_aperture^2*sv.dd);


if sv.rds2 % two rds of same size for the spatial attention task
    ndots = ndots*2;
    ncdots = ncdots*2;
    % default position of second stimulus is mirror image of first
    if ~isfield(sv,'x02')
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
else
    y0 = sv.y0;
end

% fixed seed for noise correlation measurement
if isfield(ex.stim.vals,'fixedSeed') && ex.stim.vals.fixedSeed==1
    rng(datenum(date));
end

% for repeatability
ex.Trials(ex.j).rngState = rng;
ex.Trials(ex.j).ndots = ndots;

if sv.dyn % dynamic RDS    
    nFrames = ceil(ex.fix.stimDuration*ex.setup.refreshRate);
    dots = cell(1,nFrames);
    cdots = cell(1,nFrames);
    ucdots = cell(1,nFrames);
    
    if isinf(aperture)  % fullfield RDS surround
        maxR = ex.setup.screenRect(3);
        maxC = ex.setup.screenRect(4);
        for n = 1 : nFrames
            % make dots
            dots{n} = [randi(maxR,1,ndots);randi(maxC,1,ndots);randi(2,1,ndots)];
            %dots{n} = [dots{n};randi(2,1,ndots)]; % indices for dot colors
            cdots{n} = ceil(rand(2,ncdots)*cd_aperture*ppd); % center dots (+max disparity)
            cdots{n} = [cdots{n};randi(2,1,ncdots)]; % indices for dot colors
            ucdots{n} = ceil(rand(2,ncdots)*cd_aperture*ppd); % dots not correlated between the eyes
            ucdots{n} = [ucdots{n};randi(2,1,ncdots)];
        end
    else
        maxN = ceil(aperture*ppd);
        for n = 1 : nFrames
            % make dots
            dots{n} = [randi(maxN,2,ndots);randi(2,1,ndots)];
            %dots{n} = ceil(rand(2,ndots)*aperture*ppd);
            %dots{n} = [dots{n};randi(2,1,ndots)]; % indices for dot colors
            cdots{n} = ceil(rand(2,ncdots)*cd_aperture*ppd); % center dots (+max disparity)
            cdots{n} = [cdots{n};randi(2,1,ncdots)]; % indices for dot colors
            ucdots{n} = ceil(rand(2,ncdots)*cd_aperture*ppd); % dots not correlated between the eyes
            ucdots{n} = [ucdots{n};randi(2,1,ncdots)];
        end
    end
else % static RDS
    dots{1} = ceil(rand(2,ndots)*aperture*ppd);
    dots{1} = [dots{1};randi(2,1,ndots)]; % indices for dot colors
    cdots{1} = ceil(rand(2,ncdots)*cd_aperture*ppd); % center dots (+max disparity)
    cdots{1} = [cdots{1};randi(2,1,ncdots)]; % indices for dot colors
    ucdots{1} = ceil(rand(2,2*ndots)*aperture*ppd); % dots not correlated between the eyes
    ucdots{1} = [ucdots{1};randi(2,1,ncdots)];
end


% add disparities and x/y center positions, dot colors--------------------
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
    % round the edges
    if ~isempty(strcmpi(ex.stim.vals,'circle')) && ~isinf(aperture)
        edges = find(sqrt((dots{n}(1,:)-aperture*ppd/2).^2 + ...
            (dots{n}(2,:)-aperture*ppd/2).^2)  > (aperture*ppd/2));
        if ~isempty(edges)
                dots{n}(:,edges) = [];
        end
    end   
    
    % find surrounddots
   if isinf(aperture)
        x = ex.fix.PCtr(1) + sv.x0 * ppd;
        y = ex.fix.PCtr(2) + sv.y0 * ppd;
        idx = sqrt((dots{n}(1,:) - x).^2 + (dots{n}(2,:) - y).^2) ...
            >= c_aperture * ppd /2;
        sdots = dots{n}(:,idx);
        deltaA = 0;
    else
        deltaA = abs(c_aperture-aperture); %delta aperture
        sdots = dots{n}(:,sqrt((dots{n}(1,:)-(deltaA+c_aperture)*ppd/2).^2 + ...
            (dots{n}(2,:)-(deltaA+c_aperture)*ppd/2).^2)  >= (c_aperture*ppd/2));
    end
%     sdots = dots{n}(:,sqrt((dots{n}(1,:)-c_aperture*ppd).^2 + ...
%         (dots{n}(2,:)-c_aperture*ppd).^2)  >= (c_aperture*ppd/2));

    
    % find centerdots, accounting for disparity
    hdx = 0;
    if ~isempty(seq) % do we need to vary disparity during the trial?
        hdx = round(seq(n)*ppd);
    else % otherwise use constant horizontal disparity
        % set disparity for uncorrelated, monocular & blank stimuli to 0
        if sv.hdx>995
            hdx=0;
        else
            hdx=round(sv.hdx*ppd);
        end
    end

    if hdx>=0  % to ensure we don't have a gap when adding disparities
        hR = hdx;
        hL = hdx/2;
    else
        hR = -hdx/2;
        hL = -hdx;
    end
    
    % add vdx, ik - 2023.05.14
    vdx = 0; vseq = [];
    if ~isempty(vseq) % do we need to vary vert disparity during the trial?
        vdx = round(vseq(n)*ppd);
    else % otherwise use constant vertical disparity
        % set disparity for uncorrelated, monocular & blank stimuli to 0
        if sv.vdx>995
            vdx=0;
        else
            vdx=round(sv.vdx*ppd);
        end
    end

    if vdx>=0  % to ensure we don't have a gap when adding disparities
        vR = vdx;
        vL = vdx/2;
    else
        vR = -vdx/2;
        vL = -vdx;
    end
    
    
    if sv.rds2
        hs      =round(size(cdots{n},2)/2); % half dots
        if ~isempty(seq)
            hdx2 = round(seq2(n)*ppd);
        else
            if sv.hdx2>995
                hdx2 = 0;
            else
                hdx2 = round(sv.hdx2*ppd);
            end
        end
        if hdx2>=0
            hR2 = hdx2;
            hL2 = hdx2/2;
        else
            hR2 = -hdx2/2;
            hL2 = -hdx2;
        end
        
        % dots with different disparities for first and second half        
        dotsR = [cdots{n}(:,1:hs)-[hR;0;0],cdots{n}(:,hs+1:end)-[hR2;0;0]];
        dotsR(3,hs+1:end) = dotsR(3,hs+1:end)+2; %identifyer for dot color of second half
        dotsR = [dotsR;zeros(1,hs),ones(1,size(cdots{n},2)-hs)]; % identifyers for first and second half
        
        dotsL = [cdots{n}(:,1:hs)-[hL;0;0],cdots{n}(:,hs+1:end)-[hL2;0;0]];  
        dotsL(3,hs+1:end) = dotsL(3,hs+1:end) +2; %identifyer for dot color of second half
        dotsL = [dotsL;zeros(1,hs),ones(1,size(cdots{n},2)-hs)]; % identifyer for first and second half
        
    else
        % rows: 1: xpos 2: ypos 3: dotcol 4: identifyer for center dots
        %dotsR = [cdots{n}-[hR;0;0];zeros(1,size(cdots{n},2))]; %
        %dotsL = [cdots{n}-[hL;0;0]; zeros(1,size(cdots{n},2))];
        dotsR = [cdots{n}-[hR;vR;0];zeros(1,size(cdots{n},2))]; %
        dotsL = [cdots{n}-[hL;vL;0]; zeros(1,size(cdots{n},2))];
    end
    
    dotsR = dotsR(:,sqrt((dotsR(1,:) -(c_aperture)*ppd/2).^2+ ...
        (dotsR(2,:) -(c_aperture)*ppd/2).^2)< c_aperture*ppd/2);
    dotsL = dotsL(:,sqrt((dotsL(1,:) -(c_aperture)*ppd/2).^2+ ...
        (dotsL(2,:) -(c_aperture)*ppd/2).^2)< c_aperture*ppd/2);
    %
%       dotsR = dotsR(:,sqrt((dotsR(1,:) -(xc+c_aperture)*ppd/2).^2+ ...
%         (dotsR(2,:) -(yc+c_aperture)*ppd/2).^2)< c_aperture*ppd/2);
%     dotsL = dotsL(:,sqrt((dotsL(1,:) -(xc+c_aperture)*ppd/2).^2+ ...
%         (dotsL(2,:) -(yc+c_aperture)*ppd/2).^2)< c_aperture*ppd/2);


    if sv.ce ==0 % replace dots for left eye
        dotsL = ucdots{n}(:,sqrt((ucdots{n}(1,:) -(c_aperture)*ppd/2).^2+ ...
        (ucdots{n}(2,:) -(c_aperture)*ppd/2).^2)< c_aperture*ppd/2);
    
        if sv.rds2
            hs = round(size(dotsL,2)/2);
         dotsL(3,hs+1:end) = dotsL(3,hs+end) +2; %identifyer for dot color of second half
           
            dotsL = [dotsL;zeros(1,hs),ones(1,size(dotsL,2)-hs)];
        else 
            dotsL(4,:) = zeros(1,size(dotsL,2));
        end
    end

    
    % correct dot positions relative to FP and center of stimulus
    if sv.rds2 
        % if we have 2 rds we need different x0,y0 positions for first and second half of dots
        % first half of dots corresponds to target stimulus, second half of
        % dots to distractor
       
        
        dotsR(1,dotsR(4,:)==0) = dotsR(1,dotsR(4,:)==0)+round((sv.x0+deltaA/2-sv.swi/2)*ppd)+ex.fix.PCtr(1); % x-position
        dotsR(2,dotsR(4,:)==0) = dotsR(2,dotsR(4,:)==0)+round((y0+deltaA/2-sv.shi/2)*ppd)+ex.fix.PCtr(2); % y-position
        dotsR(1,dotsR(4,:)==1) = dotsR(1,dotsR(4,:)==1)+round((sv.x02+deltaA/2-sv.swi/2)*ppd)+ex.fix.PCtr(1); % x-position
        dotsR(2,dotsR(4,:)==1) = dotsR(2,dotsR(4,:)==1)+round((sv.y02+deltaA/2-sv.shi/2)*ppd)+ex.fix.PCtr(2); % y-position
        
        dotsL(1,dotsL(4,:)==0) = dotsL(1,dotsL(4,:)==0)+round((sv.x0+deltaA/2-sv.swi/2)*ppd)+ex.fix.PCtr(1); % x-position
        dotsL(2,dotsL(4,:)==0) = dotsL(2,dotsL(4,:)==0)+round((y0+deltaA/2-sv.shi/2)*ppd)+ex.fix.PCtr(2); % y-position
        dotsL(1,dotsL(4,:)==1) = dotsL(1,dotsL(4,:)==1)+round((sv.x02+deltaA/2-sv.swi/2)*ppd)+ex.fix.PCtr(1); % x-position
        dotsL(2,dotsL(4,:)==1) = dotsL(2,dotsL(4,:)==1)+round((sv.y02+deltaA/2-sv.shi/2)*ppd)+ex.fix.PCtr(2); % y-position
        
        hs =round(size(sdots,2)/2);
        sdots(1,1:hs) = sdots(1,1:hs)+round((sv.x0-sv.swi/2)*ppd)+ex.fix.PCtr(1);
        sdots(2,1:hs) = sdots(2,1:hs)+round((y0-sv.shi/2)*ppd)+ex.fix.PCtr(2);
        sdots(1,hs+1:end) = sdots(1,hs+1:end)+round((sv.x02-sv.swi/2)*ppd)+ex.fix.PCtr(1);
        sdots(2,hs+1:end) = sdots(2,hs+1:end)+round((sv.y02-sv.shi/2)*ppd)+ex.fix.PCtr(2);
        sdots(3,hs+1:end) = sdots(3,hs+1:end)+2;
        
    else
        %{
         dotsL(1,:) = dotsL(1,:)+round((sv.x0-sv.swi/2)*ppd)+ex.fix.PCtr(1); % x-position of dots
         dotsL(2,:) = dotsL(2,:)+round((y0-sv.shi/2)*ppd)+ex.fix.PCtr(2); % y-position of dots
         dotsR(1,:) = dotsR(1,:)+round((sv.x0-sv.swi/2)*ppd)+ex.fix.PCtr(1); % x-position of dots
         dotsR(2,:) = dotsR(2,:)+round((y0-sv.shi/2)*ppd)+ex.fix.PCtr(2); % y-position of dots
        %}      

        % 2024.12.06: ik
        %{
        dotsL(1,:) = dotsL(1,:)+round((sv.x0+deltaA/2-sv.swi/2)*ppd)+ex.fix.PCtr(1); % x-position of dots
        dotsL(2,:) = dotsL(2,:)+round((y0+deltaA/2-sv.shi/2)*ppd)   +ex.fix.PCtr(2); % y-position of dots
        dotsR(1,:) = dotsR(1,:)+round((sv.x0+deltaA/2-sv.swi/2)*ppd)+ex.fix.PCtr(1); % x-position of dots
        dotsR(2,:) = dotsR(2,:)+round((y0+deltaA/2-sv.shi/2)*ppd)   +ex.fix.PCtr(2); % y-position of dots
        %}
        
        dotsL(1,:) = dotsL(1,:)+round((sv.x0-c_aperture/2)*ppd)+ex.fix.PCtr(1); % x-position of dots
        dotsL(2,:) = dotsL(2,:)+round((y0-c_aperture/2)*ppd)+ex.fix.PCtr(2); % y-position of dots
        dotsR(1,:) = dotsR(1,:)+round((sv.x0-c_aperture/2)*ppd)+ex.fix.PCtr(1); % x-position of dots
        dotsR(2,:) = dotsR(2,:)+round((y0-c_aperture/2)*ppd)+ex.fix.PCtr(2); % y-position of dots
        if ~isinf(aperture)
            
            sdots(1,:) = sdots(1,:)+round((sv.x0-sv.swi/2)*ppd)+ex.fix.PCtr(1);
            sdots(2,:) = sdots(2,:)+round((y0-sv.shi/2)*ppd)   +ex.fix.PCtr(2);
        end
        
    end
    
    % remove off-screen dots from surround
    offDots = sdots(1,:) > ex.setup.screenRect(3) | ...   % x
        sdots(2,:) > ex.setup.screenRect(4);              % y
    sdots(:,offDots) = [];
    sdots(4,:) = 2;         %identifyer for surround dots
    
    dR = [sdots,dotsR];
    dL = [sdots,dotsL]; 
    
    switch sv.dcol
        case 'blwi'
            
            dR(3,dR(3,:)==1) = black;
            dR(3,dR(3,:)==2) = white;
            dR(3,dR(3,:)==3) = black2;
            dR(3,dR(3,:)==4) = white2;
            
            if sv.ce >= 0
                dL(3,dL(3,:)==1) = black;
                dL(3,dL(3,:)==2) = white;
                dL(3,dL(3,:)==3) = black2;
                dL(3,dL(3,:)==4) = white2;
            elseif sv.ce == -1 % anticorrelated center RDS
                dL(3,dL(3,:)==2 & dL(4,:)<2) = black;
                dL(3,dL(3,:)==1 & dL(4,:)<2) = white;
                dL(3,dL(3,:)==4 & dL(4,:)<2) = black2;
                dL(3,dL(3,:)==3 & dL(4,:)<2) = white2;
                
                dL(3,dL(3,:)==1 & dL(4,:)==2) = black;
                dL(3,dL(3,:)==2 & dL(4,:)==2) = white;
                dL(3,dL(3,:)==3 & dL(4,:)==2) = black2;
                dL(3,dL(3,:)==4 & dL(4,:)==2) = white2;                
            end                
                            
        case 'bl'
            dR(3,dR(3,:)<3) = black;
            dR(3,dR(3,:)>2) = black2;
            if sv.ce>=0
                dL(3,dL(3,:)<3) = black;
                dL(3,dL(3,:)>2) = black2;
            elseif sv.ce ==-1 % anticorrelated center RDS
                dL(3,dL(3,:)<3 & dL(4,:)<2) = white;
                dL(3,dL(3,:)>2 & dL(4,:)<2) = white2;
                
                dL(3,dL(3,:)<3 & dL(4,:)==2) = black;
                dL(3,dL(3,:)>2 & dL(4,:)==2) = black2;                
            end
            
        case 'wi' 
            dR(3,dR(3,:)<3) = white;
            dR(3,dR(3,:)>2) = white2;

            if sv.ce >=0
                dL(3,dL(3,:)<3) = white;
                dL(3,dL(3,:)>2) = white2;
            elseif sv.ce ==-1 % anticorrelated center RDS
                dL(3,dL(3,:)<3 & dL(4,:)<2) = black;
                dL(3,dL(3,:)>2 & dL(4,:)<2) = black2;
                
                dL(3,dL(3,:)<3 & dL(4,:)==2) = white;
                dL(3,dL(3,:)>2 & dL(4,:)==2) = white2;               
            end
   
    end
    dSzR          = ones(1,size(dR,2))*sv.dotSz;
    dSzL          = ones(1,size(dL,2))*sv.dotSz;
    
        
    % make the spatial attention cue (obsolete? hn: 04/04/23)
    if sv.flashCue 
        dR(1,end+1) = round(sv.x0*ppd)+ex.fix.PCtr(1);
        dR(2,end) = round((y0+sv.flashCueYoffset)*ppd)+ex.fix.PCtr(2);
        dL(1,end+1) = round(sv.x0*ppd)+ex.fix.PCtr(1);
        dL(2,end) = round((y0+sv.flashCueYoffset)*ppd)+ex.fix.PCtr(2);
        
        % flash this cue on only for flashCueDuration
        if n*fd>sv.flashCueOnsetTime && n*fd<sv.flashCueOnsetTime+sv.flashCueDur
            dR(3,end) = white;
            dL(3,end) = white;
        else
            dR(3,end) = gray;
            dL(3,end) = gray;
        end
        dSzR(end+1) = sv.flashCueDotSz;
        dSzL(end+1) = sv.flashCueDotSz;
    end
    
    dR(4,:) = dSzR;
    dL(4,:) = dSzL;

    RDS.R{n} = dR;
    RDS.L{n} = dL;
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

%disp([sprintf('hdx: %1.2f  hdx2: %1.2f', sv.hdx, sv.hdx2)])

% MAKE BLANK TEXTURE ----------------------------------------------------
% this should extend exactly over the RDS area
if isinf(aperture)
    aperture = 10;
end
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


