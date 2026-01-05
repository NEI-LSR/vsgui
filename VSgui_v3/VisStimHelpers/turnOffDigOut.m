function turnOffDigOut()
% function turnOffDigOut()
%
% this replaces the function turnOffReward() as a more general purpose
% function that sets the digout to low.
%
% history
% 09/22/25  hn: renamed turnOffReward to turnOffDigOut

Datapixx('SetDoutValues',0);
Datapixx('RegWrRd');


