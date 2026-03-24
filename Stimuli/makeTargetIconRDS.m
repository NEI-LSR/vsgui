function ex=makeTargetIconRDS(ex)

%function ex=makeTargetIconRDS(ex) 
% creates the dot positions of a RDS for one experiment for the two
% alternative choices
% create    dots(4,ndots): 1,2: x,y; 3,4: hor/vert dx
% then make dots for each frame

% history
% 2014      hn: wrote it
% 07/11/14  hn: -included field 'setup' and moved setup parameters into it
%               new parameter name          old parameter name
%               ex.setup.stereo             ex.stereo
%               ex.setup.window             ex.window
%               ex.setup.overlay            ex.overlay
%               ex.setup.refreshRate        ex.refreshrate
% 01/18/16  hn: -allow for ramping up of the target contrast during
%               presentaion

sv = ex.stim.vals;
tv = ex.targ.icon;

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
% ex.targ.icon.hdx = [-0.1;0.1];  % horizontal disparities t-iconol center
% ex.targ.icon.T1co = 1;
% ex.targ.icon.T2co = 0;


% 
% 
%sv.dd: dot density
%sv.swi: surround width
%sv.shi: surround height
%sv.hdx: horizontal dx of center patch
%sv.vdx: vertical dx of center
%sv.shdx: horizontal dx of surround
%sv.svdx: vertical dx of surround
%sv.square: aperture square (1) or circular (0)


dpp = atan(ex.setup.monitorWidth/2/ex.setup.viewingDistance)*180/pi/(ex.setup.screenRect(3)/2);  % degrees per pixes
ppd = 1/dpp;  % pixels per degree

aperture = max(tv.ssz);  % in degrees
ndots = round(sv.dd*tv.sz^2/min(sv.dotSz,tv.ssz));


if sv.dyn % dynamic RDS
    for n = 1 : ceil(ex.targ.duration*ex.setup.refreshRate)
        % make dots
        dots{n} = ceil(rand(2,ndots)*aperture*ppd);
    end
else % static RDS
    dots{1} = ceil(rand(2,ndots)*aperture*ppd);
end


% add disparities and x/y center positions, dot colors
c_aperture = max(tv.sz);
if ~ex.setup.stereo.Display
    % dot colors, accounting for contrast
    white = round(ex.idx.white * sv.co);  % white, scaled down by contrast
    black = ex.idx.black;  %account for overlay indices
    gray = round((white+black)/2);
    inc=(white-gray)*sv.co;
    white = round(gray+inc); 
    black = round(gray-inc);  %account for overlay indices
else white = WhiteIndex(ex.setup.window);
    black = BlackIndex(ex.setup.window);
    gray = (white+black)/2;
    
    % compute the dot colors if they change during the trial
    for n = 1:length(dots)
        if tv.rampDur ==0  
            co1 = tv.T1co;
            co2 = tv.T2co;
        else
            % duration of the ramping up of the contrast
            rampDur = min([1/tv.rampDur/ex.setup.refreshRate*n,1]);
            co1 = tv.T1co*rampDur;
            co2 = tv.T2co*rampDur;
        end
        
        inc1 = (white-gray)*co1;
        inc2 = (white-gray)*co2;
        white1_{n} = (gray+inc1); 
        black1_{n} = (gray-inc1); 
        white2_{n} = (gray+inc2); 
        black2_{n} = (gray-inc2); 
    end
    %
    
    % baseline contrast at the beginning of the trial, before "official"
    % target onset
    inc1 = (white-gray)*tv.T1co2;
    inc2 = (white-gray)*tv.T2co2;
    white1_2 = (gray+inc1); 
    black1_2 = (gray-inc1); 
    white2_2 = (gray+inc2); 
    black2_2 = (gray-inc2); 
    
end

for n = 1:length(dots)
    if ~isempty(strcmpi(ex.stim.vals,'circle'))
        % round the edges
        edges = find(sqrt((dots{n}(1,:)-aperture*ppd/2).^2 + (dots{n}(2,:)-aperture*ppd/2).^2)  > (aperture*ppd/2));
        if ~isempty(edges)
                dots{n}(:,edges) = [];
        end
    end
    
    % assign dot color values for the contrast at the current time during the
    % trial (allows for contrast variation)
    white1 = white1_{n};
    white2 = white2_{n};
    black1 = black1_{n};
    black2 = black2_{n};
    
    % find centerdots and surrounddots
    xc = abs(tv.ssz-tv.sz);
    yc = abs(tv.ssz-tv.sz);
    cdots = find(sqrt((dots{n}(1,:)-(xc+c_aperture)*ppd/2).^2 + (dots{n}(2,:)-(yc+c_aperture)*ppd/2).^2)  < (c_aperture*ppd/2));    
    
    % disparities for center 
    dots{n}(3,:) = 0;
    dots{n}(3,cdots) = round(tv.hdx*ppd);
    
    % dot positions relative to patch center
    dots{n}(1,:) = dots{n}(1,:)-round((tv.ssz*ppd)/2);
    dots{n}(2,:) = dots{n}(2,:)-round((tv.ssz*ppd)/2);

    switch sv.dcol
        case 'blwi'
            hndots = round(size(dots{n},2)/2);
            indots = size(dots{n},2);
            Col1{n} = [ones(1,hndots)*black1,ones(1,indots-hndots)*white1]';
            Col2{n} = [ones(1,hndots)*black2,ones(1,indots-hndots)*white2]';
            Col1_2{n} = [ones(1,hndots)*black1_2,ones(1,indots-hndots)*white1_2]';
            Col2_2{n} = [ones(1,hndots)*black2_2,ones(1,indots-hndots)*white2_2]';
            
        case 'bl'
            Col1 = black1;
            Col2 = black2;
        case 'wi' 
            Col1 = white1;
            Col2 = white2;
    end

end

ex.targ.icon.RDS = dots;   % target 1 is the correct target
ex.targ.icon.Col{1} = Col1;
ex.targ.icon.Col{2} = Col2;
ex.targ.icon.Col{3} = Col1_2;
ex.targ.icon.Col{4} = Col2_2;
ex.targ.icon.framecnt = 0;  % framecount for "real" target after targetOnsetDelay
ex.targ.icon.framecnt2 = 0; % framecount for "baseline" targets

