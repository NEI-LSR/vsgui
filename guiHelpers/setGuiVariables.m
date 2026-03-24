function setGuiVariables(handles)

% function setGuiVariables(handles)

% history
% 11/24/16  hn: bugfix relating to trellis filename

disp('in set guivariables')
global ex
nex = ex; % we would otherwise overwrite the current 
% parameters in ex

%% StimulusType, Masktype
stim_type_list = cellstr(get(handles.stimulus_type,'String'));
idx = find(strcmp(stim_type_list,ex.stim.type));
if ~isempty(idx)
    set(handles.stimulus_type,'Value',idx);
else
    stim_type_list{length(stim_type_list)+1} = ex.stim.type;
    set(handles.stimulus_type,'String',stim_type_list);
    set(handles.stimulus_type,'Value',length(stim_type_list));
end 

mask_type_list = cellstr(get(handles.mask_type,'String'));
idx = find(strcmp(mask_type_list,ex.stim.masktype));
if ~isempty(idx)
    set(handles.mask_type,'Value',idx);
else
    mask_type_list{length(mask_type_list)+1} = ex.stim.masktype;
    set(handles.mask_type,'String',mask_type_list);
    set(handles.mask_type,'Value',length(mask_type_list));
end 


%% stimulus parameters
stim_vals = fieldnames(ex.stim.vals);
for n = 1:length(stim_vals)
    if isfield(handles,stim_vals{n})
        if isnumeric(eval(['ex.stim.vals.' stim_vals{n}]))
            set(eval(['handles.' stim_vals{n}]),'String',num2str(eval(['ex.stim.vals.' stim_vals{n}])));
        else 
            set(eval(['handles.' stim_vals{n}]),'String',eval(['ex.stim.vals.' stim_vals{n}]));
        end
    end
end

param_list = cellstr(get(handles.stimParams,'String'));
param_selected = param_list{get(handles.stimParams,'Value')};
param  = strtok(param_selected,' ');
if isfield(ex.stim.vals,param)
    val = eval(['ex.stim.vals.' param ';']);
else val = '';
end
% display the value of the selected stimulus parameter for editing
if ischar(val)
    set(handles.stimVals,'String',val);
else
    if length(val)>1
        val_str = '';
        for n = 1:length(val)
            val_str = [val_str ' ' num2str(val(n))];
        end
        set(handles.stimVals,'String',(val_str));
    else
        set(handles.stimVals,'String',num2str(val));
    end
end

% set experiment parameters
set(handles.nreps,'String',num2str(ex.exp.nreps));
set(handles.nStimPerTrial,'String',num2str(ex.exp.StimPerTrial));

