function reward = getDefaultRewardParameters
% function reward = getDefaultRewardParameters
% here we define the default reward parameters .
%
% These definitions were previously included in 'getDefaultSettings.m' but
% I moved them here for better readability of the code.
% This function is called by 'getDefaultSettings.m'.
% reward parameters are stored in ex.reward.XX

% history
% 08/15/25  hn: wrote it


reward.time = 0.15;
reward.earlyRewardTime = 0.08;
reward.includeBigReward = 1;
reward.juice_proportion = NaN; % accommodating Bharath's changes
reward.scale = 1;  % scales the reward size down following shakes
reward.nTrialsAfterShake = inf; % counter to check how many trials back the monkey was shaking; default inf, i.e. no recent shake.
reward.nTrialsThreshold = 5; % number of trials after a shakebefore reward is set back to default 
reward.scaleStepSize = 0.05; % step size by which we increase rewards after shakes
reward.type = 'sequential'; % default 
reward.dual = false; % true if using dual reward

