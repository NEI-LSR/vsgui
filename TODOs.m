% list of TODOs for VisStim toolbox
%   11/16/16
%   -include reminder for filters when presenting monocular or disparity
%   stimuli
%   -include uncorrelated RDS
%   -gamma correction for rig 2
%   -update grid position: DONE
%   -repeat seeds for DXxDC: DONE but needs checking; checked
%   -fixed seeds for 100% correlated RDS: DONE
%
%   10/31/23
%   -replace gui by appdesigner

% 10/03/24:
% runExpt
% -line 148: stimDuration needs to be revisited; DONE (11/19/2024)
% -line 197: remove the default reward type and move it to setdefaults
% instead; DONE (11/19/24)
% -line 300: ex.quit == 3 seems to be redundant, as it is the same as
% ex.quit==2; DONE (11/19/24)

% runTrialTask:
% -line 185: targOn_delay in the gui: check if it is a range then pick a 
% random value from the range, if it is a scalar then fix this. Avoid adding
% randomisation in the stimulus script
% -Also check if targOn_delay is a stimulus value or an experimental value 
% and implement this accordingly; DONE (11/19/24)
% -line 488: remove ex.targ.go_delay
% -line 806: reward asymmetry should be generalised to account for non-stimulus
% values; DONE (11/19/24)
% -line 843: include parameters for the error tone in the setup file instead
% of in the script; DONE (11/19/24)
% -lines 908: times should be times in the experiment- not the timing 
% information set by the experimenter; DONE (11/19/24)

% runTrialStim_new (runTrialStim_mergeB1A19):
% -line 108: have a general variable for length and breadth of fixation
% cross, in a different top level script; DONE (11/19/2024)
% -line 307: parameterise xlimInPixels and ylimINPixels in a different
% script, and use runtrialstim only to run the script; DONE (11/19/2024)
% -lines 1221-1222: double check if we need to save x0 and y0 on every
% trial, or deal with it in a better way; DONE (11/19/2024)
% -line 1049: remove bsolute value for trial_duration; DONE (11/19/2024)

% General:
% -Fixing X & Y eye signals: ex.Trials.eye.v values are flipped between
% left and right; DONE

% 11/19/2024:
% - remove ex.targ.freeduration
% - remove correction loop when using reward asymmetry bias
% -remove tocs? (runTrialTask & runTrialStim)
% -revert to ex.fix.duration instead of having a relative value to have 
% consistency with runTrialStim_new: so, new fixation duration in the gui =
% stim + target_on + fix_dur; ASSIGNED TO BT
% -line 276: check why prestimDuration=0; dont want fixation duration to be
% extended by prestimDuration; runTrialStim; ASSIGNED TO IK
% -Change everything from pixels to degrees: pixels flips the y-axis;
% ASSIGNED TO CZ
% -Fix setUp code- it is very messy now; ASSIGNED TO HN; DONE
% add y_offset for target icons in the gui
% replace GUI by APPDESIGNER: assigned to BT/IK
% have an explainer sheet for variables: assigned to ST
% - make default settings folder; DONE


% 12/02/2024:
% read spikes in trial for SGLX: assigned to BT
% read LFP in trial for SGLX: assigned to BT
% plotTC for SGLX: assigned to BT
% check interference of pausing for SGLX communication with running
% trial/task: BT/HN
% mimic testFiles/Trellis for SGLX: BT
% make userInput version for NPP in getDefaultProbeSettings: BT
% use listdlg to include single electrodes into the dialog box in
% getDefaultProbeSettings: BT/HN
% remove ex.setup.leftHemisphereRecorded from gui as it is now obsolete, and redesign gui:
% BT/HN
% move probe specification values for grapevine also to userInput: HN
% change synch pos values for neiRigB: ST
% integrate changes from dome to new vsgui: LC/CZ/HN
% Add giveDualReward code inside giveREward: ST/BT
% Replace all manual / "deg2pixel" to "deg2pixelFlex"
% modifyt drawOverlayHelperLines similarly to overlayFrames
% all positions specified in degrees: HN
%   -eye calibration files
%   -stimulus files
%   -check eye
%   -targ.WinH/ WinW, fix.WinH/WinW
%   -extras.rfW/ rfH, also in drawOverlayFrames
%   
% reduce the number of eye calibration files, and clean up final version: HN & CMZ
% merge eye calibration file types: HN
% fix the reward strobe/ don't hard-code the delay for sendStrobes: HN
