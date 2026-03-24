function handles = scmap(varargin)

global ex


% set default font size
if strcmpi(computer,'GLNXA64')
    set(groot,'DefaultUIControlFontSize',9);
end

varargin = lower(varargin);
if isempty(varargin) || ismember('launch',varargin)
    
    % User defined variables
    handles.mapType = 1;
    handles.showRF = 1;
    handles.showPSTH = 0;
    handles.rfStartEvent = 3;
    handles.rfStartEventName = [];
    handles.rfStartTime = 0;
    handles.rfEndEvent = 3;
    handles.rfEndEventName = [];
    handles.rfEndTime = 500;
    handles.psthAlignEvent = 1;
    handles.psthAlignEventName = [];
    handles.psthAlignTime1 = 500;
    handles.psthAlignTime2 = 1500;
    handles.binWidth = 20;
    handles.psthTarget = 1;
    
    rfTimeSet = {'rfStartEvent','rfStartTime','rfEndEvent','rfEndTime'};
    psthTimeSet = {'psthAlignEvent','psthAlignTime1','psthAlignTime2',...
        'binWidth','psthTarget'};
    
    for i=1:length(rfTimeSet)
        handles.currentSetting.rf.(rfTimeSet{i}) = handles.(rfTimeSet{i});
    end
    
    for i=1:length(psthTimeSet)
        handles.currentSetting.psth.(psthTimeSet{i}) = handles.(psthTimeSet{i});
    end
    
    handles.autoUpdate = 0;
    handles.selectAllChannels = 1;
    
    % handles for response field figure and psth figure
    handles.rf.figureTag = 'rfFigure';
    handles.rf.params = [];
    handles.rf.data = [];
    
    handles.psth.figureTag = 'psthFigure';
    handles.psth.binWidth = handles.binWidth/1000;
    handles.psth.edges = -1*handles.psthAlignTime1/1000:handles.psth.binWidth:...
        handles.psthAlignTime2/1000;
    handles.psth.params = [];
    handles.psth.fr = [];
    
    handles.dataFolder = [];
    handles.oldDataFolder = [];
    handles.onlineFileName = [];
    handles.addTrialsOnline = 0;
    handles.addTrials2SelectedExpts = 0;
    handles.lastTrial = 0;
    handles.lastUpdateTime = datetime;
    handles.updateInterval = 60;    % update at every this many seconds


    % data for individual files
    handles.data = [];
    
    % create GUI figure
    hObject = createGUI;
    handles.output = hObject;
    guidata(hObject,handles)
    
    % check if the current ex in work space
    if isempty(ex)
        warning('no ex file in workspace!')

    else
        if length(ex.setup.gv.elec) < 24
            warning('check ev.setup.gv for channel numbers')
            %return
        end

        handles.dataFolder = ex.Header.onlineDirName;
        handles.nChannels = length(ex.setup.gv.elec);
        handles.currentChannels = 1:handles.nChannels;
        listChannels(handles);
        
        % only if online file is sc mapping expt
        %if contains(lower(ex.Header.onlineFileName),'none.txxty')
        if ex.exp.scmap
            
            handles = setInitParams(ex,handles);
            
            handles.onlineFileName = ex.Header.onlineFileName;
            handles.autoUpdate = 1;
            handles.lastTrial = ex.j-1;
        end
        guidata(hObject,handles)
    end
    
    setGUI(hObject);
    
end

if ismember('addtrials',varargin)

    % check if the GUI exists
    h = findall(0,'Tag','scMap','Type','figure');
    if isempty(h)
        handles = scmap;
        guidata(handles.output,handles);
    else
        handles = guidata(h);
    end
    
    % if autoUpdate is off, don't bother
    if ~handles.autoUpdate || ...
            seconds(datetime - handles.lastUpdateTime) < handles.updateInterval
        return
    end
   
    if isempty(ex) || ex.exp.scmap == 0 %~contains(lower(ex.Header.onlineFileName),'none.txxty')
        warning('no mapping expt in workspace.')
        return;
    end
    
    % check if onlineFileName matches
    if isempty(handles.onlineFileName) || ...
            ~strcmpi(handles.onlineFileName,ex.Header.onlineFileName)
        handles.onlineFileName = ex.Header.onlineFileName;
    end
    
    % check if online expt is listed
    hlist = findobj(handles.output,'Tag','exptList');
    if ~ismember(handles.onlineFileName,hlist.String)
        hlist.String = [hlist.String;{handles.onlineFileName}];
        hlist.Value = [hlist.Value,length(hlist.String)];
        hlist.Max = length(hlist.String);
        handles.lastTrial = ex.j - 1;
    end
    
    val = find(ismember(hlist.String,handles.onlineFileName));
    h = findobj(handles.output,'Tag','add2Selected');
    if h.UserData
        if ~ismember(val,hlist.Value)
            hlist.String = [hlist.String;{handles.onlineFileName}];
            [hlist.Value,idx] = sort([hlist.Value,val]);
            hlist.String = hlist.String(idx);
            hlist.Max = length(hlist.String);
        end
    else
        hlist.Value = val;
    end

    if strcmpi(ex.Header.onlineFileName,handles.onlineFileName) && ...
            ex.j > handles.lastTrial
        handles.addTrialsOnline = 1;
        handles.lastTrial = ex.j - 1;
        handles.lastUpdateTime = datetime;
    else
        handles.addTrialsOnline = 0;
    end
    

    % save
    guidata(handles.output,handles);
    
    if handles.addTrialsOnline
        whichPlot = [get(findobj(handles.output,'Tag','showRF'),'Value'),...
            get(findobj(handles.output,'Tag','showPSTH'),'Value')];
        updatePlots(handles,whichPlot,'addTrials');
        drawnow
    end
end

end

function handles = setInitParams(ex,handles)


switch ex.exp.scmap
    case 1  % memory-guided
        
        handles.rfStartEvent = 3;
        %handles.rfStartEventName = [];
        handles.rfStartTime = 0;
        handles.rfEndEvent = 3;
        %handles.rfEndEventName = [];
        handles.rfEndTime = ex.targ.duration * 1000;
        handles.psthAlignEvent = 2;
        %handles.psthAlignEventName = [];
        handles.psthAlignTime1 = 500;
        handles.psthAlignTime2 = 1500;
        
    case 2  % visual delayed-saccade
        handles.rfStartEvent = 3;
        %handles.rfStartEventName = [];
        handles.rfStartTime = 0;
        handles.rfEndEvent = 3;
        %handles.rfEndEventName = [];
        handles.rfEndTime = ex.targ.go_delay(1) * 1000;
        handles.psthAlignEvent = 2;
        %handles.psthAlignEventName = [];
        handles.psthAlignTime1 = 500;
        handles.psthAlignTime2 = 1500;

    case 3  % dot flashing
        handles.rfStartEvent = 2;
        %handles.rfStartEventName = [];
        handles.rfStartTime = 0;
        handles.rfEndEvent = 2;
        %handles.rfEndEventName = [];
        handles.rfEndTime = ex.fix.stimDuration * 1000;
        handles.psthAlignEvent = 1;
        %handles.psthAlignEventName = [];
        handles.psthAlignTime1 = handles.rfStartTime + 200;
        handles.psthAlignTime2 = handles.rfEndTime + 200;
    otherwise
end

% save
guidata(handles.output,handles);

tags.rfStartEvent = 'rfStart';
tags.rfStartTime = 'startTime';
tags.rfEndEvent = 'rfEnd';
tags.rfEndTime = 'endTime';
tags.psthAlignEvent = 'psthAlign';
tags.psthAlignTime1 = 'alignTime1';
tags.psthAlignTime2 = 'alignTime2';
tags.rfStartTime = 'startTime';

handles = setGUI(handles.output,tags);

end


function listChannels(handles)

h = findobj(handles.output,'Tag','channelList');
h.Max = handles.nChannels;
h.String = 1:handles.nChannels;
h.Value = handles.currentChannels;

end


% functions

function handles = setGUI(hObject,tags,listExpts)

if nargin == 1
    tags.rfStartEvent = 'rfStart';
    tags.rfStartTime = 'startTime';
    tags.rfEndEvent = 'rfEnd';
    tags.rfEndTime = 'endTime';
    tags.psthAlignEvent = 'psthAlign';
    tags.psthAlignTime1 = 'alignTime1';
    tags.psthAlignTime2 = 'alignTime2';
    tags.binWidth = 'binWidth';
    tags.rfStartTime = 'startTime';
    tags.showRF = 'showRF';
    tags.showPSTH = 'showPSTH';
    tags.autoUpdate = 'autoUpdate';
    
    listExpts = true;
    
elseif nargin == 2
    listExpts = false;
end

% set eventName fields
handles = guidata(hObject);

