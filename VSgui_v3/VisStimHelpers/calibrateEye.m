function ex = calibrateEye(ex)

% function ex = calibrateEye(ex)
% --- initial work around for manual calibration of eye position
% 
% 
% 
% history
% 11/14/13      hn: wrote it
% 04/17/14      hn: extend to binocular measurements
% 07/11/14  hn: -included field 'setup' and moved setup parameters into it
%               new parameter name          old parameter name
%               ex.setup.stereo             ex.stereo
%               ex.setup.window             ex.window
%               ex.setup.screen_number      ex.screenNum
%               ex.setup.screenRect         ex.screenRect
%               ex.setup.overlay            ex.overlay


tic
Screen('FillRect', ex.setup.window,ex.idx.bg_lum);
%Screen('FillRect', ex.setup.window,0.5);

Screen('Flip', ex.setup.window);
disp('click mouse on command window') 
pause(.2)
disp('press any key to start calibration')
pause(.2) 
KbWait ; % wait for subject to be ready 
pause(.3)
resetAdcBuffer(ex);
Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
Screen('Drawdots',ex.setup.window,ex.fix.PCtr',ex.fix.PSz',ex.idx.white); % draw FP
% Screen('FillRect', ex.setup.window, [0] , ex.setup.stereo.b_ROn);
% Screen('FillRect', ex.setup.window, [0] ,ex.setup.stereo.b_ROff);

Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
Screen('Drawdots',ex.setup.window,ex.fix.PCtr',ex.fix.PSz',ex.idx.white); % draw FP
% Screen('FillRect', ex.setup.window, [1] , ex.setup.stereo.b_LOn);
% Screen('FillRect', ex.setup.window, [0] ,ex.setup.stereo.b_LOff);


Screen('Flip', ex.setup.window);
disp('press any key to accept eye position') 
KbWait;
         
Datapixx RegWrRd ;
status = Datapixx ('GetAdcStatus') ;
[v,t]=Datapixx('ReadAdcBuffer',[status.newBufferFrames],-1);

Screen('FillRect', ex.setup.window,ex.idx.bg_lum);
%Screen('FillRect', ex.setup.window,0.5);
Screen('Flip', ex.setup.window);

if size(v,2)>20
    vv = v(:,end-20:end);
else vv = v;
end
    fig_h=figure;
