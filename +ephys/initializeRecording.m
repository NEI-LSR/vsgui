function ex = initializeRecording(ex)
% function ex = initializeRecording(ex)
%
% +ephys.initializeRecording
%
% initializes ex structure for recordings, tests ephys connection
%

% history
% 02/11/26  hn: wrote it (moved code from +default.getSettings)

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
        ex.setup.sglx.readOnlineSpikes = true;
    case 'yes, GV'
        ex.setup.recording = 1;
        ex.setup.ephys = 'gv';
        ex.setup.gv.cl = [0 1 2];
        ex.setup.gv.recording = 1;
        % grapevine parameters
        ex.setup.gv.elec = 1;  % channel IDs that should be read out online
        ex.setup.gv.readLFP = false; % do not read out the online LFP for single channels by default
        ex.setup.gv.readOnlineSpikes = true;
    case 'no'
        ex.setup.recording = 0;
    case 'cancel'
        error('please respond whether we are running a recording session when starting VisStim');
end

%%%%%%%%%%%%%%%%%%%%%% settings and checks for recording neural data
if ex.setup.recording
    ephys.testConnection(ex); % test whether we have a connection to ephys system
    ex = ephys.probeSettings(ex); % get probe settings
    ServoDrive   % open servo drive for microdrive 
end
