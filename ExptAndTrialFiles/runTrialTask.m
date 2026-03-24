function [ex] = runTrialTask(ex)
% run Trial
% hn 8/31/13

% history
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
% 07/27/14  hn: included read-in of mouse positions to change stimulus x,y
%               but commented it out for now; too confusing for now
% 08/02/14  hn: we now draw overlay items that are fixed during the
%               trial before the while loop to save timing for stimulus
%               drawing
% 08/31/14  hn: included read in of iontophoresis input;
% 09/04/14  hn: included Datapixx trialStart time to match up PTB and
%               Datapixx clocks
% 09/10/14  hn: included additional timing information; and ports are
%               flushed before they are being used to retrieve timing
%               trial start:
%                   -Datapixx1
%                   -Getsecs
%                   -sendStrobe
%                   -Datapixx
%                   -Eyelink
%               trial end:
%                   -Datapixx1
%                   -Getsecs
%                   -sendStrobe
%                   -Eyelink
% 09/12/14  hn: new timing order, for each communication step tic/toc is
%               also retrieved
%               trial start:
%                   -Eyelink
%                   -Datapixx
%                   -Getsecs
%                   -sendStrobe
%               trial end:
%                   -Eyelink
%                   -Datapixx
%                   -Getsecs
%                   -sendStrobe
% 09/14/14  hn: replaced Datapixx('GetTime') by Datapixx('GetMarker') (requires setting the marker first)
%               new timing order, for each communication step tic/toc is
%               also retrieved
%               trial start:
%                   -Eyelink
%                   -Getsecs
%                   -Datapixx
%                   -sendStrobe
%               trial end:
%                   -Eyelink
%                   -Getsecs
%                   -Datapixx
%                   -sendStrobe
% 04/10/15  hn: storing time-out and pause in trial structure as
%               ex.Trials(n).to or ex.Trials(n).pa
% 05/27/15  hn: included eye re-cenering
% 09/28/15  hn: include early stimulus off
% 11/25/15  hn: include y_OffsetCueAmp
% 12/02/15  hn: include add AC Trial % still need to implement full
% functionality
% 01/05/16  hn: include target x-offset
% 01/18/16  hn: include TO after fixation break
%               (ex.fix.toDurationAfterFixBreak)
% 04/05/16  hn: TO after fixation break now only later in the trial:
%               if time_breakFixation > ex.fix.freeOfToDuration
% 09/19/17  hn: include option to adjust probabilities for lower/upper
%               target; in 'ex.targ.lowerTargProb'
% 09/28/17  hn: increased reward after 3 correct trials
%
% 03/06/23  bt: changed the fixation duration from fixed value to relative
%               values from target onset: from now, only give actual target
%               onset values and relative fixation values (eg., targOn_delay = 0.1 instead of 2.1 and fix_duration = 0.09 instead of 2.09)
% 06/27/23  bt: changed the target onset delay from uniform to exponential
% 09/05/23 bt: changed target onset delay to fixed value. Line 905: added a
%              variable to trial structure that quantifies the proportion of juice
% 10/11/23: bt: changed the fixation duration from fixed value to introduce
%               jitter within a specific hard-coded range
% 05/15/24: bt: introduced sequential timeouts for errors (lines 828-839)
% 05/20/24: bt: introduced type of reward variable to interchange between
%               sequential reward or asymmetric reward (line 786)
% 11/19/24  bt: removed time out with 'o' (ex.quit == 3)
% 11/19/24  bt: removed fix_duration and targOn_delay from saving to
%               ex.times structure
% 11/19/24: bt: going back to the previous version where fixation duration
% and target onset delay are specified from onset of fixation
% 11/14/24: st: introduced second type of asymmetry(response based
%               asymmetry). Also created variable to keep track of reward bias block
%               within ex.trials.rewardBias (lines 799 and 881). To set, do
%               ex.reward.type = 'ResponseAsymmetry'. the alternative
%               asymmetry is 'RewardAsymmetry'. The first element in the
%               vector is the bias for a near stimulus or downward target.
%               The second element in the vector is a reward bias for a far
%               stimulus or upward target.
% 1/21/25   st: instantiated rewardBiases tracker variable. (line 292)
%               If we are testing a response asymmetry, disable the correction 
%               loop. (line 318)
%               introduced variable in ex.trials to keep track of reward
%                bias blocks(line 938)
%               store information about reward bias block for reward asymmetry
%               (line 1044)
% 09/22/25  hn: early rewards are now implemented via 
%               "turnOnDigOut(ex.strobe.REWARD), lines 693, 698          
% 12/02/2025 ST: Removed correction loop for stimulus and response asymmetry
%               (line 324)
%               Introduced vanilla reward type for no reward asymmetry. line
%               867 and 966. ex.reward.type = ""; Updated tracker and reward bias
%               multiplier to be accomodate for new no asymmetry condition by updating
%               tracker and reward multipler conditional statement. Correction loop is in
%               place for vanilla condition. RewardBias is recorded as "NaN'.
% 02/10/26   hn/bt: added ITI at the start of trial
%               - removed TOCS

% ------------------------------------------------------------------------
% pretrial allocations, stimulus generation and setup
% ------------------------------------------------------------------------

