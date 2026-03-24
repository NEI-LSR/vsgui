function ex = openEDF(ex,clocktime)
% function ex=openEDF(ex,clocktime)
% 
% helper in +eylink.openEDF opens EDF file
%
% 02/10/26  hn: moved code from runExpt

if Eyelink('IsConnected') == 1
    
    Eyelink('SetOfflineMode')
    Eyelink('CloseFile');
    
    % only when Eyelink is used to record eye positions
    if strcmpi(ex.setup.eyeTracker,'Eyelink')
        % maximum length of an edf file name = 8
        ex.Header.edfFileName = sprintf('%02d%02d%02d%02d.edf',clocktime(2),clocktime(3),...
            clocktime(4),clocktime(5));
        Eyelink('OpenFile',ex.Header.edfFileName);
        Eyelink('Message','exFileName: %s',ex.Header.onlineFileName);
        Eyelink('StartRecording');
    end
end