handlesField = fieldnames(tags);
for i=1:length(handlesField)
    h = findobj(hObject,'Tag',tags.(handlesField{i}));
    if isempty(h)
        error('object not found!')
    end
    
    if ismember(h.Style,{'popupmenu','togglebutton','checkbox'})
        h.Value = handles.(handlesField{i});
        
        switch h.Tag
            case 'rfStart'
                handles.rfStartEventName = h.UserData{h.Value};
            case 'rfEnd'
                handles.rfEndEventName = h.UserData{h.Value};
            case 'psthAlign'
                handles.psthAlignEventName = h.UserData{h.Value};
            otherwise
        end
    end
    
    if ismember(h.Style,{'edit'})
        h.String = handles.(handlesField{i});
    end
end

h = findobj(hObject,'Tag','dataPath');
h.String = handles.dataFolder;

h = findobj(hObject,'Tag','add2Selected');
h.UserData = handles.addTrials2SelectedExpts;
if h.UserData
    h.Text = 'Add Trials to Selected Expts OFF';
else
    h.Text = 'Add Trials to Selected Expts ON';
end

% save
guidata(handles.output,handles);

if listExpts
    % list expts
    listExpts_Callback(hObject, [],handles)
end

end



function updatePlots(handles,whichPlot,caller)

if nargin == 1
    whichPlot = true(1,2);
    caller = [];
elseif nargin == 2
    caller = [];
end

if ~strcmpi(caller,'addTrials') && handles.addTrialsOnline
    handles.addTrialsOnline = 0;
    guidata(handles.output,handles);
end

processData(handles);

handles = guidata(handles.output);

% response fields
if whichPlot(1) 
    plotRF(handles)
end

% psth
if whichPlot(2)
    plotPSTH(handles)
end

% update summary
if ~isempty(findobj(0,'Tag','summaryRF','Type','figure'))
    summaryRF_Callback([],[],handles)
end

end


function processData(handles)

handles = checkParams(handles);

h = findobj(handles.output,'Tag','exptList');
handles.data.files = h.String(h.Value);

nFiles = length(handles.data.files);
handles.data.params = cell(nFiles,1);
handles.data.paradigm = zeros(nFiles,1);
handles.data.spkCount = cell(nFiles,1);
handles.data.nPSTH = cell(nFiles,1);

handles.psth.binWidth = handles.binWidth/1000;
handles.psth.edges = -1*handles.psthAlignTime1/1000:handles.psth.binWidth:...
    handles.psthAlignTime2/1000;

if handles.addTrialsOnline && handles.autoUpdate
    
    tic
    i = ismember(handles.data.files,handles.onlineFileName);
    fn = fullfile(handles.dataFolder,handles.data.files{i});
    
    [s, handles] = processOneExpt(fn,handles,1);

    if s.nChannels ~= handles.nChannels
        warning('Number of channels does not match')
        handles.nChannels = s.nChannels;
    end
    handles.data.params{i} = s.params;
    handles.data.paradigm(i) = s.paradigm;
    handles.data.spkCount{i} = s.spkCount;
    handles.data.nPSTH{i} = s.nPSTH;
    toc

else
    
    for i=1:length(handles.data.files)
        fn = fullfile(handles.dataFolder,handles.data.files{i});
        
        if strcmpi(handles.data.files{i},handles.onlineFileName)
            [s, handles] = processOneExpt(fn,handles,1);
        else
            [s, handles] = processOneExpt(fn,handles,0);
        end
        if s.nChannels ~= handles.nChannels
            warning('Number of channels does not match')
            handles.nChannels = s.nChannels;
        end
        handles.data.params{i} = s.params;
        handles.data.paradigm(i) = s.paradigm;
        handles.data.spkCount{i} = s.spkCount;
        handles.data.nPSTH{i} = s.nPSTH;
    end
end

% save
guidata(handles.output,handles);

preparePlots(guidata(handles.output));

end


function [output,handles] = processOneExpt(fn,handles,online)

global ex

if nargin == 2
    online = false;
end

if online
    afile.ex = ex;
    handles.lastTrial = ex.j - 1;
else
    afile = load(fn,'ex');
end

if ~afile.ex.setup.recording
    warning('recording was off')
    output = [];
    return
end

%if length(afile.ex.Trials(1).oSpikes) ~= length(afile.ex.setup.gv.elec) || ...
%        length(afile.ex.Trials(1).oSpikes) < 24
if length(afile.ex.setup.gv.elec) > 1 && ...
        length(afile.ex.Trials(1).oSpikes) ~= length(afile.ex.setup.gv.elec)
    warning('ex.setup.gv setting was wrong!')
    output = [];
    return
end

% if rf event is wrong, set default values  
if afile.ex.exp.scmap == 3
    wrongEvent = 'targOn';
else
    wrongEvent = 'stimOn';
end

if any(strcmpi({handles.rfStartEventName,handles.rfEndEventName,...
        handles.psthAlignEventName},wrongEvent))
    handles = setInitParams(afile.ex,handles);
end


% set ex trial event
rfStartEvent = handles.rfStartEventName;
startOffset = handles.rfStartTime/1000;    % in seconds

rfEndEvent = handles.rfEndEventName;
endOffset = handles.rfEndTime/1000;

psthAlignEvent = handles.psthAlignEventName;

% activate later
idx = [afile.ex.Trials.Reward] == 1;
afile.ex.Trials = afile.ex.Trials(idx);

nChannels = length(afile.ex.setup.gv.elec);
% list channels
if ~isfield(handles,'nChannels')
    handles.nChannels = nChannels;
    handles.currentChannel = 1:handles.nChannels;
    
    h = findobj(handles.output,'Tag','channelList');
    h.Max = handles.nChannels;
    h.String = 1:handles.nChannels;
    h.Value = handles.currentChannel;
end

if afile.ex.exp.scmap == 3
    if isfield(afile.ex.Trials,'co')
        co = [afile.ex.Trials.co];
        h = findobj(handles.output,'Tag','stimContrast');
        if h.Value == 2
            idx = co > 0;
            afile.ex.Trials = afile.ex.Trials(idx);
        end
        if h.Value == 3
            idx = co < 0;
            afile.ex.Trials = afile.ex.Trials(idx);
        end
    end
    Tx = [afile.ex.Trials.x0]';
    Ty = [afile.ex.Trials.y0]';

    idx = ismember(Tx,afile.ex.exp.e1.vals) & ...
        ismember(Ty,afile.ex.exp.e2.vals);
    Tx = Tx(idx);
    Ty = -1 * Ty(idx);
    
else
    Tx = [afile.ex.Trials.Tx]';
    Ty = -1 * [afile.ex.Trials.Ty]';
end

% removem blank trials
idx = abs(Tx) > 1000 | abs(Ty) > 1000;
Tx(idx) = []; Ty(idx) = [];

Txy = unique([Tx, Ty],'rows');
nTargets = size(Txy,1);

varName = {'Tx','Ty','nTrials4RF','nTrials4PSTH'};
params = array2table([Txy,zeros(nTargets,length(varName)-2)],...
    'VariableNames',varName);

varName = {'Tx','Ty','spikeCount','countInterval','nTrials','firingRate'};
spkCount = repmat({array2table([Txy,zeros(nTargets,length(varName)-2)],...
    'VariableNames',varName)},nChannels,1);
nPSTH = repmat({uint16(zeros(nChannels,length(handles.psth.edges)-1))},nTargets,1);

for i=1:nTargets
    tridx = find(Tx == params.Tx(i) & Ty == params.Ty(i));
    n = length(tridx);
    nspks = zeros(nChannels,1);
    dur = 0;
    nTrials = 0;
    spkTimes = cell(nChannels,n);
    valid4PSTH = true(1,n);
    for j=1:n
        if nChannels > 1 && ...
                length(afile.ex.Trials(tridx(j)).oSpikes) ~= nChannels
            warning('number of channels does not match')
            nChannels = length(afile.ex.Trials(tridx(j)).oSpikes);
        end
        
        t1 = afile.ex.Trials(tridx(j)).times.(rfStartEvent) + ...
            startOffset -  afile.ex.Trials(tridx(j)).TrialStart;
        t2 = afile.ex.Trials(tridx(j)).times.(rfEndEvent) + ...
            endOffset -  afile.ex.Trials(tridx(j)).TrialStart;

        if ~isnan(t2-t2)
            for k=1:nChannels
                nspks(k) = nspks(k) + ...
                    sum(afile.ex.Trials(tridx(j)).oSpikes{k} >= t1 & ...
                    afile.ex.Trials(tridx(j)).oSpikes{k} < t2);
            end
            nTrials = nTrials + 1;
            dur = dur + t2 - t1;
        end
        %%%
        t3 = afile.ex.Trials(tridx(j)).times.(psthAlignEvent) ...
            - afile.ex.Trials(tridx(j)).TrialStart;
        
        if isnan(t3)
            valid4PSTH(j) = false;
        else
            for k=1:nChannels
                spkTimes{k,j} = afile.ex.Trials(tridx(j)).oSpikes{k} - t3;
            end            
        end
    end
    spkTimes = spkTimes(:,valid4PSTH);
    
    for k=1:nChannels
        spkCount{k}.spikeCount(i) = nspks(k);
        spkCount{k}.countInterval(i) = dur;
        spkCount{k}.nTrials(i) = nTrials;
        spkCount{k}.firingRate(i) = nspks(k)/dur;
        
        nPSTH{i}(k,:) = ...
            uint16(histcounts(cell2mat(spkTimes(k,:)),handles.psth.edges));
    end
    
    params.nTrials4RF(i) = nTrials;
    params.nTrials4PSTH(i) = sum(valid4PSTH);
    
