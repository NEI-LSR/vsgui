function plotRF(ex,figh,figh2 ,varargin)
% function plotTC(ex)
%
% plots RF properties RC stimulus 

% history
% 06/26/18  hn: wrote it

disp('in plotRF')
tic
j=1;
plot_hold_on = 0;
iTrials = [];
lineStyle = '-';
latency = [];
% default: plot x vs y position
xvar = 'x0_seq'; 
yvar = 'y0_seq';
zvar = 'or_seq';
latency = 0.05;
duration = 0.2;
if nargin<3
    figh2 = figure;
end
if nargin <2
    figh = figure;
end
while j<nargin-2
    str = varargin{j};
    switch str
        case {'linestyle','LineStyle','lineStyle','Linestyle'}
            lineStyle = varargin{j+1};
            j=j+1;
        case 'PlotHoldOn'
         plot_hold_on = 1;
        case 'Trials'
            beh_data_flag = 1;
            iTrials = varargin{j+1};
            i_tr = varargin{j+2};
            x_vals = varargin{j+3};
            j=j+3;
        case 'latency'
            latency = varargin{j+1};
        case 'duration'
            duration = varargin{j+1};
    end
    j=j+1;
end

if (~isfield(ex.Trials(1),'oRate') && ~isfield(ex.Trials(end),'oRate')) && ...
    (~isfield(ex.Trials(1),'Rate') && ~isfield(ex.Trials(end),'Rate'))
    disp('no spikes found')
    return;
end

itr = (find((abs([ex.Trials.Reward])>0)));
if length(itr)<2
    disp('too few trials')
    return
end

% if we have fixation trials take those
if ~isempty(itr)
    Trials = ex.Trials(itr);
else Trials = ex.Trials;  % for testing purposes when we don't have fixation trials
end
% check, which parameters we have varied
allfields = {'phase_seq','st_seq','me_seq','sf_seq','or_seq','co_seq','x0_seq','y0_seq'};
cnt = 1;
for n = 1:length(allfields)
    if ~isempty(eval(['Trials(1).' allfields{n}]))
        myfields{cnt} = allfields{n};
        cnt = cnt+1;
    end
end

% NOTE: we only read out the spike times for the first channel, cluster 0; we
% will hence only plot these

% pre-processing and formatting the data
% equalize lengths of Trials
len = nan(1,length(Trials));
for n = 1:length(Trials)
    len(n) = length(Trials(n).Start);
end

lmin = min(len);
spk = [];
for n = 1:length(Trials)
    Trials(n).Start = Trials(n).Start(1:lmin);
    for n2 = 1:length(myfields)
        Trials(n).(myfields{n2})= Trials(n).(myfields{n2})(1:lmin);
    end
    % have spike times in absolute times on PTB clock, just like starttimes
    % of each videoframe
    Trials(n).oSpikes = Trials(n).oSpikes+Trials(n).TrialStart;
    % put spike times in one long vector
    spk = [spk,Trials(n).oSpikes];
end
starts = [Trials.Start];

% we are simply ignoring the separation into trials and convert the values
% for each stimulus dimension into one long vector

% use x and y as the first two dimensions we plot
xseq = []; yseq=[]; zseq = [];
if isfield(Trials(1),xvar);
    xseq = [Trials.(xvar)];
    xs = unique(xseq);
end
if isfield(Trials(1),yvar)
    yseq = [Trials.(yvar)];
    ys = unique(yseq);
end
if isfield(Trials(1),zvar)
    zseq = [Trials.(zvar)];
    zs = unique(zseq);
end

% get 2D data, collapsing over z and 3D data
sta_2D = nan(length(xs),length(ys)); % stimulus triggered average response
sta_3D = nan(length(xs),length(ys),length(zs));
for n1 = 1:length(xs)
    for n2 = 1:length(ys)
        idx = find(abs(xseq-xs(n1))<0.001 & abs(yseq-ys(n2))<0.001);
        ispk = NaN;
        if ~isempty(idx)
            for tr = 1:length(idx);
                ispk(tr) = sum(spk>starts(idx(tr))+latency & ...
                    spk>starts(idx(tr))+latency+duration);
            end
            sta_2D(n1,n2) = mean(ispk)/duration;
        end
        for n3 = 1:length(zs)
            idx = find(abs(xseq-xs(n1))<0.001 & abs(yseq-ys(n2))<0.001 &....
                abs(zseq-zs(n3))<0.001);
            ispk = NaN;
            if ~isempty(idx)
                for tr = 1:length(idx) 
                    ispk(tr) = sum(spk>starts(idx(tr))+latency & ...
                        spk>starts(idx(tr))+latency+duration);
                end
                sta_3D(n1,n2,n3) = mean(ispk)/duration;
            end
        end
    end
end

% 
figure(figh)
imagesc(sta_2D')
xlabel(strrep(xvar,'_seq',''));
ylabel(strrep(yvar,'_seq',''));
set(gca,'xtick',[1:2:length(xs)],'xticklabel',[xs([1:2:length(xs)])], ...
    'ytick',[1:2:length(ys)],'yticklabel',[ys([1:2:length(ys)])]);

% plot 3D data with 3rd dimension in different subplots
figure(figh2);
ncol = ceil(length(zs)/4);
for n = 1:length(zs)
    subplot(ncol,4,n)
    imagesc(squeeze(sta_3D(:,:,n))');
    title(num2str(zs(n)));
end

toc


      






