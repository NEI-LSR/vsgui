function ex=initDisplay(ex)

% function ex=initDisplay(ex), only included after v3; was previously
% function ex=initVisStim(ex)
% initializes the dual CLUT for Mac

% history
% 4/29/14   hn: added option for stereodisplay
%               added PsychImaging('AddTask', 'General', 'UseDataPixx');
%               (although not sure it's needed as this ran without before)
% 07/11/14  hn: -customize setup according to rig using the computer name 
%               of each setup:
%               hns-mac-pro-2.cin.medizin.uni-tuebingen.de  rig 2, two
%                                                            projectors
%               
%               -included field 'setup' and moved setup parameters into it
%               new parameter name          old parameter name
%               ex.setup.Clut               ex.Clut
%               ex.setup.stereo             ex.stereo
%               ex.setup.window             ex.window
%               ex.setup.screen_number      ex.screenNum
%               ex.setup.screenRect         ex.screenRect
%               ex.setup.overlay            ex.overlay
%               ex.setup.refreshRate        ex.refreshrate
%
%               -included these lines (previously in VisStim)            
%               ex.setup.refreshRate = FrameRate(ex.setup.window);
%               ex.fix.PCtr = [ex.setup.screenRect(3:4)]/2;
% 07/29/14  hn: -added alpha-blending to allow masking of stimuli
% 09/25/17  hn: -added option for anti-aliasing (multisampling)
% 02/19/21  hn: -added position of photodiode synch pulse
% 10/30/23  hn: -added updated screen initialization for vpixx linux
%               machine
% 08/18/25  hn: -moved all the rig-specific display initializations to
%               the different setup files for each rig. 
%               Called by 'getDefaultRigSetup.m'

disp('in initDisplay')
ex.setup.screenNum = max(Screen('Screens'));

% initDisplay
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'UseDataPixx');

if ex.setup.stereo.Display
    Datapixx('EnableVideoStereoBlueline');
    Datapixx('RegWr');
end

disp(['host: ' ex.setup.computerName])
% initialize display for the specific rig according to the rig setup file
% in ~/rigSetups

ex = getDefaultRigSetup(ex,'display');
 
% 
%% store settings and define position of fixation point 
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ex.setup.refreshRate = FrameRate(ex.setup.window);
ex.fix.PCtr = [ex.setup.screenRect(3:4)]/2;

if ex.setup.stereo.Display
    % Initially fill left- and right-eye image buffer with gray background
    % color:
    Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
    Screen('FillRect', ex.setup.window, ex.idx.bg_lum);
    Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
    Screen('FillRect', ex.setup.window, ex.idx.bg_lum);
    
    Screen('Flip', ex.setup.window);
end



