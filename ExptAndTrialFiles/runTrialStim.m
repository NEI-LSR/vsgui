function [ex] = runTrialStim_new(ex)
% run TrialStim_new, forked off runTrialTask
% hn 8/31/13
% will need to expand:
% - make sure the monkeys can't switch choices!
% -make gui to do input/experimental control (?), check timing here!!!


% history of runTrialTask
% 6/17/14   hn: RDS dot patterns are no longer stored for each trial.
%           instead: ex.Trials(ex.j).rngState = rng; ex.Trials(ex.j).ndots
%           (number of dots in each RDS)
% 7/01/14   hn: enable randomized target onset during stimulus presentation
%           for this, targ-on state had to be removed; Instead, I now have
%           a separate state variable only for the targets
% 7/06/14   now storing all the times of events in ex-structure
% 07/11/14  hn: -included field 'setup' and moved setup parameters into it
%               new parameter name          old parameter name
%               ex.setup.Clut               ex.Clut
%               ex.setup.stereo             ex.stereo
%               ex.setup.window             ex.window
%               ex.setup.screen_number      ex.screenNum
%               ex.setup.screenRect         ex.screenRect
%               ex.setup.overlay            ex.overlay
%               ex.setup.refreshRate        ex.refreshrate

% history of runTrialStim_new
% 07/27/14  hn: started it
% 07/27/14  hn: included read-in of mouse positions to change stimulus x,y
% 07/29/14  hn: included read-in of RF center position and display on
%               overlay screen
% 08/02/14  hn: included read-in of helper lines on the screen (eg. RF
%               borders) and display on overlay screen
%               included re-centering of eye positions
% 08/31/14  hn: included read in of iontophoresis input; 
% 09/02/14  hn: included ex.exp.StimPerTrial (option for multiple Stimuli
%               presented per trial)
%               -make sure x,y positions from mouse click are only used to
%               update stimulus positions if mouse is on PTB screen
% 09/04/14  hn: included Datapixx trialStart time to match up PTB and
%               Datapixx clocks
% 09/10/14  hn: included more timing information to match up clocks
%               order of time stamps:
%               trial start: Datapixx1
%                            GetSecs
%                            sendStrobe
%                            Datapixx
%                            Eyelink
%               trial end:   Datapixx1
%                            GetSecs
%                            Eyelink
% 09/12/14  hn: changed order of time stamps
% 09/16/14  hn: included early reward
% 09/21/14  hn: -included audio feedback
%               -included sync pulse for synchronization between Datapixx
%               and grapevine
% 11/09/14  hn: -removed sync pulse for synchronization between datapixx and gv
%                and use time_stamp for ex.strobe.TRIAL_START insead;
%                no longer use Datapixx('SetMarker') but read out using
%                Datapixx('ReadDinLog') in 'getDatapixxDin'.
%               -analogously: get time stamp for ex.strobe.TRIAL_END
%               -toc.trstartdatapixx therefore is obsolete as well and was removed 
% 01/04/15  hn: storing electrode depth
% 04/10/15  hn: storing time-out and pause in trial structure as
%               ex.Trials(n).to or ex.Trials(n).pa
% 08/26/15  hn: increased resolution of clocktime to 1/100 sec
% 02/19/21  hn: included synch pulse for photodiode
% 06/30/22  hn: include functionality for fullfield stimulus and
%               randomization of the (early) rewards
%               this required changes to the while loop, which are
%               documented below
% XX        ik: added trial-based synchronization with eyelink timestamps
% 07/19/22  hn: include functionality for varying trial duration and
%               randomizing the reward time throught the trial during the free viewing
%               condition
% 07/25/22  hn: include flag to switch off reading out the online spikes
% 04/24/23  ik: added ex.reward.delay (default = 100 ms) to allow this
%               much time before reweard after fixation completion
% 02/06/24  hn: allow for monocular fixation marker
% 11/19/24  bt: removed time out with 'o' (ex.quit == 3)
% 11/19/24  bt: take default settings for fixation cross from
%               getDefaultSettings
% 11/19/24  bt: using the target window variables from getDefaultSettings for
%               search task
% 11/19/24  bt: not saving x0 and y0 on every trial
% 12/08/25  hn: updated giveReward
% 01/27/26  hn: added readout of trial-start for sglx
%               -removed 'tocs'
% 03/09/26  hn: ex.freeViewing is permitted for stimuli other than fullfield      
%               removed line 325: else ... ex.freeViewing = 0;




% -----------------------------------------------------
% -------------------
% pretrial allocations, stimulus generation and setup
% ------------------------------------------------------------------------
%
% ITI -------------------------------------------------------------------
% wait for inter-trial interval before starting a trial
% fixed ITI (only when we are not in free viewing mode, i.e. freeViewing
% =0) this needs to be after we closed the stimulus and removed fixation
% marker
if isfield(ex.exp,'fixedITIDur') && ~isempty(ex.exp.fixedITIDur) && ...
        ex.freeViewing == 0 && ex.nStimFinished == 0 && ...
        ex.j > 1
    wait4thisLong = ex.exp.fixedITIDur - ...
        (GetSecs -ex.Trials(ex.j-1).TrialEnd);
    WaitSecs(wait4thisLong);
    ex.Trials(ex.j).iti = ex.exp.fixedITIDur;
end



