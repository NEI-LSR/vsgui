function playNoise
% function playNoise()
% without arguments it plays the default noise (error signal)
% 
% ToDos: pre-load default noise buffer when initializing Datapixx 
%
% history
%
% 10/30/13      hn      written
% 04/05/16      hn: uncommented AssertOpenGL, Datapixx('Open'). This may
%               have caused some of the freezes in the past
% AssertOpenGL; 
% Datapixx('Open');
dB = .1;
durTone = 2;
freq = 8000;
waveData = sin([0:.01:50*pi]);
%waveData = randn(1,100000); waveData = waveData/max(abs(waveData));
waveData = waveData+randn(1,length(waveData)); waveData = waveData/max(abs(waveData));
waveData = waveData(1:floor(length(waveData)/10));

nTotalFrames = size(waveData,2);
for n = [2*ones(1,5)]
    %Datapixx('Open');
    Datapixx('StopAudioSchedule');
    Datapixx('InitAudio'); 
    Datapixx('SetAudioVolume', dB);    % Not too loud
    Datapixx('RegWrRd');    % Synchronize Datapixx registers to local register cache
    Datapixx('WriteAudioBuffer', waveData, 0);
    Datapixx('SetAudioSchedule', 0, freq*n, nTotalFrames, 0, 0, nTotalFrames);
    Datapixx('StartAudioSchedule'); 
    Datapixx('RegWrRd');
    while 1
        Datapixx('RegWrRd');   % Update registers for GetAudioStatus
        status = Datapixx('GetAudioStatus'); 
        if ~status.scheduleRunning
            break;
        end
    end
end
