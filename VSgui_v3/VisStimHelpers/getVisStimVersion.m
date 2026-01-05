function version = getVisStimVersion;
% helper to keep track of the versions of this VisStim toolbox

% history
% 08/28/15  hn: wrote it

version = '1.0.0';  % 08/28/15: hn: initial version when starting version numbering 
version = '1.0.1';  % 08/28/15: hn: renamed ex.Header.file(dir)Name to ex.Header.onlineFile(Dir)Name
                    % - removed empty tocs in runTrial*
                    % 08/29/15  hn: re-wired the analog input connection to
                    % Datapixx (in rig 2) such that for monocular
                    % recordings these correspond to the right eye (as
                    % indicated in the ex file).  v([1:3],:) = right eye;
                    % v([4:6],:) = left eye;  still need to check this in
                    % rig 1!
                    
version = '1.0.2';  % 09/28/15: hn: now include ex.fix.stimDuration
version = '1.0.3';  % 09/29/15: hn: now include earlyReward for runTrialTask
version = '1.0.4';  % 10/23/15: hn: now exclude two trials after TO for
                    % ppRC and plotPerformance
version = '1.0.5';  % 10/26/15: hn: -now exclude all instruction for 
                    % ppRC and plotPerformance; average kernels for Dc2
                    % -include experimenter initials in header:
                    %                           in ex.Header.experimenter
version = '1.0.6';  % 10/27/15: hn: -allow flash Cue for cueing for spatial attention    
version = '1.0.7';  % 11/01/15  hn: include option for anticorrelated cued and uncued stimuli 'AC-flag'
version = '1.0.8';  % 11/03/15  hn: include ORxDC task; fixed bug with AC-flag
version = '1.0.9';  % 11/06/15  hn: randomize phase of ori-target icon; include option for y_offsetCue
version = '1.0.10';  % 11/23/15  hn: 
                    % - allow plotting multuple clusters
                    % - include decreaseReward option instead of timeouts
version = '1.0.11';  % 11/24/15  hn: 
                    % - modify decreaseReward option to still run the afc
                    % task
                    % pump in Rig 1: at 10
                    % pump in Rig 2: at 4
                    % fixation breaks in plotPerformance are now defined as
                    % occuring after 0.5 stimulus duration
version = '1.0.12'; % 11/25/15  hn: include option to store the motionSensor data
                    % -scale down the reward after decrease error based on
                    % the baseline reward size, not the upscaled one after
                    % several correct trials
                    % -added option to manually insert instruction trials
                    % on the fly using 'i'
                    % -included y_OffsetCueAmp as an experiment
version = '1.0.13'; % 11/26/15  hn: make sure instruction trials are easy
version = '1.0.14'; % 12/13/15  hn: exponential reward schedule
                    %           modified plotPerformance to accommodate
                    %           ORxDC task
version = '1.0.15'; % 01/05/16  hn: -removed exponential reward schedule
                    %               -removed phase randomization for
                    %               targets in ORxDC task (now fixed at 0)
                    %               -include target x Offset for rds
                    %               stimuli (as spatial attention cue)
version = '1.0.16'; % 01/06/16  hn: -fixed bug for target x Offset for overlay window and target window
version = '1.0.17'; % 01/07/16  hn: -fixed bug for target x Offset for first trial after switch
version = '1.0.18'; % 01/18/16  hn: -included ramping on of target contrast; include TO after fixation break
version = '1.0.19'; % 02/02/16  hn: -modified dateString format in filenames; now have a leading 0
version = '1.0.20'; % 02/14/16  hn: -fixed bug for RCperiod
version = '1.0.21'; % 04/05/16  hn: -TO after fixation break now only if time_fixationBreak >  ex.fix.freeOfToDuration
                    %               -included auditory feedback for fixation
                    %               breaks: playTone(12000,2,1)
version = '1.0.22'; % 10/18/16  hn: -bug fix with seqcnt in makeGratingRC 
version = '1.0.23'; % 11/08/16  hn: -option to read out/plot 24 channels and LFP
version = '1.0.24'; % 12/07/16  hn: -option to show blank and monoc for RDS
version = '1.0.25'; % 12/09/16  hn: -option for two-pass of stimuli 
version = '1.0.26'; % 12/15/16  hn: -bug fix in plotTC
version = '1.0.27'; % 01/28/16  hn: -CP calculation in plotTC
version = '1.0.28'; % 02/06/17  hn: -read out LFP flag included
version = '1.0.29'; % 05/22/17  hn: -updates in setup for rig 2 upgrade with propixx
version = '1.0.30'; % 06/16/17  hn: -modified two-pass 
version = '1.0.31'; % 09/19/17  hn: -include option to adjust probability 
                    % for lower target in 'ex.targ.lowerTargProb'
