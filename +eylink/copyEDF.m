function copyEDF(ex,fname,dirName)
%
% function copyEDF(ex,dirName)
%
% +eylink.copyEDF 
% copies edf file to data folder and starts recording a new edf file on
% eyelink
%
% history
% 02/10/2026    hn: moved code from runExpt

% copy edf file to data folder if Eyelink is on
if Eyelink('IsConnected') == 1 && strcmpi(ex.setup.eyeTracker,'Eyelink')
    fprintf('Transferring EDF file: %s...\n',ex.Header.edfFileName);
    Eyelink('ReceiveFile',ex.Header.edfFileName,dirName,1);
    
    % make a copy of edf file
    edfLocalName = sprintf('%s/%s',dirName,regexprep(fname,'.mat','.edf'));
    copyfile(sprintf('%s/%s',dirName,ex.Header.edfFileName),edfLocalName);
    fprintf('%s transferred and copied as %s\n',ex.Header.edfFileName,...
        edfLocalName);
    Eyelink('StartRecording');
end
