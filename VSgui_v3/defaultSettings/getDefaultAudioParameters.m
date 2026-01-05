function audio = getDefaultAudioParameters
% function audio = getDefaultAudioParameters
% here we define the default audio parameters for auditory feedback.
%
% These definitions were previously included in 'getDefaultSettings.m' but
% I moved them here for better readability of the code.
% This function is called by 'getDefaultSettings.m'.
% audio parameters are stored in ex.setup.audio.XX

% history
% 08/15/25  hn: wrote it

audio.bigRewardLoops = 1; % duration
audio.bigRewardFreq = 60000; % frequency of tone
audio.errorLoops = 1; % duration
audio.errorFreq = 15000; % frequency of tone
audio.errordB = 0.6; % frequency of tone
audio.rewardLoops = 1; % duration
audio.rewardFreq = 36000; % frequency of tone
audio.rewarddB = 0.3; % frequency of tone