function ex = getDefaultSettings(ex)

% initializes the experimental structure ex
%
% history
% 11/11/13  hn: written
% 
% 04/29/14  hn: -include stimuli and experiments
%               -include options for recording monocular or binocular eye
%               signals
%               -include option for showing stereo-stimuli
%               -ex.fixPCtr is now set in VisStim.m
%               -condensed structure (created field "fix', 'stereo')
% 07/11/14  hn: -customize set-up to each of my rigs for viewing distance
%               and display
%               -included field 'setup' and moved setup parameters into it
%               new parameter name          old parameter name
%               ex.setup.eyePSz             ex.setup.eyePSz
%               ex.setup.viewingDistance    ex.viewingDistance
%               ex.setup.monitorWidth       ex.monitorWidth
%               ex.setup.Clut               ex.Clut
%               ex.setup.stereo             ex.stereo
%               ex.setup.el                 ex.el
%               ex.setup.adc                ex.adc 
%               ex.setup.computerName       -
% 08/02/14  hn: -included bar values
%               -inluded extras
% 08/31/14  hn: included read in of iontophoresis input; 
% 09/02/14  hn: included ex.exp.StimPerTrial (option for multiple Stimuli
%               presented per trial)
% 12/21/14  hn: moved read-in input from VisStim to this file
% 09/28/15  hn: included ex.fix.stimDuration
% 09/25/17  hn: included anti-aliasing for stereo mode
% 02/19/21  hn: included paras for synch pulse for photodiode
% 07/05/22  hn: include freeViewing parameter
% 04/04/23  hn: include new RDS with ce parameter
%               -default setup to account for SC mapping
% 11/24/23  hn: added field for reward_proportion (introduced by BCT)
% 05/05/24  hn: uncommented iontophoresis for
%           convenience
% 02/06/24  hn: added ex.exp.monocBlank
% 06/03/24  hn: included ex.setup.horEyeSign to account for sign inversion with
%           hot mirror
% 07/10/24  ik: added ex.setup.eyeToCheck   hn: 01/25/25: is this being used? 
% 11/05/24  ik: added default setting for bvo
% 12/08/24  ik: added ex.fix.SSz for the size of the fixation surround
% 08/15/25  hn: moved subsections to different functions
%               states -> getStateDefinitions
%               fix    -> getDefaultFixationParameters
%               targ   -> getDefaultTargetParameters
%               audio  -> getDefaultAudioParameters
%               animal -> getAnimalName
%               reward -> getDefaultRewardParameters
%               stim   -> getDefaultStimulusParameters
%               probe  -> getDefaultProbeSettings
%               testXippmexConnection -> testXippmexConnection
%               exp    -> getDefaultExpParameters
%               extras -> getDefaultExtrasParameters
%               el     -> getDefaultEyelinkSettings
% 11/10/2025 BT: - replaced testXippmexConnction with testEphysConnection to
%                  generalise with SGLX
%                - added sglx button to recording neural data prompt
% 12/02/2025 BT: - commented out motion detector prompts

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%% make the experimental control structure
ex.finish = 300;  % last trial
ex.quit = 0; % 0 = continue, 1 = pause, 2 = quit,
ex.passOn = 0;
ex.freeViewing = 0;

%% --------------------setup parameters----------------------------------
%% -----------------------------------------------------------------------
ex.setup.eyePSz = 6;   % eye point (cursor) size 
ex.setup.computerName = getComputerName;
ex.setup.horEyeSign = 1; % set to -1 to account for the hot-mirror

% stereo setup parameters
ex.setup.stereo.Display = 1; % 1 for stereo Setup, 0 for  mono display (no stereo)
ex.setup.stereo.Mode = 8;   %1: use hardware stereo (frame alternating stereo)
                            %8: anaglyph stereo: red channel:  left 
                            %                    blue channel: right 
ex.setup.stereo.Multisampling = 8;  % anti-aliasing; option included starting 0/25/17
                            % 0 means no anti-aliasing used
                            
% color indices for stereo setup------------------------------------------
ex.idx.bg = 128;
ex.idx.bg_lum = 128; 
ex.idx.white = 255;
ex.idx.black = 0;
% for the stereo setup we only have one salient color for the overlay
% which only is visible when the background is not black.
ex.idx.overlay = 255;  



%% get rig-specific setups using computerName %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------------------------------------------------------
% setup for NEI rig B on linux-machine: 'hn-stim-1'
% setup for NIMH Dome in B1A19 in Leopold lab: 'lab-ms-98h9'
% setup for NEI rig A on linux-machine:  'klab-mouse-3'
% setup for NEI rig C on vpixx linux machine:'vpixx'
ex = getDefaultRigSetup(ex,'setup');


    
%%%%%%%%%%%%%%%%%%%%%%% get experimenter initials
ex.Header.experimenter = getExperimenterInitialsVS;

%%%%%%%%%%%%%%%%%%%%%%% get monkey name
[ex.Header.animal, ex.setup.filePrefix] = getAnimalName;


%%%%%%%%%%%%%%%%%%%%%% ask user whether we are recording, check connection, get grid location
button = questdlg('are we recording neural data?','','yes, SGLX', 'yes, GV','no','no');
% 11112025: BT: change readLFP and readOnlineSpikes according to number of
% electrodes
switch button
    case 'yes, SGLX'
        ex.setup.recording = 1;
        ex.setup.ephys = 'sglx';
        ex.setup.sglx.recording = 1;
        ex.setup.sglx.handle = SpikeGL('10.101.20.29');
        ex.setup.sglx.elec = 1;  % channel IDs that should be read out online
        ex.setup.sglx.readLFP = false; % do not read out the online LFP for single channels by default
        ex.setup.sglx.readOnlineSpikes = false;
    case 'yes, GV'
        ex.setup.recording = 1;
        ex.setup.ephys = 'gv';
        ex.setup.gv.cl = [0 1 2];
        ex.setup.gv.recording = 1;
        % grapevine parameters
        ex.setup.gv.elec = 1;  % channel IDs that should be read out online
        ex.setup.gv.readLFP = false; % do not read out the online LFP for single channels by default
        ex.setup.gv.readOnlineSpikes = false;
    case 'no'
        ex.setup.recording = 0;
    case 'cancel'
        disp('forced exit: please respond whether we are running a recording session when starting VisStim');
        return
end

%%%%%%%%%%%%%%%%%%%%%% settings and checks for recording neural data
if ex.setup.recording
    testEphysConnection(ex); % test whether we have a connection to ephys system
    ex = getDefaultProbeSettings(ex); % get probe settings
    ServoDrive   % open servo drive for microdrive 
end


ex.setup.iontophoresis.on = false; % for backward compatibility

% %% motion detection
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% motion signals recorded? %%%%
% button = questdlg('are we using the motion detector or video motiontracking?' ...
%     ,'shake detector','yes','no','no');
% switch button
%     case 'yes'
%         ex.setup.motionDetector.on = 1;
%         ex.setup.adc.Channels = [ex.setup.adc.Channels, ex.setup.adc.Channels(end)+1];
%         ex.setup.adc.DiffChannels = [ex.setup.adc.DiffChannels, 0];
%     case 'no'
%         ex.setup.motionDetector.on = 0;
%     case 'cancel'
%         disp('forced exit: please respond whether you monitor movements');
%         return
% end

%% get default eye settings and initialize Datapixx Adc channels (for eye data)
ex = getDefaultEyelinkSettings(ex);

%% States:
ex.states = getStateDefinitions; 

%% strobe words to send to grapevine
ex.strobe = getStrobeDefinitions;

%% get default fixation parameters
ex.fix = getDefaultFixationParameters;

%% get default target parameters
ex.targ = getDefaultTargetParameters(ex);

%% audio parameters for reward
ex.setup.audio = getDefaultAudioParameters;

%% get default reward parameters
ex.reward = getDefaultRewardParameters;

%% get default stimulus parameters
if isfield(ex,'stim')
    ex=rmfield(ex,'stim');
end
ex.stim = getDefaultStimulusParameters(ex);

%% get default experiment parameters
ex = getDefaultExpParameters(ex);

%%  % define extras (RF position, helper lines for online orientation)
ex.extras = getDefaultExtrasParameters;

%% synch pulse for photodiode (white point in top right corner of screen)
ex.synch.PSz = 20; % use an even number
ex.synch.Col = ex.idx.white;
%% default optical stimulation values
ex.setup.optoStim.flag = false;
ex.setup.optoStim.onsetTimes = 5;
ex.setup.optoStim.durations = 0.001;  % default as short as possible

%% default values for fUS Trigger 
ex.setup.fUS.flag = false;
ex.setup.fUS.triggerOnsetLag = 0;  % relative to stimulus onset
ex.setup.fUS.triggerDuration = 0.1; % 100ms pulse (should not matter exactly remain fixed)