for n = 1:5  % experiment settings    
    ns = num2str(n);
    if isfield(ex.exp,['e' ns])
        if ~isfield(eval(['ex.exp.e' ns]),'type')
            warndlg(['please select an experiment type for exp' ns]);
            ex.exp = rmfield(ex.exp,['e' ns]);
            return
        else
            etype_list = cellstr(get(eval(['handles.exp' ns '_type']),'String'));
            idx = find(strcmp(etype_list,eval(['ex.exp.e' ns '.type'])));
            if ~isempty(idx)
                set(eval(['handles.exp' ns '_type']),'Value',idx);
            else
                etype_list{length(etype_list)+1} = eval(['ex.exp.e' ns '.type']);
                set(eval(['handles.exp' ns '_type']),'String',etype_list);
                set(eval(['handles.exp' ns '_type']),'Value',length(etype_list));
            end 

            scale_list = cellstr(get(eval(['handles.exp' ns '_scale']),'String'));
            idx = find(strcmp(scale_list,eval(['ex.exp.e' ns '.scale'])));
            if ~isempty(idx)
                set(eval(['handles.exp' ns '_scale']),'Value',idx);
            else
                scale_list{length(scale_list)+1} = eval(['ex.exp.e' ns '.type']);
                set(eval(['handles.exp' ns '_scale']),'String',scale_list);
                set(eval(['handles.exp' ns '_scale']),'Value',length(scale_list));
            end 

            if isfield(eval(['ex.exp.e' ns]),'min')
                set(eval(['handles.exp' ns '_min']),'String',num2str(eval(['ex.exp.e' ns '.min'])));
            end
            if isfield(eval(['ex.exp.e' ns]),'inc')
                set(eval(['handles.exp' ns '_inc']),'String',num2str(eval(['ex.exp.e' ns '.inc'])));
            end        

            if isfield(eval(['ex.exp.e' ns]),'nsamples')
                set(eval(['handles.exp' ns '_nsamples']),'String',num2str(eval(['ex.exp.e' ns '.nsamples'])));
            end
            if isfield(eval(['ex.exp.e' ns ]),'range')
                range = eval(['ex.exp.e' ns '.range']);
            else
                [ex,vals] = getStimulusValues(ex,['e' ns]);
                range = vals;
            end
            range_str = '';
            for r = 1:length(range)
                range_str = [range_str '  ' num2str(range(r))];        
            end
            set(eval(['handles.exp' ns '_range']),'String',range_str);
        end
    else
       set(eval(['handles.exp' ns '_type']),'Value',1); 
       set(eval(['handles.exp' ns '_min']),'String',[]);
       set(eval(['handles.exp' ns '_inc']),'String',[]);
       set(eval(['handles.exp' ns '_scale']),'Value',1);
       set(eval(['handles.exp' ns '_nsamples']),'String',[]);
       set(eval(['handles.exp' ns '_range']),'String',[]);
    end
end

% other experiment parameters
if isfield(ex.exp,'afc') && ex.exp.afc
    set(handles.afc,'Value',1);
else set(handles.afc,'Value',0);
end

if isfield(ex.exp,'include_blank') && ex.exp.include_blank
    set(handles.include_blank,'Value',1);
else set(handles.include_blank,'Value',0);
end

if isfield(ex.exp,'include_monoc') && ex.exp.include_monoc
    set(handles.include_monoc,'Value',1);
else set(handles.include_monoc,'Value',0);
end

if isfield(ex.exp,'spatialAttention') 
    if ex.exp.spatialAttention
        set(handles.spatialAttention,'Value',1);
        ex.exp.spatialAttention =1;
    else
         set(handles.spatialAttention,'Value',0);
         ex.exp.spatialAttention = 0;
    end
else ex.exp.spatialAttention = get(handles.spatialAttention,'Value');
end

if isfield(ex.exp,'cuedUncuedAntiCorrelated') 
    if ex.exp.cuedUncuedAntiCorrelated
        set(handles.AC,'Value',1);
        ex.exp.cuedUncuedAntiCorrelated =1;
    else
         set(handles.AC,'Value',0);
         ex.exp.cuedUncuedAntiCorrelated = 0;
    end
else ex.exp.cuedUncuedAntiCorrelated = get(handles.AC,'Value');
end


if isfield(ex.exp,'flashCue')
    if ex.exp.flashCue
        set(handles.flashCue,'Value',1);
        ex.exp.flashCue =1;
    else
         set(handles.flashCue,'Value',0);
         ex.exp.flashCue = 0;
    end
else ex.exp.flashCue = get(handles.flashCue,'Value');
end
    

if isfield(ex.exp,'nInstructionTrials')
    if isnumeric(ex.exp.nInstructionTrials)
        set(handles.nInstructionTrials,'String',num2str(ex.exp.nInstructionTrials));
    else
        set(handles.nInstructionTrials,'String','0');
        ex.exp.nInstructionTrials = 0;
    end
else
    ex.exp.nInstructionTrials = str2num(get(handles.nInstructionTrials,'String'));
end

if isfield(ex.exp,'nTrialsInBlock')
    if isnumeric(ex.exp.nTrialsInBlock)
        set(handles.nTrialsInBlock,'String',num2str(ex.exp.nTrialsInBlock));
    else
        set(handles.nTrialsInBlock,'String','0');
        ex.exp.nTrialsInBlock = 0;
    end
