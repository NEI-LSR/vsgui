function ex = unknownRig(ex,type)
% function ex = unknownRig(ex,type)
%
% setup function to get a default, not individualized setup, and to
% initialize the display in a default way. (computerName: ??)
%
% These definitions were previously included in 'getDefaultSettings.m' but
% I moved them here for better readability of the code.
% This function is called by 'getDefaultRigSetup.m'  
% state definitions are stored in ex.setup.XX
%
% input:
%   ex -structure
%   type: 'setup' (for parameters such as viewing distance etc.) 
%         'display' (specific initialization of this display)
%
% history
% 08/18/25  hn: wrote it

switch lower(type)
    case 'setup' 
        warndlg([ex.setup.computerName ': host machine not known, viewing distance not calibrated']) 
        ex.setup.viewingDistance = 100; % prelim values during development; measure these
        ex.setup.monitorWidth = 50;
 

    case 'display'
    warndlg('host machine not known, using PTB stereomode 8 (R/B anaglyph') 
    ex.setup.stereo.Mode = 8;  % we only use this mode
    [ex.setup.window, ex.setup.screenRect]=PsychImaging('OpenWindow',...
        ex.setup.screenNum, [], [], [], [], ex.setup.stereo.Mode,...
        ex.setup.stereo.Multisampling); 
    ex.synch.Pos = [ex.setup.screenRect(3)-ex.synch.PSz/2;0];

end

