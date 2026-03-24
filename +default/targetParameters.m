function targ = targetParameters(ex)
% function targ = targetParameters(ex)
%
% +default.targetParameters(ex)
%
% here we define the default parameters for the animals' fixation
% requirements.
%
% These definitions were previously included in 'getDefaultSettings.m' but
% I moved them here for better readability of the code.
% This function is called by 'getDefaultSettings.m'.
% state definitions are stored in ex.targ.XX

% history
% 08/15/25  hn: wrote it
% 12/02/25  hackathon: added targ.FB_delay
% 02/13/26  hn: moved to package +default

targ.duration = 2;
targ.freeduration = 0; 
targ.icon.type='rds';
targ.WinW = 100;  % target window width in pixels
targ.WinH = 100;  % target window hight in pixels
targ.PSz = 8;  % targ point size
targ.Pos = [ 0 180;  0 -180];  % targ position in pixels relative to fixation point 
targ.T1Col = ex.idx.white;  %correct targ color
targ.T2Col = ex.idx.white; % error target color
targ.go_delay = 0.05; % delay until monkey can choose a target
targ.RT_delay = 0;  % if one wants to include a delay to prevent early choices
targ.FB_delay = 0.3; % time for which subject has to fixate before target reappears in MGS task
targ.fixOnDuringDelay = true; % fixation point is on during tagrte onset delay
targ.hold = .1;
targ.icon.sz = 2.2; % center size of target icon
targ.icon.ssz = 3; % surround size of target icon

targ.icon.T1co = 1;
targ.icon.T2co = 1;
targ.icon.T1co2 = 0;  % target contrast during stimulus presentation
targ.icon.T2co2 = 0; 
targ.icon.hdx = 0.2;
targ.icon.rampDur = 0;