% allocations of variables------------------------------------------------
%
% converting pixels to degrees (needed to changes stimulus position with
% mouse
dpp = atan(ex.setup.monitorWidth/2/ex.setup.viewingDistance)...
    *180/pi/(1920/2);  % degrees per pixes

fpPos = ex.fix.PCtr;
fpSz = ex.fix.PSz;

% allow for fixation cross instead of dot
flX      =   [ex.fix.PCtr(1) - ex.fix.PSz, ex.fix.PCtr(1)+ex.fix.PSz, ...
    ones(1,2)* ex.fix.PCtr(1)];
flY      =   [ones(1,2)*ex.fix.PCtr(2), ex.fix.PCtr(2)-ex.fix.PSz, ...
    ex.fix.PCtr(2)+ex.fix.PSz];
fLines =   [flX;flY];
fWidth   =  ex.fix.lineWidth;

% point for photodiode synch pulse 
spPos = ex.synch.Pos;
spSz = ex.synch.PSz;
spCol = ex.synch.Col;

% initial color assignments
fpCol = ex.idx.bg;
fpCol = ex.idx.white;
t1Col = ex.idx.bg;
t2Col = ex.idx.bg;
targWinCol = ex.idx.bg;

if ex.nStimFinished == 0
    fpOn = 0;
else
    fpOn = 1;
end


% assign colors for eye and mouse positions (overlay dots: ol)
if ~isempty(ex.eyeCal.LXPos)
    if ~ ex.setup.stereo.Display
    olColBinoc = [ex.idx.overlayRed,ex.idx.overlayGreen,...
        ex.idx.overlayBlue, ex.idx.overlayGreen]; % right,left,binoc, mouse
    olColBinoc = [olColBinoc'*ones(1,3)];
    else
    olColBinoc = [ex.idx.overlay,ex.idx.overlay ...
        ex.idx.overlay ex.idx.overlay]; % right, left, binoc, mouse
    olColBinoc = [olColBinoc'*ones(1,3)];
    end
    olPSz = [ceil(ex.setup.eyePSz/2)*ones(2,1); ...
        ex.setup.eyePSz; 2]; % eye (R,L,B), mouse
else
    olColBinoc = ex.idx.overlay*ones(1,3); % qwqqq
    olPSz = [ex.setup.eyePSz; 2]; % eye, mouse pos
end

% pre-allocate memory; initialize variables
frametimestep = 1/ex.setup.refreshRate;
eyetimestep = 1/ex.setup.adc.Rate;  % 500Hz is the fastest Eyelink sample binocularly
maxTrialDur = ex.fix.waitstop+ex.fix.freeduration+ex.fix.duration+ ...
    ex.targ.go_delay+ex.targ.duration;

% loop indices
fi = 1; % frame index
si = 0; % frame index for stimulus
ei = 1; % frame index for eye sampling

% time variables
time_fpOn = NaN;
time_fpOff = NaN;  % this is the go cue
time_startFixation = NaN;
time_breakFixation = NaN; 
time_fixationComplete = NaN;  
time_stimOn = NaN;
time_stimOff = NaN;
time_reward = NaN;  % time when reward is started to be given
time_rewardGiven = NaN; % time immediately after reward
time_error = NaN;   % time when error signal (if any) is played
time_lastEyeReading = NaN;
time_beforeLastEyeReading = NaN;
time_beforeLastEyeReadingDatapixx = NaN;
time_lastEyeReadingDatapixx = NaN;
time_earlyReward = NaN;
    
line_t0 = GetSecs; % hack to prevent several line-updates per key-press
centerEye_t0 = GetSecs; % hack to prevent several re-centerings of eye 
                        % position per key-press

% timing information on PTB display
flip_info = NaN(ceil(maxTrialDur*ex.setup.refreshRate),4); % [VBLTimestamp 
                                    %StimulusOnsetTime FlipTimestamp Missed]

%%
%initialize eye structure
trEye.v = NaN(length(ex.setup.adc.Channels),...
    ceil(maxTrialDur*ex.setup.adc.Rate)); % pre-allocate memory
trEye.t = NaN(1,ceil(maxTrialDur*ex.setup.adc.Rate));
trEye.n = 0; % nAcquiredFrames
trEye.sacc = [];

% initialize trial variables
pass_eye = 0;
if ~isempty(ex.eyeCal.LXPos)
    lastEyePos = [0 0;0 0];
else
    lastEyePos = [0 0];
end
[x,y] = GetMouse;
mousePos = [x+ex.setup.mouseXOffset,y];
tchosen = 0;
RewardSize = 0;
lasteyepostime = 0;
lastframet = 0;
stimOn_flag = 0;
stimCompleted = 0;
earlyReward_start = 0;
earlyReward_on = 0;
earlyReward_cnt = 0;
timeBeforeStimOn = 0; % 

% default fixation point offset
xPos = 0;
yPos = 0;

% this changed from frametimestep * 0.1, 04.25.2023, ik to prevent a frozen
% RDS due to cylce drops
frameDelta = frametimestep * 0.01;
% flag to continue trial after NOFIX in visual search
missedFP = false; 

% added by ik: 2023.04.21
if ~isfield(ex.reward,'delay')
    ex.reward.delay = 0.1;
end

ex.loopcnt(ex.j) = 0;
%ex.tocsSTIM{ex.j} = [];
ex.stim.vals.framecnt = 0;


%SET PARAMETERS FOR fUS IF NEEDED ----------------------------------------
fUS_on = [];
time_fUS = NaN;
% parameters for fUS triggers if we need them
if isfield(ex.setup,'fUS') && isfield(ex.setup.fUS,'flag') ...
        && ex.setup.fUS.flag
    fUS_on = 0;
    fUS_duration = ex.setup.fUS.triggerDuration; %% 
    fUS_triggerOnsetTime = ex.setup.fUS.triggerOnsetLag; % trigger onset 
    %                                           relative to fixation onset
    fUS_triggered = false;
end        

if ex.reward.includeBigReward && ex.nStimFinished == 0
    b = 0.7;
    if rand > b    % ratio of small to big reward is (1-b)/b
        ex.bigReward = 1;
    end
end

% MAKE STIMULUS AND REFRESH BACKGROUND-----------------------------------
[ex,RDS]=makeStimulus(ex);  
me  = ex.stim.vals.me;  % monocular stimulus or not

% SET PARAMETERS FOR OPTICAL STIMULATION IF NEEDED  ---------------------
optoStim_cnt = [];
time_optoStim = NaN;
if isfield(ex.setup,'optoStim') && isfield(ex.setup.optoStim,'flag') ...
        && ex.setup.optoStim.flag == true &&~ ...
        (isfield(ex.stim.vals,'optoStim') && ex.stim.vals.optoStim == 0)
    
    optoStim_cnt = 0;
    optoStim_on = 0;
    optoStim_onsetTimes = ex.setup.optoStim.onsetTimes;
    optoStim_onsetTime = optoStim_onsetTimes(1);
    optoStim_durations =0;
    if length(optoStim_onsetTimes) ~= length(ex.setup.optoStim.durations)
        optoStim_durations = ...
        ex.setup.optoStim.durations(1)*ones(1,length(optoStim_onsetTimes));
    else
        optoStim_durations = ex.setup.optoStim.durations;
    end
    optoStim_duration = optoStim_durations(1);   
    
    % make sure th last onset time is after the trial is completed (i.e. we
    % never get to it)
    optoStim_onsetTimes(end+1) = ex.fix.waitstop+ex.fix.duration+...
        ex.fix.freeduration+ex.fix.preStimDuration+ex.fix.stimDuration;
    optoStim_durations(end+1) = .001;  % short, should not be used
    time_optoStim = NaN;
end


% default settings for fullfield
% ik - not a good implementation, think about a better way
if strcmpi(ex.stim.type,'fullfield')
    if isfield(ex.exp,'blockedFreeViewing') && ex.exp.blockedFreeViewing
        if ~isfield(ex.fix,'blockedFreeViewing')
            ex.fix.blockedFreeViewing.duration = [2, 2, 0.3];
            ex.fix.blockedFreeViewing.waitstop = [5, 5, 0.5];
        end
        if ~isfield(ex.reward,'blockedFreeViewing')
            ex.reward.blockedFreeViewing.earlyRewardTime = [0.12, 0.03, 0.12];
        end
        
        ex.fix.duration = ex.fix.blockedFreeViewing.duration(ex.freeViewing+1);
        ex.fix.waitstop = ex.fix.blockedFreeViewing.waitstop(ex.freeViewing+1);
        ex.reward.earlyRewardTime = ...
            ex.reward.blockedFreeViewing.earlyRewardTime(ex.freeViewing+1);
    end
end

fix_duration = ex.fix.duration;
if ex.exp.StimPerTrial>1
    preStimDuration = ex.fix.preStimDuration;
    fix_duration = ex.fix.duration+preStimDuration;
else
    preStimDuration = ex.fix.preStimDuration;
end

duration_forEarlyReward = ex.fix.duration_forEarlyReward(1);

% randomized early reward restricted to free viewing
% randomize fixation duration for freeviewing condition
% iknew - added trial_duration to control trial time in freeViewing trials
preFixDuration = ex.fix.freeduration;
trial_duration = ex.fix.duration;

% full-field
% ex.freeViewing = 0    central fixation
% ex.freeViewing = 1    no fixation
% ex.freeViweing = 2    visual search for fixation target
if ex.freeViewing
    % trial_duration is only used for freeViewing trials
    % iknew - visual search
    % set trial duration for freeViewing trials
    if isfield(ex.fix,'trialDurationRange')
        trial_duration = rand*(diff(ex.fix.trialDurationRange)) + ...
            ex.fix.trialDurationRange(1);
        %disp(sprintf('fixation duration: %1.2f',fix_duration))
    end
    
    %if ex.exp.visualSearch
    if ex.freeViewing == 2
        % check parameters
        % set target position & onset time
        xlimInPixels = [-ex.targ.searchW, ex.targ.searchW]; % previously set at [-200, 200]
        ylimInPixels = [-ex.targ.searchH, ex.targ.searchH];
        %xPos = sign(rand-0.5)*randi(xlimInPixels,1);
        %yPos = sign(rand-0.5)*randi(ylimInPixels,1);
        
        xPos = rand * diff(xlimInPixels) + xlimInPixels(1);
        yPos = rand * diff(ylimInPixels) + ylimInPixels(1);
        
        
        fpPos = ex.fix.PCtr + [xPos, yPos];
        % make ex.waitstop short for freeViewing visual search trials
        preFixDuration = rand(1)*(trial_duration - ex.fix.duration);

        % ik - for visual search, ex.fix.duration is the fp ON duration
        %fpCol = ex.idx.white;
        fix_duration = 0.2;
        
        %fprintf('preFixDuration = %4.3f  trial duration = %4.3f\n\n',...
        %    preFixDuration, trial_duration)
    else
        fix_duration = trial_duration;
        
        if isfield(ex.reward,'randomEarlyRewardRange') && ...
                length(ex.reward.randomEarlyRewardRange) == 2
            duration_forEarlyReward = ...
                rand*diff(ex.reward.randomEarlyRewardRange) + ex.reward.randomEarlyRewardRange(1);
            %disp('in early reward ')
            disp(sprintf('duration for early reward: %1.2f\n',duration_forEarlyReward))
        end
        
    end
    
end

StimStart = NaN*ones(1,ceil(ex.setup.refreshRate*ex.fix.duration));

% DRAW OVERLAY ITEMS THAT ARE FIXED DURING THE TRIAL --------------------
% (RF, FP frame, helper lines, correct target, if needed) 
% draw these first to save timing during the while loop 
drawOverlayHelperLines(ex);
drawOverlayFrames(ex,[],fpPos);

% -----------------------------------------------------------------------
% TRIAL START and SYNCHRONIZATION INFORMATION BETWEEN CLOCKS
% ------------------------------------------------------------------------
% use clock time as unique trial ID (seconds is too coarse, make 0.01 sec resolution)
% clocktime: 1x6 vector: year month day hour(1:24) min sec*100
clocktime = clock; 
clocktime(6) = round(clocktime(6)*100);
% send strobe of this to rppl for trial identification
% we store both the unique trial ID and the trial number in the ripple file
% This might be overkill and we can remove unique trial ID in the future.
% 
% flush ports 
Datapixx('GetTime');
Eyelink('TrackerTime');

% iknew 6.9.2022
% send trial number to Eyelink
Eyelink('Message','trialNumber %d',ex.j);

% get trial start times for different clocks.  We use tocs to get an
% estimate for the maximal mismatch between clocks. The mismatch between
% Eyelink and Datapixx should be <1ms (as evaluated using tocs).  
% Ripple and Datapixx are synchronized via the Trial_start strobe.
% PTB and Datapixx synchronization is done at the end of the experiment
% using PsychDataPixx('BoxsecsToGetsecs',[TrStartDP,TrEndDP]);
sendStrobes([ex.strobe.TRIAL_ID,clocktime,ex.strobe.TRIAL_NUMBER,ex.j]);  

%disp('before Eyelink Trackertime')
trstart_Eyelink = Eyelink('TrackerTime');  
trstart = GetSecs;  % start of trial time

% get trial start time for the SGLX clock. HN checked the latency for this,
% (on 01/27/26, in NIH Rig A), and it was < 1ms
if ex.setup.recording && isfield(ex.setup.(ex.setup.ephys),'handle')
    trstart_sglx = GetStreamSampleCount(ex.setup.(ex.setup.ephys).handle,-2,0);
    begin_idx      = trstart_sglx;
    t_begin        = trstart;
end

% this synchronizes the ripple and the datapixx clocks
maxTrial = 5;
trstart_Datapixx = [];
nAttempts = 0;
while isempty(trstart_Datapixx) && nAttempts < maxTrial
    %disp('before sendStrobe')
    sendStrobe(ex.strobe.TRIAL_START);
    % get time stamp of when ex.strobe.TRIAL_START was sent to ripple
    %disp('before getDatapixxDin')
    [~,~,trstart_Datapixx] = getDatapixxDin(ex.strobe.TRIAL_START);
    nAttempts = nAttempts + 1;
end

if ex.bigReward && ex.nStimFinished == 0
    playTone
end

% fixed pre-stim ITI ------------------------------------------------------
% this needs to happen after we recorded the trial start-------------------
if isfield(ex.exp,'fixedPreITIDur') && ~isempty(ex.exp.fixedPreITIDur) && ...
        ~ex.freeViewing 
    ex.Trials(ex.j).preIti = ex.exp.fixedPreITIDur;
    pause(ex.exp.fixedPreITIDur);
end

ttime = GetSecs-trstart; %  trial time
state = ex.states.START;

% ------------------------------------------------------------------------
% DONE WITH PRE-STIMULUS STUFF, NOW START THE STIMULUS WHILE LOOP --------
% ------------------------MAIN WHILE LOOP---------------------------------
% ------------------------------------------------------------------------
while state ~= ex.states.BREAKFIX && state~=ex.states.REWARD &&...
        state ~= ex.states.ERROR && state~=ex.states.NOCHOICEMADE && ...
        state ~= ex.states.SWITCHCHOICE && ...
        state ~= ex.states.NOFIX && ex.quit == 0 && ttime > 0 
    
    %--------------------------------------------------------------------
    % START STATE CHANGES -----------------------------------------------
    % BEFORE FIXATION DOT -----------------------------------------------
    if  state == ex.states.START && ttime > preFixDuration
        state = ex.states.FPON;
        
        fpOn = 1;
        %disp('in fixation dot on');
        time_fpOn = GetSecs - trstart;
    end
    % WAITING FOR SUBJECT FIXATION --------------------------------------
    if  state == ex.states.FPON
        if ttime < time_fpOn + ex.fix.waitstop
            if pass_eye
                time_startFixation = GetSecs - trstart;
                sendStrobe(ex.strobe.FIXATION_START)
                state = ex.states.FPHOLD;
                %disp('in fixation acquired');
                % give big reward cue
                timeBeforeStimOn = time_startFixation + preStimDuration;
            end
        else
            if ex.freeViewing == 2 %ex.exp.visualSearch && ex.freeViewing
                missedFP = true;
            else
                state = ex.states.NOFIX;
            end
            %disp('in no fixation acquired');
            time_breakFixation = GetSecs - trstart;
            if fpOn
                time_fpOff = time_breakFixation;
            end
            fpOn = 0;
        end
    end
    
    % HOLD FIXATION -----------------------------------------------------
    if state == ex.states.FPHOLD
        if pass_eye
            if ttime > time_startFixation + fix_duration
                state = ex.states.FIXATIONCOMPLETE;
                
                % leave fp ON on multi-stimuli trials
                if ex.exp.StimPerTrial == 1 || ...
                        ex.nStimFinished == ex.exp.StimPerTrial
                    time_fixationComplete = GetSecs - trstart;
                    if fpOn
                        time_fpOff = time_fixationComplete;
                    end
                    fpOn = 0;
                end
                %disp('in trial complete');
            end
            % 
            if ~earlyReward_on && ttime > time_startFixation + duration_forEarlyReward
                earlyReward_cnt = earlyReward_cnt+1;
                duration_forEarlyReward = ex.fix.duration_forEarlyReward(earlyReward_cnt);
                earlyReward_start = 1;

                fprintf('duration_for EarlyReward = %d\n',duration_forEarlyReward)
                %keyboard
            end
            
        else
            state = ex.states.BREAKFIX;
            %disp('in breakfix');
            time_breakFixation = GetSecs - trstart;
            if fpOn
                time_fpOff = time_breakFixation;
            end
            fpOn = 0;
            ex.bigReward = 0;
        end
    end
    
    % turn off FP after ex.fix.duration
    if ex.freeViewing == 2 && fpOn && ttime > time_fpOn + ex.fix.duration
        time_fpOff = GetSecs - trstart;
        fpOn = 0;
    end
    
    % BEFORE STIMULUS ON ----------------------------------------------
    if ttime > timeBeforeStimOn && stimOn_flag == 0 && ~stimCompleted
        if ex.freeViewing || (state == ex.states.FPHOLD && pass_eye)
            time_stimOn = GetSecs - trstart;
            stimOn_flag = 1;
            fprintf('%3.2f %3.2f\n\n',time_startFixation,time_stimOn)
        end
    end
    
    % BEFORE STIMULUS OFF ----------------------new addition on 06/30/22
    if ttime > time_stimOn + ex.fix.stimDuration && stimOn_flag == 1
        if ex.freeViewing || (state == ex.states.FPHOLD && pass_eye)
            %disp('in stim off')
            stimOn_flag = 0;
            stimCompleted = 1;
            time_stimOff = GetSecs -trstart;
            %fprintf('stim ON: %3.2f   stim OFF: %3.2f\n\n',time_stimOn,time_stimOff)
        end
    end
    
            
    
    % REWARD if fixation is held after trial is completed ----------------
    if state == ex.states.FIXATIONCOMPLETE && pass_eye
        if ex.freeViewing == 2
            if ~earlyReward_on
                earlyReward_cnt = earlyReward_cnt+1;
                %duration_forEarlyReward = 0;
                earlyReward_start = 1;
            end
            %stimCompleted = 1; % hn: 06/03/24: needed to set screen to blank
        else
            ex.nStimFinished = ex.nStimFinished + 1;
            state = ex.states.REWARD;
            
            if stimOn_flag
                %stimOn_flag = 0;
                %stimCompleted = 1;
                time_stimOff = GetSecs -trstart;
            end
            
            stimOn_flag = 0;
            stimCompleted = 1;
            % wait for ex.reward.delay before reward delivery
            %if ttime > time_stimOff + ex.reward.delay
            %    state = ex.states.REWARD;
            %end
        end
    end
    
    
    % iknew - freeViewing trial ends after trial_duration from trial start
    if ex.freeViewing && ttime > trial_duration
        if missedFP
            state = ex.states.NOFIX;
        else
            state = ex.states.REWARD;
        end
        %stimCompleted = 1; % hn: 06/03/24: needed to set screen to blank
    end
    
    
    %---------------------------------------------------------------------
    % END STATE CHANGES --------------------------------------------------
    %---------------------------------------------------------------------    
    
    % update eye position (fast)
    ttime = GetSecs-trstart;
    if ttime > lasteyepostime + eyetimestep 
        if state== ex.states.GO || state == ex.states.CHOICE
            [pass_eye,trEye,lastEyePos,tchosen] = ...
                checkEye(trEye,ex,ex.targ,pass_eye,lastEyePos,tchosen,xPos,yPos);
        else 
            [pass_eye,trEye,lastEyePos] = ...
                checkEye(trEye,ex,[],pass_eye,lastEyePos,tchosen,xPos,yPos);
        end
        lasteyepostime = ttime;
        ei = ei+1;    
    end
    
    % OPTICAL STIMULATION (fast)-------------------new addition on 09/10/25
    if ~isempty(optoStim_cnt)
        %disp('in optostim')
        if  state== ex.states.FPHOLD && ttime>time_startFixation+ ...
                optoStim_onsetTime && optoStim_on == 0
            %disp('in optostimOn')
            time_optoStim(optoStim_cnt+1) = GetSecs - trstart;
            turnOnDigOut(ex.strobe.OPTO_PULSE);
            optoStim_on = 1;
        elseif optoStim_on ==1 && ttime> optoStim_onsetTime+optoStim_duration
            %disp('in optoStimOff')
            turnOffDigOut;
            optoStim_on = 0;
            optoStim_cnt = optoStim_cnt + 1;
            optoStim_onsetTime = optoStim_onsetTimes(optoStim_cnt);
            optoStim_duration = optoStim_durations(optoStim_cnt);
        end
    end
    
    % fUS TRIGGERS ------------------------------- new addition on 9/18/25
    if ~isempty(fUS_on)
        if state== ex.states.FPHOLD && ttime > time_startFixation + ...
                fUS_triggerOnsetTime &&~ fUS_triggered           
            turnOnDigOut(ex.strobe.SYNC_PULSE)
            time_fUS = GetSecs -trstart;
            fUS_on = true;
            fUS_triggered = true;
        elseif fUS_on == true && ttime> time_fUS+fUS_duration
            turnOffDigOut;
            fUS_on = false;
        end
    end
         
    
    % give earlyReward if fixation is long enough
    if earlyReward_start && ~earlyReward_on
        disp('give earlyReward')
        time_earlyReward(earlyReward_cnt) = GetSecs - trstart;
        turnOnDigOut(ex.strobe.REWARD);
        earlyReward_start = 0;
        earlyReward_on = 1;
    end
    
    if earlyReward_on && ttime > time_earlyReward(earlyReward_cnt) + ...
            ex.reward.earlyRewardTime*ex.reward.scale
        turnOffDigOut;
        earlyReward_on = 0;
    end
    
    % update frame stuff (slow)
    ttime = GetSecs-trstart;
    %if ttime > lastframet + frametimestep - 0.008  %07/04/22: changed delta from 0.008 to 0.006
    if ttime > lastframet + frameDelta
    %if GetSecs-lastframet > frameDelta

        %Prepare single screen call for all onscreen dots ( fp, eyepos,
        %mousepos)
        if isempty(ex.eyeCal.LXPos) %monocular eye position
            olPos = [lastEyePos;mousePos]; % eye pos; mouse pos
            dotPos=  fpPos;
                  
        else %overlay dot positions: binocular eye positions; mouse
            olPos = [lastEyePos; 
                   mean(lastEyePos,1); ... % mean R/L eye position; 
                   mousePos]; % mouse positions
            dotPos =  fpPos;
        end        
        
        dotSz =  fpSz;              
        dotCol =  fpCol*ones(1,3);
        
        %tic
        % draw stimulus first because fullfield will erase everything
        % Play Stimulus
        %if state == ex.states.FPHOLD && stimOn_flag
        if stimOn_flag
            % draw synch pulse on every stimulus frame
            %if si == 0
            %{
            % dot for photodiode
            Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
            Screen('Drawdots',ex.setup.window,spPos,spSz,spCol);
            
            Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
            Screen('Drawdots',ex.setup.window,spPos,spSz,spCol);
            %}
            
            if strcmpi(ex.stim.type,'fullfield')
                

                Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
                Screen('Drawdots',ex.setup.window,spPos,spSz,spCol);
                
                Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
                Screen('Drawdots',ex.setup.window,spPos,spSz,spCol);
                
                ex=playStimulus(ex,RDS,ttime-time_startFixation);
            else
                
                ex=playStimulus(ex,RDS,ttime-time_startFixation);

                Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
                Screen('Drawdots',ex.setup.window,spPos,spSz,spCol);
                
                Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
                Screen('Drawdots',ex.setup.window,spPos,spSz,spCol);
            end
            
            si = si+1;
            
        else
            if ex.setup.stereo.Display
                % Select left-eye image buffer for drawing:
                Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
                Screen('FillRect',ex.setup.window,ex.idx.bg_lum);  % background to start
                % Select right-eye image buffer for drawing:
                Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
                % Draw right stim:
                Screen('FillRect',ex.setup.window,ex.idx.bg_lum);  % background to start
            else
                Screen('FillRect',ex.setup.window,ex.idx.bg_lum);
            end
            
        end
        
        %ex.tocsSTIM{ex.j} = [ex.tocsSTIM{ex.j} toc];
        
        
        
        %% draw eye dots, mouse position
        Screen('Drawdots',ex.setup.overlay,olPos',olPSz',olColBinoc');
        
        
        %% draw all dots unless we have a fullfield stimulus
        if strcmpi(ex.stim.type,'fullfield') && ex.freeViewing
            
            % we need to switch off the stimulus at the end added on
            % 06/30/22
            if stimCompleted
                if ex.setup.stereo.Display
                    % Select left-eye image buffer for drawing:
                    Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
                    Screen('FillRect',ex.setup.window,ex.idx.bg_lum);  % background to start
                    % Select right-eye image buffer for drawing:
                    Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
                    % Draw right stim:
                    Screen('FillRect',ex.setup.window,ex.idx.bg_lum);  % background to start
                else
                    Screen('FillRect',ex.setup.window,ex.idx.bg_lum);
                end
            end
            
            
            %if ex.exp.visualSearch && fpOn
            if ex.freeViewing == 2 && fpOn
                if ~ex.setup.stereo.Display
                    Screen('Drawdots',ex.setup.window,dotPos',dotSz',dotCol');
                else
                    Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
                    Screen('Drawdots',ex.setup.window,dotPos',dotSz',dotCol');
                    
                    Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
                    Screen('Drawdots',ex.setup.window,dotPos',dotSz',dotCol');
                end
            end
            
        else
            
            %% draw FP,target and eye dots
            %{
            if fpOn
                if ~ex.setup.stereo.Display
                    Screen('Drawdots',ex.setup.overlay,dotPos',dotSz',dotCol');
                else
                    Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
                    Screen('Drawdots',ex.setup.window,dotPos',dotSz',dotCol');
                    
                    Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
                    Screen('Drawdots',ex.setup.window,dotPos',dotSz',dotCol');
                end
            end
            %}
            
            %{
            if stimCompleted
                if ex.setup.stereo.Display
                    % Select left-eye image buffer for drawing:
                    Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
                    Screen('FillRect',ex.setup.window,ex.idx.bg_lum);  % background to start
                    % Select right-eye image buffer for drawing:
                    Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
                    % Draw right stim:
                    Screen('FillRect',ex.setup.window,ex.idx.bg_lum);  % background to start
                else
                    Screen('FillRect',ex.setup.window,ex.idx.bg_lum);
                end
            end
            %}
            
            %% draw FP,target and eye dots
            if fpOn
                
                if ex.fix.fixCross==false
                    if ~ex.setup.stereo.Display
                        Screen('Drawdots',ex.setup.overlay,dotPos',dotSz',dotCol');
                    else
                        if me>=0 % right eye image
                            Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
                            Screen('Drawdots',ex.setup.window,dotPos',dotSz',dotCol');
                        end
                        if me<=0 % left eye image
                            Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
                            Screen('Drawdots',ex.setup.window,dotPos',dotSz',dotCol');
                        end
                    end
                else
                    if ex.stim.vals.st == 0
                        % monocular fix marker when the screen is blank
                        if me>=0 % right eye image
                            % add by ik, 2023.05.11
                            Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
                            Screen('Drawdots',ex.setup.window,dotPos',35,ones(1,3)*ex.idx.bg_lum);
                            
                            %Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
                            Screen('DrawLines',ex.setup.window,fLines,fWidth,dotCol(1));
                        end
                        if me<=0 % left eye image
                            Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
                            Screen('Drawdots',ex.setup.window,dotPos',35,ones(1,3)*ex.idx.bg_lum);
                    
                            %Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
                            Screen('DrawLines',ex.setup.window,fLines,fWidth,dotCol(1));
                        end
                        
                    else
                        % binocular fix marker when stimuli are presented 
                        Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
                        Screen('Drawdots',ex.setup.window,dotPos',35,ones(1,3)*ex.idx.bg_lum);
                        Screen('DrawLines',ex.setup.window,fLines,fWidth,dotCol(1));
                        
                        Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
                        Screen('Drawdots',ex.setup.window,dotPos',35,ones(1,3)*ex.idx.bg_lum);
                        Screen('DrawLines',ex.setup.window,fLines,fWidth,dotCol(1));
                    end
                end
                    
                    
            end
        end

        
        %tic
        Screen('DrawingFinished', ex.setup.window);
        [flip_info(fi,1), flip_info(fi,2), flip_info(fi,3), ...
            flip_info(fi,4)] = Screen('Flip', ex.setup.window);

         % Log current frame after Flip for gabornoise - LC: added 12/25
        if stimOn_flag && ...
            isfield(ex,'stim') && isfield(ex.stim,'vals')&&...
            isfield(ex.stim.vals, 'currFrame') && ...
            isfield(ex.stim.vals, 'absFrame') && ...
            isfield(ex.stim.vals, 'chunkIdx')

            entry.trial = ex.j;
            entry.absFrame = ex.stim.vals.absFrame;
            entry.currFrame = ex.stim.vals.currFrame;
            entry.chunkIdx = ex.stim.vals.chunkIdx;
            entry.time = flip_info(fi,1);

            if ~isfield(ex, 'sessionFrameLog') || isempty(ex.sessionFrameLog)
                ex.sessionFrameLog = entry;
            else
                ex.sessionFrameLog(end+1) = entry;
            end
        end
        
        % store Stimulus frame onsets
        if stimOn_flag
            StimStart(si) = flip_info(fi,1);
        end
        %lastframet = 0;
        lastframet = flip_info(fi,1)-trstart;
        %lastframet = flip_info(fi,1); % changed 07/06/22
        fi = fi+1;
    end

   
    ex.loopcnt(ex.j) = ex.loopcnt(ex.j)+1;
    
    ttime = GetSecs-trstart;
    
    
    % keyboard 
    [~, ~, keyCode] = KbCheck; % MAGIC NUMBER
    if strcmpi(KbName(keyCode),'q')  %% quit
        ex = closeStimulus(ex);
        ex.quit = 4;
    elseif strcmpi(KbName(keyCode),'p')  %% pause with gray screen
        ex.quit = 1;
        ex.Trials(ex.j).pa = 1;
    elseif strcmpi(KbName(keyCode),'d')  %% decrease Reward
        ex.Trials(ex.j).dR = 1;
        ex.reward.scale = ex.reward.scaleStepSize;
        ex.reward.nTrialsAfterShake = 0;  
        disp('DECREASE REWARD')
    elseif strcmpi(KbName(keyCode),'t')  %% pause with black screen
        ex.nCorrectChoice = 0;
        ex.quit = 2;
        ex.Trials(ex.j).to = 1;
    end
    %KbName(keyCode)
    
    % mouse input
    %tic
    [x,y,b] = GetMouse(ex.setup.screenNum);
    mousePos = [x+ex.setup.mouseXOffset,y];
   
    % if mouse left button is pressed, use new x,y positions for stimulus
    % if right mouse button is pressed, use it to update the orientation
    % if "h" is pressed, use mouse position to update stimulus height
    % if "w" is pressed, use mouse position to update stimulus width 
    % change orientation when right mouse button is pressed
    if  b(2)>0 && mousePos(1)>0
        b = (mousePos(2)-ex.fix.PCtr(2))*dpp -ex.stim.vals.y0;
        a = (mousePos(1)-ex.fix.PCtr(1))*dpp - ex.stim.vals.x0;
        if ~ isnan(atan(b/a)*180/pi)
            ex.stim.vals.or = -atan(b/a)*180/pi;    
        end
    % change x/y position when left mouse button is pressed
    elseif  b(1)>0 && mousePos(1)>0 && mousePos(1)<ex.setup.screenRect(3) ...
            && mousePos(2)>0 && mousePos(2)<ex.setup.screenRect(4)

    % % cmz - 20260206 - trying to modify so works in the dome

    % mousePosFlipx = [ex.setup.scal.rect(3)/2 - (mousePos(1)-ex.setup.scal.rect(3)/2) mousePos(2)];
    % [mousePosGC(1),mousePosGC(2)] = geomCorrection(mousePosFlipx(1),mousePosFlipx(2),ex.setup);
    % [mousePosGC(1),mousePosGC(2)] = geomCorrection(mousePos(1),mousePos(2),ex.setup);
    % [xPos, yPos] = pixel2degxy(mousePosGC(1),mousePosGC(2),ex.setup);

    %[xPos, yPos] = pixel2degxy(mousePos(1),mousePos(2),ex.setup);

    % %disp this for debugging
    %[mousePos(1) xPos]
    %ex.stim.vals.x0 = xPos;
    %ex.stim.vals.y0 = yPos;

     ex.stim.vals.x0 = (mousePos(1)-ex.fix.PCtr(1))*dpp;
     ex.stim.vals.y0 = (mousePos(2)-ex.fix.PCtr(2))*dpp;
        
    % change stimulus height when 'h' is pressed
    elseif strcmpi(KbName(keyCode),'h')
        b = (mousePos(2)-ex.fix.PCtr(2))*dpp-ex.stim.vals.y0;
        a = (mousePos(1)-ex.fix.PCtr(1))*dpp - ex.stim.vals.x0;
        ex.stim.vals.hi = sqrt(a.^2+b^2);
        if isempty(ex.stim.vals.hi)
            ex.stim.vals.hi =1;
        end
    % change stimulus width when 'w' is pressed
    elseif strcmpi(KbName(keyCode),'w')
        b = (mousePos(2)-ex.fix.PCtr(2))*dpp-ex.stim.vals.y0;
        a = (mousePos(1)-ex.fix.PCtr(1))*dpp - ex.stim.vals.x0;
        ex.stim.vals.wi = sqrt(a.^2+b^2)/5;
    % get RF position when 'r' is pressed
    elseif strcmpi(KbName(keyCode),'r')
        ex.extras.rfx =  (mousePos(1)-ex.fix.PCtr(1))*dpp;
        ex.extras.rfy = (mousePos(2)-ex.fix.PCtr(2))*dpp;
    % add new line when 'l' is pressed
    elseif strcmpi(KbName(keyCode),'l') 
        % to make sure that we only update the line once per keyboard press
        if GetSecs-line_t0 > .1
            ex.extras.line = [ex.extras.line,[mousePos(1); mousePos(2)]];
            line_t0 = GetSecs;
        end
    % clear alls lines when 'a' and 'c' and'l' are pressed
    elseif sum([strcmpi(KbName(keyCode),'a'), ...
            strcmpi(KbName(keyCode),'c'), strcmpi(KbName(keyCode),'l')])>=3
        ex.extras.line = [];
    % center Eye when 'x' and 'y' are pressed
    elseif sum([strcmpi(KbName(keyCode),'z'), ...
            strcmpi(KbName(keyCode),'x')]) >=2 
        % to make sure we only re-center once per keyboard press
        if GetSecs - centerEye_t0 > .5
            ex=centerEye(ex);     
            disp(['eye recentering #: ' num2str(ex.eyeCal.Delta(1).cnt)])
            centerEye_t0 = GetSecs;
        end
    end
    % fetch spikes during free viewing
    if ex.freeViewing && ex.setup.recording && isfield(ex.setup,'sglx') ...
            && GetSecs+ex.setup.sglx.fetchInterval > t_begin
        t_begin = GetSecs;
        [ex, begin_idx] = fetchSpks(ex,begin_idx);
        %disp('infetchS ')
    end
    
end
% ------------------------------------------------------------------------
% done with while loop ---------------------------------------------------
% ------------------------------------------------------------------------

% blank screen at the end of trial, close offscreen stimulus windows----
if ex.nStimFinished == ex.exp.StimPerTrial || state ~= ex.states.REWARD
    ex = closeStimulus(ex);
end

if ex.nStimFinished == 0
    ex = closeStimulus(ex);
end


% ITI of random duration (only in freeViewing and fullfield mode)
% 07/19/22: hn: we no longer use this
iti = NaN;
giveRewardFlag = true;
if isfield(ex.exp,'randomITIRange') && length(ex.exp.randomITIRange) ==2 && ...
        ex.freeViewing ==1 && strcmpi(ex.stim.type,'fullfield')
    iti  = rand * diff(ex.exp.randomITIRange) + ex.exp.randomITIRange(1);
    ex.Trials(ex.j).iti = iti;
    sprintf('iti: %1.2f%\n',iti)
    pause(iti);
    giveRewardFlag = false;
end
if sum(isnan(time_earlyReward))>0 && ~isnan(iti) && ...
    duration_forEarlyReward(end)<fix_duration+iti
    giveRewardFlag=  true;
end

% we are now giving the early reward in the while loop above for the
% randomized trial duration. So we need to switch it off here.
if isfield(ex.fix,'trialDurationRange') && length(ex.fix.trialDurationRange) == 2 &&...
    ex.freeViewing == true
    giveRewardFlag = false;
end


% give feedback (exact timing is less crucial now); 
% hn: 11/23/15: moved this part of the code outside the while loop now
if state== ex.states.REWARD
    
    if ex.freeViewing == 0 && giveRewardFlag == 0
        keyboard
    end
    
    if ex.exp.StimPerTrial == ex.nStimFinished && giveRewardFlag

        %disp('in REWARD')
        if ex.bigReward
            RewardSize = ex.reward.time*3;
            %disp('in big reward')
        else
            RewardSize = ex.reward.time;
        end
        RewardSize = RewardSize*ex.reward.scale;
        %playTone
        time_reward = GetSecs - trstart;
        giveReward(RewardSize,ex);
        
        time_rewardGiven = GetSecs - trstart;
    end
    
elseif state== ex.states.BREAKFIX
    %playNoise
    time_error = GetSecs - trstart;
    ex.nStimFinished = 0;
    %disp('in ERROR')  
end    

trEnd_Eyelink = Eyelink('TrackerTime');
trEnd = GetSecs;  % end of trial time
if ex.setup.recording && isfield(ex.setup.(ex.setup.ephys),'handle')
    trEnd_sglx = GetStreamSampleCount(ex.setup.(ex.setup.ephys).handle,-2,0);
end

    
sendStrobe(ex.strobe.TRIAL_END);
[~,~,trEnd_Datapixx] = getDatapixxDin(ex.strobe.TRIAL_END);


% blank screen at the end of trial, close offscreen stimulus windows----
if ex.nStimFinished == ex.exp.StimPerTrial || state ~= ex.states.REWARD
    ex = closeStimulus(ex);
end


% -------------------------------------------------------------------------
% store Trial information--------------------------------------------------
% -------------------------------------------------------------------------
ex.Trials(ex.j).ID = clocktime;

% store trial times---------------------------------------------
ex.Trials(ex.j).TrialEnd = trEnd;
ex.Trials(ex.j).TrialStart = trstart;
ex.Trials(ex.j).TrialStartDatapixx = trstart_Datapixx;
ex.Trials(ex.j).TrialEndDatapixx = trEnd_Datapixx; 
ex.Trials(ex.j).TrialStartEyelink = trstart_Eyelink;
ex.Trials(ex.j).TrialEndEyelink = trEnd_Eyelink;
if ex.setup.recording && isfield(ex.setup,'sglx')
    ex.Trials(ex.j).TrialStartSGLX = trstart_sglx;
    ex.Trials(ex.j).TrialEndSGLX = trEnd_sglx;
end

% read in spikes for this trial 
if ex.setup.recording && ex.freeViewing ~=1 && ...
    ex.setup.(ex.setup.ephys).readOnlineSpikes == true 
    ex=readSpksInTrial(ex);
    
end


ex.Trials(ex.j).times.fpOn = time_fpOn + trstart;
ex.Trials(ex.j).times.fpOff = time_fpOff + trstart;  % this is the go cue 
ex.Trials(ex.j).times.fixationComplete = time_fixationComplete + trstart;  % this is the go cue 
ex.Trials(ex.j).times.stimOn = time_stimOn + trstart; % stimulus comes on
ex.Trials(ex.j).times.stimOff = time_stimOff + trstart;  % stimulus goes off
ex.Trials(ex.j).times.startFixation = time_startFixation + trstart;
ex.Trials(ex.j).times.breakFixation = time_breakFixation + trstart;
ex.Trials(ex.j).times.reward = time_reward + trstart;  % time of starting to give rew
ex.Trials(ex.j).times.rewardGiven = time_rewardGiven + trstart; % time at end of reward
ex.Trials(ex.j).times.earlyReward = time_earlyReward + trstart;
ex.Trials(ex.j).times.error = time_error + trstart; % time when error signal (if any) is played
ex.Trials(ex.j).times.optoStim = time_optoStim + trstart;
ex.Trials(ex.j).times.fUS = time_fUS + trstart;

% store display timing, eye info and signals from NPI (iontophoresis unit) 
ex.Trials(ex.j).flip_info = flip_info(1:fi-1,:);
ex.Trials(ex.j).Start = StimStart(1:si);

% read out eye info to cover the reward period (allows us to look at pupil
% measurements)
time_beforeLastEyeReadingDatapixx = Datapixx('GetTime');  % to match up the 
%                                           Datapixx clock and the PTB clock
time_beforeLastEyeReading = GetSecs - trstart;
[~,trEye] = checkEye(trEye,ex,[],pass_eye,lastEyePos,tchosen);
time_lastEyeReading = GetSecs-trstart;
Datapixx('SetMarker');
time_lastEyeReadingpostMarker = GetSecs - trstart;
Datapixx('RegWr');
Datapixx('RegWrRd')
time_lastEyeReadingDatapixx = Datapixx('GetMarker');  % to match up the 
%                                           Datapixx clock and the PTB clock

ex.Trials(ex.j).times.lastEyeReading = time_lastEyeReading+trstart;
ex.Trials(ex.j).times.beforeLastEyeReading = time_beforeLastEyeReading+trstart;
ex.Trials(ex.j).times.lastEyeReadingDatapixx = time_lastEyeReadingDatapixx; % last time stamp still using 'GetTime'
ex.Trials(ex.j).times.beforeLastEyeReadingDatapixx = time_beforeLastEyeReadingDatapixx;
ex.Trials(ex.j).times.lastEyeReadingPostMarker = time_lastEyeReadingpostMarker+trstart;

% iknew: 7.13.2022
trEye.v = trEye.v(:,1:trEye.n);
trEye.t = trEye.t(1:trEye.n);
ex.Trials(ex.j).Eye = trEye;

if ex.setup.iontophoresis.on
    ex.Trials(ex.j).iontophoresis = trEye.v(end-1:end,:);
    ex.Trials(ex.j).Eye.v = trEye.v(1:end-2,:);
end

ex.Trials(ex.j).nStim = ex.nStimFinished;



% ik - check for freeViewing > 0
% store behavioral performance and reward information-----------
good = 0;
if state == ex.states.REWARD % successfully completed trial
    good = 1;
    ex.reward.nTrialsAfterShake = ex.reward.nTrialsAfterShake+1;
elseif isfield(ex.stim,'seq')
    % make sure we have the same number of repeats for each combination of
    % stimulus parameters
    fname = fieldnames(ex.stim.seq);
    for n = 1:length(fname)
        eval(['ex.stim.seq.' fname{n} '(end+1) = ex.stim.seq.' ...
            fname{n} '(ex.j);']);
    end
    ex.finish = ex.finish+1;
end
% number of successfully completed trials:
ex.goodtrial = ex.goodtrial + abs(good); 
ex.Trials(ex.j).Reward = good;
ex.Trials(ex.j).RewardSize = RewardSize;
ex.Trials(ex.j).fixDuration = trial_duration;


% store electrode depth
if  ex.setup.recording
    if ~(strcmpi(ex.setup.computerName,'hns-mac-pro-2.cin.medizin.uni-tuebingen.de') ||...
        strcmpi(ex.setup.computerName,'hns-mac-pro-2.local')) 
        %store electrode depth if we are recording neural data & only works on
        %rig 1 for microdrive
        % h = ServoDrive;
        % if isfield(h,'position')
        %     ex.Trials(ex.j).ed = h.position;
        % end
    end
end

% trial information for experimenter only on rewarded trials (saves time)
% and re-setting nStimFinished
correct = 0;
if ex.nStimFinished == ex.exp.StimPerTrial
    % read in LFP only on rewarded trials to save time
    if ex.setup.recording && eval(['ex.setup.' ex.setup.ephys '.readLFP==true'])
        ex = readLFPInTrial(ex);
        %disp('in read LFP')
    end
    
    GetFigure('Online Plot');
    % plot tuning curves if we have spike data
    plotEyePosTraces(ex,trEye);
    if ~strcmpi(ex.stim.type,'blank') &&~strcmpi(ex.stim.type,'image')
        if ex.setup.recording && ex.setup.(ex.setup.ephys).readOnlineSpikes == true && ...
                strcmp(ex.setup.ephys,'gv')
            plotTC(ex);
        end
    end
    % -------------------------------------------------------------------------
    % Trial online output for experimenter ------------------------------------
    correct = length(find([ex.Trials.Reward]==1));
    disp(['# trials: ' num2str(ex.goodtrial) ])
    disp(['fileName: ' ex.Header.onlineFileName])
    disp([' '])
    if (ex.exp.afc) 
        disp(['# max trials:' num2str(ex.finish) '  # stim:' ... 
            num2str(length(ex.stim.seq)) ' # correct:' num2str(correct)])
    end
    ex.nStimFinished = 0;
    ex.bigReward = 0;
end

% plot RF for RC data every 10 completed trials
if ex.Trials(ex.j).Reward && round(correct/5) == correct/5 && ...
        isfield(ex.Trials(ex.j),'y0_seq') && ~isempty(ex.Trials(ex.j).y0_seq) && ...
        isfield(ex.Trials(ex.j),'x0_seq') && ~isempty(ex.Trials(ex.j).x0_seq)
    figh = GetFigure('RF 2D');
    figh2 = GetFigure('RF 3D');
    plotRF(ex,figh,figh2);
end

if abs(good) >0
    ex.changedBlock = 0; % needed to keep track of block changes even when 
    %                                                   he breaks fixation
end

%save frame count if we use it to display stimulus (used for fullfield)
if ~isempty(ex.stim.vals.framecnt)
    ex.Trials(ex.j).framecnt = ex.stim.vals.framecnt;
    
end

% iknew: 7.13.2022
ex.Trials(ex.j).freeViewing = ex.freeViewing;
ex.Trials(ex.j).fpPos = fpPos;
ex.Trials(ex.j).preFixDuration = preFixDuration;


% increase trial counter----------------------------------------
ex.j = ex.j+1;


