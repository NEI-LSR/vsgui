function fix = getDefaultFixationParameters
% function fix = getDefaultFixationParameters
%
% +default.fixationParameters
% 
% here we define the default parameters for the animals' fixation
% requirements.
%
% These definitions were previously included in 'getDefaultSettings.m' but
% I moved them here for better readability of the code.
% This function is called by 'getDefaultSettings.m'.
% state definitions are stored in ex.fix.XX

% history
% 08/15/25  hn: wrote it
% 02/13/26  hn: moved to package +default

% fixation parameters
fix.duration = 2;
fix.preStimDuration = 0;
fix.stimDuration = 2;
fix.waitstop = 5;
fix.freeduration = 0; % pre-FP duration
fix.WinW = 60;  % fixation window width in pixels
fix.WinH = 60;  % fixation window hight in pixels
fix.PSz = 7;  % fix point size
fix.duration_forEarlyReward = [2.1 3.7] ;
fix.toDurationAfterFixBreak = 0;
fix.fixCross = false;
fix.lineWidth = 5;
fix.searchW = 200; % search window width for freeViewing=2 in pixels
fix.searchH = 200; % search window height for freeViewing=2 in pixels
fix.SSz = 46; %deg2pixel(2,setup); % surround of the fixation
