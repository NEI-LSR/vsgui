function synch = synchParameters(idx)
% function synch = synchParameters
%
% +default.synchParameters
%
% here we define the default parameters for the synch pulse for the
% photodior when VS is started.
%
% These definitions were previously included in 'getDefaultSettings.m' but
% I moved them here for better readability of the code.
% This function is called by '+default.getSettings.m'.
% Parameters are stored in ex.synch.XX

% history
% 08/18/25  hn: wrote it; 
% 02/13/26  hn: moved it to +default package

%%  synch pulse for photodiode (white point in top right corner of screen)
synch.PSz = 20; % use an even number
synch.Col = idx.white;
%%
