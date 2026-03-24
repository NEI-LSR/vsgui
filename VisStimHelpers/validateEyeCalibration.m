function ex = validateEyeCalibration(ex)

% ex = validateEyeCalibration(ex)
%
% history
% 03/13/26  hn: wrote it (took validation section from calibrateEye_dome)

initialOffset = 0;
%initialGain = 340;  % Lemieux
% initialGain = 200;  % for Barnum
initialGain = 10;  % for dome

eyeflds = {'RX','RY','LX','LY'};

if ~isfield(ex,'eyeCal')
    ex.eyeCal = [];
end
    
if isfield(ex.eyeCal,'Delta')
    ex.eyeCal.Delta = ex.eyeCal.Delta(1);
end

ex.eyeCal.Delta.cnt = 1;

for i=1:length(eyeflds)
    ex.eyeCal.([eyeflds{i},'0']) = initialOffset;
    ex.eyeCal.([eyeflds{i},'Pos']) = NaN(1,4);
    ex.eyeCal.([eyeflds{i},'Gain']) = initialGain;
    ex.eyeCal.Delta.([eyeflds{i},'0']) = 0;
end

ex.eyeCal = orderfields(ex.eyeCal,{'RX0','RY0','LX0','LY0','RXPos',...
    'RYPos','LXPos','LYPos','RXGain','RYGain','LXGain','LYGain','Delta'});


% number of samples per condition
sampleDur = 0.1;    % in second
nSamples = round(sampleDur*ex.setup.adc.Rate);

ex.fix.PSz = 12;

Screen('FillRect', ex.setup.window,ex.idx.bg_lum);

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

Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
Screen('Drawdots',ex.setup.window,ex.fix.PCtr',ex.fix.PSz',ex.idx.white); % draw FP

Screen('Flip', ex.setup.window);

disp('press any key to accept eye position') 

[v,t,ex.eyeCal] = plotEyePos(ex);
idx = max([1,length(t)-nSamples]);
vv = v(:,idx:end);



if ~strcmpi(ex.setup.computerName,'lab-ms-98h9')
    % iknew
    % number of pixels corresponding a fixed visual angle, e.g., 5 deg
    targetEcc = 2;
    offset = round(ex.setup.viewingDistance * tan(deg2rad(targetEcc)) * ...
        ex.setup.screenRect(3)/ex.setup.monitorWidth);
    pos = [0,0;-1,1;1,1;-1,-1;1,-1] * offset;

else
    % cmz
    targetEcc   = 10;
    posDeg      = [0,0; -1,1;1,1;-1,-1;1,-1] * sqrt((targetEcc^2)/2);
    offset      = sqrt((targetEcc^2)/2); % now in units of degrees not pixels

    [posPixX,posPixY]   = deg2pixelxy(posDeg(:,1),posDeg(:,2),ex.setup);
    [posPixX0,posPixY0] = deg2pixelxy(0,0,ex.setup);

    % pos expressed in pixels from center for both flat and dome screen
    pos = [posPixX - posPixX0,posPixY - posPixY0];
end



% iknew: 7.1.2022
% second phase - more repetitions and store eye positions to ex.Trials
% borrowed from the validation loop in calibrateEye_long.m

% store the current experimental values
reward_time = ex.reward.time;
stim = ex.stim.type;
finish = ex.finish;
targ = ex.targ;
fix_ = ex.fix;

ex.targ.WinW = 4;% now defined in degrees
ex.targ.WinH = 4; % now defined in degrees
ex.fix.WinW = 0;
ex.fix.duration = 0.3;
ex.stim.type = 'blank';
ex.finish = size(pos,1);
ex.j = 1;
ex.goodtrial = 0;

% set reward size differently for dome
if strcmpi(ex.setup.computerName,'lab-ms-98h9') 
    ex.reward.time = 0.03;
else
    ex.reward.time = 0.2;
end

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

if ~strcmpi(ex.setup.computerName,'lab-ms-98h9')
    % iknew
    % number of pixels corresponding a fixed visual angle, e.g., 5 deg
    offsets_inDeg   = -10:5:10;
    % offsets_inDeg   = -2:1:2;
    offsets         = round(ex.setup.viewingDistance * tan(deg2rad(offsets_inDeg)) * ...
        ex.setup.screenRect(3)/ex.setup.monitorWidth);
    [x,y]           = meshgrid(offsets);
    pos             = [x(:),y(:)];