plot(t,v')
legend(['X1',],['Y1'],['P1'],['X2',],['Y2'],['P2'])
set(fig_h,'position',[1288         553         560         420]);


% getting 0 position
if size(v,1)>=5
    ex.eyeCal.RX0 = mean(vv(1,:));  % smoothing over 20samples (40ms)
    ex.eyeCal.RY0 = mean(vv(2,:));
    ex.eyeCal.LX0 = mean(vv(4,:));  % smoothing over 20samples (40ms)
    ex.eyeCal.LY0 = mean(vv(5,:));
else 
    ex.eyeCal.RX0 = mean(vv(1,:));  % smoothing over 20samples (40ms)
    ex.eyeCal.RY0 = mean(vv(2,:));
    ex.eyeCal.LX0 = [];  
    ex.eyeCal.LY0 = [];
end
    
%return
% default calibration positions:
%  1                2
%
%
%          0
%
%
%  3                4

% iknew
% number of pixels corresponding a fixed visual angle, e.g., 5 deg
offset = round(ex.setup.viewingDistance * tan(deg2rad(5)) * ...
    ex.setup.screenRect(3)/ex.setup.monitorWidth);
pos = [-1,-1;1,-1;-1,1;1,1] * offset;

% getting other positions
%pos = [-400,-400;400,-400;-400,400;400,400];  % screen Pixels start top-left
rp = randperm(4);
for n = rp
    disp(['press any key to start getting position ' num2str(n)]) 
    pause(.3) 
    KbWait ; % wait for subject to be ready 
    pause(.3)
    resetAdcBuffer(ex);
    Screen('SelectStereoDrawBuffer', ex.setup.window, 0);

    Screen('Drawdots',ex.setup.window,ex.fix.PCtr' + pos(n,:)',ex.fix.PSz',ex.idx.white); % draw FP
%     Screen('FillRect', ex.setup.window, [0] , ex.setup.stereo.b_ROn);
%     Screen('FillRect', ex.setup.window, [0] ,ex.setup.stereo.b_ROff);
    
    Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
    Screen('Drawdots',ex.setup.window,ex.fix.PCtr' + pos(n,:)',ex.fix.PSz',ex.idx.white); % draw FP
%     Screen('FillRect', ex.setup.window, [1] , ex.setup.stereo.b_LOn);
%     Screen('FillRect', ex.setup.window, [0] ,ex.setup.stereo.b_LOff);

    
    Screen('Flip', ex.setup.window);
    disp('press any key to accept eye position') 
    KbWait;
    Datapixx RegWrRd ;
    status = Datapixx ('GetAdcStatus') ;
    [v,t]=Datapixx('ReadAdcBuffer',[status.newBufferFrames],-1);
    Screen('FillRect', ex.setup.window,ex.idx.bg_lum);
    %Screen('FillRect', ex.setup.window,0.5);
    Screen('Flip', ex.setup.window);
    if size(v,2)>20
        vv = v(:,end-20:end);
    else vv = v;
    end
    if size(v,1)>=5
        ex.eyeCal.RXPos(n) = mean(vv(1,:));  % smoothing over 20samples (40ms)
        ex.eyeCal.RYPos(n) = mean(vv(2,:));
        ex.eyeCal.LXPos(n) = mean(vv(4,:));  % smoothing over 20samples (40ms)
        ex.eyeCal.LYPos(n) = mean(vv(5,:));
    else 
        ex.eyeCal.RXPos(n) = mean(vv(1,:));  % smoothing over 20samples (40ms)
        ex.eyeCal.RYPos(n) = mean(vv(2,:));
        ex.eyeCal.LXPos = [];  
        ex.eyeCal.LYPos = [];
    end
    close(fig_h);
    fig_h=figure;
plot(t,v')
legend(['X1',],['Y1'],['P1'],['X2',],['Y2'],['P2'])
set(fig_h,'position',[1288         553         560         420]);

end

% iknew
% unit - pixels/voltage
RxGain = offset/mean(abs(ex.eyeCal.RXPos-ex.eyeCal.RX0));
RyGain = offset/mean(abs(ex.eyeCal.RYPos-ex.eyeCal.RY0));
LxGain = offset/mean(abs(ex.eyeCal.LXPos-ex.eyeCal.LX0));
LyGain = offset/mean(abs(ex.eyeCal.LYPos-ex.eyeCal.LY0));

ex.eyeCal.RXGain = RxGain;  
ex.eyeCal.RYGain = RyGain;
ex.eyeCal.LXGain = LxGain;  
ex.eyeCal.LYGain = LyGain;

% counter for the number of centering corrections 
ex.eyeCal.Delta(1).cnt = 1;

% Delta X/Y by which the eye position from calibration should be corrected
% initial correction is 0
ex.eyeCal.Delta(ex.eyeCal.Delta.cnt).RX0 = 0;
ex.eyeCal.Delta(ex.eyeCal.Delta.cnt).RY0 = 0;
ex.eyeCal.Delta(ex.eyeCal.Delta.cnt).LX0 = 0;
ex.eyeCal.Delta(ex.eyeCal.Delta.cnt).LY0 = 0;


close(fig_h);
fig_h=figure;
plot(t,v')
legend(['X1',],['Y1'],['P1'],['X2'],['Y2'],['P2'])
set(fig_h,'position',[1288         553         560         420]);


disp('done eye calibration')


% iknew: 7.1.2022
% second phase - more repetitions and store eye positions to ex.Trials
% borrowed the validation loop in calibrateEye_long.m

% store the current experimental values
reward_time = ex.reward.time;
stim = ex.stim.type;
finish = ex.finish;
targ = ex.targ;
fix_ = ex.fix;

ex.targ.WinW = 70;
ex.targ.WinH = 70;
ex.fix.WinW = 0;
ex.fix.duration = .5;
ex.reward.time = .5; 
ex.stim.type = 'blank';
ex.finish = size(pos,1);
ex.j = 1;
ex.goodtrial = 0;


%
clearkeyboard = input('please press the RETURN key','s');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% store unique experiment ID
clocktime = fix(clock);
sendStrobes([ex.strobe.FILE_ID,clocktime,ex.strobe.EXPERIMENT_START]);

ex.Header.fileID = clocktime;

[fname,dirName] = makeFilenameAndDir(ex,'EyeCal');
ex.Header.onlineFileName = fname;
ex.Header.onlineDirName = dirName;


ex.loopcnt =[];
if isfield(ex,'Trials')
    ex = rmfield(ex,'Trials');
    fnames = fieldnames(ex);
    for n = 1:length(fnames)
        if strfind(fnames{n},'tocs')
            ex = rmfield(ex,fnames{n});
        end
    end
end

% iknew
% number of pixels corresponding a fixed visual angle, e.g., 5 deg
offsets_inDeg = -10:5:10;
offsets = round(ex.setup.viewingDistance * tan(deg2rad(offsets_inDeg)) * ...
    ex.setup.screenRect(3)/ex.setup.monitorWidth);
[x,y] = meshgrid(offsets);
pos = [x(:),y(:)];

%pos = [-1,-1;1,-1;-1,1;1,1] * offset;
%[x,y] = meshgrid(-1:1);
%pos = [x(:),y(:)] * offset;

% iknew 6.27.2022
% open Eyelink edf file
% close any open edf file
if Eyelink('IsConnected') == 1
    Eyelink('SetOfflineMode')
    Eyelink('CloseFile');
    
    % maximum length of an edf file name = 8
    ex.Header.edfFileName = sprintf('%02d%02d%02d%02d.edf',clocktime(2),clocktime(3),...
        clocktime(4),clocktime(5));
    Eyelink('OpenFile',ex.Header.edfFileName);
    Eyelink('Message','exFileName: %s',fname);
    Eyelink('StartRecording')
end

nRepeat = 3;
nRepeated = 0;
ex.targ.Pos(2,:) = [1000,1000];
while nRepeated <= nRepeat && ex.quit ~=4
    rp = randperm(size(pos,1));
    for i=1:length(rp)
        HideCursor
        if ex.quit == 0
            resetAdcBuffer(ex);
            ex.targ.Pos(1,:) = pos(rp(i),:);
            %ex.targ.Pos(2,:) = [1000,1000];
            ex = runTrialFixTarg(ex);
        elseif ex.quit == 1
            disp('in pause')
            keyboard
            ex.quit = 0;
            ShowCursor
        elseif ex.quit ==2
            disp('in pause with timeout')
            if ex.setup.stereo.Display
                % right eye
                Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
                Screen('FillRect',ex.setup.window,0);  % black background
                % Select left-eye image buffer for drawing:
                Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
                % Draw left stim:
                Screen('FillRect',ex.setup.window,0);  % black background
            else
                % black screen
                Screen('FillRect', ex.setup.overlay,ex.idx.black);
            end
            Screen('Flip', ex.setup.window);
            
            keyboard
            ex.quit = 0;
            ShowCursor
        elseif ex.quit ==3
            disp('in timeout')
            if ex.setup.stereo.Display
                % right eye
                Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
                Screen('FillRect',ex.setup.window,0);  % black background
                % Select left-eye image buffer for drawing:
                Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
                % Draw left stim:
                Screen('FillRect',ex.setup.window,0);  % black background
            else
                % black screen
                Screen('FillRect', ex.setup.overlay,ex.idx.black);
            end
            Screen('Flip', ex.setup.window);
            pause(0.1)
            ex.quit =4;
        end
    end
    nRepeated = nRepeated + 1;
end


cur_dir = pwd;
ex.dirName = dirName;
cd(ex.dirName)
ex.fileName = fname;
disp('saving...')
save(fname, 'ex');
cd(cur_dir)
ex.quit = 0;


% iknew 06.27.2022
% close edf file
if Eyelink('IsConnected') == 1
    Eyelink('StopRecording')
    Eyelink('SetOfflineMode')
    Eyelink('CloseFile');
    
    % copy edf file to data foler
    fprintf('Transferring EDF file: %s...\n',ex.Header.edfFileName);
    Eyelink('ReceiveFile',ex.Header.edfFileName,dirName,1);
    % make a copy of edf file
    edfLocalName = sprintf('%s/%s',dirName,regexprep(fname,'.mat','.edf'));
    copyfile(sprintf('%s/%s',dirName,ex.Header.edfFileName),edfLocalName)
    fprintf('%s transferred and copied as %s\n',ex.Header.edfFileName,...
        edfLocalName);
    Eyelink('StartRecording')
end

ShowCursor

ex.reward.time = reward_time;
ex.stim.type = stim;
ex.finish = finish;
ex.targ = targ;
ex.fix = fix_;




