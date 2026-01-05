function [ex] = runTrialSCMap(ex)
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
% 11/19/24  bt: removed time out with 'o' (ex.quit == 3)
% 08/25/2025 ST: Catching Scanning strategy in memory guided saccade task.
%               Subject was originally given unlimited time to respond in response
%               time period barring early response. Now, we return an error if subject 
%               takes too much time. (line 488)

% ex.exp.scmap = 1      memory-guided saccade
% ex.exp.scmap = 2      delayed saccade
% 

ttime = GetSecs;

% add a flag for the completed sequence, ik, 3.29.2023
if ex.j == 1
    % remove (0,0)
    idx = ex.stim.seq.Tx == 0 & ex.stim.seq.Ty == 0;
    ex.stim.seq.st(idx) = [];
    ex.stim.seq.me(idx) = [];
    ex.stim.seq.Tx(idx) = [];
    ex.stim.seq.Ty(idx) = [];
    
    ex.stim.completed = false(1,length(ex.stim.seq.Tx));
    % this is not assigned during makeSequence()
    ex.stim.nseq = length(ex.stim.seq.Tx);
    ex.finish = ex.stim.nseq;
end

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

    
% point for photodiode synch pulse 
spPos = ex.synch.Pos;
spSz = ex.synch.PSz;
spCol = ex.synch.Col;

% initial color assignments
fpWinCol = ex.idx.bg;
fpCol = ex.idx.bg;
t1Col = ex.idx.bg;
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
time_targReOn = NaN;
time_targReOff = NaN;

% target and stimulus variables
goodTPos = 1;
good_targ = 1;
good_resp = 1;


% set the values of the timing variables
% use a local variable for the variable timing 
% set maximum allowed latency
if ~isfield(ex.targ,'waitstop')
    ex.targ.waitstop = 0.5;
end

% set targOn_delay if undefined
if ~isfield(ex.stim.vals,'targOn_delay') || any(isnan(ex.stim.vals.targOn_delay))
    ex.stim.vals.targOn_delay = [0.75, 1];
end

% initialize trial variables
targ = ex.targ;

targOn_delay = ex.stim.vals.targOn_delay;
% DETERMINE TARGET ONSET IF IT IS BEING VARIED ---------------------------
if isfield(ex.stim.seq,'targOn_delay')
    targOn_delay = ex.stim.seq.targOn_delay(ex.j);
end
%}
if length(targOn_delay) == 2
   targOn_delay = targOn_delay(1) + diff(targOn_delay)*rand(1);  
end

if length(targ.go_delay) == 2
   targ.go_delay = targ.go_delay(1) + diff(targ.go_delay)*rand(1);  
end    

if length(targ.hold) == 2
   targ.hold = targ.hold(1) + diff(targ.hold)*rand(1);  
end    

targOn_flag = 0 ; % boolean to signal when targets get switched on/off
targetHasPresented = 0;

centerEye_t0 = GetSecs; % hack to prevent several re-centerings of eye position per key-press

% pre-allocate memory; initialize variables
frametimestep = 1/ex.setup.refreshRate;
eyetimestep = 1/ex.setup.adc.Rate;  % 500Hz is the fastest Eyelink sample binocularly

maxTrialDur = ex.fix.waitstop + ex.fix.freeduration + targOn_delay + ...
    targ.go_delay + ex.targ.waitstop + targ.hold;

% timing information on PTB display
flip_info = NaN(ceil(maxTrialDur*ex.setup.refreshRate),4); %[VBLTimestamp StimulusOnsetTime FlipTimestamp Missed]

%initialize eye structure
trEye.v = NaN(length(ex.setup.adc.Channels),ceil(maxTrialDur*ex.setup.adc.Rate)); % pre-allocate memory
trEye.t = NaN(1,ceil(maxTrialDur*ex.setup.adc.Rate));
trEye.n = 0; % nAcquiredFrames
trEye.sacc = [];

pass_eye = 0;
if isempty(ex.eyeCal.LXPos) 
    lastEyePos = [0 0];
else
    lastEyePos = [0 0; 0 0];
end

