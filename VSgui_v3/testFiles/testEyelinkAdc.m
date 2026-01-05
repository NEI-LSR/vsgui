function TestEyelinkAD
%% recording monocular data
%% Eyelink analog out (breakout box) need to be connected to Datapixx ADC 
%% channels 0-2
%% Eyelink (monocular): channel#   0   1   2    
%%                      signal     x   y   pupilsize

%% history
%% 11/13/13     hn: wrote it

clear all;
commandwindow;
AssertOpenGL;

%% Open PTB
% Open a graphics window on the main screen
screenNumber=max(Screen('Screens'));
[winPtr, wRect]=Screen('OpenWindow', screenNumber);

% Open Datapixx and get ready for data aquisition %%%
Datapixx('Open');
Datapixx('StopAllSchedules');
Datapixx('RegWrRd');   
%
disp('press any key to continue') 
%pause(1) 
KbWait  % wait for subject to be ready 
%

% Configure Datapixx AnalogIn
% scheduleRate: samples/sec
% channelList: [channelNumbers;differential voltage references (0 means no
% differential voltage is computed; see
% http://docs.psychtoolbox.org/SetAdcSchedule for more information)
% Datapixx('SetAdcSchedule', scheduleOnset, scheduleRate, maxScheduleFrames [, channelList=0] [, bufferBaseAddress=4e6] [, numBufferFrames=maxScheduleFrames]);
%
tic
Datapixx('StopAdcSchedule')
Datapixx('SetAdcSchedule',0,1000,0,[0:2;0,0,0],0,5e6);
Datapixx('StartAdcSchedule')
Datapixx('EnableAdcFreeRunning');
Datapixx('RegWrRd')
toc
disp('set AdcSchedule')
%
%pause(3)
%  read in Data between Screen frame flips

tic
% pre-allocate memory 
v=NaN(3,2000);
t=NaN(1,2000); 
n = 0;  % nAcquiredFrames
for j = 1:250
    a=randperm(255);
    Screen(winPtr,'FillRect',a(1))
    temptime = Screen('Flip', winPtr,GetSecs); 
    Datapixx RegWrRd 
    status = Datapixx ('GetAdcStatus') 
    if status.newBufferFrames >0 && n+status.newBufferFrames<2000 %% 
        % v: voltage signals in each of the recorded channels
        % t: time-stamps for the voltage samples
        % Upload the acquired ADC data
        [v(:, n+1:n+status.newBufferFrames) t(n+1:n+status.newBufferFrames)]=...
            Datapixx('ReadAdcBuffer',[status.newBufferFrames],-1);
        n=n+status.newBufferFrames;
    end
end

figure; plot(t-t(1),v');  
xlabel time[s]
ylabel voltage
legend([ 'horizontal'],['vertical'],['pupil'])

toc 
return

%% Initiate Eyelink (not necessary when the signals are read in via
%% the Eyelink analog breakout-box and Datapixx, but it's safer to have a 
%% separate record of the data)
el=EyelinkInitDefaults(window);
% Initialization of the connection with the Eyelink Gazetracker.
EyelinkInit()
% open file for recording data
edfFile='demo.edf';
Eyelink('Openfile', edfFile);
% Start Recording
Eyelink('StartRecording');
el.elstart = Eyelink('TrackerTime');
el.hasSamples = true; el.hasEvents = true;
Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA,INPUT,HMARKER');
Eyelink('command','inputword_is_window = ON')