end

output.params = params;
output.paradigm = afile.ex.exp.scmap;
output.spkCount = spkCount;
output.nPSTH = nPSTH;
output.nChannels = nChannels;

end


function preparePlots(handles)

nFiles = length(handles.data.files);

nChannels = length(handles.data.spkCount{1});

if nFiles == 1
    handles.rf.params = handles.data.params{1};
    handles.rf.data = handles.data.spkCount{1};
    
    nTargets = length(handles.data.nPSTH{1});
    oldParams = handles.psth.params;
    handles.psth.params = handles.data.params{1};
    handles.psth.fr = cell(nTargets,1);
    
    for i=1:length(handles.data.nPSTH{1})
        handles.psth.fr{i} = single(handles.data.nPSTH{1}{i})...
            /handles.psth.binWidth/handles.data.params{1}.nTrials4PSTH(i);
    end
    
    range_FR = [Inf,-Inf];
    for k=1:nChannels
        range_FR(1) = min([range_FR(1);handles.rf.data{k}.firingRate]);
        range_FR(2) = max([range_FR(2);handles.rf.data{k}.firingRate]);
    end
    
else
    T = [];
    for i=1:nFiles
        T = [T;handles.data.params{i}{:,{'Tx','Ty'}}];
    end
    T = unique(T,'rows');
    nTargets = size(T,1);
    
    varNames = handles.data.spkCount{1}{1}.Properties.VariableNames;
    spkCount = repmat({array2table([T,zeros(nTargets,length(varNames)-2)],...
        'VariableNames',varNames)},nChannels,1);
    
    varNames = handles.data.params{1}.Properties.VariableNames;
    params = array2table([T,zeros(nTargets,length(varNames)-2)],...
        'VariableNames',varNames);
    psth = repmat({zeros(nChannels,length(handles.psth.edges)-1,'single')},...
        nTargets,1);
    
    for i=1:nFiles
        for j=1:nTargets
            idx = handles.data.params{i}.Tx == params.Tx(j) & ...
                handles.data.params{i}.Ty == params.Ty(j);
            
            if sum(idx) == 1
            
                params.nTrials4RF(j) = params.nTrials4RF(j) + ...
                    handles.data.params{i}.nTrials4RF(idx); 
                params.nTrials4PSTH(j) = params.nTrials4PSTH(j) + ...
                    handles.data.params{i}.nTrials4PSTH(idx); 
                
                for k=1:nChannels
                    spkCount{k}.spikeCount(j) = spkCount{k}.spikeCount(j) + ...
                        handles.data.spkCount{i}{k}.spikeCount(idx);
                    spkCount{k}.countInterval(j) = spkCount{k}.countInterval(j) + ...
                        handles.data.spkCount{i}{k}.countInterval(idx);
                    spkCount{k}.nTrials(j) = spkCount{k}.nTrials(j) + ...
                        handles.data.spkCount{i}{k}.nTrials(idx);
                    
                    psth{j}(k,:) = psth{j}(k,:) + ...
                        single(handles.data.nPSTH{i}{idx}(k,:));
                end
            end
        end
    end
    
    range_FR = [Inf,-Inf];
    for k=1:nChannels
        spkCount{k}.firingRate = spkCount{k}.spikeCount ./ ...
            spkCount{k}.countInterval;
        range_FR(1) = min([range_FR(1);spkCount{k}.firingRate]);
        range_FR(2) = max([range_FR(2);spkCount{k}.firingRate]);
    end
    
    % convert to firing rate in spks/s
    for j=1:nTargets
        psth{j} = psth{j}/params.nTrials4PSTH(j)/handles.psth.binWidth;
    end
    
    handles.rf.params = params;
    handles.rf.data = spkCount;
    
    oldParams = handles.psth.params;
    handles.psth.params = params;
    handles.psth.fr = psth;
end

handles.rf.range = range_FR;

% set RF grids here
minRes = 0.1;
Tx = unique(handles.rf.params.Tx);
Ty = unique(handles.rf.params.Ty);
d = min([diff(Tx);diff(Ty)]);
gridRes = min([minRes,d/2]);
[handles.rf.grid.x, handles.rf.grid.y] = ...
    meshgrid(min(handles.rf.params.Tx):gridRes:max(handles.rf.params.Tx),...
    min(handles.rf.params.Ty):gridRes:max(handles.rf.params.Ty));

% list available target positions 
if isempty(oldParams) || ...
        ~(isempty(setdiff(oldParams(:,{'Tx','Ty'}),handles.psth.params(:,{'Tx','Ty'}))) && ...
        isempty(setdiff(handles.psth.params(:,{'Tx','Ty'}),oldParams(:,{'Tx','Ty'}))))
    str = cell(nTargets,1);
    for i=1:nTargets
        str{i} = sprintf('X=%3.1f, Y=%3.1f',handles.psth.params.Tx(i),...
            handles.psth.params.Ty(i));
    end
    
    h = findobj(handles.output,'Tag','target4psth');
    h.String = [{'Max'};{'All'};str];
    if h.Value > 2
        Tidx = h.Value - 2;
        idx = find(handles.psth.params.Tx == oldParams.Tx(Tidx) & ...
            handles.psth.params.Ty == oldParams.Ty(Tidx));
        if isempty(idx)
            warning('Target position is set to Max\n')
            h.Values = 1;
        else
            h.Value = idx + 2;
        end
    end
end


% set these flags zero
handles.rf.plotted = 0;
handles.psth.plotted = 0;

% save handles
guidata(handles.output,handles);

end


function plotPSTH(handles)

hf = findobj(0,'Tag',handles.psth.figureTag,'Type','figure');
% check if figure has been created
%hf = findobj(0,'Tag',handles.psth.figureTag,'Type','figure');
if isempty(hf)
    hf = figure;
    hf.Tag = handles.psth.figureTag;
    hf.Name = 'PSTH';
    hf.NumberTitle = 'on';
end

% check axes
if handles.nChannels == 24
    r = 6; c = 4;
elseif handles.nChannels == 32
    r = 8; c = 4;
elseif handles.nChannels == 1
    r = 1; c = 1;
else
    error('unknonwn channel number');
end

h = findobj(hf,'Tag','axis_ch1','Type','axes');
% plot all axes if axes for ch1 absent
if isempty(h)
    for i=1:handles.nChannels
        ha = subplot(r,c,i);
        ha.Tag = sprintf('axis_ch%d',i);
        ha.ButtonDownFcn = ...
            @(hObject,eventdata)channelSelected(ha,handles, [0,1]);
    end
end

showPSTH = get(findobj(handles.output,'Tag','showPSTH'),'Value');
if ~showPSTH
    hf.Visible = 'off';
    return
end

t = handles.psth.edges(1:end-1) + handles.psth.binWidth/2;

% this should be configurable
nTargets = size(handles.psth.params,1);
h = findobj(handles.output,'Tag','target4psth');
Tidx = h.Value;

meanFR = zeros(size(handles.psth.fr{1}),'single');
if Tidx == 2
    for i=1:nTargets
        meanFR = meanFR + handles.psth.fr{i};
    end
    meanFR = meanFR / nTargets;
end

ha = gobjects(handles.nChannels,1);
for i=1:handles.nChannels
    
    ha(i) = findobj(hf,'Tag',sprintf('axis_ch%d',i),'Type','axes');

    switch Tidx
        case 1
            [~,idx] = max(handles.rf.data{i}.firingRate);
            y = handles.psth.fr{idx}(i,:);
            ha(i).Title.String = sprintf('Ch %d (%3.1f,%3.1f, N=%d)',...
                i,handles.psth.params.Tx(idx),...
                handles.psth.params.Ty(idx),...
                handles.psth.params.nTrials4PSTH(idx));
        case 2
            y = meanFR(i,:);
            ha(i).Title.String = sprintf('Ch %d, N=%d',i,...
                sum(handles.psth.params.nTrials4PSTH));
            
        otherwise
            idx = Tidx - 2;
            y = handles.psth.fr{idx}(i,:);
            ha(i).Title.String = sprintf('Ch %d (%3.1f,%3.1f, N=%d)',...
                i,handles.psth.params.Tx(idx),...
                handles.psth.params.Ty(idx),...
                handles.psth.params.nTrials4PSTH(idx));
    end
    
    set(hf,'CurrentAxes',ha(i))
    h = findobj(ha(i),'Tag',sprintf('psth_ch%d',i));
    
    if isempty(h)
        h = line(t,y);
        h.Tag = sprintf('psth_ch%d',i);
        h.ButtonDownFcn = ...
            @(hObject,eventdata)channelSelected(handles, [0,1]);
    else
        h.XData = t;
        h.YData = y;
    end
   
