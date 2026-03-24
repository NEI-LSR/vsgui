function extras = extrasParameters
% function extras = extrasParameters
%
% +default.extrasParameters
%
% here we define the default experimental parameters when VS is started.
%
% These definitions were previously included in 'getDefaultSettings.m' but
% I moved them here for better readability of the code.
% This function is called by 'getDefaultSettings.m'.
% Parameters are stored in ex.extras.XX

% history
% 08/18/25  hn: wrote it; 
% 02/13/26  hn: moved it to +default package

%%  % define extras (RF position, helper lines for online orientation)
extras.rfW = .5;
extras.rfH = .5;
extras.rfx = 10;
extras.rfy = 10;
extras.line = [];
%%