version = '1.0.32'; % 09/25/17  hn: -include anti-aliasing in stereo-setup (not yet fully tested though)
version = '1.0.33'; % 11/28/17  hn: -include correction loop for response bias; 
                    %               -updated experimenter initials
version = '1.0.34'; % 12/05/17  hn: -include sleep On/off
                    %               -updated experimenter initials
version = '1.0.35'; % 01/31/18  hn: -added fixed seeds every Nth Trial
version = '1.0.36'; % 03/20/18  hn: -bug fix 
version = '1.0.37'; % 05/03/18  hn: -include options to plot 32 or 48 channel data
version = '1.0.38'; % 05/04/18  hn: -input for multiple probes
version = '1.0.39'; %05/08/18   hn: -include x/y-RC maps
version = '1.0.40'; % 06/28/18  hn: -included function to plotRF for RC data: plotRF
version = '1.0.41'; % 08/21/18  hn: -include option for different x0/x02 and y0/y02 values
%                                   -option ex.exp.att_training
version = '1.0.42'; % 08/21/18  hn: -include option for pause after error: ex.reward.pausAfterError
version = '1.0.43'; % 11/06/18  hn: -include prompt for area; bug fix for plotTC
version = '1.0.44'; % 12/11/18  hn: -include general way to accommodate different numbers of channels in plotTC
version = '1.0.45'; % 01/30/19  hn: -include flag of whether we want to use a fixed seed for the stimulus
version = '1.0.50'; % 02/19/21  hn: -initial version at NIH, extended to include photodiode synch pulse
version = '1.0.51'; % 02/22/21  hn: -fixed bug in matchTrialFields
version = '1.0.52'; % 03/10/21  ik: -revised matchTrialFields.m to use set operations
                    %               -revised rescueFile.m to run a single
                    %               for loop adding individual Trial#.mat
                    %               -added if caluse to check the size of ex 
                    %               to use '-v7.3' flag if it exceeds 2GB
                    %               -revised calibrateLR.m to use PR655
                    %               instead of PR670
version = '1.0.53'; % 06/30/22  hn: -updated to allow for full-field stimulus, 
%                                   free viewing, randomized reward times
%                                   -new function: playFullField.m
%                                   -modified: playStimulus to include
%                                   fullField
%                                   -modified: runTrialStim_new to
%                                   accommodated full field stimulus
%                                   presentation, randomized reward times
%                                   and variable ITI when ex.passOn = 1
%                                   (free viewing)
version = '1.0.54'; % 07/19/22  hn: -modified runTrialStim_new to allow for 
%                                   randomized trial duration and times of reward
%                                   -ex.fix.trialDurationRange
%                               ik: -trial-based synchronization with
%                               eyelink
version = '1.0.55'; % 07/25/22  hn: -flag to switch off readout of online spikes
version = '1.0.56'; % 11/15/22  hn: -allow for trial-based free viewing
version = '1.0.57'; % 02/17/23  ik: - in blockedFreeViewing condition with full-field stimuli, 
%                                   added trial type ex.freeViewing = 2 in
%                                   which fixation point appears at random
%                                   position and random time during a
%                                   trial.
version = '1.0.58'; %04/04/23   hn: new RDS allowing for uncorrelated dots etc.
version = '1.0.59'; %10/30/23   hn: merged version in RigC from Rig A and runTrialTask from RigB
version = '1.0.60'; %11/24/23   hn: minor fixes for merged code and 2 RDS presentation
version = '1.0.61'; %06/03/24   hn: changes to accommodate sign inversion with hot mirror
%                               and setup changes to Leopold dome
version = '1.0.62'; %08/19/24   hn: includes functionality to present pre-computed and stored images; 
%                               undid change by IK in runExpt to allow for 
%                               control of stimulus duration during 4-stim
%                               per trial experiments
version = '2.0.0'; % 10/03/24   hn: after merging the versions of the different 
%                               rigs and integrating all changes
%                               -analog eye-signals in all rigs are now wired 
%                               up such that the R/L eye assignments are correct
version = '2.0.1'; %11/05/24    ik: added noisy orientation pattens as a new stimulus to present Divya's stimului
%                               VSgui.fig -     added 'orNoise' to StimulusType
%                                               added 'bvo' to ex1~5
%                                               added jocamo to Anim
%                               makeStimulus.m - added 'orNoise to
%                               ex.stim.type
%                               getDefaultSetting.m - added default setting
%                               for bvo
%                               playStimulus.m - added 'orNoise'
%                               makeORnoise.m and playORnoise.m are created
%                               in \stimuli
version = '2.0.2'; %11/19/24    hackathon: runExpt: commented out the fixed ex.fix.Duration when StimPerTrial == 4
                                % runExpt, runTrialStim, runTrialTask, runTrialSCMap, runTrialFixTarg: removed ex.quit==3 because it
                                % was redundant and left the space open for
                                % future use
                                % getDefaultSettings.m: added default audio settings for error
                                % and reward
                                % getDefaultSettings.m: added default
                                % settings for fixation cross
                                % getDefaultSettings.m: added default
                                % settings for search window in search task
