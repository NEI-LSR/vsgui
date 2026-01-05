function closeEyelink(ex)

% function closeEyelink(ex)
% closes the Eyelink connection, stores the eye-link data 
% history
% similar to closeVS but without closing the display and storing the ex
% file

% 11/04/14  hn: wrote it

if ~(isfield(ex,'fileName') && isfield(ex,'dirName'))
    [fname, dirName, trDir ] = makeFilenameAndDir(ex,'');
    ex.fileName = fname;
    ex.dirName = dirName;    
end
[prefix,rm] = strtok(ex.fileName,'_');

timeString = strrep(strrep(datestr(rem(now,1)),' ', ''),':','.');
ex.setup.el.fileName = [prefix timeString 'el.edf'];
ex.setup.el.elstop = Eyelink('TrackerTime');
Eyelink('StopRecording');

% Close/Transfer File
%status=Eyelink('closefile');
status=Eyelink('ReceiveFile',ex.setup.el.edfFileName,ex.dirName,1);

if status>0
    ret = cd(ex.dirName);
    movefile('tmp.edf',ex.setup.el.fileName);
    cd(ret);
else disp('error in eyelink file transfer')
end

% Close Eyelink Connection
Eyelink('shutdown');
