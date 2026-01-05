function sendStrobes(words)

% function sendStrobes(words)
%
% similar to sendStrobe but can send several words 
% send n 15-bit (1-32767) words (1-by-n vector) from datapixx
% ---- see also sendStrobe
%
%
% history
% 08/05/14  hn: wrote it; 
% 11/10/2025 BT: added a short pause to enable communication with sglx
for n = 1:length(words)
    if words(n) < 32768
        Datapixx('SetDoutValues',words(n) );    
        Datapixx('RegWr');
        pause(0.003);
        Datapixx('SetDoutValues',0);
        Datapixx('RegWr');
        pause(0.003);
    else 
        disp(['strobe word' num2str(words(n)) ' exceeds the usable range: 1-32767'])
    end
end