end

set(ha,'TickDir','out','Box','off',...
    'XLim',t([1,end]),...
    'DataAspectRatioMode','auto')
if handles.nChannels == 1
    ha.XLabel.String = 'Time (s)';
    ha.YLabel.String = 'FR (spks/s)';
else
    set(ha(1:handles.nChannels-4),'XTickLabel',[],'XLabel',[])
    ha(handles.nChannels-3).XLabel.String = 'Time (s)';
    ha(handles.nChannels-3).YLabel.String = 'FR (spks/s)';
end

handles.psth.plotted = 1;
guidata(handles.output,handles)

hf_sel = findobj(0,'Tag','fig4SelectedPSTH','Type','Figure');
if ~isempty(hf_sel)
    plotSelectedChannels(hf_sel.UserData,[0,1]);
end

end


function clearRF(handles)
hf = findobj(0,'Tag',handles.rf.figureTag,'Type','figure');
if ~isempty(hf)
    for i=1:handles.nChannels
        ha = findobj(hf,'Tag',sprintf('axis_ch%d',i));
        if ~isempty(ha)
            hp = findobj(ha,'Tag',sprintf('pcolor_ch%d',i));
            
            if ~isempty(hp)
                delete(hp);
            end
            
            hl = findobj(ha,'Tag',sprintf('max_ch%d',i));
            if ~isempty(hl)
                delete(hl);
            end
            
            hcbar = findobj(hf,'Tag','scale');
            if ~isempty(hcbar)
                delete(hcbar);
            end
        end
        
    end
end
end


function plotRF(handles)

% for now, plot rf only when at least 3 target positions are available
nTargets = size(handles.rf.params,1);
if nTargets < 4
    clearRF(handles);
    return
end

hf = findobj(0,'Tag',handles.rf.figureTag,'Type','figure');
if isempty(hf)
    hf = figure;
    hf.Tag = handles.rf.figureTag;
    hf.Name = 'Response Field';
    hf.NumberTitle = 'off';
    hf.Colormap = jet(64);
end

% check axes
if handles.nChannels == 24
    r = 4; c = 6;
elseif handles.nChannels == 32
    r = 4; c = 8;
elseif handles.nChannels == 1
    r = 1; c = 1;
else
    error('unknonwn channel number');
end

h = findobj(hf,'Tag','axis_ch1','Type','axes');
% plot all axes if axes for ch1 absent
if isempty(h)
    for i=1:handles.nChannels
        ha = subplot(r,c,i);
        ha.Tag = sprintf('axis_ch%d',i);
    end
    ha = axes;
    ha.Tag = 'oneChannel';
    ha.Visible = 'off';
end


showRF = get(findobj(handles.output,'Tag','showRF'),'Value');
if ~showRF
    hf.Visible = 'off';
    return
end


varNames = {'channel','Xmax','Ymax','Rmax','Xinterp','Yinterp',...
    'Xfit','Yfit','Rsqr_fit','sigmaX','sigmaY'};
summaryTable = array2table(NaN(handles.nChannels,length(varNames)),...
    'VariableNames',varNames);
summaryTable.channel = (1:handles.nChannels)';

set(0,'CurrentFigure',hf)


