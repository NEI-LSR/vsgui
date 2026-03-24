function closeVS(ex)

% closes the display, stores the eye-link data and closes the connection to
% eyelink

if isfield(ex,'fileName') && isfield(ex,'dirName')
    [prefix,rm] = strtok(ex.fileName,'_');
else 
    sca
    return
end
    
timeString = strrep(strrep(datestr(rem(now,1)),' ', ''),':','.');
    
ex.setup.el.fileName = [prefix timeString 'el.edf'];
ex.setup.el.elstop = Eyelink('TrackerTime');
Eyelink('StopRecording');

% Close/Transfer File
%status=Eyelink('closefile');
status = 0;
if isfield(ex,'dirName')
    status=Eyelink('ReceiveFile',ex.setup.el.edfFileName,ex.dirName,1)
end
if status>0
    ret = cd(ex.dirName);
    movefile('tmp.edf',ex.setup.el.fileName);
    cd(ret);
else disp('error in eyelink file transfer')
end

% Close Eyelink Connection
Eyelink('shutdown');

%%
% save file
cur_dir = cd(ex.dirName);
fname = ex.fileName;
disp('saving...')
save(fname, 'ex');
cd(cur_dir)


%%
% close display
sca