else
    ex.exp.nTrialsInBlock = str2num(get(handles.nTrialsInBlock,'String'));
end

%% setup parameters-----------------------------------------
if ex.setup.el.binoc
    set(handles.binoc_eyeSignals,'Value',1);
else set(handles.binoc_eyeSignals,'Value',2);
end
    
if ex.setup.recording
    set(handles.recording,'Value',1);
    switch ex.setup.ephys
        case 'sglx'
            if ex.setup.sglx.recording
                set(handles.storeNeuralData,'Value',1);
            else
                set(handles.storeNeuralData,'Value',0);
            end
        case 'gv'
            if ex.setup.gv.recording
                set(handles.storeNeuralData,'Value',1);
            else
                set(handles.storeNeuralData,'Value',0);
            end
    end
else
    set(handles.recording,'Value',0);
end



if ex.setup.iontophoresis.on
    set(handles.iontophoresis,'Value',1)
else
    set(handles.iontophoresis,'Value',0);
end

if isfield(ex.setup,'rightHemisphereRecorded')
    if ex.setup.rightHemisphereRecorded
        set(handles.RightHemisphere,'Value',1)
    else
           set(handles.RightHemisphere,'Value',0)
    end
end
if isfield(ex.setup,'leftHemisphereRecorded')
    if ex.setup.leftHemisphereRecorded
        set(handles.LeftHemisphere,'Value',1)
    else
        set(handles.LeftHemisphere,'Value',0)
    end
end

fields = {['Left_Hemisphere_gridX'],['Left_Hemisphere_gridY'],...
    ['Right_Hemisphere_gridX'],['Right_Hemisphere_gridY']};
for n = 1:length(fields)
    if isfield(ex.setup,fields{n})
            set(eval(['handles.' fields{n}]),'String',num2str(eval(['ex.setup.' fields{n}])));
    end
end


%% target icon parameters --------------------------------------
targ_paras = fieldnames(ex.targ.icon);
tlist={};
cnt = 1;
for n = 1:length(targ_paras)
    switch targ_paras{n}
        case 'type'  % type is chosen separately in the scroll down menu
        otherwise
            tlist{cnt} = targ_paras{n};
            cnt = cnt+1;
    end
end
set(handles.targIconParamList,'String',tlist);

param_list = cellstr(get(handles.targIconParamList,'String'));
%param_selected = param_list{get(handles.targIconParamList,'Value')};
if isfield(ex.targ.icon,param_selected)
    val = eval(['ex.targ.icon.' param_selected ';']);
else val = '';
end
% display the value of the selected target icon parameter for editing
if ischar(val)
    set(handles.targIconVals,'String',val);
else
    if length(val)>1
        val_str = '';
        for n = 1:length(val)
            val_str = [val_str ' ' num2str(val(n))];
        end
        set(handles.targIconVals,'String',(val_str));
    else
        set(handles.targIconVals,'String',num2str(val));
    end
end

% Ephys file name
if ex.setup.recording
    switch ex.setup.ephys
        case 'sglx'
            hSGL = ex.setup.sglx.handle;
            if IsSaving(hSGL) && isfield(ex.Header,'fileNameEphys')
                set(handles.fileNameEphys,'String',ex.Header.fileNameEphys);
            else
                set(handles.fileNameEphys,'String','')
            end
        case 'gv'
            try % for backwards compatibility: Trellis version < 1.8; i.e. xippmex version <1.2.1.294
                oper = xippmex('opers');
                status = xippmex('trial',oper);
                ex.Header.XippmexVersion = '<1.2.1.294';
            catch
                try
                    status = xippmex('trial');
                    ex.Header.XippmexVersion = '1.2.1.294'; % came with Trellis 1.8.3
                catch
                    error('%s\n%s','xippmex error (invalid directory):',...
                        'does datafolder on the trellis PC exist?');
                end
            end
            if strcmpi(status.status,'recording')
                % make sure the name fits into the window
                if length(ex.Header.fileNameEphys)>60
                    fNT = strrep(ex.Header.fileNameEphys,'C:\Users\nienborg_group','~');
                else fNT = ex.Header.fileNameEphys;
                end
                set(handles.fileNameEphys,'String',fNT)
            end
    end
