function ex = neiRigA(ex,type)
% function ex = neiRigA(ex,type)
%
% setup function to get the individualized settings for Rig A, and to
% initialize the display for this rig. (computerName: 'klab-mouse-3')
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
        % NEI Rig A
        %ex.setup.viewingDistance = 46; % LEM measured on 12/02/20 
        %ex.setup.monitorWidth = 68;
        
        ex.setup.viewingDistance = 45; % LEM measured on 11/03/22 
        ex.setup.monitorWidth = 66;
    
        ex.setup.mouseXOffset = 0 ;
        ex.setup.dirRoot = '/usr/data';
        
        % for Datapixx the Buffer size has to be <1e6 for bino
        % monocular signals; for Propixx 1e7 works
        ex.setup.adc.NumBufferFrames = 9e5;  % large number for lots of buffer space 
    case 'display'

        % -------------------------------------------------------------------------
        % setup for NEI rig A (Propixx projector) (10/02/20)----------------------
        % -------------------------------------------------------------------------    
        if ex.setup.stereo.Display
            Datapixx('SetPropixxDlpSequenceProgram' , 1);  % 1: Cumming3D mode; 0 back to normal
            Datapixx('RegWr');
             disp('checking datapixx')
            Datapixx('isready')     
            
            ex.setup.stereo.Mode = 8; % in case the wrong mode was set
            try
                [ex.setup.window, ex.setup.screenRect]=PsychImaging('OpenWindow',...
                    ex.setup.screenNum, [], [], [], [], ex.setup.stereo.Mode,...
                    ex.setup.stereo.Multisampling);   
            catch
                 [ex.setup.window, ex.setup.screenRect]=PsychImaging('OpenWindow',...
                    ex.setup.screenNum, [], [], [], [], ex.setup.stereo.Mode,...
                    ex.setup.stereo.Multisampling);   
            end
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
            ex.setup.Clut.combined = combinedClut;
        end
        Screen('BlendFunction', ex.setup.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
        ex.synch.Pos = [ex.setup.screenRect(3)-ex.synch.PSz/2;ex.synch.PSz*3/2];

end

