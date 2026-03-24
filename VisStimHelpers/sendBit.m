function sendBit(bit)

% sendBit(bit)
%
% sendBit sends a bit on the digital out values of the Datapixx
% box.  The bit flipped is specified
% ordinally, so if bit = 3, the third
% bit is set to 1, and quickly set back to zero. 
% based on pdsDatapixxFlipBit(bit)

% history
% 09/21/14  hn: wrote it


Datapixx('SetDoutValues',2^(bit-1))
Datapixx('RegWrRd');
% pause(.1)
% Datapixx('SetDoutValues',0)
% Datapixx('RegWrRd');
