function handles = plotFiles(handles,varargin)
handles
%% Variable inputs
pa = inputParser;
addOptional(pa, 'populationResponse', false);  % default is plotTC
addOptional(pa,'raster',false);
parse(pa, varargin{:});
inputs = pa.Results;

if isfield(handles,'selectedExFiles')
    flist = handles.selectedExFiles;
    if isfield(handles,'exFileDirname')
    fdir = handles.exFileDirname;
    else
        fdir = get(handles.exFileDir,'String');
        handles.exFileDirname = fdir;
        guidata(handles.figure1,handles);
    end
else flist = handles;
    fdir = pwd;
end    

bigFile = {};
if length(flist)>1
    for n = 1:length(flist)
        fname = [fdir '/' flist{n}];
        disp('currently working on file:')
        disp(fname)
        ex_n=load(fname);
        % first check whether there are empty fields for hdx2, Dc2, hdx_seq2
        % because of instruction trials.  If so, set these to NaN
        ex_n = fillEmptyTrialFields(ex_n.ex,'hdx2','Dc2','hdx_seq');

        if isempty(bigFile)
            bigFile = ex_n;
        else
            [bigFile,ex_n] = trackStimvalsSettings(bigFile,ex_n);        
            [bigFile,ex_n] = matchTrialFields(bigFile,ex_n);
            fields = fieldnames(bigFile.Trials);
            ex_n.Trials = orderfields(ex_n.Trials,fields);
            ntr = length(bigFile.Trials);
            bigFile.Trials(ntr+1: ntr+length(ex_n.Trials)) = ex_n.Trials;
        end
    end
else 
    fname = [fdir '/' flist{1}];
    disp(fname);
    ex_n=load(fname);
    bigFile = ex_n.ex;
end

% plot population response if requested
if inputs.populationResponse
    [bigFile, vtr] = voltage2Spikes(bigFile);
    figH = plotPopulationTC(bigFile,vtr);
    handles.currentFigure = figH;
    return
end

% plot raster if requested
if inputs.raster
    [bigFile, vtr] = voltage2Spikes(bigFile);
    figH = plotRaster(bigFile,vtr);
    handles.currentFigure = figH;
    return
end



if bigFile.exp.afc
    fig_h=figure;
    [~,~,~,tr,xvals,~,N,Trials]=plotPerformance(bigFile);
    if bigFile.setup.recording
        fig_h2=figure;
        plotTC(bigFile,'Trials',Trials,tr,xvals);
        handles.secondFig = fig_h2;
    end
    handles.currentFigure = fig_h;
    if get(handles.plotppRC,'value')
        ppRC(bigFile);
    end
elseif ~isempty(findstr(fname,'RC'))
    figure;
    PlotRevCorAny_tue(bigFile);
elseif isfield(bigFile.exp,'e1') && isfield(bigFile.exp,'e2') &&...
        strcmpi(bigFile.exp.e2.type, [bigFile.exp.e1.type, '2'])
    ex2 = bigFile;
    ex2.exp = rmfield(ex2.exp,'e2');
    fig_h = figure;
    plotTC(ex2);
    handles.currentFigure = fig_h;
    ex2 = bigFile;
    ex2.exp.e1 = ex2.exp.e2
    ex2.exp = rmfield(ex2.exp,'e2');
    
    plotTC(ex2,'PlotHoldOn','LineStyle','--');
    disp('in plot 2 exp')
else
    if get(handles.superimpose,'Value')
        if isfield(handles,'currentFigure') &~isempty(handles.currentFigure)
            set(0,'currentFigure',handles.currentFigure)
        else  
            a = get(0,'currentfigure');
            if ~isempty(a); set(0,'currentFigure',a(end));
            else
                fig_h = figure;
                handles.currentFigure = fig_h;
            end
        end
        plotTC(bigFile,'PlotHoldOn','LineStyle','--');
    else 
        fig_h=figure;
        plotTC(bigFile);
        handles.currentFigure = fig_h;
    end
end
guidata(handles.figure1,handles);
set(gcf,'position',[672    33   555   518]);
        