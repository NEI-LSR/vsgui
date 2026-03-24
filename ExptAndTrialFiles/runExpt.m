function runExpt
% my first function to run an experiment using the DataPixx/PTB (daps) setup
% will need to expand:
% -make gui to do input/experimental control (?), check timing here!!!
%
% history
% 11/11/13: hn written (based on 8/31/13)
% 07/11/14  hn: -included field 'setup' and moved setup parameters into it
%               new parameter name          old parameter name
%               ex.setup.stereo             ex.stereo
%               ex.setup.window             ex.window
%               ex.setup.overlay            ex.overlay
% 09/02/14  hn: included ex.exp.StimPerTrial (option for multiple Stimuli
%               presented per trial)
% 03/08/21  ik: when saving ex file, if it exceeds 2GB, use '-v7.3' flag
% 05/20/24: bt: introduced a variable called "reward type" to
% 03/29/23  ik: added runTrialSCMap() fof SC response field mapping
% 05/20/24: bt: introduced a variable called "reward type" to
% provide control over switching between sequential or
% asymmetric reward types (line 192)
% 05/20/24: bt: switch rewardbias at a specific trial number if reward
% asymmetry (line 219)
% 08/19/24  hn: re-enabled control of stimulus duration during 4-per experiment
% 11/19/24  bt: commented out the fixed ex.fix.Duration when StimPerTrial == 4
% 1/21/25: st: changed names of asymmetry types to stimulusAsymmetry and
% responseAymmetry from "asymmetry" alone
% 01/26/26  hn: modified sglx filename readout; added warning about dir naming
%           convention
% 02/10/26  hn: made packages +eylink and +ephys and moved respective code
%           -sections there
%           -moved loadDailyLog and updateDailyLog to separate functions

global ex
global myhandles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% warning if we use a big reward %%%%%%%%%%
if ex.reward.time > 0.5
    button = questdlg(['do you want to use a large reward: ' ...
        num2str(ex.reward.time) ' ?'],'large reward','yes','no','yes');
    if ~strcmp(button,'yes')
        return
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%% get EPHYS file name if recording %%%%%%%%%%%%%%
if ex.setup.recording
    ex = ephys.startRecording(ex);
    setGuiVariables(myhandles);
end

ex.j = 1;  % trial counter
ex.goodtrial = 0;
ex.changedBlock = 0;  % keeps track of whether we changed blocks

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%  make stimulus/trial sequence
ex = makeSequence(ex);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% if there are several changes of eye position offset (delta x, delta y)
%%% stored from a previous experiment, use only the last one
ex = resetEyeDelta(ex);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% store unique experiment ID
clocktime = fix(clock);
sendStrobes([ex.strobe.FILE_ID,clocktime,ex.strobe.EXPERIMENT_START]);

ex.Header.fileID = clocktime;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% make filename and, if needed, a directory where to store current file
[fname,dirName,trDir] = makeFilenameAndDir(ex);
ex.Header.onlineFileName = fname;
ex.Header.onlineDirName = dirName;

% initialize ex structure-------------------------------------------------
ex.loopcnt =[];
if isfield(ex,'Trials')
    ex = rmfield(ex,'Trials');
end
if isfield(ex,'fileName')
    ex = rmfield(ex,'fileName');
end
ex.nCorrectChoice = 0;
ex.nErrorChoice=0;
ex.nStimFinished = 0;
ex.bigReward = 0;

switchTrials = [];

%%%%%%%%%%%%%%%%%%%%%% open Eyelink edf file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ex = eylink.openEDF(ex,clocktime);

%%%%%%%%%%%%% synchronizes Datapixx and PTB clocks (takes about .5sec) %%%%
PsychDataPixx('GetPreciseTime'); 

% save initial state of ex structure to recover the data in case of a crash
cur_dir = cd (trDir);
save(fname, 'ex');
cd(cur_dir);

% get daily Log (number of trials, number of correct trials)
dailyLog_old = loadDailyLog(dirName); 
dailyLog = {};

