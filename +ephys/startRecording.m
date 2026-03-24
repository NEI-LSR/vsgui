function ex = startRecording(ex)

% function ex = ephys.startRecording(ex)
% 
% +ephys.startRecording 
% make EPHYS file name and initiates recording of a new file for an
% experiment
%
% 02/10/2026    hn: moved it from runExpt

not_recording = 0;
switch ex.setup.ephys
    case 'sglx'
        % check that NaN position was saved
        button = questdlg(['Did you save the NaN positions?' ...
            num2str(ex.reward.time)],'NaN position','yes','no','yes');
        if ~strcmp(button,'yes')
            return
        end

        hSGL = ex.setup.sglx.handle;
        ex.Header.SGLXVersion = GetVersion(hSGL);
        dataDir = GetDataDir(hSGL,0);
        [~,sessionDir] = fileparts(dataDir);
        
        % if session dir doesn't comply with naming standard give user
        % the option to abort
        if ~strcmp(sessionDir, strrep(datestr(now,26),'/',''))
            button = questdlg(['directory differs from standard format' ...
                ': YYYYMMDD. Are you sure?'], ...
                'SGLX directory name','yes','no','no');
            if ~strcmpi(button,'yes')
                disp('%%% You chose to exit the Expt to fix the name of the ')
                disp('%%% direcctory on the SGLX machine.')
                disp('%%% If you want to keep the current dir name')
                disp('%%% name, click "yes" when the')
                disp('%%% warning pops up.')
                disp('%%%')
                disp('%%% To chose a standard name')
                disp('%%% make a data directory on the SGLX ') 
                disp('%%% machine with this format: YYYYMMDD')
                error('incorrect directory format for sglx')
            end
        end   
        ex.Header.ephysDataDir = dataDir;
        SetRecordingEnable(hSGL, 1);pause(0.1);
        
        if IsSaving(hSGL)
            % get filename of current run/gate
            r = GetRunName(hSGL);   
            
            str = fullfile(dataDir,r) ;             
            runEphysFiles = EnumDataDir(hSGL, 0);
            idx = cellfun(@(x) contains(x,str),runEphysFiles);
            runEphysFiles = runEphysFiles(idx);
            
            % parse filenames to get highest gate number for this run
            pat = [str '_g'] + digitsPattern(1,4);
            b= cellfun(@(x) extract(x,pat), runEphysFiles,...
                'uniformoutput',false);
            c= split(cell2mat([b{:}]),[fullfile(dataDir,r) '_g']);
            [~,idx] = sort(cell2mat(cellfun(@(x) str2num(x), c, ...
                'uniformoutput',false)));
            runEphysFiles = runEphysFiles(idx); 
            
            % parse filename to remove suffix
            dots = strfind(runEphysFiles{end},'.')
            if ~isempty(dots)
                sglxFname = runEphysFiles{end}(1:dots(1)-1);
            else
                sglxFname = runEphysFiles{end};
            end

            ex.Header.fileNameEphys = sglxFname;
         
        else
            not_recording = 1;
        end

        % get sampling rate for current run
        ex.setup.sglx.sampleRate = GetStreamSampleRate(hSGL, -2, 0);
        
    case 'gv'
        status = [];
        try % for backwards compatibility: Trellis version < 1.8; i.e.
            % xippmex version <1.2.1.294
            oper = xippmex('opers');
            status = xippmex('trial',oper);
            ex.Header.XippmexVersion = '<1.2.1.294';
            xippmex('trial',oper,'recording',[],[],1);
            status = xippmex('trial',oper);
        catch
            disp('in catch')
            status = xippmex('trial');
            ex.Header.XippmexVersion = '1.2.1.294'; % came with Trellis 1.8.3
            xippmex('trial','recording',[],[],[]);  % previous settings gave an error
            status = xippmex('trial');
        end
        if strcmpi(status.status,'recording')
            % give warning if data directory format is off
            if ~contains(status.filebase,strrep(datestr(now,26),'/',''))
                button = questdlg(['directory differs from standard format' ...
                    ': YYYYMMDD. Are you sure?'], ...
                    'Trellis directory name','yes','no','no');
                if ~strcmpi(button,'yes')
                    disp('%%% You chose to exit the Expt to fix the name of the ')
                    disp('%%% direcctory on the Trellis machine.')
                    disp('%%% If you want to keep the current dir name')
                    disp('%%% name, click "yes" when the')
                    disp('%%% warning pops up.')
                    disp('%%%')
                    disp('%%% To chose a standard name')
                    disp('%%% make a data directory on the Trellis ') 
                    disp('%%% machine with this format: YYYYMMDD')
                    error('incorrect directory format for sglx')
                end
            end
            ex.Header.fileNameEphys = sprintf('%s%04d',status.filebase,...
                status.incr_num);
        else
            not_recording=1;
        end
    otherwise
        not_recording = 1;
end

if not_recording
    ex.Header.fileNameTrellis = [];
    button = questdlg('are you sure you do not want to store the neural data? ' ...
        ,'no recording','yes','no','yes');
    switch button
        case 'yes'
        case 'no'
            return
        case 'cancel'
            disp('forced exit: please respond whether you want to record');
            return
    end
end

% manual input for recorded area for single probes when no input was
% provided during probe specifications
if ~not_recording && length(ex.setup.(ex.setup.ephys).probe)==1 && ...
        isempty(ex.setup.(ex.setup.ephys).probe.Area)
    answer = inputdlg('which area are you recording from?','Area?',...
        1,{'VX'});
    ex.setup.(ex.setup.ephys).probe(1).Area = answer;
end


