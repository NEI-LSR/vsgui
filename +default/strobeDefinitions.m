function strobe = strobeDefinitions

% strobe = strobeDefinitions
%
% +default.strobeDefinitions
%
% formerly: function ex = getStrobeDefinitions(ex)
% here we define the meaning of the strobe words that are being sent from
% datapixx to ripple
% DO NOT USE values 1 through 10000 (they are reserved to send digits such
% as trial IDs or trial numbers)
% note that bit 1 is also used for the reward. 
% Strobes are stored in ex.strobe.XX

% history
% 08/05/14  hn; wrote it
% 12/05/17  hn: added strobes for sleep on/off
% 08/15/25  hn: remove required input (ex): 'strobe = getStrobeDefinitions'
% 09/22/25  hn: defined OPTO_PULSE, and strobe.REWARD
% 02/13/26  hn: moved to package strobeDefinitions


% reserved: 1:10000 for trial numbers etc.

strobe.TRIAL_START       = 10001;
strobe.TRIAL_END         = 10002;
strobe.TRIAL_ID          = 10003; % should always be followed by 
%                                     6 digits representing clocktime YYYY MO DY HOUR MIN SEC
strobe.TRIAL_NUMBER      = 10004;
strobe.FILE_ID           = 10005; % followed by 6 digits representing clocktime YYYY MO DY HOUR MIN SEC
strobe.EXPERIMENT_START  = 10006;
strobe.EXPERIMENT_END    = 10007;

strobe.FIXATION_START    = 10008;

strobe.SLEEP_ON          = 10011;
strobe.SLEEP_OFF         = 10012;

strobe.SYNC_PULSE = 2;  % use the 2nd bit for the synchronization 
                            % between fUS and datapixx
                            % this is usually not used as a strobe word
strobe.OPTO_PULSE = 4;   % third bit for optical stimulation                            

strobe.REWARD = 1;       % default strobe used for reward 