else
    % cmz
    offsets_inDeg   = -20:10:20;%-20:5:20;
    [xDeg,yDeg]     = meshgrid(offsets_inDeg);
    [xPix,yPix]     = deg2pixelxy(xDeg(:),yDeg(:),ex.setup);

    pos     = [xPix-ex.fix.PCtr(1),yPix-ex.fix.PCtr(2)];
    posDeg  = [xDeg(:),yDeg(:)];
end

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

nRepeat = 2;
nRepeated = 0;
ex.targ.Pos(2,:) = [1000,1000];

% initialize data table
varNames = {'TX','TY','RX','RY','LX','LY','reward'};
nTrials = nRepeat * size(pos,1);

dat = array2table(NaN(nTrials,length(varNames)),'VariableNames',varNames);


curr_idx = 1;
while nRepeated <= nRepeat && ex.quit ~= 4
    rp = randperm(size(pos,1));
    for i=1:length(rp)
        HideCursor
        if ex.quit == 0
            resetAdcBuffer(ex);
            ex.targ.Pos(1,:)    = pos(rp(i),:);
            ex.targ.PosDeg(1,:) = posDeg(rp(i),:);  

            ex = runTrialFixTarg(ex);
            
            [dat,eyeCal] = updateTable(ex.Trials(end),ex.eyeCal,dat,curr_idx);
            %eyeCal
            curr_idx = curr_idx + 1;
        
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
    cur_dir = pwd;
    ex.dirName = dirName;
    cd(ex.dirName)
    ex.fileName = fname;
    disp('saving...')
    save(fname, 'ex');
    cd(cur_dir)

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

end

%%----------------------------------------------------- subfunctions------
% -----------------------------------------------------------------------
function [dat,eyeCal] = updateTable(Trial,eyeCal,dat,i)

dat.TX(i) = Trial.targ.Pos(1);
dat.TY(i) = Trial.targ.Pos(2);
dat.reward(i) = Trial.Reward;

t = Trial.Eye.t - Trial.TrialStartDatapixx;

if Trial.Reward
    idx = t >= Trial.times.reward - 0.15 & ...
        t <= Trial.times.reward - 0.05;
else
    idx = t >= Trial.times.startFixation + 0.05 & ...
        t <= min([t(end) - 0.01,...
        Trial.times.startFixation + 0.15]);
end
if ~isempty(idx) && sum(idx) >= 20
    dat{i,{'RX','RY','LX','LY'}} = ...
        mean(Trial.Eye.v([1,2,4,5],idx),2)';
end

eyeFields = {'RX','RY','LX','LY'};
tFields = {'TX','TY','TX','TY'};
idx0 = dat.TX == 0 & dat.TY == 0;
for i=1:length(eyeFields)
    if any(idx0)
        eyeCal.([eyeFields{i},'0']) = mean(dat.(eyeFields{i})(idx0),'omitnan');
    end
    idx = ~isnan(dat.(eyeFields{i}));
    if length(unique(dat.(tFields{i})(idx))) > 1
        p = polyfit(dat.(tFields{i})(idx),dat.(eyeFields{i})(idx),1);
        eyeCal.([eyeFields{i},'Gain']) = 1/p(1);
    end
end

end



% submodules added by ik
% iknew - 9.23.2022

function [v,t,eyeCal] = plotEyePos(ex,Pos,resetOffset)


if nargin == 1
    Pos = zeros(1,2);
    resetOffset = true;
elseif nargin == 2
    resetOffset = false;
end

if sum(abs(Pos)==0)
    resetOffset = true;
end

olColBinoc = ex.idx.overlay * ones(3,3); % right, left, binoc, mouse
olPSz = [ceil(ex.setup.eyePSz/2)*ones(1,2), ex.setup.eyePSz]; % eye (R,L,B)


fpPos = ex.fix.PCtr+ex.targ.Pos(1,:);
fpCol = ex.idx.bg * ones(1,3);
bgColor = ones(1,3) * ex.idx.bg;

nBuffers = 10^6;
v = cell(1,nBuffers);
t = cell(1,nBuffers);

