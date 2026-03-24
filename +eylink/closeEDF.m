function closeEDF
% function closeEDF
% 
% helper in +eylink.closeEDF closes EDF file
%
% 02/10/26  hn: moved code from runExpt

if Eyelink('IsConnected') == 1
    Eyelink('StopRecording')
    Eyelink('SetOfflineMode')
    Eyelink('CloseFile');
end
