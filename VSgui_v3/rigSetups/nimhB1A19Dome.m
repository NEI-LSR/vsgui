function ex = nimhB1A19Dome(ex,type)
% function = nimhB1A19Dome(ex,type)
%
% setup function to get the individualized settings for the dome, and to
% initialize the display for this rig. (computerName: 'lab-ms-98h9')
%
% These definitions were previously included in 'getDefaultSettings.m' but
% I moved them here for better readability of the code.
% This function is called by 'getDefaultRigSetup.m'  
% state definitions are stored in ex.setup.XX
%
% input:
%   ex -structure
%   type: 'setup' (for parameters such as viewing distance etc.) 
%         'display' (specific initialization of this display)
%
% history
% 08/18/25  hn: wrote it

switch lower(type)
    case 'setup' 
        ex.setup.viewingDistance = 104; % dome in Leopold lab
        %ex.setup.monitorWidth = 326.73;
        ex.setup.monitorWidth = 357.45;
    
        ex.setup.mouseXOffset = 0 ;
        ex.setup.horEyeSign = -1; % to flip sign of horizontal eye position when using hot mirror
        ex.setup.dirRoot = '/home/lab/Desktop/data';
        
        % for Datapixx the Buffer size has to be <1e6 for bino
       % monocular signals; for Propixx 1e7 works
        ex.setup.adc.NumBufferFrames = 9e5;  % large number for lots of buffer space 
        
        % currently we only have monocular display
        ex.setup.stereo.Display = false; % 1 for stereo Setup, 0 for  mono display (no stereo)
        ex.setup.stereo.Mode = NaN;   %1: use hardware stereo (frame alternating stereo)
                                    %8: anaglyph stereo: red channel:  left 
                                    %                    blue channel: right 
        ex.setup.stereo.Multisampling = NaN;  % anti-aliasing; option included starting 0/25/17
                                    % 0 means no anti-aliasing used
    
        
        ex.idx.bg         = .5; % midgray background (colors go from 0 to 1)
        
        %% calibration file for display geometrycorrection
        ex.setup.warpingCalibrationFile = fullfile(ex.setup.VSdirRoot ,...
            '../setupFiles/DisplayCalibrationFiles/', ...
            'calibfile_harish_DVA_updated.mat');
        if ~exist(ex.setup.warpingCalibrationFile,"file")
            [fileN,pathN] = uigetfile('*.mat','Select a display warping calibration file');
            ex.setup.warpingCalibrationFile = fullfile(pathN,fileN);
        end
   

    case 'display'
        % -------------------------------------------------------------------------
        % setup for dome in B1 A19 (12/01/23)----------------------
        % -------------------------------------------------------------------------          
        % 04/24/24  stereo display doesn't work yet
        if ex.setup.stereo.Display
             warndlg('stereomode currently not available for this setup, using monocular display') 
             ex.setup.stereo.Display = false;
        end
    
        % ---- second try-----------------------------------------
        % minimal configuration to allow gratings as in driftdemo2
        PsychImaging('PrepareConfiguration');
        %Screen('Preference','ScreenToHead',1,2,2);
        % Geometrycorrection for the dome (calibration file is defined in
        % 'getDefaultSettings')
        PsychImaging('AddTask','AllViews','GeometryCorrection',ex.setup.warpingCalibrationFile) ;
        %PsychImaging('PrepareConfiguration');
        % added from M16 Demo
        PsychImaging('AddTask', 'General', 'UseDataPixx'); 
        %disp('use datapixx')
        PsychImaging('AddTask', 'General', 'EnableDataPixxM16OutputWithOverlay');
    
        % opening windows
        bgCol = ex.idx.bg;     % default bg color
        [ex.setup.window, ex.setup.screenRect]= ....
                        PsychImaging('OpenWindow', ex.setup.screenNum,bgCol);
        ex.setup.overlay = PsychImaging('GetOverlayWindow',ex.setup.window );
    
        % set transparency color to bg (not sure that this matters)
        transparencyColor = [bgCol bgCol bgCol];
        Datapixx('SetVideoClutTransparencyColor',transparencyColor);
        Datapixx('EnableVideoClutTransparencyColorMode');
        Datapixx('RegWr')
    
        % CLUTs as in the M16 overlay demo; But we will only use 1 overlay
        % color
        clutTest = repmat(transparencyColor,[256,1]);
        clutConsole = repmat(transparencyColor,[256,1]);
        clutTest(242:246,:) = repmat([1,0,0],[5,1]);
        clutTest(252:256,:) = repmat([1,1,1],[5,1]); % was [0,0,1]
    
        clutConsole(247:251,:) = repmat([1,1,0],[5,1]);
        clutConsole(252:256,:) = repmat([1,1,1],[5,1]);
        Datapixx('SetVideoClut',[clutConsole;clutTest]); 
    
        ex.setup.Clut.monkey = clutTest;
        ex.setup.Clut.human = clutConsole;
        ex.setup.Clut.combined = [ex.setup.Clut.human;ex.setup.Clut.monkey]; 
    
        ex.idx.white    = WhiteIndex(ex.setup.window);
        ex.idx.black    = BlackIndex(ex.setup.window);
    
        % now overwrite white and black (we need 256-based color values for
        % stimuli etc.)
        ex.idx.white = 255;
        
        % background luminace to 128/255 instead of 127
        ex.idx.bg       = round((ex.idx.white+ex.idx.black)/2)./ex.idx.white;
        ex.idx.bg_lum   = ex.idx.bg; 
    
        % setting all the overlay values to the same value for now
        ex.idx.overlay = 240; 
        ex.idx.overlayBlue = 240;
        ex.idx.overlayGreen = 240;
        ex.idx.overlayRed = 240;
        ex.idx.overlayWhite = 240;
    
        % Load in calibration file and add scal field to setup, so DVA>pixel
        % grid variables are available for translating between distances
        % specified in pixels and in DVA
        load(ex.setup.warpingCalibrationFile);
        ex.setup.scal=scal;
    
        % Change position of synch pulse are for the dome
        % ex.synch.Pos = [1446; 236]; % Busse procedure hand mapped warp
        ex.synch.Pos = [485; 40]; % Harish automatic warping map
    
        % adjust fixation point size for dome
        ex.fix.PSz=3;

        % set blend function
        Screen('BlendFunction', ex.setup.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
end


% for documentation only: attempted and failed display initialiations:
    %{
        % -------------------------
        %% first unsuccessful attempt at this setup, mirrored after Garboriumdemo and pds
        PsychImaging('PrepareConfiguration');
        PsychImaging('AddTask','General','NormalizedHighreseColorRange',1)  % added from pds
        PsychImaging('AddTask', 'General', 'UseDataPixx');
        disp('use datapixx')
        PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
        disp('floatingpoint32bit')
        PsychImaging('AddTask', 'General', 'EnableDataPixxM16OutputWithOverlay');
        disp('enabledatapixxM16')
        PsychImaging('AddTask', 'General', 'FloatingPoint32Bit','diableDithering',1); % added from pds
        
        [ex.setup.window ex.setup.screenRect] = PsychImaging('OpenWindow',ex.setup.screenNum);
        %[win winRect] = PsychImaging('OpenWindow', screenid);
        ex.setup.overlay = PsychImaging('GetOverlayWindow',ex.setup.window )
        disp('overlay window')
    
        % Enable DATAPixx blueline support, and VIEWPixx scanning backlight for optimal 3D
        Datapixx('Open');
        %transparencyColor = [0, 1, 0];
        bgCol = GrayIndex(ex.setup.window,0.5);
        transparencyColor = [bgCol*ones(1,3)];
        Datapixx('SetVideoClutTransparencyColor',transparencyColor); % not used by pds
        Datapixx('EnableVideoClutTransparencyColorMode'); % not used by pds
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
        %Screen('LoadNormalizedGammaTable', win, combinedClut, 2);
        PsychImaging('PrepareConfiguration');
        PsychImaging('AddTask','FinalFormatting','DisplayColorCorrection','SimpleGamma') %added from pds
        %}