% converting pixels to degrees (needed to changes stimulus position with
% mouse
dpp = atan(ex.setup.monitorWidth/2/ex.setup.viewingDistance)*180/pi/(ex.setup.screenRect(3)/2);  % degrees per pixes
ppd = 1/dpp;  % pixels per degree

fpPos = ex.fix.PCtr;
fpSz = ex.fix.PSz;
tp_Offset = [0 0];
targ = ex.targ;

% point for photodiode synch pulse
spPos = ex.synch.Pos;
spSz = ex.synch.PSz;
spCol = ex.synch.Col;



% initial color assignments
fpWinCol = ex.idx.bg;
fpCol = ex.idx.bg;
t1Col = ex.idx.bg;
t2Col = ex.idx.bg;
targWinCol = ex.idx.bg;
% assign colors for eye and mouse positions (overlay dots: ol)
if ~isempty(ex.eyeCal.LXPos)
    if ~ ex.setup.stereo.Display
        olColBinoc = [ex.idx.overlayRed,ex.idx.overlayGreen,ex.idx.overlayBlue, ex.idx.overlayGreen]; % right,left,binoc, mouse
        olColBinoc = [olColBinoc'*ones(1,3)];
    else
        olColBinoc = [ex.idx.overlay,ex.idx.overlay ex.idx.overlay ex.idx.overlay]; % right, left, binoc, mouse
        olColBinoc = [olColBinoc'*ones(1,3)];
    end
    olPSz = [ceil(ex.setup.eyePSz/2)*ones(2,1); ex.setup.eyePSz; 2]; % eye (R,L,B), mouse
else olColBinoc = ex.idx.overlay*ones(1,3); %
    olPSz = [ex.setup.eyePSz; 2]; % eye, mouse pos
end

% pre-allocate memory; initialize variables
frametimestep = 1/ex.setup.refreshRate;
eyetimestep = 1/ex.setup.adc.Rate;  % 500Hz is the fastest Eyelink sample binocularly

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
time_fpOff = NaN;
time_targOn = NaN;
time_targOff = NaN;
time_stimOn = NaN;
time_stimOff= NaN;
time_choice = NaN;  % use this to compute RT
time_switchChoice = NaN;
time_noChoiceMade = NaN;
time_reward = NaN;  % time when reward is started
time_rewardGiven = NaN;
time_lastEyeReading = NaN;
time_beforeLastEyeReading = NaN;
time_beforeLastEyeReadingDatapixx = NaN;
time_lastEyeReadingDatapixx = NaN;
time_error = NaN;   % time when error signal (if any) is played
time_earlyReward = NaN;

% target and stimulus variables
goodTPos = NaN;
good_targ = NaN;
good_resp = NaN;

% BCT, 03/06/23: changed the default target onset value to reflect the
% relative fixation duration
% targOn_delay = ex.fix.duration;  % default target onset is at stimulus offset
% targOn_delay = ex.fix.preStimDuration + ex.fix.stimDuration;  % default target onset is at stimulus offset
% if isfield(ex.stim.vals,'targOn_delay')  && ~isnan(ex.stim.vals.targOn_delay)
%     targOn_delay = ex.fix.preStimDuration + ex.fix.stimDuration+ 0.25 + ex.stim.vals.targOn_delay*rand;
% else
%     targOn_delay = ex.fix.preStimDuration + ex.fix.stimDuration + rand;
% end
% BCT, 06/27/23: changed the target onset delay to exponential distribution
% and set a maximum value of 5 s
% targOn_delay = ex.fix.preStimDuration + ex.fix.stimDuration;  % default target onset is at stimulus offset
if isfield(ex.stim.vals,'targOn_delay')  && ~isnan(ex.stim.vals.targOn_delay)
    % targOn_delay = ex.fix.preStimDuration + ex.fix.stimDuration + ex.stim.vals.targOn_delay;
    % 11/19/24: going back to absolute values for target onset delay
    targOn_delay = ex.stim.vals.targOn_delay;
end

% BCT, 10/11/2023: defining fixation duration value below, to add jitter on
% a trial-by-trial level, instead of using a fixed value. This jitter is
% currently hard-coded in the script

% ITI -------------------------------------------------------------------
% wait for inter-trial interval before starting a trial
% fixed ITI (only when we are not in free viewing mode, i.e. freeViewing
% =0) this needs to be after we closed the stimulus and removed fixation
% marker

% 02/10/26: ITI is now implemented at the start of the trial
if isfield(ex.exp,'ITIDur') && ~isempty(ex.exp.ITIDur) && ...
        ex.freeViewing == 0 && ex.nStimFinished == 0 && ...
        ex.j > 1
    iti = ex.exp.ITIDur;
    if length(ex.exp.ITIDur) == 2
        iti  = rand * diff(ex.exp.ITIDur) + ex.exp.ITIDur(1);
    end
    WaitSecs(iti);
    ex.Trials(ex.j).iti = iti;
end


% DETERMINE TARGET ONSET IF IT IS BEING VARIED ---------------------------
if isfield(ex.stim.seq,'targOn_delay')
    %     if isfield(ex.exp,'two_pass') && ex.exp.two_pass
    %         if ex.j>ex.stim.nseq
    %             targOn_delay = ex.stim.seq2pass.targOn_delay(ex.j-ex.stim.nseq);
    %         else
    %             targOn_delay = ex.stim.seq.targOn_delay(ex.j);
    %         end
    %     else
    targOn_delay = ex.stim.seq.targOn_delay(ex.j);
    %     end
end

% 11/19/24:
fixation_dur = ex.fix.duration;
RT_delay = ex.targ.RT_delay;
if targOn_delay > ex.fix.duration
    if ex.targ.fixOnDuringDelay
        fixation_dur = targOn_delay;
    else
        RT_delay = ex.targ.RT_delay + targOn_delay - ex.fix.duration;
    end
end

targOn_flag = 0 ; % boolean to signal when targets get switched on/off
% default is that targets are off at the beginning
stimOn_flag = 0;

% BCT, 03/06/23: changed the default target onset value to reflect the
% relative fixation duration

% BCT, 11/19/24: going back to the previous version where fixation duration
% and target onset delay are specified from onset of fixation
% maxTrialDur = ex.fix.waitstop+ex.fix.freeduration + targOn_delay + fixation_dur + ...
%     ex.targ.go_delay+ex.targ.duration;
maxTrialDur = ex.fix.waitstop+ex.fix.freeduration+fixation_dur + ...
   ex.targ.go_delay+ex.targ.duration;

% timing information on PTB display
flip_info = NaN(ceil(maxTrialDur*ex.setup.refreshRate),4); %[VBLTimestamp StimulusOnsetTime FlipTimestamp Missed]

centerEye_t0 = GetSecs; % hack to prevent several re-centerings of eye position per key-press

%initialize eye structure
trEye.v = NaN(length(ex.setup.adc.Channels),ceil(maxTrialDur*ex.setup.adc.Rate)); % pre-allocate memory
trEye.t = NaN(1,ceil(maxTrialDur*ex.setup.adc.Rate));
trEye.n = 0; % nAcquiredFrames
trEye.sacc = [];

% initialize trial variables
pass_eye = 0;
if isempty(ex.eyeCal.LXPos)
    lastEyePos = [0 0];
else lastEyePos = [0 0; 0 0];
end
[x,y] = GetMouse;
mousePos = [x+ex.setup.mouseXOffset,y];
first_choice = 0;
tchosen = 0;
RewardSize = 0;
if isfield(ex.reward,'pauseAfterError')
    ErrorPause = 0;
end
lasteyepostime = 0;
lastframet = 0;
ex.loopcnt(ex.j) = 0;
ex.Trials(ex.j).to = 0; % default is no time-out
ex.Trials(ex.j).pa = 0; % default is no pause
ex.Trials(ex.j).dR = 0; % default is no decrease in reward size
ex.Trials(ex.j).addInstructionTrials = 0;
earlyReward_start = 0;
earlyReward_on = 0;
earlyReward_cnt = 0;
duration_forEarlyReward = ex.fix.duration_forEarlyReward(1);

% 11/14/24 ST: Initiated RewardBias tracker variable, which keeps track of
% bias magnitude and direction across session
rewardBiases = NaN; 

% MAKE TARGET ICONS IF NEEDED --------------------------------------------
if ex.exp.afc
    ex=makeTargetIcon(ex);

end

% RANDOMIZE TARGET LOCATIONS ----------------------------------------------
a=randn;
lowerBias = 0;
if isfield(ex.targ,'lowerTargProb')
    lowerBias = norminv(ex.targ.lowerTargProb);
    fprintf('lower targ bias: = %1.3f \n',lowerBias);
end
if a<lowerBias
    goodTPos = targ.Pos(1,:); % lower target is correct
    good_targ = [1,0]; % lower target is correct
else
    goodTPos = targ.Pos(2,:); % upper target is correct
    good_targ = [0,1]; % lower target is correct
end

% implement a correction loop in case of a response bias
% 1/21/25: If we are testing a response asymmetry, disable the correction
% loop.
if ~contains(ex.reward.type, 'Asymmetry')
    [goodTPos,good_targ,ex] = correctionLoop(goodTPos,good_targ,ex);
end

% GIVE THE Y-OFFSET OF STIMULUS TOWARDS TARGET THE CORRECT SIGN----------
% first check whether we are changing it as an experiment
if isfield(ex.stim.seq,'y_OffsetCueAmp')
    y_OffsetCueAmp = ex.stim.seq.y_OffsetCueAmp(ex.j);
else y_OffsetCueAmp = ex.stim.vals.y_OffsetCueAmp;
end
ex.stim.vals.y_OffsetCue = sign(goodTPos(2))*y_OffsetCueAmp;
%disp(['yOffsetCue:' num2str(ex.stim.vals.y_OffsetCue)])


% MAKE STIMULUS AND REFRESH BACKGROUND-----------------------------------
[ex,RDS]=makeStimulus(ex);
StimStart = NaN*ones(1,ceil(ex.setup.refreshRate*ex.fix.stimDuration));

% DETERMINE TARGET ICON BELONGING TO THE CORRECT RESPONSE ----------------
% I believe that this can be done after the stimulus has been made (hn:
% 12/09/16)
if isfield(ex.stim.seq,'or')
    good_resp = ex.stim.seq.or(ex.j);  % for orientation discrimination we
    % use the orientation value directly
    %elseif sign(ex.stim.seq.hdx(ex.j))<0  % near response is correct
elseif sign(ex.stim.vals.hdx)<0  % near response is correct
    % (hn: 12/00916: need to use stim.vals to account for 2pass)
    good_resp = -1;
    %elseif sign(ex.stim.seq.hdx(ex.j))>0 % far response is correct
elseif sign(ex.stim.vals.hdx)>0  % far response is correct
    % (hn: 12/00916: need to use stim.vals to account for 2pass)

    good_resp = 1;
else    % if we run the fine task and dx is 0

    disp(['in dx = ' num2str(ex.stim.seq.hdx(ex.j))])
    if randn(1) >0
        good_resp = 1;
    else good_resp = -1;
    end
end



% UPDATE TARGET POSITIONS TO INCLUDE X-OFFSET IF THERE IS ONE -----------
if isfield(ex.targ.icon,'xOffset')
    tp_Offset = [sign(ex.stim.vals.x0)*ppd*ex.targ.icon.xOffset 0];
    targ.Pos(:,1) = targ.Pos(:,1)+ sign(ex.stim.vals.x0)*ppd*ex.targ.icon.xOffset;
    goodTPos(1) = goodTPos(1) + + sign(ex.stim.vals.x0)*ppd*ex.targ.icon.xOffset;
end


% DRAW OVERLAY ITEMS THAT ARE FIXED DURING THE TRIAL --------------------
% (RF, FP frame, helper lines, correct target, if needed)
% if we have stored lines to orient the experimenter (e.g. RF borders), RF
% position, fixation window, correct target window, draw
% these first to avoid taking time from the stimulus drawing
drawOverlayHelperLines(ex);
drawOverlayFrames(ex,goodTPos);


% -----------------------------------------------------------------------
% TRIAL START
% ------------------------------------------------------------------------
% use clock time as unique trial ID
% clocktime: 1x6 vector: year month day hour(1:24) min sec
clocktime = fix(clock); % send strobe of this to rppl for trial identification
% we store both the unique trial ID and the trial number in the ripple file
% This might be overkill and we can remove unique trial ID in the future.

% flush ports (not sure that this is needed)
tmp = Datapixx('GetTime');
tmp = Eyelink('TrackerTime');

% get trial start times for different clocks.  We use tocs to get an
% estimate for the maximal mismatch between clocks.  The mismatch between
% Eyelink and Datapixx should be <1ms (as evaluated using tocs).
% Ripple and Datapixx are synchronized via the Trial_start strobe.
% PTB and Datapixx synchronization is done at the end of the experiment
% using PsychDataPixx('BoxsecsToGetsecs',[TrStartDP,TrEndDP]);
sendStrobes([ex.strobe.TRIAL_ID,clocktime,ex.strobe.TRIAL_NUMBER,ex.j]);
trstart_Eyelink = Eyelink('TrackerTime');
trstart = GetSecs;  % start of trial time

% this synchronizes the ripple and the datapixx clocks
sendStrobe(ex.strobe.TRIAL_START);
toc_trstartSENDSTROBE = toc;
% get time stamp of when ex.strobe.TRIAL_START was sent to ripple
[tmp,tmp,trstart_Datapixx] = getDatapixxDin(ex.strobe.TRIAL_START);


ttime = GetSecs-trstart; %  trial time


state = 0;
while state ~= ex.states.BREAKFIX && state~=ex.states.REWARD &&...
        state ~= ex.states.ERROR && state~=ex.states.NOCHOICEMADE && ...
        state ~= ex.states.SWITCHCHOICE && ...
        state ~=     ex.states.NOFIX && ex.quit == 0 &&ttime>0
    %tic;
    %--------------------------------------------------------------------
    % START STATE CHANGES -----------------------------------------------
    % BEFORE FIXATION DOT -----------------------------------------------
    if  state == ex.states.START && ttime > ex.fix.freeduration
        state = ex.states.FPON;
        fpCol = ex.idx.white;
        fpWinCol = ex.idx.overlay;
        disp('in fixation dot on');
        time_fpOn = GetSecs - trstart;
    end
    % WAITING FOR SUBJECT FIXATION --------------------------------------
    if  state == ex.states.FPON && ttime < ex.fix.waitstop && pass_eye
        time_startFixation = GetSecs - trstart;
        sendStrobe(ex.strobe.FIXATION_START)
        %t1Col = ex.targ.T1Col;
        %t2Col = ex.targ.T2Col;
        state = ex.states.FPHOLD;
        disp('in fixation acquired');
    elseif state == ex.states.FPON && ttime > ex.fix.waitstop
        state = ex.states.NOFIX;
        disp('in no fixation acquired');
        time_breakFixation = GetSecs - trstart;
    end
    % HOLD FIXATION -----------------------------------------------------
    if state == ex.states.FPHOLD;
        % check if fixation is broken
        %if ttime < time_startFixation + fixation_dur &&~ pass_eye
        if ~ pass_eye
            state = ex.states.BREAKFIX;
            disp('in breakfix');
            time_breakFixation = GetSecs - trstart;
            % if fixation is held until end of fixduration, move to next
            % state
            % BCT, 03/06/23: changed the default target onset value to reflect the
            % relative fixation duration
            %         elseif ttime > time_startFixation + fixation_dur && pass_eye
            % BCT, 11/19/24: going back to the previous version where fixation duration
            % and target onset delay are specified from onset of fixation
        % elseif ttime > time_startFixation + targOn_delay + fixation_dur && pass_eye
        elseif ttime > time_startFixation + fixation_dur && pass_eye
            state = ex.states.FIXATIONCOMPLETE;
            time_fixationComplete = GetSecs - trstart;
        elseif ~earlyReward_on && ttime > time_startFixation + duration_forEarlyReward && pass_eye
            earlyReward_cnt = earlyReward_cnt+1;
            duration_forEarlyReward = ex.fix.duration_forEarlyReward(earlyReward_cnt+1);
            earlyReward_start = 1;
            
        end
    end
    % BEFORE STIMULUS ON ----------------------------------------------
    if state == ex.states.FPHOLD && pass_eye && ...
            ttime > time_startFixation + ex.fix.preStimDuration && ...
            ttime <= time_startFixation + ex.fix.preStimDuration + ex.fix.stimDuration
        % BCT: 10/06/22: added the additional conditional statement above,
        % otherwise this  is also getting executed even after the
        % stimulus off time
        if ~stimOn_flag
            time_stimOn = GetSecs - trstart;
            disp('stim presentation');
        end
        stimOn_flag = 1;
    end
    % BEFORE STIMULUS OFF ---------------------------------------------
    if state == ex.states.FPHOLD && pass_eye && ...
            ttime>time_startFixation + ex.fix.preStimDuration+ex.fix.stimDuration
        %fprintf('stimOn_flag = %d\n\n',stimOn_flag)
        if stimOn_flag
            time_stimOff = GetSecs -trstart;
             disp('stim done');
        end
        stimOn_flag = 0;
    end

    %if ttime>time_startFixation + ex.fix.preStimDuration+ex.fix.stimDuration
    %    keyboard
    %end


    % BEFORE TARGETS ON ------------------------------------------------
    if state == ex.states.FPHOLD
        if pass_eye && ...
                ttime > time_startFixation + targOn_delay  % make sure targets come on at the latest at stimulus offset
            t1Col = ex.targ.T1Col;
            t2Col = ex.targ.T2Col;
            targWinCol = ex.idx.overlay;
            if ~targOn_flag
                time_targOn = GetSecs-trstart;
                disp('in Target on')
                %             fprintf('\n Target On time = %5.1f ms\n\n',(time_targOn-time_stimOn)*1000);
            end
            targOn_flag = 1;
        elseif ~pass_eye
            state = ex.states.BREAKFIX;
            time_breakFixation = GetSecs - trstart;
            disp('early response')
        end
    end


    % WAITING FOR GO CUE (FP OFF) ----------------------------------------
    if state == ex.states.FIXATIONCOMPLETE
        % BCT, 03/06/23: changed the default target onset value to reflect the
        % relative fixation duration
        %         if pass_eye && ...
        %             ttime >time_startFixation+fixation_dur + ex.targ.go_delay
        % BCT, 11/19/24: going back to the previous version where fixation duration
            % and target onset delay are specified from onset of fixation
        % if pass_eye && ...
        %        ttime >time_startFixation + targOn_delay + fixation_dur + ex.targ.go_delay
        if pass_eye && ...
                ttime >time_startFixation + fixation_dur + ex.targ.go_delay
            state = ex.states.GO;
            fpCol = ex.idx.bg;  % FP off
            fpWinCol = ex.idx.bg;
            time_fpOff = GetSecs-trstart;
            %         fprintf('\n Go time = %5.1f ms\n\n',(time_fpOff-time_stimOn)*1000);
            disp('in Go cue on')
        elseif ~pass_eye
            state = ex.states.BREAKFIX;
            time_breakFixation = GetSecs - trstart;
            disp('early response')
        end
    end


    % BCT: 10/06/2022: i think we need a conditional statement here
    % stopping the monkey from breaking out the fixation window for the
    % duration of RT_delay; something like this:
    % WAITING FOR A SMALL WINDOW, DEFINED BY RT_DELAY BEFORE RESPONSE EXECUTION ---------------
    % BCT, 03/06/23: changed the default target onset value to reflect the
    % relative fixation duration
    %     if state == ex.states.GO && ...
    %             ttime >time_startFixation+fixation_dur + ex.targ.go_delay && ...
    %             ttime <time_startFixation+fixation_dur + ex.targ.go_delay+ex.targ.RT_delay
    % BCT, 11/19/24: going back to the previous version where fixation duration
    % and target onset delay are specified from onset of fixation
    % if state == ex.states.GO && ...
    %        ttime >time_startFixation+targOn_delay + fixation_dur + ex.targ.go_delay && ...
    %        ttime <time_startFixation+targOn_delay + fixation_dur + ex.targ.go_delay+RT_delay
    if state == ex.states.GO && ...
         ttime >time_startFixation + fixation_dur + ex.targ.go_delay && ...
         ttime <time_startFixation + fixation_dur + ex.targ.go_delay+RT_delay
        if ~pass_eye
            state = ex.states.BREAKFIX;
            time_breakFixation = GetSecs - trstart;
            fprintf('t = %5.1f\n\n',(time_breakFixation - time_targOn)*1000);
            disp('early response')
        end
    end

    % BEFORE CHOICE ------------------------------------------------------
    % BCT, 03/06/23: changed the default target onset value to reflect the
    % relative fixation duration
    %     if state == ex.states.GO && sum(tchosen)>0 && ...
    %             ttime >time_startFixation+fixation_dur + ex.targ.go_delay + ...
    %             ex.targ.RT_delay && ttime <time_startFixation+fixation_dur+...
    %             ex.targ.go_delay+ex.targ.duration
    % BCT, 11/19/24: going back to the previous version where fixation duration
    % and target onset delay are specified from onset of fixation
    % if state == ex.states.GO && sum(tchosen)>0 && ...
    %         ttime >time_startFixation+targOn_delay + fixation_dur + ex.targ.go_delay + ...
    %         RT_delay && ttime <time_startFixation+targOn_delay + fixation_dur+...
    %         ex.targ.go_delay+ex.targ.duration
    if state == ex.states.GO && sum(tchosen)>0 && ...
            ttime >time_startFixation + fixation_dur + ex.targ.go_delay + ...
            RT_delay && ttime <time_startFixation + fixation_dur+...
            ex.targ.go_delay+ex.targ.duration
        state = ex.states.CHOICE;
        first_choice = find(tchosen);  % initial target choice
        time_choice = GetSecs-trstart;
        %         fprintf('\n Choice time = %5.1f ms\n\n',(time_choice-time_stimOn)*1000);
        % BCT: 10/04/22: targtes should ideally stay on until the hold time
        % to help monkey inspect their choice. This is currently not
        % possible; so moving the targOn_flag variable to below where
        % choice is accepted.
        % targOn_flag = 0;
        disp('in choice');
        fprintf('\n targOn_delay = %5.2f ms\n\n',(targOn_delay - (ex.fix.preStimDuration + ex.fix.stimDuration))*1000);
        fprintf('\n RT = %5.1f ms\n\n',(time_choice - time_fpOff)*1000);
        %fprintf('ttime = %4.3f\n\n',ttime)

    end
    % GIVE ERROR IF NO TARGET IS CHOSEN-----------------------------------
    % BCT, 03/06/23: changed the default target onset value to reflect the
    % relative fixation duration
    %     if state == ex.states.GO &&...
    %         ttime> time_startFixation+fixation_dur+ex.targ.go_delay+ ...
    %         ex.targ.duration
    % BCT, 11/19/24: going back to the previous version where fixation duration
    % and target onset delay are specified from onset of fixation
    % if state == ex.states.GO &&...
    %         ttime> time_startFixation + targOn_delay + fixation_dur+ex.targ.go_delay+ ...
    %         ex.targ.duration
    if state == ex.states.GO &&...
            ttime> time_startFixation + fixation_dur+ex.targ.go_delay+ ...
            ex.targ.duration
        state = ex.states.NOCHOICEMADE;
        t1Col = ex.idx.bg;
        t2Col = ex.idx.bg;
        targWinCol = ex.idx.bg;
        time_noChoiceMade = GetSecs - trstart;
        time_targOff = time_noChoiceMade;
        targOn_flag = 0;
        disp('no choice made')
    end

    % ACCEPT CHOICE IF TARGET IS HELD LONG ENOUGH AND CHOICE NOT SWITCHED--
    % BCT, 03/06/23: changed the default target onset value to reflect the
    % relative fixation duration
    %     if state == ex.states.CHOICE && sum(tchosen) && ...
    %             ttime >time_startFixation+fixation_dur + ex.targ.go_delay + ...
    %             ex.targ.RT_delay + ex.targ.hold
    % BCT, 11/19/24: going back to the previous version where fixation duration
    % and target onset delay are specified from onset of fixation
    % if state == ex.states.CHOICE && sum(tchosen) && ...
    %         ttime >time_startFixation + targOn_delay + fixation_dur + ex.targ.go_delay + ...
    %         RT_delay + ex.targ.hold
    if state == ex.states.CHOICE && sum(tchosen) && ...
            ttime >time_startFixation + fixation_dur + ex.targ.go_delay + ...
            RT_delay + ex.targ.hold
        disp('in accept choice')
        % BCT: 10/04/22: targtes should ideally stay on until the hold time
        % to help monkey inspect their choice. This is currently not
        % possible; so moving the targOn_flag variable from above to here
        targOn_flag = 0;
        time_targOff = GetSecs - trstart;
        % did monkey switch choice?
        if find(tchosen) == first_choice
            disp('in accept choice2')
            % REWARD  if correct target was chosen
            if find(tchosen) == find(good_targ)
                disp('in reward')
                state = ex.states.REWARD;
            else state = ex.states.ERROR;
                disp('in error')
            end
        else state = ex.states.SWITCHCHOICE;
            time_switchChoice = GetSecs - trstart;
        end
        t1Col = ex.idx.bg;
        t2Col = ex.idx.bg;
        targWinCol = ex.idx.bg;
    end

    %---------------------------------------------------------------------
    % END STATE CHANGES --------------------------------------------------
    %---------------------------------------------------------------------

    % update eye position (fast)
    ttime = GetSecs-trstart;
    if ttime > lasteyepostime + eyetimestep
        if state== ex.states.GO | state == ex.states.CHOICE
            [pass_eye,trEye,lastEyePos,tchosen] = checkEye(trEye,ex,targ,pass_eye,lastEyePos,tchosen);
        else
            [pass_eye,trEye,lastEyePos] = checkEye(trEye,ex,[],pass_eye,lastEyePos,tchosen);
        end
        lasteyepostime = ttime;
        ei = ei+1;
    end


    % give earlyReward if fixation is long enough
    if earlyReward_start
        time_earlyReward(earlyReward_cnt) = GetSecs - trstart;
        turnOnDigOut(ex.strobe.REWARD)
        earlyReward_start = 0;
        earlyReward_on = 1;
    end
    if earlyReward_on && ttime > time_earlyReward(earlyReward_cnt) + ex.reward.earlyRewardTime*ex.reward.scale
        turnOffDigOut;
        earlyReward_on = 0;
    end


    % update frame stuff (slow)
    ttime = GetSecs-trstart;
    if ttime > lastframet + frametimestep -0;

        % refresh screen
        %Screen('FillRect', ex.setup.overlay,ex.idx.bg_lum); % do I really need this?

        %Prepare single screen call for all onscreen dots ( fp, target)
        if isempty(ex.eyeCal.LXPos) %monocular eye position
            olPos = [lastEyePos;mousePos]; % eye pos; mouse pos
            dotPos=  [fpPos;...
                ex.targ.Pos(good_targ==1,:) + fpPos+tp_Offset;...
                ex.targ.Pos(good_targ~=1,:) + fpPos+tp_Offset];

        else %overlay dot positions: binocular eye positions; mouse
            olPos = [lastEyePos;
                mean(lastEyePos,1); ... % mean R/L eye position;
                mousePos]; % mouse positions
            dotPos =  [fpPos;...
                ex.targ.Pos(good_targ==1,:)+ fpPos+tp_Offset;...  correct target
                ex.targ.Pos(good_targ~=1,:)+ fpPos+tp_Offset];   % error target(s)
        end

        dotSz =  [fpSz;  ...
            ex.targ.PSz*ones(size(ex.targ.Pos,1),1)];

        dotCol =  [fpCol*ones(1,3); ...
            t1Col*ones(1,3); ...
            t2Col*ones(size(ex.targ.Pos,1)-1,3)];

        %% draw eye dots
        Screen('Drawdots',ex.setup.overlay,olPos',olPSz',olColBinoc');

        %%% draw FP,target and eye dots
        if ~ ex.setup.stereo.Display
            Screen('Drawdots',ex.setup.overlay,dotPos',dotSz',dotCol');
        else
            % draw right eye image
            Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
            Screen('Drawdots',ex.setup.window,dotPos',dotSz',dotCol');
            % draw left eye image
            Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
            Screen('Drawdots',ex.setup.window,dotPos',dotSz',dotCol');
        end



        % Play Target Icon
        if targOn_flag %ismember(state,[ex.states.GO,ex.states.TARGON])
            ex=playTargetIcon(ex,good_targ,good_resp,0);
        elseif state==ex.states.FPHOLD
            ex=playTargetIcon(ex,good_targ,good_resp,1);
        end

        % Play Stimulus
        if state == ex.states.FPHOLD && stimOn_flag

            % draw synch pulse on every frame
            %if si == 0
            Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
            Screen('Drawdots',ex.setup.window,spPos,spSz,spCol);

            Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
            Screen('Drawdots',ex.setup.window,spPos,spSz,spCol);
            %end


            ex=playStimulus(ex,RDS,ttime-time_startFixation);
            si = si+1;
        end

        %tic
        Screen('DrawingFinished', ex.setup.window);
        [flip_info(fi,1), flip_info(fi,2), flip_info(fi,3), ...
            flip_info(fi,4)] = Screen('Flip', ex.setup.window);
        %temptime = Screen('Flip', ex.setup.window,GetSecs);

        %temptime = 0;  % ?? why this?
        %lastframet = temptime-trstart;
        if state == ex.states.FPHOLD && stimOn_flag
            StimStart(si) = flip_info(fi,1);
        end
        lastframet = 0;
        fi = fi+1;
    end
    % %     % debuggin
    %     if targOn_flag
    %         pause(5);
    %     end

    ex.loopcnt(ex.j) = ex.loopcnt(ex.j)+1;

    ttime = GetSecs-trstart;

    % mouse input
    %tic
    [x,y,b] = GetMouse;
    mousePos = [x+ex.setup.mouseXOffset,y];

    %     % if mouse button is pressed, use new x,y positions for stimulus
    %     if  sum(b)>0
    %         ex.stim.vals.x0 = (x+ex.setup.mouseXOffset-ex.fix.PCtr(1))*dpp;
    %         ex.stim.vals.y0 = (y-ex.fix.PCtr(2))*dpp;
    %     end
    %
    % keyboard
    [keyIsDown, secs, keyCode] = KbCheck; % MAGIC NUMBER
    if strcmpi(KbName(keyCode),'q');  %% quit
        ex.quit = 4;
        state
    elseif strcmpi(KbName(keyCode),'p');  %% pause with gray screen
        ex.quit = 1;
        ex.Trials(ex.j).pa = 1;
        state
    elseif strcmpi(KbName(keyCode),'s');  %% sleep ON
        ex=sendSleepStrobe(ex,ex.strobe.SLEEP_ON);
    elseif strcmpi(KbName(keyCode),'f');  %% sleep OFF
        ex=sendSleepStrobe(ex,ex.strobe.SLEEP_OFF);
    elseif strcmpi(KbName(keyCode),'d');  %% decrease Reward
        ex.Trials(ex.j).dR = 1;
        ex.reward.scale = ex.reward.scaleStepSize;
        disp('DECREASE REWARD')
        %    elseif strcmpi(KbName(keyCode),'a');  %% additional AC Trial
        %         ex.Trials(ex.j).addAC = 1;
        %         disp('ADDITIONAL AC TRIAL')
    elseif strcmpi(KbName(keyCode),'i');  %% additional InstructionTrials
        ex.Trials(ex.j).additionalInstructionTrials = 1;
        ex.exp.addInstructionTrials = 1;
        ex.exp.countAddInstructionTrials = -1;
        disp('ADDITIONAL INSTRUCTION TRIALS')
    % 11/19/2024: removed timeout 'o' (removed the option to end the 
    % experiment with black screen), and now set 't' for timeout (pause) 
    % with black screen
    elseif strcmpi(KbName(keyCode),'t') %% timeout
        ex.nCorrectChoice = 0;
        ex.quit = 2;
        ex.Trials(ex.j).to=1;
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
end

% ------------------------------------------------------------------------
% done with while loop ---------------------------------------------------
% ------------------------------------------------------------------------
% 11/23/15: I now move the rewards out of the while loop
% give feedback (exact timing is less crucial now)
% 05/20/2024: bt: introduced type of reward variable to interchange between
% sequential reward or asymmetric reward.
% 11/14/2024: st: introduced subtype of reward asymmetry: responseAsymmetry
if state== ex.states.REWARD
    disp('in REWARD')
    ex.nErrorChoice = 0;
    ex.nCorrectChoice = ex.nCorrectChoice+1;
    RewardSize = ex.reward.time;
    if strcmp(ex.reward.type,'sequential')
        if ex.nCorrectChoice>4
            RewardSize = ex.reward.time*3;
        elseif ex.nCorrectChoice>3
            RewardSize = ex.reward.time*2;
        elseif ex.nCorrectChoice>2
            RewardSize = ex.reward.time;
        elseif ex.nCorrectChoice>1
            RewardSize = ex.reward.time;
        else
            RewardSize = ex.reward.time;
        end
    elseif strcmp(ex.reward.type,'stimulusAsymmetry')
        
         % 04/22/2024: BT: introduced a reward bias for far vs near stimuli
        if ex.Trials(ex.j).instructionTrial == 0
            if ex.Trials(ex.j).hdx > 0 % far stimulus
                RewardSize = RewardSize * ex.reward.rewardBias(2);
            elseif ex.Trials(ex.j).hdx < 0 % near stimulus
                RewardSize = RewardSize * ex.reward.rewardBias(1);
            end
        end
    elseif strcmp(ex.reward.type,'responseAsymmetry')
         % 11/14/2024: ST: introduced a reward bias upper vs lower target
        if ex.Trials(ex.j).instructionTrial == 0
            if find(good_targ) == 2  % upper target
                RewardSize = RewardSize * ex.reward.rewardBias(2);
            elseif find(good_targ) == 1 % lower target
                RewardSize = RewardSize * ex.reward.rewardBias(1);
            end
        end
    end 

    %     % exponential reward schedule  % 12/13/15 through 01/05/15
    %     if ex.nCorrectChoice >10
    %         RewardSize = ex.reward.time*6;
    %     elseif ex.nCorrectChoice>5
    %         RewardSize = ex.reward.time*(ex.nCorrectChoice-4);
    %     elseif ex.nCorrectChoice>4
    %         RewardSize = ex.reward.time*1.5;
    %     elseif ex.nCorrectChoice>3
    %         RewardSize = ex.reward.time*1.1;
    %     else
    %         RewardSize = ex.reward.time;
    %     end
    
    if ex.reward.scale <1
        RewardSize = ex.reward.time*ex.reward.scale;
    end
    playTone(ex.setup.audio.rewardFreq, ex.setup.audio.rewardLoops, ex.setup.audio.rewarddB);
    disp(['Reward Size: ' num2str(RewardSize)]);
    time_reward = GetSecs - trstart;
    giveReward(RewardSize,ex);
    time_rewardGiven = GetSecs - trstart;
elseif state== ex.states.ERROR
    disp('in ERROR')
    ex.nCorrectChoice = 0;
    ex.nErrorChoice = ex.nErrorChoice + 1;
    playTone(ex.setup.audio.errorFreq, ex.setup.audio.errorLoops, ex.setup.audio.errordB);
    time_error = GetSecs - trstart;
    % 05/15/24: bt: introduced sequential timeouts for errors
    if isfield(ex.reward,'pauseAfterError')
        if ex.nErrorChoice>3
            ErrorPause = ex.reward.pauseAfterError+3;
        elseif ex.nErrorChoice>2
            ErrorPause = ex.reward.pauseAfterError+2;
        elseif ex.nErrorChoice>1
            ErrorPause = ex.reward.pauseAfterError+1;
        else
            ErrorPause = ex.reward.pauseAfterError;
        end
        disp(['Pause after error: ' num2str(ErrorPause)]);
        pause(ErrorPause);
    end
end


% 11/14/24 st: introduced variable in ex.trials to keep track of reward
%              bias blocks
if strcmp(ex.reward.type,'stimulusAsymmetry') ||  strcmp(ex.reward.type,'responseAsymmetry')
    if ex.reward.rewardBias(2) >  ex.reward.rewardBias(1) % upper target
        rewardBiases = ex.reward.rewardBias(2) /  ex.reward.rewardBias(1);
    elseif ex.reward.rewardBias(2) <  ex.reward.rewardBias(1) % lower target
        rewardBiases = (ex.reward.rewardBias(1) / ex.reward.rewardBias(2)) * -1;
    else
        rewardBiases = NaN;
    end
end

tmp = Datapixx('GetTime');
tmp = Eyelink('TrackerTime');

tocTREND_beforeEyelink = toc;
trEnd_Eyelink = Eyelink('TrackerTime');
tocTREND_EYELINK = toc;
trEnd = GetSecs;  % end of trial time
tocTREND_GETSECS = toc;
sendStrobe(ex.strobe.TRIAL_END)
tocTREND_SENDSTROBE = toc;
[tmp,tmp,trEnd_Datapixx] = getDatapixxDin(ex.strobe.TRIAL_END);

% blank screen at the end of trial, close offscreen stimulus windows----
ex=closeStimulus(ex);
GetFigure('Online Plot');
% plot Performance
disp('plot performance')
plotPerformance(ex,trEye);

% -------------------------------------------------------------------------
% store Trial information--------------------------------------------------
% -------------------------------------------------------------------------
ex.Trials(ex.j).ID = clocktime;

% store trial times---------------------------------------------
ex.Trials(ex.j).TrialEnd = trEnd;
ex.Trials(ex.j).TrialStart = trstart;
ex.Trials(ex.j).TrialStartDatapixx = trstart_Datapixx;
ex.Trials(ex.j).TrialEndDatapixx = trEnd_Datapixx; % time stamp read immediately before trstart
ex.Trials(ex.j).TrialStartEyelink = trstart_Eyelink;
ex.Trials(ex.j).TrialEndEyelink = trEnd_Eyelink;
ex.Trials(ex.j).times.fpOn = time_fpOn+trstart;
ex.Trials(ex.j).times.fpOff = time_fpOff+trstart;  % this is the go cue
ex.Trials(ex.j).times.startFixation = time_startFixation+trstart;
ex.Trials(ex.j).times.breakFixation = time_breakFixation+trstart;
ex.Trials(ex.j).times.fixationComplete = time_fixationComplete+trstart;
ex.Trials(ex.j).times.stimOn = time_stimOn+trstart; % stimulus comes on
ex.Trials(ex.j).times.stimOff = time_stimOff + trstart;
ex.Trials(ex.j).times.targOn = time_targOn+trstart;
ex.Trials(ex.j).times.targOff = time_targOff+trstart;
ex.Trials(ex.j).times.choice = time_choice+trstart; % use this to compute RT
ex.Trials(ex.j).times.switchChoice = time_switchChoice+trstart; %if choice is switched
ex.Trials(ex.j).times.noChoiceMade = time_noChoiceMade+trstart;
ex.Trials(ex.j).times.reward = time_reward+trstart;  % time of starting to give rew
ex.Trials(ex.j).times.rewardGiven = time_rewardGiven+trstart; % time at end of reward
ex.Trials(ex.j).times.error = time_error+trstart; % time when error signal (if any) is played
ex.Trials(ex.j).times.earlyReward = time_earlyReward+trstart;

% store target information--------------------------------------
ex.Trials(ex.j).targ.goodPos = goodTPos;
ex.Trials(ex.j).targ.goodT = find(good_targ); %1: lower target; 2: upper target
ex.Trials(ex.j).targ.OnDelay = targOn_delay;
% which target icon belongs to correct target: -1 (near), 1 (far):
ex.Trials(ex.j).targ.correct = good_resp;


% store behavioral performance and reward information-----------
if state == ex.states.REWARD;
    good = 1;
elseif state == ex.states.ERROR
    good = -1;
else
    good = 0;
    % for fixation break, add new trials randomly to prevent serial
    % dependencies
    if ex.finish < ex.stim.nseq
        ex.finish = ex.finish+1;
    end
end
% number of successfully completed trials:
ex.goodtrial = ex.goodtrial + abs(good);

if abs(good) >0
    ex.changedBlock = 0; % not sure why this is in here
    ex.reward.nTrialsAfterShake = ex.reward.nTrialsAfterShake+1;
end
RespDir = NaN;
if ~isempty(find(tchosen))
    RespDir = find(tchosen);
end
ex.Trials(ex.j).RespDir = RespDir;  % 1: lower target; 2: upper target
ex.Trials(ex.j).Reward = good;
ex.Trials(ex.j).RewardSize = RewardSize;
% 1/21/25 ST: store information about reward bias block for reward asymmetry
ex.Trials(ex.j).rewardBias = rewardBiases;

if isfield(ex.reward,'pauseAfterError')
    ex.Trials(ex.j).pauseAfterError = ErrorPause;
end
ex.Trials(ex.j).juice = ex.reward.juice_proportion; % proportion juice in the reward for current trial

% store n TrialsAfter shake
if ex.Trials(ex.j).dR == 1
    ex.reward.nTrialsAfterShake = 0;
else
    ex.reward.nTrialsAfterShake = ex.reward.nTrialsAfterShake +1;
end
ex.Trials(ex.j).rewardScale = ex.reward.scale;

%----------------- deal with manually added instruction trials
% update counter for additional instruction trials if we give them
if ex.exp.addInstructionTrials && abs(good)>0
    ex.exp.countAddInstructionTrials = ex.exp.countAddInstructionTrials +1;
end
% check whether we are done with the additional instruction trials.  If so
% switch off the flag to add them
if ex.exp.addInstructionTrials && ex.exp.countAddInstructionTrials >= ...
        ex.exp.numberAdditionalInstructionTrials
    ex.exp.addInstructionTrials = 0;
end
% did we add additional instruction trials? If so set counter to 0
if ex.Trials(ex.j).addInstructionTrials
    ex.exp.addInstructionTrials = 1;
    ex.exp.countAddInstructionTrials = 0;
end

% %----------------- deal with manually added AC trials (not yet
% implemented)
% if abs(good)>0 && ex.exp.addACTrials
%     ex.exp.addACTrials = 0;
% end
%
% if ex.Trials(ex.j).addACTrials
%     ex.exp.addACTrials = 1;
% end




% store electrode depth if we are recording neural data---------------
disp('reading out electrode depth for rig 1')
if ex.setup.recording && ~(strcmpi(ex.setup.computerName,'hns-mac-pro-2.cin.medizin.uni-tuebingen.de') ||...
        strcmpi(ex.setup.computerName,'hns-mac-pro-2.local') )
    h = ServoDrive;
    if isfield(h,'position')
        ex.Trials(ex.j).ed = h.position;
    end
end


% store display timing, eye info and signals from NPI (iontophoresis unit)
ex.Trials(ex.j).flip_info = flip_info(1:fi-1,:);
ex.Trials(ex.j).Start = StimStart(1:si);
% read out eye info to cover the reward period (allows us to look at pupil
% measurements)
time_beforeLastEyeReadingDatapixx = Datapixx('GetTime');  % to match up the Datapixx clock and the PTB clock
time_beforeLastEyeReading = GetSecs - trstart;
[pass_eye,trEye] = checkEye(trEye,ex,[],pass_eye,lastEyePos,tchosen);
time_lastEyeReading = GetSecs-trstart;
Datapixx('SetMarker');
time_lastEyeReadingpostMarker = GetSecs - trstart;
Datapixx('RegWr');
Datapixx('RegWrRd')
time_lastEyeReadingDatapixx = Datapixx('GetMarker');  % to match up the Datapixx clock and the PTB clock

ex.Trials(ex.j).times.lastEyeReading = time_lastEyeReading+trstart;
ex.Trials(ex.j).times.beforeLastEyeReading = time_beforeLastEyeReading+trstart;
ex.Trials(ex.j).times.lastEyeReadingDatapixx = time_lastEyeReadingDatapixx; % last time stamp still using 'GetTime'
ex.Trials(ex.j).times.beforeLastEyeReadingDatapixx = time_beforeLastEyeReadingDatapixx;
ex.Trials(ex.j).times.lastEyeReadingPostMarker = time_lastEyeReadingpostMarker+trstart;
ex.Trials(ex.j).Eye = trEye;
if ex.setup.iontophoresis.on
    ex.Trials(ex.j).iontophoresis = trEye.v(end-1:end,:);
    ex.Trials(ex.j).Eye.v = trEye.v(1:end-2,:);
end


% read in spikes, LFP and electrode depth if we are recording
if ex.setup.recording
    % read online spikes
    if eval(['ex.setup.' ex.setup.ephys '.readOnlineSpikes==true'])
        ex=readSpksInTrial(ex);
    end
    %store electrode depth
    h = ServoDrive;
    if isfield(h,'position')
        ex.Trials(ex.j).ed = h.position;
    end
    % read out LFP
    if eval(['ex.setup.' ex.setup.ephys '.readLFP==true'])
        ex = readLFPInTrial(ex);
    end
end


% -------------------------------------------------------------------------
% Trial online output for experimenter ------------------------------------
correct = length(find([ex.Trials.Reward]==1));
disp(['# trials:' num2str(ex.goodtrial) '  %success:' ...
    num2str(correct/ex.goodtrial) ])
disp(['fileName: ' ex.Header.onlineFileName ])
if state==ex.states.REWARD || state==ex.states.ERROR
    nominalLength = floor(ex.fix.stimDuration*ex.setup.refreshRate);
    propDroppedFrames = (nominalLength- length(ex.Trials(ex.j).Start))/nominalLength;
    disp(['proportionDroppedFrames: ' num2str(propDroppedFrames)])
    idx = find(ex.Trials(ex.j).flip_info(:,4)>0);
    if ~isempty(idx)
        numDroppedFrames = intersect(ex.Trials(ex.j).flip_info(idx,1),ex.Trials(ex.j).Start);
        dF_str = '';
        for n = 1:length(numDroppedFrames)
            idx = find(ex.Trials(ex.j).Start==numDroppedFrames(n));
            dF_str = [dF_str,' ', num2str(idx)];
        end
        disp(['numDroppedFrames: ' num2str(length(numDroppedFrames))])
        disp(['dropped Frames were:' dF_str])
        
    end
end
disp(['       '])


if state == ex.states.BREAKFIX && ex.fix.toDurationAfterFixBreak>0 && ...
        time_breakFixation > ex.fix.freeOfToDuration
    playTone(12000,2,1); %% comment out?
    playRandomLines(ex);
    disp('in timeOut after fixation break')
    t1 = GetSecs;
    myKey = 0;
    while GetSecs-t1<ex.fix.toDurationAfterFixBreak && myKey==0
        if strcmpi(KbName(keyCode),'q');
            myKey=1;
        end
    end
end

%{
% for testing and debugging:
if ex.passOn
    a=rand(1);
    if a>0.5
        state = ex.states.BREAKFIX;
        ex.Trials(ex.j).Reward = 0;
        disp('in Breakfix')
    end
end


% % two-pass for afc experiment
% if isfield(ex.exp,'two_pass') && ex.exp.two_pass
%     if state == ex.states.BREAKFIX
%         fnames = fieldnames(ex.stim.seq2pass);
%         if ex.j<=ex.stim.nseq % we are in the first-pass segment
%             % remove stimulus from the two-pass sequence
%             idx = find(ex.stim.idx_2pass==ex.j);
%             for n = 1:length(fnames)
%                 eval(['ex.stim.seq2pass.' fnames{n} '(idx)=[];']);
%             end
%             ex.stim.idx_2pass(idx) = [];
%             ex.finish = ex.finish-1;  % shorten experiment accordingly
%         else
%             % add trial to the end of the two-pass sequence again
%             for n = 1:length(fnames)
%                 val = eval(['ex.stim.seq2pass.' fnames{n} '(ex.j-ex.stim.nseq);']);
%                 eval(['ex.stim.seq2pass.' fnames{n} '(end+1)=val;']);
%             end
%             ex.stim.idx_2pass(end+1) = ex.stim.idx_2pass(ex.j-ex.stim.nseq);
%
%         end
%     end
% end
%}

% increase trial counter----------------------------------------
ex.j = ex.j+1;


