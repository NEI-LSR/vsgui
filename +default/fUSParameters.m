function fUS = fUSParameters
% function fUS = fUSParameters
%
% +default.fUSParameters
%
% here we define the default parameters for the synch pulse for the
% photodior when VS is started.
%
% These definitions were previously included in 'getDefaultSettings.m' but
% I moved them here for better readability of the code.
% This function is called by '+default.getSettings.m'.
% Parameters are stored in ex.setup.fUS.XX

% history
% 08/18/25  hn: wrote it; 
% 02/13/26  hn: moved it to +default package

%%  default values for fUS Trigger
fUS.flag = false;
fUS.triggerOnsetLag = 0;  % relative to stimulus onset
fUS.triggerDuration = 0.1; % 100ms pulse (should not matter exactly remain fixed)