end

%% fixation parameters --------------------------------------
set(handles.fixWinW,'String',num2str(ex.fix.WinW));
set(handles.fixWinH,'String',num2str(ex.fix.WinH));
set(handles.fix_duration,'String',num2str(ex.fix.duration));
set(handles.fixPCtr,'String',num2str(ex.fix.PCtr));

dur_str = '';
for n = 1: length(ex.fix.duration_forEarlyReward)
    dur_str = [dur_str '  ' num2str(ex.fix.duration_forEarlyReward(n))];
end
set(handles.duration_forEarlyReward,'String',dur_str)
set(handles.preStimDuration,'String',num2str(ex.fix.preStimDuration));
set(handles.stimDuration,'String',num2str(ex.fix.stimDuration));

%% reward parameters
set(handles.reward_time,'String',num2str(ex.reward.time));
set(handles.includeBigReward,'Value',ex.reward.includeBigReward);

%% animal
if isfield(ex.Header,'animal')
    animal_list = cellstr(get(handles.Animal,'String'));
    idx = find(strcmpi(animal_list,ex.Header.animal));
    if ~isempty(idx)
        set(handles.Animal,'Value',idx);
    end
else
    animal_list = cellstr(get(handles.Animal,'String'));
    val = get(handles.Animal,'Value');
    ex.Header.animal = animal_list{val};
end

%% experimenter
experimenter_list = cellstr(get(handles.Experimenter,'String'));
idx = find(strcmpi(experimenter_list,'XX'));
if ~isempty(idx)
    set(handles.Experimenter,'Value',idx);
end
if isfield(ex.Header,'experimenter')
    idx = find(strcmpi(experimenter_list,ex.Header.experimenter));
    if ~isempty(idx)
        set(handles.Experimenter,'Value',idx);
    else
        disp('experimenter initials not found')
        ex.Header.experimenter = 'XX';
    end
end


%% log
if isfield(ex.Header,'dirName')
    cur_dir = cd(ex.Header.onlineDirName);
    if exist('dailyLog.mat') ==2
        load('dailyLog.mat');
        updateGuiLogs(dailyLog);
    end
    cd(cur_dir);
end

% display experiment name
esfx = strrep(makeFilenameSuffix(ex),'.','');
set(handles.ExperimentSuffix,'String',esfx);

% display date
curr_date = datevec(date);
dateString = [num2str(curr_date(1)) '.' num2str(curr_date(2)) '.' num2str(curr_date(3))];
set(handles.DateString,'String',dateString)

% display time
if isfield(ex.Header,'fileName') && ~isempty(ex.Header.onlineFileName)
    dots = findstr(ex.Header.onlineFileName,'.');
    t_str = ex.Header.onlineFileName(1:dots(2)-1);
    us = findstr(t_str,'_');
    timeString = t_str(us(end)+1:end);
else
    timeString=strrep(datestr(rem(now,1)),' ', '');
    timeString = strrep(timeString,':','.');
end
set(handles.TimeString,'String',timeString);

%% optical stimulation
set(handles.optoStimCheckbox,'Value',ex.setup.optoStim.flag);
t_on = '';
for n = 1: length(ex.setup.optoStim.onsetTimes)
    t_on = [t_on '  ' num2str(ex.setup.optoStim.onsetTimes(n))];
end
set(handles.optoStimOnsetTimes,'String',t_on);

dur_opto = '';
for n = 1: length(ex.setup.optoStim.durations)
    dur_opto = [dur_opto '  ' num2str(ex.setup.optoStim.durations(n))];
end
set(handles.optoStimDurations,'String',dur_opto);

%% fUS triggers included?
set(handles.fUSTriggers,'Value',ex.setup.fUS.flag);
set(handles.fUSTriggerLag,'String',num2str(ex.setup.fUS.triggerOnsetLag));


%% update gui
guidata(handles.figure1,handles)


disp('set gui variables done')