% keep track of hte number of trials after a shake for which we scale down
% the rewards after shakes and keep track of the number of
ex.reward.nTrialsAfterShake = inf; % default baseline

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% run Experiment 
while ex.j <= ex.finish && ex.quit~=4
    HideCursor

    dailyLog = updateDailyLog(dailyLog, dailyLog_old, ex, dirName);

    updateGuiLogs(dailyLog);

    [ex,switchTrials] = updateRewardBias(ex,switchTrials,dailyLog);
    
    if ex.quit == 0
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%% run Trial
        resetAdcBuffer(ex);  %% reset AdcBuffer for EyeSignals
        if ex.exp.afc 
            ex = runTrialTask(ex);
            
        elseif ismember(ex.exp.scmap,[1,2])
            ex = runTrialSCMap(ex);

        else 
            ex = runTrialStim(ex);
        end
            
        if ex.setup.recording &&  ex.exp.scmap && ...
                ex.j > ex.exp.StimPerTrial && ...
                ex.Trials(ex.j-ex.exp.StimPerTrial).Reward && ...
                ex.nStimFinished == 0
            tic
            scmap('addTrials');
            etime = toc;
            fprintf('\n\nscmap took %5.4f\n\n',etime);
        end
            
        cur_dir = cd (trDir);
        Trials = ex.Trials(ex.j-1);
        save(['tr' num2str(ex.j-1)],'Trials');
        cd(cur_dir)

        % ----- only keep the last trial to prevent slowdown with number of
        % ----- trials-----------------------------------------------------
        ex = rmfield(ex,'Trials');
        ex.Trials(ex.j-1) = Trials;
        % ---------------------------------------------------------------
    elseif ex.quit ==1
        disp('in pause')
        cur_dir = cd (trDir);
        Trials = ex.Trials(ex.j-1);
        save(['tr' num2str(ex.j-1)],'Trials')
        cd(cur_dir)
        playRandomLines(ex);
        keyboard
        ex.quit = 0;
        ShowCursor

    elseif ex.quit ==2
        disp('in pause with timeout')
        if ex.setup.stereo.Display
            % right eye
            Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
            Screen('FillRect',ex.setup.window,0);  % black background
            % Select left-eye image buffer for drawing:
            Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
            % Draw left stim:
            Screen('FillRect',ex.setup.window,0);  % black background
        else
            % black screen
            Screen('FillRect', ex.setup.overlay,ex.idx.black);
        end
        Screen('Flip', ex.setup.window);

        cur_dir = cd (trDir);
        Trials = ex.Trials(ex.j-1);
        save(['tr' num2str(ex.j-1)],'Trials')
        cd(cur_dir)
        
        keyboard
        ex.quit = 0;
        ShowCursor
    end
end
ex.quit = 0;

playRandomLines(ex);

% signal end of experiment
sendStrobe(ex.strobe.EXPERIMENT_END);

% update daily Log
dailyLog = updateDailyLog(dailyLog, dailyLog_old, ex, dirName);

updateGuiLogs(dailyLog);

% close edf file
eylink.closeEDF;

%%% restore the full ex-file ----------------------------------------------
 cur_dir = cd (trDir);
 ex = rmfield(ex,'Trials');
 ex = rescueFile('parentStruct',ex,'trialDir',trDir);
 cd(cur_dir)


% store additional information
% get GetSecs timestamps remapped onto Datapixx TrialStart and TrialEnd
TrStartDP = [ex.Trials.TrialStartDatapixx];
TrEndDP = [ex.Trials.TrialEndDatapixx];
[tgetsecs, sd, ratio] = PsychDataPixx('BoxsecsToGetsecs',[TrStartDP,TrEndDP]);
TrStartgetsecs = tgetsecs(1:length(TrStartDP));
TrEndgetsecs = tgetsecs(length(TrStartDP)+1:end);
for n = 1:length(TrStartDP)
    ex.Trials(n).TrialStart_remappedGetSecs = TrStartgetsecs(n);
    ex.Trials(n).TrialEnd_remappedGetSecs = TrEndgetsecs(n);
end
ex.times.remappingSD = sd;
ex.times.PTBvsDatapixxClockRatio = ratio;


% make sure to switch off fixed Seed if it was turned on
if isfield(ex.stim.vals,'fixedSeed')
    ex.stim.vals.fixedSeed = false;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%% save file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cur_dir = cd(ex.Header.onlineDirName);
ex.Header.onlineFileName = fname;
disp('saving...')

% 2021.03.08 ik: check the size of ex, if it exceeds 2GB, use '-v7.3' flag
whosEx = whos('ex');
if whosEx.bytes < 1e+9
    save(fname, 'ex');
else
    save(fname,'ex','-v7.3');
end
cd(cur_dir);

%%%%%%%%%%%%%%%%%%%%%%%%%% put EPHYS in standby %%%%%%%%%%%%%%%%%%%%%%%%%%%
if ex.setup.recording
    ephys.stopRecording(ex.setup.ephys,ex.setup.(ex.setup.ephys));
end

%%%%%%%%%%%%%%%%%%%%%%%%%% copy edf file to data folder %%%%%%%%%%%%%%%%%%%
eylink.copyEDF(ex,fname,dirName);

%playRandomLines(ex); % hn: I don't think we need this but kept here to
%                           check

%%%%%%%%%%%%%%%%%%%%%%%%%% remove temporary trial folder %%%%%%%%%%%%%%%%%%
cur_dir = cd(trDir);
delete('*.mat');
a = dir;
cd(cur_dir);
subDirs = 0;
for n = 1:length(a)
    if a(n).isdir && a(n).bytes>0
        subDirs = 1;
        break
    end
end

if ~subDirs
    rmdir(trDir);
else
    warndlg(['Trial directory contains subdirectories:' ...
        'there is likely a bug, check!']);
end

ShowCursor;