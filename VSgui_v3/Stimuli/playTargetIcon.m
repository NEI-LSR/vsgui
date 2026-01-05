function ex=playTargetIcon(ex,gT,or,tC)

% distributes play** commands according to the experiment and stimulus
% gR : "good_response": determines the sign of the disparity; 
%       gR<0: near dx is correct
% gT : "good_target": determines the target position for the correct target
% tC:   "target color": 0: higher contrast (presented during go period)
%                       1: lower contrast (presented during stimulus when
%                       teaching them not to respond to the targets
%                       immediately while stimulus is present)
% 11/03/15  hn: wrote it
% 3/28/2023 IK: added playTargetIconSymbol to be able to use a circle or
% square as a target

switch ex.stim.type
    case 'grating'
        ex = playTargetIconGrating(ex,gT,or,tC);
    case 'rds'
        ex=playTargetIconRDS(ex,gT,or,tC);
end