[x,y] = GetMouse;
mousePos = [x+ex.setup.mouseXOffset,y];
first_choice = 0;
tchosen = 0;
RewardSize = 0;
lasteyepostime = 0;
lastframet = 0;
ex.loopcnt(ex.j) = 0;
earlyReward_start = 0;
earlyReward_on = 0;
earlyReward_cnt = 0;
duration_forEarlyReward = ex.fix.duration_forEarlyReward(1);

% iknew - 3.28.2023
% select target position from ex.stim.seq
iseq = find(~ex.stim.completed);
iseq = iseq(randperm(length(iseq),1));
xDeg = ex.stim.seq.Tx(iseq);
yDeg = ex.stim.seq.Ty(iseq);

xPixels = round(ex.setup.viewingDistance * tand(xDeg) * ...
    ex.setup.screenRect(3)/ex.setup.monitorWidth);
yPixels = round(ex.setup.viewingDistance * tand(yDeg) * ...
    ex.setup.screenRect(3)/ex.setup.monitorWidth);

targ.Pos = [xPixels,yPixels];


% MAKE STIMULUS AND REFRESH BACKGROUND-----------------------------------
ex = makeStimulus(ex);  
%StimStart = NaN*ones(1,ceil(ex.setup.refreshRate*ex.fix.stimDuration));
StimStart = [];

% overdrive stimulus parameters set by makeStimulus
ex.Trials(ex.j).Tx = xDeg;
ex.Trials(ex.j).Ty = yDeg;


% DETERMINE TARGET ICON BELONGING TO THE CORRECT RESPONSE ----------------
good_resp = 1;

% tag.Pos should be 1 X 2 
goodTPos = targ.Pos;


% DRAW OVERLAY ITEMS THAT ARE FIXED DURING THE TRIAL --------------------
% (RF, FP frame, helper lines, correct target, if needed) 
% if we have stored lines to orient the experimenter (e.g. RF borders), RF
% position, fixation window, correct target window, draw
% these first to avoid taking time from the stimulus drawing
drawOverlayHelperLines(ex);
drawOverlayFrames(ex,goodTPos);


% fixed pre-stim ITI 
preITI = 0;
if isfield(ex.exp,'fixedPreITIDur')
    preITI = ex.exp.fixedPreITIDur;
    WaitSecs(preITI - (GetSecs - ttime));
end

% -----------------------------------------------------------------------
% TRIAL START
% ------------------------------------------------------------------------
% use clock time as unique trial ID
% clocktime: 1x6 vector: year month day hour(1:2) min sec
clocktime = fix(clock); % send strobe of this to rppl for trial identification
% we store both the unique trial ID and the trial number in the ripple file
% This might be overkill and we can remove unique trial ID in the future.

% flush ports (not sure that this is needed)
Datapixx('GetTime');
Eyelink('TrackerTime');

% get trial start times for different clocks.  We use tocs to get an
% estimate for the maximal mismatch between clocks.  The mismatch between
% Eyelink and Datapixx should be <1ms (as evaluated using tocs).  
% Ripple and Datapixx are synchronized via the Trial_start strobe.
% PTB and Datapixx synchronization is done at the end of the experiment
% using PsychDataPixx('BoxsecsToGetsecs',[TrStartDP,TrEndDP]);
tic
tocBEFORESTROBES = toc;
sendStrobes([ex.strobe.TRIAL_ID,clocktime,ex.strobe.TRIAL_NUMBER,ex.j]);  
tocSENDSTROBES = toc;
trstart_Eyelink = Eyelink('TrackerTime');  
toc_trstartEYELINK = toc;
trstart = GetSecs;  % start of trial time
toc_trstartGETSECS = toc;

% this synchronizes the ripple and the datapixx clocks
maxTrial = 5;
trstart_Datapixx = [];
nAttempts = 0;
while isempty(trstart_Datapixx) && nAttempts < maxTrial
    disp('before sendStrobe')
    sendStrobe(ex.strobe.TRIAL_START);
    toc_trstartSENDSTROBE = toc;
    % get time stamp of when ex.strobe.TRIAL_START was sent to ripple
    disp('before getDatapixxDin')
    [~,~,trstart_Datapixx] = getDatapixxDin(ex.strobe.TRIAL_START);
    nAttempts = nAttempts + 1;
