function DatapixxM16Demo()
% modification of DatapixxM16Demo() trying to enable dual CLUT
% 

% history
% 04/23/24  hn: wrote it
%           tested overlay functionality for dome setup: (optoma projector
%           with Datapixx2 box). Worked well 

AssertOpenGL;

% Define response key mappings, unify the names of keys across operating
% systems:
KbName('UnifyKeyNames');
space = KbName('space');
escape = KbName('ESCAPE');





% Increase level of verbosity for debug purposes:
%Screen('Preference', 'Verbosity', 6);
%Screen('Preference', 'SkipSyncTests', 1); % This can be commented out on a well-bahaved system.

% Prepare pipeline for configuration. This marks the start of a list of
% requirements/tasks to be met/executed in the pipeline:
PsychImaging('PrepareConfiguration');
disp('prepare Configuration')

% Tell PTB we want to display on a DataPixx device:
PsychImaging('AddTask', 'General', 'UseDataPixx');
disp('use datapixx')
PsychImaging('AddTask', 'General', 'FloatingPoint32Bit');
disp('floatingpoint32bit')
PsychImaging('AddTask', 'General', 'EnableDataPixxM16OutputWithOverlay');
disp('enabledatapixxM16')

scrnNum = max(Screen('Screens'))
[windowPtr, windowRect]=PsychImaging('OpenWindow', scrnNum)
winWidth = RectWidth(windowRect)
winHeight = RectHeight(windowRect)
disp('opened window')

[wx,wy] = meshgrid(1:winWidth,1:winHeight);
plaidMatrix = (sin(wx*pi/128)+sin(wy*pi/128))/4+.5;
%plaidTexture = Screen('MakeTexture',windowPtr,plaidMatrix,[],[],2);

%Screen('DrawTexture',windowPtr,plaidTexture,[],[],[],0);
disp('drew texture')

overlay = PsychImaging('GetOverlayWindow',windowPtr)
disp('overlay window')

% Enable DATAPixx blueline support, and VIEWPixx scanning backlight for optimal 3D
Datapixx('Open');
transparencyColor = [0, 1, 0];
Datapixx('SetVideoClutTransparencyColor',transparencyColor);
Datapixx('EnableVideoClutTransparencyColorMode');
Datapixx('RegWr');

% make dual clut
% % % load dual CLUTs
clutTest = repmat(transparencyColor,[256,1]);
clutConsole = repmat(transparencyColor,[256,1]);
clutTest(242:246,:) = repmat([1,0,0],[5,1]);
clutTest(252:256,:) = repmat([0,0,1],[5,1]);

clutConsole(247:251,:) = repmat([1,1,0],[5,1]);
clutConsole(252:256,:) = repmat([0,0,1],[5,1]);
Datapixx('SetVideoClut',[clutTest;clutConsole]);

% monkeyClut = [0,0,0;0.5,.5,.5;.5,.5,.5;linspace(0, 1, 253)' * [1, 1, 1]];
% humanClut = [0,0,0;0,0,0;1,0,0;linspace(0, 1, 253)' * [1, 1, 1]];
% combinedClut = [monkeyClut; humanClut]; 
% 
% Datapixx('SetVideoClut',combinedClut);
% 
numDots = 10;
dotSize = 8;
dots = zeros(2, numDots);
xmax = RectWidth(windowRect)/2
ymax = RectHeight(windowRect)/4  % we run top/bottom split stereo

f = 4*pi/xmax;
amp = 16;

% dots(1, :) = 2*(xmax)*rand(1, numDots) - xmax;
% dots(2, :) = 2*(ymax)*rand(1, numDots) - 2*ymax;

dots(1, :) = 500:20:680;
dots(2, :) = ymax;


dotsL = dots;
dotsR = dots;
dotsL(1,:) = dotsL(1,:)+2;
dotsR(1,:) = dotsR(1,:)-2;
dotsR(2,:) = dotsR(2,:)+2*ymax;

col = BlackIndex(scrnNum)
Screen('DrawDots', windowPtr, [dotsL,dotsR], dotSize, col,[0 ,0] ,1);


Screen('FillRect',overlay,0);
Screen('TextSize',overlay,36);

% DrawFormattedText(overlay,'Test Display','center','center',243);
% DrawFormattedText(overlay,'console Display','center',80,248);
% for n = 0:7
%     DrawFormattedText(overlay,[sprintf('%s %d','console Display', 248+n)],'center',80+n*20,248+n);
% end
for n = 0:15
    DrawFormattedText(overlay,sprintf('%s %d','Test Display', 239+n),'center',200+n*20,239+n);
end


Screen('Flip',windowPtr)

return