version = '2.0.3'; %1/15/25     ik: full-field random-dot background is implemented
                                % getDefaultSettings: added ex.fix.SSz for the size of the fixation surround
                                % makeORnoise: a new file in /stimuli to create Divya's noisy oriented line patterns
                                % makeRDS - full-field random-dot background condition is added.
version = '2.0.4'; % 01/21/25   BT: changed runTrialTask to make targon_delay and fix_duration in times from stim_onset (absolute values from relative)
                                % ST: runExpt changed names of asymmetry types to stimulusAsymmetry and responseAymmetry from "asymmetry" alone
                                %     runTrialTask: implemented
                                %     responseAsymmetry variant. Modified
                                %     to store rewardBias sign and
                                %     magnitude on a trial-by-trial basis.
                                %     Disable correction loop if in
                                %     response asymmetry paradigm.
version = '2.0.5'; % 01/22/25   HN: -made compatible with version on dome
                                %   -include user input for brush-array
version = '2.0.6'; % 03/07/25   CZ: getDefaultSettings.m
                                %        -moved dome calibration warping files to new folder in setupFiles, DisplayCalibrationFiles. modifed 
                                %   initDisplay.m for B1A19
                                %       - load calib file info in ex.setup.scal
                                %       - modifed bg luminace to 128/255
                                %       - changed position of synch pulse
                                %       - Adjust fixation point size 
                                %   VSgui.m 
                                %       - add new animal 'tamago' 
                                %   playImage.m 
                                %       - Added warnings and modified for
                                %       image scaling with eccentricity.
                                %HN: renamed 'ID' to 'imID' in:
                                %       -makeFileNameSuffix.m
                                %       -getExptSettings.m
                                %       -VSgui: scrolldownmenues for
                                %       expt1-5
                                %       -getStimParamDefinitions.m
                                %CZ: calibrateEye_rev.m
                                %       - updated hardcoding of reward to
                                %       be specific for the dome.
version = '2.0.7'; % 08/15/25   HN: increased legibity of getDefaultSettings.m
                                %       moved subsections to different
                                %       functions
                                %         states -> getStateDefinitions
                                %         fix    -> getDefaultFixationParameters
                                %         targ   -> getDefaultTargetParameters
                                %         audio  -> getDefaultAudioParameters
                                %         animal -> getAnimalName
                                %         reward -> getDefaultRewardParameters
                                %         stim   -> getDefaultStimulusParameters
                                %         probe  -> getDefaultProbeSettings
                                %         testXippmexConnection -> testXippmexConnection
                                %         exp    -> getDefaultExpParameters
                                %         extras -> getDefaultExtrasParameters
                                %         el     -> getDefaultEyelinkSettings
                                %                -> getDefaultRigSetups
                                %                (distributes setup
                                %                according to rig, in
                                %                folder 'rigSetups')
                                %   new folder: 'rigSetups'
                                %       -contains a dedicated setup file for
                                %       each rig
                                %       -if we have a new rig, we only need
                                %       to include a new dedicated file for
                                %       this rig for both general and
                                %       display settings
                                %   VSgui:
                                %       -option for fUS Trigger
                                %       -option for optical stimulation
                                %   getStrobeDefinitions
                                %        -include strobe for fUS Trigger
                                %                 strobe for optical stim
                                %                 strobe for reward
                                %   turnOnReward -> turnOnDigOut(val) 
                                %         to make it more general purpose
                                %   turnOffReward -> turnOffDigOut(), just
                                %        renamed to be more general-purpose
                                %   runTrialStim:
                                %        -include option for: 
                                %           fUS Trigger
                                %           optical stimulation
                                %   ToDo: allow for NP or trellis
                                %   recordings
                                
                                
                                                                