%clim = zeros(handles.nChannels,2);
ha = gobjects(handles.nChannels,1);
for i=1:handles.nChannels
    
    ha(i) = findobj(hf,'Tag',sprintf('axis_ch%d',i));
    if isempty(ha(i))
        ha(i) = axes(hf,'Tag',sprintf('axis_ch%d',i));
    end
    set(hf,'CurrentAxes',ha(i))

    % Fit Gaussians by default
    fitOut = fitGaussian2(handles.rf.data{i}.Tx,...
        handles.rf.data{i}.Ty,handles.rf.data{i}.firingRate,...
        sqrt(handles.rf.data{i}.nTrials));
    
    summaryTable.Xfit(i) = fitOut.param.x0;
    summaryTable.Yfit(i) = fitOut.param.y0;
    summaryTable.Rsqr_fit(i) = fitOut.Rsqr;
    summaryTable.sigmaX(i) = fitOut.param.sigx;
    summaryTable.sigmaY(i) = fitOut.param.sigy;
    
    switch handles.mapType

        case 1
            F = scatteredInterpolant(handles.rf.data{i}.Tx,...
                handles.rf.data{i}.Ty,handles.rf.data{i}.firingRate);
            qz = F(handles.rf.grid.x,handles.rf.grid.y);
            [~,idx] = max(qz,[],'all','linear');
            [ii,jj] = ind2sub(size(qz),idx);
            summaryTable.Xinterp(i) = handles.rf.grid.x(1,jj);
            summaryTable.Yinterp(i) = handles.rf.grid.y(ii,1);
            
            hp = findobj(ha(i),'Tag',sprintf('pcolor_ch%d',i));
            if isempty(hp)
                hp = pcolor(handles.rf.grid.x,handles.rf.grid.y,qz);
                hp.ZData = qz;
                hp.LineStyle = 'none';
                hp.FaceColor = 'interp';
                hp.Tag = sprintf('pcolor_ch%d',i);
                ha(i).Tag = sprintf('axis_ch%d',i);
                hp.ButtonDownFcn = ...
                    @(hObject,eventdata)channelSelected(hp,[1,0]);
            else
                hp.XData = handles.rf.grid.x;
                hp.YData = handles.rf.grid.y;
                hp.ZData = qz;
                hp.CData = qz;
            end
            
        case 2
            hp = findobj(ha(i),'Tag',sprintf('scatter_ch%d',i));
            if isempty(hp)
                hp = scatter(handles.rf.data{i}.Tx,handles.rf.data{i}.Ty,60,...
                    handles.rf.data{i}.firingRate,'Filled');
                hp.Tag = sprintf('scatter_ch%d',i);
                ha(i).Tag = sprintf('axis_ch%d',i);
                hp.ButtonDownFcn = ...
                    @(hObject,eventdata)channelSelected(hp,[1,0]);
            else
                hp.XData = handles.rf.data{i}.Tx;
                hp.YData = handles.rf.data{i}.Ty;
                hp.CData = handles.rf.data{i}.firingRate;
            end
            
        case 3
            
            g = gaussian2(fitOut.param,handles.rf.grid.x,...
                handles.rf.grid.y);
            hp = findobj(ha(i),'Tag',sprintf('gaussian_ch%d',i));
            if isempty(hp)
                hp = imagesc(handles.rf.grid.x(1,:),handles.rf.grid.y(:,1)',g);
                ha(i).Tag = sprintf('axis_ch%d',i);
                hp.ButtonDownFcn = ...
                    @(hObject,eventdata)channelSelected(hp,[1,0]);
            else
                hp.XData = handles.rf.grid.x(1,:);
                hp.YData = handles.rf.grid.y(:,1)';
                hp.ZData = g;
            end
            
            ha(i).YDir = 'normal';
                
        otherwise
    end
    
    % plot target postion of the max response
    [maxR,idx] = max(handles.rf.data{i}.firingRate);
    
    summaryTable.Xmax(i) = handles.rf.data{i}.Tx(idx);
    summaryTable.Ymax(i) = handles.rf.data{i}.Ty(idx);
    summaryTable.Rmax(i) = maxR;
    
    hl = findobj(ha(i),'Tag',sprintf('max_ch%d',i));
    if isempty(hl)
        hl = line(handles.rf.data{i}.Tx(idx),...
            handles.rf.data{i}.Ty(idx),'Marker','+',...
            'MarkerFaceColor','r','MarkerEdgeColor','r',...
            'MarkerSize',10,'LineWidth',1);
        hl.Tag = sprintf('max_ch%d',i);
        hl.ZData = maxR + 1;
    else
        hl.XData = handles.rf.data{i}.Tx(idx);
        hl.YData = handles.rf.data{i}.Ty(idx);
        hl.ZData = maxR + 1;
    end
    
    ha(i).Title.String = sprintf('Ch %d',i);
    %clim(i,:) = ha(i).CLim;
end

%clim = handles.rf.range;
set(ha,'TickDir','out','Box','off',...
    'XLim',[min(handles.rf.data{i}.Tx),max(handles.rf.data{i}.Tx)],...
    'YLim',[min(handles.rf.data{i}.Ty),max(handles.rf.data{i}.Ty)],...
    'DataAspectRatioMode','auto')

if length(ha) == 1
    ha.XLabel.String = 'X (\circ)';
    ha.YLabel.String = 'Y (\circ)';
else
    ha(end-7).XLabel.String = 'X (\circ)';
    ha(end-7).YLabel.String = 'Y (\circ)';
end

hscale = findobj(hf,'Tag','scale');
if isempty(hscale)
    hcbar = findobj(hf,'Tag','scaleAxis');
    if isempty(hcbar)
        hcbar = axes;
        hcbar.Tag = 'scaleAxis';
        hcbar.Position(1) = sum(ha(end).Position([1,3]))+0.015;
        hcbar.Position(2) = ha(end).Position(2);
        hcbar.Position(3) = 0.015;
        if length(ha) == 1
        else
            hcbar.Position(4) = sum(ha(end-c).Position([2,4])) - ha(end).Position(2);
        end
    end
    
    set(hf,'CurrentAxes',hcbar);
    hscale = imagesc(1,linspace(0,1,64)',linspace(0,1,64)');
    set(hscale,'Tag','scale')
    hcbar.YDir = 'normal';
    hcbar.Tag = 'scaleAxis';
    hcbar.YAxisLocation = 'right';
    hcbar.XTick = [];
    hcbar.TickLength = [0,0];
end

handles.rf.summary = summaryTable;

handles.rf.plotted = 1;

guidata(handles.output,handles)

hf_sel = findobj(0,'Tag','fig4SelectedRF','Type','Figure');
if ~isempty(hf_sel)
    plotSelectedChannels(hf_sel.UserData,[1,0]);
end

end


function g = gaussian2(param,X,Y)

rho = param.rho;
sigx = param.sigx;
sigy = param.sigy;
x0 = param.x0;
y0 = param.y0;
A = param.A;
B = param.B;

g = A * (exp(-1*((X-x0).^2/sigx^2 + (Y-y0).^2/sigy^2 - ...
    2*rho*(X-x0).*(Y-y0)/(sigx*sigy))/(2*(1-rho^2)))) + B;

end




function [handles, rfParamsChanged, psthParamsChanged] = checkParams(handles)

global ex

if isempty(ex)
    handles.onlineFileName = [];
else
    handles.onlineFileName = ex.Header.onlineFileName;
end

% check if the time parameters are the same
% things to check
% rf time parameters
% psth time parameters
% current selcted files
rfTimeSet = {'rfStartEvent','rfStartTime','rfEndEvent','rfEndTime'};
psthTimeSet = {'psthAlignEvent','psthAlignTime1','psthAlignTime2',...
    'binWidth','psthTarget'};

rfParamsChanged = false; 
psthParamsChanged = false;

if isempty(handles.data)
    rfParamsChanged = true;
    psthParamsChanged = true;
end


% check params and update currentSettings
for i=1:length(rfTimeSet)
    if handles.currentSetting.rf.(rfTimeSet{i}) ~= handles.(rfTimeSet{i})
        handles.currentSetting.rf.(rfTimeSet{i}) = handles.(rfTimeSet{i});
        rfParamsChanged = true;
    end
end

for i=1:length(psthTimeSet)
    if handles.currentSetting.psth.(psthTimeSet{i}) ~= handles.(psthTimeSet{i})
        handles.currentSetting.psth.(psthTimeSet{i}) = handles.(psthTimeSet{i});
        psthParamsChanged = true;
    end
end

% set ex trial event
h = findobj(handles.output,'Tag','rfStart');
handles.rfStartEventName = h.UserData{h.Value};
handles.currentSetting.rf.rfStartEventName = handles.rfStartEventName;

h = findobj(handles.output,'Tag','rfEnd');
handles.rfEndEventName = h.UserData{h.Value};
handles.currentSetting.rf.rfEndEventName = handles.rfEndEventName;

h = findobj(handles.output,'Tag','psthAlign');
handles.psthAlignEventName = h.UserData{h.Value};
handles.currentSetting.psth.psthAlignEventName = handles.psthAlignEventName;

end


function plotSelectedChannels(hObject,whichPlot)

if whichPlot(1)

    delete(findobj(hObject,'Type','DataTip'));

    hf = findobj(0,'Tag','fig4SelectedRF','Type','Figure');
    if isempty(hf)
        hf = figure('Tag','fig4SelectedRF');
        hf.Colormap = jet(64);
    end
    
    set(0,'CurrentFigure',hf)
    clf
    set(hf,'UserData',hObject);
    ha = copyobj(hObject,hf);
    ha.Position = [0.1300 0.1100 0.7750 0.8150];
    colorbar
    ha.XLabel.String = 'X (\circ)';
    ha.YLabel.String = 'Y (\circ)';

end

if whichPlot(2)
    hf = findobj(0,'Tag','fig4SelectedPSTH','Type','Figure');
    if isempty(hf)
        hf = figure('Tag','fig4SelectedPSTH');
    end
    set(0,'CurrentFigure',hf)
    clf
    set(hf,'UserData',hObject);
    ha = copyobj(hObject,hf);
    ha.Position = [0.1300 0.1100 0.7750 0.8150];
    ha.XTickLabelMode = 'auto';
    ha.XLabel.String = 'Time (s)';
    ha.YLabel.String = 'Firing Rate (spks/s)';
end

end

function channelSelected(hObject,whichPlot)

persistent click_time
click_threshold = 1;

% check double clicking
if isempty(click_time)
    click_time = tic;
else
    time_between_clicks = toc(click_time);
    click_time = tic;
    if time_between_clicks < click_threshold
        plotSelectedChannels(hObject.Parent,whichPlot);
    end
end

end


% callback functions

function mapType_Callback(hObject, eventdata, handles)

doUpdate = false;
if handles.mapType ~= hObject.Value
    handles.mapType = hObject.Value;
    guidata(handles.output,handles);
    doUpdate = true;
end

if handles.autoUpdate && doUpdate
    updatePlots(handles,[1,0]);
end

end

function rfStart_Callback(hObject, eventdata, handles)

doUpdate = false;
if handles.rfStartEvent ~= hObject.Value
    handles.rfStartEvent = hObject.Value;
    handles.rfStartEventName = hObject.UserData{hObject.Value};
    guidata(handles.output,handles);
    doUpdate = true;
end

if handles.autoUpdate && doUpdate
    updatePlots(handles,[1,0]);
end

end

function startTime_Callback(hObject, eventdata, handles)

doUpdate = false;
val = str2double(hObject.String);

if handles.rfStartTime ~= val
    doUpdate = true;
    handles.rfStartTime = val;
    guidata(handles.output,handles);
end

if handles.autoUpdate && doUpdate
    updatePlots(handles,[1,0]);
end

end

function rfEnd_Callback(hObject, eventdata, handles)

doUpdate = false;
if handles.rfEndEvent ~= hObject.Value
    handles.rfEndEvent = hObject.Value;
    handles.rfEndEventName = hObject.UserData{hObject.Value};
    guidata(handles.output,handles);
    doUpdate = true;
end

if handles.autoUpdate && doUpdate
    updatePlots(handles,[1,0]);
end

end

function endTime_Callback(hObject, eventdata, handles)

doUpdate = false;
val = str2double(hObject.String);
if handles.rfEndTime ~= val
    doUpdate = true;
    handles.rfEndTime = val;
    guidata(handles.output,handles);
end

if handles.autoUpdate && doUpdate
    updatePlots(handles,[1,0]);
end

end

function psthAlign_Callback(hObject, eventdata, handles)

doUpdate = false;
if handles.psthAlignEvent ~= hObject.Value
    doUpdate = true;
    handles.psthAlignEvent = hObject.Value;
    handles.psthAlignEventName = hObject.UserData{hObject.Value};
    guidata(handles.output,handles);
end

if handles.autoUpdate && doUpdate
    updatePlots(handles,[0,1]);
end

end

function alignTime1_Callback(hObject, eventdata, handles)

doUpdate = false;
val = str2double(hObject.String);

if handles.psthAlignTime1 ~= val
    doUpdate = true;
    handles.psthAlignTime1 = str2double(hObject.String);
    guidata(handles.output,handles);
end

if handles.autoUpdate && doUpdate
    updatePlots(handles,[0,1]);
end

end

function alignTime2_Callback(hObject, eventdata, handles)

doUpdate = false;
val = str2double(hObject.String);

if handles.psthAlignTime2 ~= val
    doUpdate = true;
    handles.psthAlignTime2 = val;
    guidata(handles.output,handles);
end

if handles.autoUpdate && doUpdate
    updatePlots(handles,[0,1]);
end

end

function summaryRF_Callback(hObject,eventdata,handles)

fontSize = 18;

hf = findobj(0,'Tag','summaryRF','Type','figure');

if isempty(hf)
    hf = figure('Tag','summaryRF');
end

co = lines(2);
set(0,'CurrentFigure',hf);
clf
ha = subplot(1,2,1);
line(handles.rf.summary.Xmax,handles.rf.summary.channel,'Marker','o',...
    'Color',co(1,:),'MarkerFaceColor',co(1,:))
line(handles.rf.summary.Xfit,handles.rf.summary.channel,'Marker','o',...
    'Color',co(2,:))
idx = handles.rf.summary.Rsqr_fit > 0.6;
line(handles.rf.summary.Xfit(idx),handles.rf.summary.channel(idx),...
    'Marker','o','MarkerFaceColor',co(2,:),'Color',co(2,:),...
    'LineStyle','none')

xlabel('Peak X (\circ)','FontSize',fontSize)
ylabel('Channel','FontSize',fontSize)
set(gca,'TickDir','out','Box','off','YDir','reverse',...
    'YLim',[0,handles.nChannels+1],'YTick',[1,5:5:handles.nChannels])
   
pos = ha.Position;
ha.Position(4) = ha.Position(4)*0.8;
pos(2) = sum(ha.Position([2,4])) + 0.01;
pos(4) = 0.15;
ha = axes('Position',pos,'XLim',[0,1],'YLim',[0,1]);

str = {'Mean','Median';...
    sprintf('%4.2f\\circ',mean(handles.rf.summary.Xmax)),...
    sprintf('%4.2f\\circ',median(handles.rf.summary.Xmax));...
    sprintf('%4.2f\\circ',mean(handles.rf.summary.Xfit)),...
    sprintf('%4.2f\\circ',median(handles.rf.summary.Xfit))};
text(0.05,0.4,str(1,:),'FontSize',fontSize)
text(0.4,0.4,str(2,:),'FontSize',fontSize,'Color',co(1,:))
text(0.75,0.4,str(3,:),'FontSize',fontSize,'Color',co(2,:))
text(0.4,0.9,'Data','FontSize',fontSize);
text(0.75,0.9,'Fit','FontSize',fontSize);
ha.Visible = 'off';

ha = subplot(1,2,2);
line(handles.rf.summary.Ymax,handles.rf.summary.channel,'Marker','o',...
    'Color',co(1,:),'MarkerFaceColor',co(1,:))
line(handles.rf.summary.Yfit,handles.rf.summary.channel,'Marker','o',...
    'Color',co(2,:))
line(handles.rf.summary.Yfit(idx),handles.rf.summary.channel(idx),...
    'Marker','o','MarkerFaceColor',co(2,:),'Color',co(2,:),...
    'LineStyle','none')
xlabel('Peak Y (\circ)','FontSize',fontSize)
ylabel('Channel','FontSize',fontSize)
set(gca,'TickDir','out','Box','off','YDir','reverse',...
    'YLim',[0,handles.nChannels+1],'YTick',[1,5:5:handles.nChannels])
    
pos = ha.Position;
ha.Position(4) = ha.Position(4)*0.8;
pos(2) = sum(ha.Position([2,4])) + 0.01;
pos(4) = 0.15;
ha = axes('Position',pos,'XLim',[0,1],'YLim',[0,1]);
str = {'Mean','Median';...
    sprintf('%4.2f\\circ',mean(handles.rf.summary.Ymax)),...
    sprintf('%4.2f\\circ',median(handles.rf.summary.Ymax));...
    sprintf('%4.2f\\circ',mean(handles.rf.summary.Yfit)),...
    sprintf('%4.2f\\circ',median(handles.rf.summary.Yfit))};
text(0.05,0.4,str(1,:),'FontSize',fontSize)
text(0.4,0.4,str(2,:),'FontSize',fontSize,'Color',co(1,:))
text(0.75,0.4,str(3,:),'FontSize',fontSize,'Color',co(2,:))
text(0.4,0.9,'Data','FontSize',fontSize);
text(0.75,0.9,'Fit','FontSize',fontSize);
ha.Visible = 'off';

end


function showRF_Callback(hObject, eventdata, handles)

val = get(hObject,'Value');
handles.showRF = val;
if val
    hObject.String = 'Hide';
else
    hObject.String = 'Show';
end
guidata(handles.output,handles);

h = findobj(0,'Tag',handles.rf.figureTag,'Type','figure');
if isempty(h)
    updatePlots(handles,[1,0]);
    h = findobj(0,'Tag',handles.rf.figureTag,'Type','figure');
end

if ~isempty(h)
    if val
        h.Visible = 'on';
        if ~handles.rf.plotted
            plotRF(handles);
        end
    else
        h.Visible = 'off';
    end
end

end

function showPSTH_Callback(hObject, eventdata, handles)

val = get(hObject,'Value');
handles.showPSTH = val;
if val
    hObject.String = 'Hide';
else
    hObject.String = 'Show';
end
% save changes
guidata(handles.output,handles);


h = findobj(0,'Tag',handles.psth.figureTag,'Type','figure');
if isempty(h)
    updatePlots(handles,[0,1]);
    h = findobj(0,'Tag',handles.psth.figureTag,'Type','figure');
end

if ~isempty(h)
    if val
        h.Visible = 'on';
        if ~handles.psth.plotted
            plotPSTH(handles);
        end
    else
        h.Visible = 'off';
    end
end

end

function binWidth_Callback(hObject, eventdata, handles)

doUpdate = false;
val = str2double(hObject.String);

if handles.binWidth ~= val
    doUpdate = true;
    handles.binWidth = val;
    handles.psth.binWidth = handles.binWidth;
    guidata(handles.output,handles);
end

if handles.autoUpdate && doUpdate
    updatePlots(handles,[0,1]);
end

end

function target4psth_Callback(hObject,eventdata,handles)

doUpdate = false;
val = hObject.Value;

if handles.psthTarget ~= val
    doUpdate = true;
    handles.psthTarget = val;
    guidata(handles.output,handles);
end    

if handles.autoUpdate && doUpdate
    updatePlots(handles,[0,1]);
end

end


function exptList_Callback(hObject, eventdata, handles)

persistent click_time
click_threshold = 0.5;

% check double clicking
if isempty(click_time)
    click_time = tic;
else
    time_between_clicks = toc(click_time);
    click_time = tic;
    if time_between_clicks < click_threshold
        % do load expt
        loadExpt_Callback(hObject, [], handles)
    end
end

end

function channelList_Callback(hObject, eventdata, handles)

handles.currentChannel = get(hObject,'Value');
guidata(handles.output,handles);

fprintf('It is still under construction.\n')

end

function dataPath_Callback(hObject, eventdata, handles)

handles.oldDataFolder = handles.dataFolder;

newfolder = uigetdir;
handles.dataFolder = newfolder;
hObject.String = newfolder;
guidata(handles.output,handles);
listExpts_Callback(hObject,[],handles);

end

function listExpts_Callback(hObject, eventdata, handles)

if isempty(handles.dataFolder)
    return
end

global ex

handles.addTrialsOnline = 0;

hlist = findobj(handles.output,'Tag','exptList');

d = [dir(fullfile(handles.dataFolder,'*none.TXxTY.mat'));...
    dir(fullfile(handles.dataFolder,'*dot.XPosxYPos*.mat'))];
[~,idx] = sort([d.datenum]);
d = d(idx);

fileNames = cell(length(d),1);
valid = false(length(d),1);
for i=1:length(d)
    fn = fullfile(d(i).folder,d(i).name);
    afile = load(fn,'ex');
    % filter out defective expts
    if isfield(afile.ex,'Trials') && afile.ex.setup.recording == 1 && ...
            ~isempty(afile.ex.Trials) && ...
            afile.ex.setup.gv.readOnlineSpikes == 1
        if length(afile.ex.setup.gv.elec) == 1
            valid(i) = true;
        else
            if length(afile.ex.Trials(1).oSpikes) == length(afile.ex.setup.gv.elec)
                
                valid(i) = true;
            end
        end
        fileNames{i} = d(i).name;
    end
end
fileNames = fileNames(valid);

% call from listExpts
if strcmpi(hObject.Tag,'listExpts')
    if isempty(setdiff(fileNames,hlist.String))
        % if new list is the same as the old one, do nothing
        disp('no addtional expts to list.')
        return
    end
end

%if isempty(ex)
%    ex = afile.ex;
%end

% check for validity of the current ex in workspace
listOnlineFile = false;
if ~isempty(ex) && strcmpi(ex.Header.onlineDirName,handles.dataFolder) && ...
        ex.setup.recording == 1 && ...
        ex.setup.gv.readOnlineSpikes == 1 && ...
        length(ex.Trials(1).oSpikes) == length(ex.setup.gv.elec) && ...
        length(ex.setup.gv.elec) >= 24
    
    if ~strcmpi(ex.Header.onlineFileName,handles.onlineFileName)
        warning('onlineFile is reassigned!')
        handles.onlineFileName = ex.Header.onlineFileName;
    end
    
    listOnlineFile = true;
end

if listOnlineFile && ~ismember(handles.onlineFileName,fileNames)
    fileNames{end+1} = handles.onlineFileName;
end    

nFiles = length(fileNames);
if nFiles > 0
    hlist.String = fileNames;
    hlist.Value = nFiles;
    hlist.Max = nFiles;
    
    % add trial types
    trialType = zeros(nFiles,1);
    for i=1:nFiles
        if strcmpi(handles.onlineFileName,hlist.String{i})
            trialType(i) = ex.exp.scmap;
        else
            fn = fullfile(handles.dataFolder,hlist.String{i});
            afile = load(fn,'ex');
            trialType(i) = afile.ex.exp.scmap;
        end
    end
    hlist.UserData = trialType;
    
    handles.currentFiles = hlist.String(hlist.Value);
    
    % added on 7.31.2023.
    handles.currentTrialType = trialType(hlist.Value);
    
    guidata(handles.output,handles)
    
    whichPlot = [get(findobj(handles.output,'Tag','showRF'),'Value'),...
        get(findobj(handles.output,'Tag','showPSTH'),'Value')];
    updatePlots(handles,whichPlot);

else
    % if no files, restore dataPath back and do nothing
    warning('no valid mapping expts found in %s',handles.dataFolder)
    h = findobj(handles.output,'Tag','dataPath');
    handles.dataFolder = handles.oldDataFolder;
    h.String = handles.dataFolder;
    guidata(handles.output,handles)

end

end


function autoUpdate_Callback(hObject, eventdata, handles)

val = get(hObject,'Value');
handles.autoUpdate = val;
guidata(handles.output,handles);

end


function update_Callback(hObject, eventdata, handles)

whichPlot = [get(findobj(handles.output,'Tag','showRF'),'Value'),...
    get(findobj(handles.output,'Tag','showPSTH'),'Value')];
updatePlots(handles,whichPlot);

end


function selectAll_Callback(hObject, eventdata, handles)

handles.currentChannel = 1:handles.nChannels;

h = findobj(handles.output,'Tag','channelList');
h.Value = handles.currentChannel;
guidata(handles.output,handles);

fprintf('It is still under construction\n')

end


function loadExpt_Callback(hObject, eventdata, handles)

updatePlots(guidata(handles.output));

end


function add2Selcted_Callback(hObject,eventdata,handles)

if hObject.UserData
    disp('Add Trials to Selected Expts OFF')
    hObject.Text = 'Add Trials to Selected Expts ON';
    hObject.UserData = 1;
    handles.addTrials2SelectedExpts = 1;
else
    disp('Add Trials to Selected Expts ON')
    hObject.Text = 'Add Trials to Selected Expts OFF';
    hObject.UserData = 0;
    handles.addTrials2SelectedExpts = 0;
end
guidata(handles.output,handles);

end


function paradigm_Callback(hObject,eventdata,handles)

h = findobj(handles.output,'Tag','exptList');

if hObject.Value == 1
    val = find(ismember(h.UserData,[1,2]));
    %h.Value = 1:h.Max;
else
    val = find(h.UserData == hObject.Value-1);
end

if isempty(val)
    warning('no %s Saccade expts found',hObject.String{hObject.Value})
else
    h.Value = val;
end

end

function stimContrast_Callback(hObject,eventdata,handles)
if handles.currentTrialType == 3
    updatePlots(guidata(handles.output));
end
end




% create uicontrols
function hf = createGUI()

% set default font size
fontSize = 12;
if strcmpi(computer,'GLNXA64')
    fontSize = 9;
end

% main figure
hf = findall(0,'Tag','scMap','Type','figure');
if isempty(hf)
    hf = figure;
else
    % delete existing window
    clf(hf);
end

voffset = 34;

hf.Position([3,4]) = [420 520];
hf.Position([3,4]) = [420 600];
hf.Position([3,4]) = [420 630];
set(hf,'Tag','scMap','Name','scMap','MenuBar','none',...
    'Resize','off','NumberTitle','off');
hf.HandleVisibility = 'off';

hf.Position([1,2]) = [142,982];


% added
uicontrol(...
    'Parent',hf,...
    'HorizontalAlignment','left',...
    'String','Map Type',...
    'Style','text',...
    'Position',[31 434+80+voffset 60 27],...
    'Tag','labelMapType',...
    'FontSize',fontSize);

uicontrol(...
    'Parent',hf,...
    'Units',get(0,'defaultuicontrolUnits'),...
    'FontUnits',get(0,'defaultuicontrolFontUnits'),...
    'String',{'Interpolant'; 'Scatter'; 'Gaussian Fit'},...
    'Style','popupmenu',...
    'Value',1,...
    'ValueMode',get(0,'defaultuicontrolValueMode'),...
    'Position',[94 432+80+voffset 160 27],...
    'Callback',@(hObject,eventdata)mapType_Callback(hObject,eventdata,guidata(hObject)),...
    'Children',[],...
    'Tag','mapType',...
    'FontSize',fontSize-0);

uicontrol(...
    'Parent',hf,...
    'String','Summary',...
    'Style','pushbutton',...
    'Position',[277 468+80+voffset 72 27],...
    'Callback',@(hObject,eventdata)summaryRF_Callback(hObject,eventdata,guidata(hObject)),...
    'Tag','summaryRF',...
    'FontSize',fontSize);
    
% end of addition


uicontrol(...
    'Parent',hf,...
    'Units',get(0,'defaultuicontrolUnits'),...
    'FontUnits',get(0,'defaultuicontrolFontUnits'),...
    'String',{'Fixation Acquired'; 'Stimulus Onset'; 'Target Onset'; ...
    'Fixation Off';'Target Acquired'; 'Reward'},...
    'UserData',{'fpOn';'stimOn';'targOn';'fpOff';'choice';'reward'},...
    'Style','popupmenu',...
    'Value',2,...
    'ValueMode',get(0,'defaultuicontrolValueMode'),...
    'Position',[94 432+80 160 27],...
    'Callback',@(hObject,eventdata)rfStart_Callback(hObject,eventdata,guidata(hObject)),...
    'Children',[],...
    'Tag','rfStart',...
    'FontSize',fontSize-0);

uicontrol(...
    'Parent',hf,...
    'String',{'Fixation Acquired'; 'Stimulus Onset'; 'Target Onset'; ...
    'Fixation Off'; 'Target Acquired'; 'Reward'},...
    'UserData',{'fpOn';'stimOn';'targOn';'fpOff';'choice';'reward'},...
    'Style','popupmenu',...
    'Value',2,...
    'Position',[94 398+80 160 27],...
    'Callback',@(hObject,eventdata)rfEnd_Callback(hObject,eventdata,guidata(hObject)),...
    'Tag','rfEnd',...
    'FontSize',fontSize-0);

uicontrol(...
    'Parent',hf,...
    'String',{'Stimulus Onset'; 'Target Onset'; 'Fixation Off';...
    'Target Acquired' },...
    'UserData',{'stimOn'; 'targOn'; 'fpOff'; 'choice'},...
    'Style','popupmenu',...
    'Value',1,...
    'Position',[94 316+80 160 27],...
    'Callback',@(hObject,eventdata)psthAlign_Callback(hObject,eventdata,guidata(hObject)),...
    'Tag','psthAlign',...
    'FontSize',fontSize-0);

uicontrol(...
    'Parent',hf,...
    'String',{'X = 0, Y = 0'},...
    'Style','popupmenu',...
    'Value',1,...
    'Position',[94 282+80 160 27],...
    'Callback',@(hObject,eventdata)target4psth_Callback(hObject,eventdata,guidata(hObject)),...
    'Tag','target4psth',...
    'FontSize',fontSize-0);

uicontrol(...
    'Parent',hf,...
    'String','0',...
    'Style','edit',...
    'Value',1,...
    'Position',[94 248+80 60 27],...
    'Callback',@(hObject,eventdata)binWidth_Callback(hObject,eventdata,guidata(hObject)),...
    'Tag','binWidth',...
    'FontSize',fontSize-0);

uicontrol(...
    'Parent',hf,...
    'HorizontalAlignment','left',...
    'String','ms',...
    'Style','text',...
    'Position',[162 248+80-5 30 27],...
    'Tag','text1',...
    'FontSize',fontSize);

uicontrol(...
    'Parent',hf,...
    'HorizontalAlignment','left',...
    'String','Contrast',...
    'Style','text',...
    'Position',[210 248+80-5 60 27],...
    'Tag','text1',...
    'FontSize',fontSize);

uicontrol(...
    'Parent',hf,...
    'String',{'Both', 'Positive', 'Negative'},...
    'Style','popupmenu',...
    'Value',1,...
    'Position',[270 248+80-5 120 27],...
    'Callback',@(hObject,eventdata)stimContrast_Callback(hObject,eventdata,guidata(hObject)),...
    'Tag','stimContrast',...
    'FontSize',fontSize-0);


uicontrol(...
    'Parent',hf,...
    'String','0',...
    'Style','edit',...
    'Position',[277 434+80 72 27],...
    'Callback',@(hObject,eventdata)startTime_Callback(hObject,eventdata,guidata(hObject)),...
    'Tag','startTime',...
    'FontSize',fontSize);

uicontrol(...
    'Parent',hf,...
    'String','Hide',...
    'Style','togglebutton',...
    'Position',[277 468+80 72 27],...
    'Callback',@(hObject,eventdata)showRF_Callback(hObject,eventdata,guidata(hObject)),...
    'Tag','showRF',...
    'FontSize',fontSize);

    
h = uicontrol(...
    'Parent',hf,...
    'Style','listbox',...
    'Value',1,...
    'ValueMode',get(0,'defaultuicontrolValueMode'),...
    'Position',[31 58 218 150],...
    'Callback',@(hObject,eventdata)exptList_Callback(hObject,eventdata,guidata(hObject)),...
    'Tag','exptList',...
    'FontSize',fontSize-0);

cm = uicontextmenu(hf);
uimenu(cm,'Text','Load',...
    'Tag','loadExpt',...
    'Callback',@(hObject,eventdata)loadExpt_Callback(hObject,eventdata,guidata(hObject)));
uimenu(cm,'Text','Add Trials to Selected Expts',...
    'Tag','add2Selected',...
    'Callback',@(hObject,eventdata)add2Selcted_Callback(hObject,eventdata,guidata(hObject)));
h.ContextMenu = cm;


uicontrol(...
    'Parent',hf,...
    'Style','listbox',...
    'Value',1,...
    'Position',[278 58 102 150],...
    'Callback',@(hObject,eventdata)channelList_Callback(hObject,eventdata,guidata(hObject)),...
    'Tag','channelList',...
    'FontSize',fontSize-0);

uicontrol(...
    'Parent',hf,...
    'String','',...
    'Style','edit',...
    'Position',[31 242 218 27],...
    'Callback',@(hObject,eventdata)dataPath_Callback(hObject,eventdata,guidata(hObject)),...
    'Tag','dataPath',...
    'FontSize',fontSize-0);

uicontrol(...
    'Parent',hf,...
    'String',{'Both';'Memory-Guided';'Delayed-Visual'},...
    'Style','popupmenu',...
    'Position',[258 240 130 27],...
    'Callback',@(hObject,eventdata)paradigm_Callback(hObject,eventdata,guidata(hObject)),...
    'Tag','paradigm',...
    'FontSize',fontSize-0);

uicontrol(...
    'Parent',hf,...
    'String','Data Folder',...
    'Style','text',...
    'Position',[31 242+28 218 27],...
    'Tag','text2',...
    'FontSize',fontSize);

uicontrol(...
    'Parent',hf,...
    'String','Select Paradigm',...
    'Style','text',...
    'Position',[258 242+28 130 27],...
    'Tag','text40',...
    'FontSize',fontSize);

uicontrol(...
    'Parent',hf,...
    'String','Response Field',...
    'Style','text',...
    'Position',[97 462+80+voffset 145 27],...
    'Tag','text3',...
    'FontSize',fontSize);

uicontrol(...
    'Parent',hf,...
    'String','Auto',...
    'Style','checkbox',...
    'Position',[31 26 60 27],...
    'Callback',@(hObject,eventdata)autoUpdate_Callback(hObject,eventdata,guidata(hObject)),...
    'Tag','autoUpdate',...
    'FontSize',fontSize);

uicontrol(...
    'Parent',hf,...
    'String','Update',...
    'Style','pushbutton',...
    'Position',[91 26 80 27],...
    'Callback',@(hObject,eventdata)update_Callback(hObject,eventdata,guidata(hObject)),...
    'Tag','update',...
    'FontSize',fontSize);

uicontrol(...
    'Parent',hf,...
    'String','List',...
    'Position',[179 210 70 27],...
    'Callback',@(hObject,eventdata)listExpts_Callback(hObject,eventdata,guidata(hObject)),...
    'Tag','listExpts',...
    'FontSize',fontSize);

uicontrol(...
    'Parent',hf,...
    'String','PSTH',...
    'Style','text',...
    'Position',[97 343+80 145 27],...
    'Tag','text4',...
    'FontSize',fontSize);

uicontrol(...
    'Parent',hf,...
    'String','Show',...
    'Style','togglebutton',...
    'Position',[277 349+80 72 27],...
    'Callback',@(hObject,eventdata)showPSTH_Callback(hObject,eventdata,guidata(hObject)),...
    'Tag','showPSTH',...
    'FontSize',fontSize);

uicontrol(...
    'Parent',hf,...
    'HorizontalAlignment','left',...
    'String','Start',...
    'Style','text',...
    'Position',[31 434+80 60 27],...
    'Tag','text5',...
    'FontSize',fontSize);

uicontrol(...
    'Parent',hf,...
    'HorizontalAlignment','left',...
    'String','End',...
    'Style','text',...
    'Position',[31 398+80 60 27],...
    'Tag','text6',...
    'FontSize',fontSize);

uicontrol(...
    'Parent',hf,...
    'HorizontalAlignment','left',...
    'String','Align',...
    'Style','text',...
    'Position',[31 316+80 60 27],...
    'Tag','text7',...
    'FontSize',fontSize);

uicontrol(...
    'Parent',hf,...
    'HorizontalAlignment','left',...
    'String','Target',...
    'Style','text',...
    'Position',[31 282+80 60 27],...
    'Tag','text8',...
    'FontSize',fontSize);

uicontrol(...
    'Parent',hf,...
    'HorizontalAlignment','left',...
    'String','Width',...
    'Style','text',...
    'Position',[32 248+80-5 50 27],...
    'Tag','text9',...
    'FontSize',fontSize);

uicontrol(...
    'Parent',hf,...
    'String','0',...
    'Style','edit',...
    'Position',[277 398+80 72 27],...
    'Callback',@(hObject,eventdata)endTime_Callback(hObject,eventdata,guidata(hObject)),...
    'Tag','endTime',...
    'FontSize',fontSize);

uicontrol(...
    'Parent',hf,...
    'String','0',...
    'Style','edit',...
    'Position',[277 316+80 72 27],...
    'Callback',@(hObject,eventdata)alignTime1_Callback(hObject,eventdata,guidata(hObject)),...
    'Tag','alignTime1',...
    'FontSize',fontSize);

uicontrol(...
    'Parent',hf,...
    'String','0',...
    'Style','edit',...
    'Position',[277 282+80 72 27],...
    'Callback',@(hObject,eventdata)alignTime2_Callback(hObject,eventdata,guidata(hObject)),...
    'Tag','alignTime2',...
    'FontSize',fontSize);

uicontrol(...
    'Parent',hf,...
    'String','Expt',...
    'Style','text',...
    'Position',[31 210 48 27],...
    'Tag','text10',...
    'FontSize',fontSize);

uicontrol(...
    'Parent',hf,...
    'String','Channel',...
    'Style','text',...
    'Position',[282 210 90 27],...
    'Tag','text11',...
    'FontSize',fontSize);

uicontrol(...
    'Parent',hf,...
    'HorizontalAlignment','left',...
    'String','ms',...
    'Style','text',...
    'Position',[358 396+80 30 27],...
    'Tag','text12',...
    'FontSize',fontSize);

uicontrol(...
    'Parent',hf,...
    'HorizontalAlignment','left',...
    'String','ms',...
    'Style','text',...
    'Position',[358 433+80 30 27],...
    'Tag','text13',...
    'FontSize',fontSize);


uicontrol(...
    'Parent',hf,...
    'HorizontalAlignment','left',...
    'String','ms',...
    'Style','text',...
    'Position',[358 314+80 30 27],...
    'Tag','text14',...
    'FontSize',fontSize);

uicontrol(...
    'Parent',hf,...
    'HorizontalAlignment','left',...
    'String','ms',...
    'Style','text',...
    'Position',[358 282+80 30 27],...
    'Tag','text15',...
    'FontSize',fontSize);

uicontrol(...
    'Parent',hf,...
    'String','+',...
    'Style','text',...
    'Position',[254 434+80 24 27],...
    'Tag','text16',...
    'FontSize',fontSize);


uicontrol(...
    'Parent',hf,...
    'String','+',...
    'Style','text',...
    'Position',[254 398+80 24 27],...
    'Tag','text17',...
    'FontSize',fontSize);

uicontrol(...
    'Parent',hf,...
    'String','-',...
    'Style','text',...
    'Position',[254 316+80 24 27],...
    'Tag','text18',...
    'FontSize',fontSize);

uicontrol(...
    'Parent',hf,...
    'String','+',...
    'Style','text',...
    'Position',[254 282+80 24 27],...
    'Tag','text19',...
    'FontSize',fontSize);

uicontrol(...
    'Parent',hf,...
    'String','Select All',...
    'Style','pushbutton',...
    'Position',[279 26 96 27],...
    'Callback',@(hObject,eventdata)selectAll_Callback(hObject,eventdata,guidata(hObject)),...
    'Tag','selectAll',...
    'FontSize',fontSize);

end

