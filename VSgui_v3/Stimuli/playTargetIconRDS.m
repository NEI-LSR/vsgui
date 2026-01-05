function ex=playTargetIconRDS(ex,gT,gR,tC)
% ex=playTargetIconRDS(ex,goodT,gR)
% display TargetIconRDS
%
% gR : "good_response": determines the sign of the disparity; 
%       gR<0: near dx is correct
% gT : "good_target": determines the target position for the correct target
% tC:   "target color": 0: higher contrast (presented during go period)
%                       1: lower contrast (presented during stimulus when
%                       teaching them not to respond to the targets
%                       immediately while stimulus is present)
%
% history
% 5/5/14    hn: wrote it
% 07/11/14  hn: -included field 'setup' and moved setup parameters into it
%               new parameter name          old parameter name
%               ex.setup.stereo             ex.stereo
%               ex.setup.window             ex.window
%               ex.setup.overlay            ex.overlay
% 01/05/15  hn: -include target x-Offset

if tC ==0
    if ex.targ.icon.framecnt +1 <= length(ex.targ.icon.RDS)    % if enough frames prepared
        ex.targ.icon.framecnt = ex.targ.icon.framecnt +1; 
    else ex.targ.icon.framecnt = 1;  % otherwise start over with first frame
    end
    n = ex.targ.icon.framecnt;
else
    if ex.targ.icon.framecnt2 +1 <= length(ex.targ.icon.RDS)    % if enough frames prepared
        ex.targ.icon.framecnt2 = ex.targ.icon.framecnt2 +1; 
    else ex.targ.icon.framecnt2 = 1;  % otherwise start over with first frame
    end
    n = ex.targ.icon.framecnt2;
end

dpp = atan(ex.setup.monitorWidth/2/ex.setup.viewingDistance)*180/pi/(ex.setup.screenRect(3)/2);  % degrees per pixes
ppd = 1/dpp;  % pixels per degree

txO = 0; % target xOffset
if isfield(ex.targ.icon,'xOffset')
    txO = sign(ex.stim.vals.x0)*ppd*ex.targ.icon.xOffset;
end



% Select RIGHT-eye image buffer for drawing:-------------------------------
Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
% Screen('FillRect',ex.setup.window,ex.idx.bg_lum);  % background to start 
 
% Draw RIGHT stim:
Screen('DrawDots', ex.setup.window,...
    [ex.targ.icon.RDS{n}(1,:)-gR*ex.targ.icon.RDS{n}(3,:)/2 + ex.fix.PCtr(1) + ex.targ.Pos(gT==1,1)+txO,... %T1 x
     ex.targ.icon.RDS{n}(1,:)+gR*ex.targ.icon.RDS{n}(3,:)/2 + ex.fix.PCtr(1) + ex.targ.Pos(gT~=1,1)+txO;... %T2 x
     ex.targ.icon.RDS{n}(2,:)                    + ex.fix.PCtr(2) + ex.targ.Pos(gT==1,2), ...            %T1 y
     ex.targ.icon.RDS{n}(2,:)                    + ex.fix.PCtr(2) + ex.targ.Pos(gT~=1,2)], ...           %T2 y
     ex.stim.vals.dotSz, [[ex.targ.icon.Col{tC*2+1}{n};ex.targ.icon.Col{tC*2+2}{n}]*ones(1,3)]');

% blue lines not needed 
% Screen('FillRect', ex.setup.window, [0] , ex.setup.stereo.b_ROn);
% Screen('FillRect', ex.setup.window, [0] , ex.setup.stereo.b_ROff);

% Select LEFT-eye image buffer for drawing:--------------------------------
Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
%Screen('FillRect',ex.setup.window,ex.idx.bg_lum);  % background to start

% Draw LEFT stim:
Screen('DrawDots', ex.setup.window, ...
    [ex.targ.icon.RDS{n}(1,:)+gR*ex.targ.icon.RDS{n}(3,:)/2 + ex.fix.PCtr(1) + ex.targ.Pos(gT==1,1)+txO,... %T1 x
     ex.targ.icon.RDS{n}(1,:)-gR*ex.targ.icon.RDS{n}(3,:)/2 + ex.fix.PCtr(1) + ex.targ.Pos(gT~=1,1)+txO;... %T2 x
     ex.targ.icon.RDS{n}(2,:)                    + ex.fix.PCtr(2) + ex.targ.Pos(gT==1,2),...             %T1 y
     ex.targ.icon.RDS{n}(2,:)                    + ex.fix.PCtr(2) + ex.targ.Pos(gT~=1,2)],...            %T2 y
     ex.stim.vals.dotSz, [[ex.targ.icon.Col{tC*2+1}{n};ex.targ.icon.Col{tC*2+2}{n}]*ones(1,3)]');
 
% no longer needed: 
% Screen('FillRect', ex.setup.window, [1] , ex.setup.stereo.b_LOn);  
% Screen('FillRect', ex.setup.window, [0] , ex.setup.stereo.b_LOff);