end


ttime = GetSecs-trstart; %  trial time

state = 0;
if ttime > 0
    stayInLoop = true;
end

while stayInLoop && ex.quit == 0
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
    
    if state == ex.states.FPON
        if ttime <= ex.fix.waitstop && pass_eye
            time_startFixation = GetSecs - trstart;
            sendStrobe(ex.strobe.FIXATION_START)
            state = ex.states.FPHOLD;
            disp('in fixation acquired');
        end
        if ttime > ex.fix.waitstop && ~pass_eye
            state = ex.states.NOFIX;
            time_breakFixation = GetSecs - trstart;
            stayInLoop = false;
            disp('in no fixation acquired');
        end
    end
    
    % HOLD FIXATION ----------------------------------------------------- 
    if state == ex.states.FPHOLD
        if pass_eye
            if ttime > time_startFixation + targOn_delay
                
                if ~targOn_flag && ~targetHasPresented
                    time_targOn = GetSecs-trstart;
                end
                targOn_flag = 1;
                t1Col = ex.idx.white;
                
                if ttime > time_targOn + targ.go_delay
                    state = ex.states.GO;
                    fpCol = ex.idx.bg;  % FP off
                    fpWinCol = ex.idx.bg;
                    time_fpOff = GetSecs-trstart;
                end
                
                if ex.exp.scmap == 1 && targOn_flag && ...
                        ttime > time_targOn + targ.duration
                    targOn_flag = 0;
                    t1Col = ex.idx.bg;
                    if ~targetHasPresented
                        time_targOff = GetSecs - trstart;
                        disp('Time Off!!!')
                    end
                    targetHasPresented = true;
                end
            end
        else 
            state = ex.states.BREAKFIX;
            disp('in breakfix');
            time_breakFixation = GetSecs - trstart;
            stayInLoop = false;
        end
    end
    
    % pass_eye - within fixation window
    % tchosen - within target windows
    % BEFORE CHOICE ------------------------------------------------------
    if state == ex.states.GO
        if any(tchosen)
            if ttime < time_fpOff + targ.RT_delay
                state = ex.states.BREAKFIX;
                time_breakFixation = GetSecs - trstart;
                stayInLoop = false;
                disp('early response')
            else
                state = ex.states.CHOICE;
                first_choice = find(tchosen);  % initial target choice
                time_choice = GetSecs-trstart;
                disp('in choice')
                fprintf('\n RT = %5.1f ms\n\n',(time_choice - time_fpOff)*1000);
            end
        else
            if ttime > time_fpOff + targ.waitstop
                state = ex.states.NOCHOICEMADE;
                time_noChoiceMade = GetSecs - trstart;
                t1Col = ex.idx.bg;
                targOn_flag = 0;
                stayInLoop = false;
                disp('no choice made')
            end
        end
    end
    
    % ACCEPT CHOICE IF TARGET IS HELD LONG ENOUGH AND CHOICE NOT SWITCHED--
    if state == ex.states.CHOICE && sum(tchosen)
        
        if ttime > time_choice + targ.FB_delay % amount of time to wait before giving kiwi feedback
            if ex.exp.scmap == 1 && ~targOn_flag % turn the target on again for memory-guided saccade
                t1Col = ex.idx.white;
                targOn_flag = 1;
                time_targReOn = GetSecs-trstart;
            end
        end
        
        if ttime > time_choice + targ.hold
            
            % did monkey switch choice?
            if find(tchosen) == first_choice
                % REWARD  if correct target was chosen
                if find(tchosen) == find(good_targ)
                    disp('in reward')
                    state = ex.states.REWARD;
                else
                    state = ex.states.ERROR;
                    disp('in error')
                end
            else
                state = ex.states.SWITCHCHOICE;
                time_switchChoice = GetSecs - trstart;
            end
            
            if ex.exp.scmap == 1
                time_targReOff = GetSecs - trstart;
            else
                time_targOff = GetSecs - trstart;
            end
            
            targOn_flag = 0;
            t1Col = ex.idx.bg;
            stayInLoop = false;
        end
    elseif state == ex.states.CHOICE && ~sum(tchosen) ...
            && (ttime > (time_choice + targ.hold))
        % 08/25/2025 ST attempting to correct for strategy that Kiwi
        % scans across screen in search for target in reporting time.
        state = ex.states.ERROR;
        disp('did not maintain fixation on target window')
  
        stayInLoop = false;
        
    end

    %---------------------------------------------------------------------
    % END STATE CHANGES --------------------------------------------------
    %---------------------------------------------------------------------    
    
    % update eye position (fast)
    ttime = GetSecs-trstart;
    if ttime > lasteyepostime + eyetimestep 
        if state== ex.states.GO || state == ex.states.CHOICE
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
        Datapixx('SetDoutValues',1);
        Datapixx('RegWr');
        earlyReward_start = 0;
        earlyReward_on = 1;
    end
    if earlyReward_on && ttime > time_earlyReward(earlyReward_cnt) + ex.reward.earlyRewardTime*ex.reward.scale
        Datapixx('SetDoutValues',0);
        Datapixx('RegWr');   
        earlyReward_on = 0;
    end

    
    % update frame stuff (slow)
    ttime = GetSecs-trstart;
    if ttime > lastframet + frametimestep -0
        
        % refresh screen
        
        %Prepare single screen call for all onscreen dots ( fp, target)
        if isempty(ex.eyeCal.LXPos) %monocular eye position
            olPos = [lastEyePos;mousePos]; % eye pos; mouse pos
                  
        else %overlay dot positions: binocular eye positions; mouse
            olPos = [lastEyePos; 
                   mean(lastEyePos,1); ... % mean R/L eye position; 
                   mousePos]; % mouse positions
        end
        
        dotPos =  [fpPos;...
            targ.Pos + fpPos];   % error target(s)
        dotSz =  [fpSz;  ...
                 ex.targ.PSz*ones(size(targ.Pos,1),1)];
        dotCol =  [fpCol*ones(1,3); ...
                  t1Col*ones(1,3)];

              
        % draw eye dots
        Screen('Drawdots',ex.setup.overlay,olPos',olPSz',olColBinoc');
        
        %%% draw FP,target and eye dots
        if ~ex.setup.stereo.Display
            Screen('Drawdots',ex.setup.overlay,dotPos',dotSz',dotCol');
        else
            % draw right eye image
            Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
            Screen('Drawdots',ex.setup.window,dotPos',dotSz',dotCol');
            % draw left eye image
            Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
            Screen('Drawdots',ex.setup.window,dotPos',dotSz',dotCol');
        end
        
        if targOn_flag
            Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
            Screen('Drawdots',ex.setup.window,spPos,spSz,spCol);
            
            Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
            Screen('Drawdots',ex.setup.window,spPos,spSz,spCol);
        end

            
        %tic
        Screen('DrawingFinished', ex.setup.window);
        [flip_info(fi,1), flip_info(fi,2), flip_info(fi,3), ...
            flip_info(fi,4)] = Screen('Flip', ex.setup.window);
        %temptime = Screen('Flip', ex.setup.window,GetSecs);

        %temptime = 0;  % ?? why this?
        %lastframet = temptime-trstart;
        %{
        if state == ex.states.FPHOLD && stimOn_flag
            StimStart(si) = flip_info(fi,1);
        end
        %}
        
        lastframet = 0;
        fi = fi+1;
    end

     
    ex.loopcnt(ex.j) = ex.loopcnt(ex.j)+1;
    
    ttime = GetSecs-trstart;
    
    % mouse input
    %tic
    [x,y] = GetMouse;
    mousePos = [x+ex.setup.mouseXOffset,y];

    %{
     % if mouse button is pressed, use new x,y positions for stimulus
     if  sum(b)>0
         ex.stim.vals.x0 = (x+ex.setup.mouseXOffset-ex.fix.PCtr(1))*dpp;
         ex.stim.vals.y0 = (y-ex.fix.PCtr(2))*dpp;
     end

    %}
    
    % keyboard
    [keyIsDown, ~, keyCode] = KbCheck; % MAGIC NUMBER
    if keyIsDown
        kb = lower(KbName(keyCode));
        if length(kb) == 1
            switch kb
                case 'q'
                    ex.quit = 4;
                case 'p'    %% pause with gray screen
                    ex.quit = 1;
                    ex.Trials(ex.j).pa = 1;
                case 's'    %% sleep ON
                    ex=sendSleepStrobe(ex,ex.strobe.SLEEP_ON);
                case 'f'    %% sleep OFF
                    ex=sendSleepStrobe(ex,ex.strobe.SLEEP_OFF);
                case 'd'    %% decrease Reward
                    ex.Trials(ex.j).dR = 1;
                    ex.reward.scale = ex.reward.scaleStepSize;
                    disp('DECREASE REWARD')
                case 'i'    %% additional InstructionTrials
                    ex.Trials(ex.j).additionalInstructionTrials = 1;
                    ex.exp.addInstructionTrials = 1;
                    ex.exp.countAddInstructionTrials = -1;
                    disp('ADDITIONAL INSTRUCTION TRIALS')
                case 't'    %% pause with black screen (timeout)
                    ex.nCorrectChoice = 0;
                    ex.quit = 2;
                    ex.Trials(ex.j).to=1;
            end
            
        else
            % center Eye when 'x' and 'y' are pressed
            if all(contains(kb,{'x','z'}))
                % to make sure we only re-center once per keyboard press
                if GetSecs - centerEye_t0 > .5
                    ex=centerEye(ex);
                    disp(['eye recentering #: ' num2str(ex.eyeCal.Delta(1).cnt)])
                    centerEye_t0 = GetSecs;
                end
            end
        end
    end
    
end
% ------------------------------------------------------------------------
% done with while loop ---------------------------------------------------
% ------------------------------------------------------------------------
% 11/23/15: I now move the rewards out of the while loop
% give feedback (exact timing is less crucial now)
if state== ex.states.REWARD
    disp('in reward')
    ex.nCorrectChoice = ex.nCorrectChoice+1;
    RewardSize = ex.reward.time;
    if ex.reward.includeBigReward
        if ex.nCorrectChoice>4
            RewardSize = ex.reward.time*8;
        elseif ex.nCorrectChoice>3
            RewardSize = ex.reward.time*2;
        elseif ex.nCorrectChoice>2
            RewardSize = ex.reward.time;
        end
    end
    
    if ex.reward.scale <1
        RewardSize = ex.reward.time*ex.reward.scale;
    end
    playTone
    time_reward = GetSecs - trstart;
    giveReward(RewardSize);
    time_rewardGiven = GetSecs - trstart;
    
elseif state== ex.states.ERROR
    playNoise
    time_error = GetSecs - trstart;
    ex.nCorrectChoice = 0;
    if isfield(ex.reward,'pauseAfterError')
        pause(ex.reward.pauseAfterError);
    end

    disp('in ERROR')  
end

Datapixx('GetTime');
Eyelink('TrackerTime');

tocTREND_beforeEyelink = toc; 
trEnd_Eyelink = Eyelink('TrackerTime');
tocTREND_EYELINK = toc;
trEnd = GetSecs;  % end of trial time
tocTREND_GETSECS = toc;
sendStrobe(ex.strobe.TRIAL_END)
tocTREND_SENDSTROBE = toc;
[~,~,trEnd_Datapixx] = getDatapixxDin(ex.strobe.TRIAL_END);

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
ex.Trials(ex.j).times.targReOn = time_targReOn + trstart;
ex.Trials(ex.j).times.targReOff = time_targReOff + trstart;
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
if state == ex.states.REWARD
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

if good == 1
    % count in completed stimulus sequence, ik, 2023.03.31
    ex.stim.completed(iseq) = true;

    % number of successfully completed trials:
    ex.goodtrial = ex.goodtrial + 1; 
else
    % add one more trial to finish
    ex.finish = ex.finish + 1;
end


RespDir = NaN;
if any(tchosen)
    RespDir = find(tchosen);
end
ex.Trials(ex.j).RespDir = RespDir;  % 1: lower target; 2: upper target
ex.Trials(ex.j).Reward = good;
ex.Trials(ex.j).RewardSize = RewardSize;


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
tocs_beforeLastEyeReading = toc;
time_beforeLastEyeReadingDatapixx = Datapixx('GetTime');  % to match up the Datapixx clock and the PTB clock
time_beforeLastEyeReading = GetSecs - trstart;
[pass_eye,trEye] = checkEye(trEye,ex,[],pass_eye,lastEyePos,tchosen);
time_lastEyeReading = GetSecs-trstart;
Datapixx('SetMarker');
time_lastEyeReadingpostMarker = GetSecs - trstart;
Datapixx('RegWr');
Datapixx('RegWrRd')
time_lastEyeReadingDatapixx = Datapixx('GetMarker');  % to match up the Datapixx clock and the PTB clock

tocsLASTEYEREADING = toc;
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


% save trial tocs
ex.Trials(ex.j).tocs.lastEyeReading = tocsLASTEYEREADING -tocs_beforeLastEyeReading;
ex.Trials(ex.j).tocs.trstart_sendStrobes = tocSENDSTROBES - tocBEFORESTROBES;
ex.Trials(ex.j).tocs.trstart_eyelink = toc_trstartEYELINK - tocSENDSTROBES;
ex.Trials(ex.j).tocs.trstart_getSecs = toc_trstartGETSECS - toc_trstartEYELINK;
%ex.Trials(ex.j).tocs.trstart_datapixx = toc_trstartDATAPIXX-toc_trstartGETSECS; % obsolete
ex.Trials(ex.j).tocs.trstart_sendStrobe = toc_trstartSENDSTROBE - toc_trstartGETSECS;

ex.Trials(ex.j).tocs.trend_eyelink = tocTREND_EYELINK - tocTREND_beforeEyelink ;
ex.Trials(ex.j).tocs.trend_getSecs = tocTREND_GETSECS - tocTREND_EYELINK;
% ex.Trials(ex.j).tocs.trend_datapixx = tocTREND_DATAPIXX-tocTREND_GETSECS; % obsolete
ex.Trials(ex.j).tocs.trend_sendStrobe = tocTREND_SENDSTROBE-tocTREND_GETSECS;


ex.Trials(ex.j).tocs.abs.lastEyeReading = tocsLASTEYEREADING ;
ex.Trials(ex.j).tocs.abs.trstart_sendStrobes = tocSENDSTROBES ;
ex.Trials(ex.j).tocs.abs.trstart_eyelink = toc_trstartEYELINK ;
%ex.Trials(ex.j).tocs.abs.trstart_datapixx = toc_trstartDATAPIXX;
ex.Trials(ex.j).tocs.abs.trstart_getSecs = toc_trstartGETSECS ;
ex.Trials(ex.j).tocs.abs.trstart_sendStrobe = toc_trstartSENDSTROBE ;
ex.Trials(ex.j).tocs.abs.trend_eyelink = tocTREND_EYELINK ;
%ex.Trials(ex.j).tocs.abs.trend_datapixx = tocTREND_DATAPIXX;
ex.Trials(ex.j).tocs.abs.trend_getSecs = tocTREND_GETSECS ;
ex.Trials(ex.j).tocs.abs.trend_sendStrobe = tocTREND_SENDSTROBE;

ex.Trials(ex.j).preIti = preITI;


% read in spikes, LFP and electrode depth if we are recording
if ex.setup.recording
    if eval(['ex.setup.' ex.setup.ephys '.readOnlineSpikes==true'])
        ex=readSpksInTrial(ex);
    end
    
    %store electrode depth 
    %h = ServoDrive;
    h = get(findobj('tag','Servo Drive','Type','figure'),'UserData');
    if isfield(h,'position')
        ex.Trials(ex.j).ed = h.position;
    end
    
    % read out LFP only for multi-channel recordings
    if eval(['ex.setup.' ex.setup.ephys '.readLFP==true'])
        ex = readLFPInTrial(ex);
    end
    
    % make data array for Rich's SC mapping GUI
    %ex = make_ts(ex);
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
        if strcmpi(KbName(keyCode),'q')
            myKey=1;
        end
    end
end


fprintf('\n\n X = %d, Y = %d\n\n',ex.Trials(ex.j).Tx,-1*ex.Trials(ex.j).Ty)

%}
% increase trial counter----------------------------------------
ex.j = ex.j+1;

    
    
    
    
    