WaitSecs(0.2);
keyIsDown = false;
i = 0;
waitframes = 10;
ifi = Screen('GetFlipInterval',ex.setup.window);
vbl = Screen('Flip',ex.setup.window);
while ~keyIsDown && i <= nBuffers
    i = i + 1;
    Datapixx RegWrRd
    status = Datapixx ('GetAdcStatus') ;
    if status.newBufferFrames <1
        i = i-1;
        failedReadCnt = failedReadCnt +1;
        if failedReadCnt >10
            sprintf('%s',' no new frames in Buffer; reset Datapixx');
            return
        else
            continue
        end
    end
    [v{i},t{i}] = Datapixx('ReadAdcBuffer',status.newBufferFrames,-1);

    % added by IK: 06.04.2024
    v{i}([1,4],:) = ex.setup.horEyeSign * v{i}([1,4],:);

    % 03.05.2026,  cmz - invert the sign of vertical eye position - unclear why
    % it's necessary at the moment
    v{i}([2,5],:) = ex.setup.vertEyeSign * v{i}([2,5],:);
    
    if resetOffset && i > 3
        vv = cell2mat(v(i-3:i));
        if size(vv,1)>=5
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
    end
        
    
    p = reshape(eyePosInScreen(v{i}([1,2,4,5],:),ex),...
        2,2);
    olPos = [p, mean(p,2)];
    
    % background
    Screen('FillRect',ex.setup.overlay,bgColor);
    
    % draw eye dots, mouse position
    Screen('Drawdots',ex.setup.overlay,olPos,olPSz,olColBinoc);

    
    % draw fixation point
    Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
    Screen('Drawdots',ex.setup.window,ex.fix.PCtr'+Pos',ex.fix.PSz',...
        ex.idx.white); % draw FP
    
    Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
    Screen('Drawdots',ex.setup.window,ex.fix.PCtr'+Pos',ex.fix.PSz',...
        ex.idx.white); % draw FP
    
    Screen('DrawingFinished', ex.setup.window);
    vbl = Screen('Flip', ex.setup.window,vbl + (waitframes - 0.5) * ifi);
    
    keyIsDown = KbCheck;
end

Screen('FillRect',ex.setup.overlay,bgColor);
Screen('Flip',ex.setup.window);

v = cell2mat(v(1:i));
t = cell2mat(t(1:i));
eyeCal = ex.eyeCal;

end


function p = eyePosInScreen(v,ex)
% v is a row vector - [RX, RY, LX, LY]'
% cmz 10/31/25: for the dome, gain must now be specified in degrees pixels
% cmz 11/04/25: Because eye position is plotted in the overlay, the warping
% must be applied here.

% center offset in voltage
offset = [ex.eyeCal.RX0; ex.eyeCal.RY0; ex.eyeCal.LX0; ex.eyeCal.LY0] + ...
    [ex.eyeCal.Delta(ex.eyeCal.Delta(1).cnt).RX0;...
    ex.eyeCal.Delta(ex.eyeCal.Delta(1).cnt).RY0;...
    ex.eyeCal.Delta(ex.eyeCal.Delta(1).cnt).LX0;...
    ex.eyeCal.Delta(ex.eyeCal.Delta(1).cnt).LY0];

% gain 
gain = [ex.eyeCal.RXGain; ex.eyeCal.RYGain; ex.eyeCal.LXGain; ex.eyeCal.LYGain];
    
% screen center
PCtr = [ex.fix.PCtr(:);ex.fix.PCtr(:)];

% p = (mean(v,2) - offset) .* gain + PCtr;
pDeg = (mean(v,2) - offset) .* gain;

% First, translate degrees to pixels
% right eye
[preWarp(1),preWarp(2)] = deg2pixelxy(pDeg(1),pDeg(2),ex.setup);
% left eye
[preWarp(3),preWarp(4)] = deg2pixelxy(pDeg(3),pDeg(4),ex.setup);

% First, translate degrees to pixels
% right eye
[p(1),p(2)] = geomCorrection(preWarp(1),preWarp(2),ex.setup);
% left eye
[p(3),p(4)] = geomCorrection(preWarp(3),preWarp(4),ex.setup);

end

