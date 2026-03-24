% here we just keep track of previous settings for previous rigs that are
% no longer in use

% -------------------------------------------------------------------------
% old setup for rig 2 (two projection-design projectors); now obsolete ----
% -------------------------------------------------------------------------
elseif strcmpi(ex.setup.computerName,'hns-mac-pro-OBSOLETE.cin.medizin.uni-tuebingen.de') || ...
       strcmpi(ex.setup.computerName,'hns-mac-pro-OBSOLETE.local')  
    ex.setup.viewingDistance = 97; % until changes on 1/10/15
    ex.setup.viewingDistance = 149; % starting on 1/10/15
    ex.setup.monitorWidth = 59;
    ex.setup.mouseXOffset = 1920;
    ex.setup.dirRoot = '/Users/nienborg_group1/CIN_local/data';
    
    % for Datapixx the Buffer size has to be <1e6 for binocular signals; for Propixx 1e7 works
    ex.setup.adc.NumBufferFrames = 9e5;  % large number for lots of buffer space 
    % 11/24/15  pump in rig 2 at 4 (0.5 reward Time corresponds to 0.01ml/trial)

% -------------------------------------------------------------------------
% setup for rig 1 (Propixx projector) ---------------------- now obsolete
% -------------------------------------------------------------------------        
elseif strcmpi(ex.setup.computerName,'hns-mac-pro1.cin.medizin.uni-tuebingen.de') || ...
        strcmpi(ex.setup.computerName,'hns-mac-pro1.local') || ...
        strcmpi(ex.setup.computerName,'nienborg-groups-mac-pro.local')
    ex.setup.viewingDistance = 97.5; % Mango in cm   
    ex.setup.monitorWidth = 56;
    ex.setup.mouseXOffset = 1920;
    ex.setup.dirRoot = '/Users/nienborg_group/CIN_local/data';

    % for Datapixx the Buffer size has to be <1e6 for binocular signals; for Propixx 1e7 works
    ex.setup.adc.NumBufferFrames = 9e6;  % large number for lots of buffer space 
    % 11/24/15  pump in rig 1 at 10 (0.15 reward Time corresponds to 0.01ml/trial)

    % if ~ running in stereo mode use PLDAPS type setup
    if ~ex.setup.stereo.Display 
        %% CLUTs:
        ex.setup.Clut.monkey = [0.5,0.5,0.5;0.5,0.5,0.5;0.5,0.5,0.5;0.5,0.5,0.5;0.5,0.5,0.5;linspace(0, 1, 251)' * [1, 1, 1]];
        ex.setup.Clut.human =  [0.5,0.5,0.5;1 1 1      ;1,0,0      ;0,1,0      ;0,0,1      ;linspace(0, 1, 251)' * [1, 1, 1]];
        
        %%% keeping track of which color is which
        % idx to the bg color; this is the only value that needs to be changed; 
        % the overlay luminance values get automatically updated below.
        ex.idx.bg = 130; 
        ex.idx.bg_lum   = ex.Clut.monkey(ex.idx.bg+1,1);  % luminance level of bg
        ex.idx.cursor     = 100;
        ex.idx.window     = 200;
        ex.idx.fixation   = 255;
        ex.idx.white      = 255;
        ex.idx.black      = 5;
        ex.idx.overlayBlue = 4;
        ex.idx.overlayGreen = 3;
        ex.idx.overlayRed = 2;
        ex.idx.overlayWhite = 1;
        ex.idx.overlay = ex.idx.overlayRed;

        ex.setup.Clut.monkey(1,:) = ex.setup.Clut.monkey(ex.idx.bg+1,1); % first line in both Cluts corresponds to bg
        ex.setup.Clut.human(1,:) = ex.setup.Clut.human(ex.idx.bg+1,1);
        ex.setup.Clut.monkey(1:5,:) = ex.setup.Clut.monkey(ex.idx.bg+1,1);  % make overlaycolor is same as bg
    end
% -------------------------------------------------------------------------
% NEW setup for rig 2 (Propixx projector) ---------------------- obsolete
% -------------------------------------------------------------------------        
elseif strcmpi(ex.setup.computerName,'hns-mac-pro-2.cin.medizin.uni-tuebingen.de') ||...
        strcmpi(ex.setup.computerName,'hns-mac-pro-2.local') 
    ex.setup.viewingDistance = 103; % Mango in cm   
    ex.setup.monitorWidth = 53.5;
    ex.setup.mouseXOffset = 1920;
    ex.setup.dirRoot = '/Users/nienborg_group1/CIN_local/data';
    %ex.online.rootName = '/Users/nienborg_group/CIN_share';  % obsolete
    % for Datapixx the Buffer size has to be <1e6 for binocular signals; for Propixx 1e7 works
    ex.setup.adc.NumBufferFrames = 9e6;  % large number for lots of buffer space 

    % if ~ running in stereo mode use PLDAPS type setup
    if ~ex.setup.stereo.Display 
        %% CLUTs:
        ex.setup.Clut.monkey = [0.5,0.5,0.5;0.5,0.5,0.5;0.5,0.5,0.5;0.5,0.5,0.5;0.5,0.5,0.5;linspace(0, 1, 251)' * [1, 1, 1]];
        ex.setup.Clut.human =  [0.5,0.5,0.5;1 1 1      ;1,0,0      ;0,1,0      ;0,0,1      ;linspace(0, 1, 251)' * [1, 1, 1]];
        %%% keeping track of which color is which

        % idx to the bg color; this is the only value that needs to be changed; 
        % the overlay luminance values get automatically updated below.
        ex.idx.bg = 130; 
        ex.idx.bg_lum   = ex.Clut.monkey(ex.idx.bg+1,1);  % luminance level of bg
        ex.idx.cursor     = 100;
        ex.idx.window     = 200;
        ex.idx.fixation   = 255;
        ex.idx.white      = 255;
        ex.idx.black      = 5;
        ex.idx.overlayBlue = 4;
        ex.idx.overlayGreen = 3;
        ex.idx.overlayRed = 2;
        ex.idx.overlayWhite = 1;
        ex.idx.ovrlay = ex.idx.overlayRed;

        ex.setup.Clut.monkey(1,:) = ex.setup.Clut.monkey(ex.idx.bg+1,1); % first line in both Cluts corresponds to bg
        ex.setup.Clut.human(1,:) = ex.setup.Clut.human(ex.idx.bg+1,1);
        ex.setup.Clut.monkey(1:5,:) = ex.setup.Clut.monkey(ex.idx.bg+1,1);  % make overlaycolor is same as bg
    end


    %%% display initializations:

    % -------------------------------------------------------------------------
% NOW OBSOLETE (05/22/17) setup for rig 2 (two projection-design projectors)  --------
% -------------------------------------------------------------------------
if strcmpi(ex.setup.computerName,'hns-mac-pro-OBSOLETE.cin.medizin.uni-tuebingen.de')  || ...
      strcmpi(ex.setup.computerName,'hns-mac-pro-OBSOLETE.local') % quick hack for upgrade of rig 2
    ex.setup.stereo.Mode = 8;  % we only use this mode
    [ex.setup.window, ex.setup.screenRect]=PsychImaging('OpenWindow', ex.setup.screenNum, [], [], [], [], ...
        ex.setup.stereo.Mode,ex.setup.stereo.Multisampling); 
    ex.setup.overlay = SetAnaglyphStereoParameters('CreateGreenOverlay',ex.setup.window);
       
 

% -------------------------------------------------------------------------
% NEW (05/22/17) setup for rig 2 (Propixx projector, obsolete) ------------
% -------------------------------------------------------------------------    
elseif  strcmpi(ex.setup.computerName,'hns-mac-pro-2.cin.medizin.uni-tuebingen.de') || ...
        strcmpi(ex.setup.computerName,'hns-mac-pro-2.local')
    %hns-mac-pro1.cin.medizin.uni-tuebingen.de  
    if ex.setup.stereo.Display
        disp('cumming mode')
        Datapixx('SetPropixxDlpSequenceProgram' , 1);  % 1: Cumming3D mode; 0 back to normal
        Datapixx('RegWr');
        
        ex.setup.stereo.Mode = 8; % in case the wrong mode was set
        [ex.setup.window, ex.setup.screenRect]=PsychImaging('OpenWindow',...
            ex.setup.screenNum, [], [], [], [], ex.setup.stereo.Mode,...
            ex.setup.stereo.Multisampling);   
        
        ex.setup.overlay = SetAnaglyphStereoParameters('CreateGreenOverlay',ex.setup.window);

    else
        % for monocular display use PLDAPS-type overlay
        PsychImaging('AddTask', 'General', 'FloatingPoint32Bit');
        PsychImaging('AddTask', 'General', 'EnableDataPixxM16OutputWithOverlay');
        PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
        [ex.setup.window ex.setup.screenRect] = PsychImaging('OpenWindow',ex.setup.screenNum);

        combinedClut = [ex.setup.Clut.monkey;ex.setup.Clut.human]; 
        % open overlaywindow. Overlaywindow is a standard offscreen window except
        % that it is a pure index window: it only has one color channel for values
        % 0 to 255.  (Nonetheless it seems like Screen('Drawdots') needs a matrix
        % of the color-indices: if col_n is an index vector of n dots, it has to be
        % converted to into a n-by-3 matrix m= [col_n' * ones(1,3)]' )
        ex.setup.overlay = PsychImaging('GetOverlayWindow', ex.setup.window);  
        Screen('LoadNormalizedGammaTable', ex.setup.window, combinedClut, 2);
        tic
        ex.setup.Clut.combined = combinedClut;
    end
else
    warndlg('host machine not known, using PTB stereomode 8 (R/B anaglyph') 
    ex.setup.stereo.Mode = 8;  % we only use this mode
    [ex.setup.window, ex.setup.screenRect]=PsychImaging('OpenWindow',...
        ex.setup.screenNum, [], [], [], [], ex.setup.stereo.Mode,...
        ex.setup.stereo.Multisampling); 
end
    