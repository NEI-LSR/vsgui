function states = stateDefinitions
% function states = stateDefinitions
%
% +default.stateDefinitions
%
% here we define the meaning of the different states during trials used to advance 
% through our trial-based while loop (runTrials_XX).  
%
% These definitions were previously included in 'getDefaultSettings.m' but
% I moved them here for better readability of the code.
% This function is called by 'getDefaultSettings.m'.
% state definitions are stored in ex.states.XX

% history
% 08/15/25  hn: wrote it
% 02/13/26  hn: moved to +default package

states.START             = 0;
states.FPON              = 1;
states.FPHOLD            = 2; 
states.NOFIX             = 3;  % fixation never acquired; start new trial
%states.TARGON            = 4;  % hn: 7/5/14 removed after I introduced target
%                                   onset randomization to manipulate those
%                                   independently
states.ERROR             = 5;
states.GO                = 6;
states.CHOICE            = 6.5;
states.NOCHOICEMADE      = 6.6;
states.SWITCHCHOICE      = 6.7;
states.BREAKFIX          = 7;
states.FIXATIONCOMPLETE  = 8;
states.REWARD            = 9;

states.BREAKHOLD         = 7.5;  % ik - added to designate trials on 
                                    % the eyes entered target window then
                                    % go out of the target window.
                                    % 4.19.2024

                                    % ik - added to control trial duration indepdent of reward for freeViewing
% trials.  This may not be in use any more.
states.TRIALCOMPLETE     = 10;

