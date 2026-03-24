function turnOnDigOut(digOutVal)
% function turnOnDigOut(digOutVal)
% 
% this function replaces turnOnReward and is more general purpose,
% requiring an input digOutVal
%
% input: digOutVal (determining which bit(s) should be set to high
%
% history
% 09/22/25  hn: wrote it to repace "turnOnReward.m" below
%
% function turnOnReward()
% Datapixx('SetDoutValues',1);
% Datapixx('RegWrRd


Datapixx('SetDoutValues',digOutVal);
Datapixx('RegWrRd');

%disp('in turnonDigOut') % for debugging