function playTone(freq,loops,dB)
% function playTone(freq,durTone,dB)
% without arguments it plays the default tone (reward signal)
%
% ToDos: pre-load the default reward audio-file into buffer
%
% history
%
% 10/30/13      hn      written

tic
es.audio.rewardFreq= 36000;    
es.audio.rewardWave =  sin([0:.1:50*pi]);
es.audio.rewardDB= .3;
es.audio.rewardLoops = 1;  % how many Sounds
es.audio.rewardReps = 2;  % duration of sound
%AssertOpenGL; 
%%
waveData = es.audio.rewardWave;
if nargin <3
dB = es.audio.rewardDB;
end
if nargin<1
    freq = es.audio.rewardFreq;
end
if nargin <2
    loops = es.audio.rewardLoops;  % how many Sounds
end
nTotalFrames = size(waveData,2);
reps = es.audio.rewardReps;
%

for n = 1:loops    
    Datapixx('StopAudioSchedule');
    Datapixx('InitAudio'); 
    Datapixx('SetAudioVolume', dB);    % Not too loud
    Datapixx('RegWrRd');    % Synchronize Datapixx registers to local register cache
    Datapixx('WriteAudioBuffer', waveData, 0);
    Datapixx('SetAudioSchedule', 0, freq, nTotalFrames*reps, 0, 0, nTotalFrames);
    Datapixx('StartAudioSchedule'); 
    Datapixx('RegWrRd');
    %
    while 1
        Datapixx('RegWrRd');   % Update registers for GetAudioStatus
        status = Datapixx('GetAudioStatus'); 
        if ~status.scheduleRunning
            break;
        end
    end
end

toc
