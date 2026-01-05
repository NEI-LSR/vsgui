function [mn_,se_,cl,extra_mn_,extra_se_,vals1,vals2,N,N_bl,tr,Trials,cp_,rateByTrial]= plotTC(ex,varargin)

% function plotTC(ex)
%
% plots a tuning curve of the currently run experiment

% history
% 08/05/14  hn: wrote it
% 01/02/15  hn: included options to plot up to three clusters (cl 0 to 2)
% 03/03/15  hn: for adaptation do not extract mean response for adapter.
% 07/12/15  hn: oRate for sorted spikes are now spike rates and no longer
%           spike counts
% 09/20/15  hn: now also returns the number of trials per condition
% 10/05/15  hn: now also returns the trial-indices (tr) and the corresponding 
%           Trials after exlcuding fixation breaks and extras
% 10/06/15  hn: now make sure that we only plot spikes for completed cycles
%           of the drifting grating stimuli

% 11/3/16: ToDos: update for display of 24-ch activity- done, but it's very
%           slow (3-5sec); 
% 11/18/16: 
% 01/22/17  hn: now read out CP, rateByTrial

disp('in TC')

tic
j=1;
plot_hold_on = 0;
beh_data_flag = 0;
iTrials = [];
lineStyle = '-';
N_bl=[];
N=[];
mn_={};
se_={};
cl={};
extra_mn_={};
extra_se_={};
vals1=[];
vals2=[];
Trials = {};
rateByTrial={};
tr={};
cp_=[];
latency = [];
while j<nargin
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
    end
    j=j+1;
end


if (~isfield(ex.Trials(1),'oRate') && ~isfield(ex.Trials(end),'oRate')) && ...
    (~isfield(ex.Trials(1),'Rate') && ~isfield(ex.Trials(end),'Rate'))
    disp('no spikes found')
    return;
end

% don't plot responses for bar stimulus
if strcmpi(ex.stim.type,'bar')
    return
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

valid = true(length(Trials),1);
for i=1:length(Trials)
    if isempty(Trials(i).oRate)
        valid(i) = false;
    end
end
Trials = Trials(valid);

% get the the spikes for the individual clusters
if length(ex.setup.gv.elec)<=2
    cl = {['cl1'],['cl2'],['cl3'],['cl4'],['cl0']};
else 
    % 
    %ex.setup.gv.elec = [1:2:31,2:2:16]; % channel map for V-probe
    for n=1:length(ex.setup.gv.elec)
        cl{n} = ['cl' num2str(ex.setup.gv.elec(n))];
    end
end


% do we have sorted Spikes?  If so, plot these
if isfield(Trials,'Spikes')
    cl={'cl1'};
    for n = 1:length(Trials)
        spks = Trials(n).Spikes;
        sts = Trials(n).Start - Trials(n).TrialStart; % in sec
        if ex.stim.vals.adaptation
            sts = sts(find(sts>ex.stim.vals.adaptationDur));
        end
        frame_duration = mean(diff(sts));
        
        % make sure we only use full cycles in case we have a grating
        % stimulus
        stim_duration = sts(end)-sts(1)+frame_duration;
        if isempty(latency)
            offset = sts(1);
        else offset = latency;
        end
        if strcmpi(ex.stim.type,'grating') && Trials(n).st == 1
            if isfield(Trials(n),'tf') &~isempty(Trials(n).tf) 
                tf = Trials(n).tf;
            else tf=ex.stim.vals.tf;
            end
            period = 1/tf;
            ncycles =floor(stim_duration/period);
            
            if ncycles >0 % hack to include trials even if we have less than a complete cycle
                offset = stim_duration-ncycles*period;
                stim_duration = ncycles*period;   
            else
                disp('warning: stim duration < period of stimulus')
            end
        end
        
        oRate.cl1 = [];
        if length(sts)>=1
            oRate.cl1 = length(find(spks>=offset & ...
                spks<=offset+stim_duration))/stim_duration;
        else
            oRate.cl1 = [];
        end
        Trials(n).oRate = oRate;
    end
end

% for backward compatibility: (we now read out spikes for diff. clusters)
if ~isfield(Trials(1).oRate,'cl1') && ~isfield(Trials(end).oRate,'cl1')
    disp('in backward compatibility')
    for n = 1:length(Trials)
        Trials(n).oRate.cl1 = Trials(n).oRate;
        Trials(n).oRate.cl0 = [];
        Trials(n).oRate.cl2 = [];
    end
end

% unless we are given the information to plot already in the input
% select these 

if isempty(iTrials)
    % first get trials for blank stimulus
    extra_mn = [];
    extra_se = [];
    blTrials = [];
    if ex.exp.include_blank
        bl_tr = find([Trials.st] ==0);
        st_tr = find([Trials.st] ==1);
        blTrials = Trials(bl_tr);
        Trials = Trials(st_tr);
        N_bl = length(bl_tr);
    end

    % what are the tuning parameters?
    par1=[];
    if isfield(ex,'exp') && isfield(ex.exp,'e1')
        par1 = ex.exp.e1.type;
    end
    par2=[];
    if isfield(ex,'exp') && isfield(ex.exp,'e2')
        par2 = ex.exp.e2.type;
    end
    
    % in case we concatenated two experiments with different ocularity
    if isempty(par2)
        if isfield(Trials,'me') && length(unique([Trials.me]))>1
            par2 = 'me';
        end
    end
    
    vals1 = []; vals2 = [];
    if ~isempty(par1)
        vals1 = eval(['unique([Trials.' par1 ']);']);
    end
    if ~isempty(par2)
        vals2 = eval(['unique([Trials.' par2 ']);']);
    end

        
    % get the sorted trials for the remaining stimuli 
    legendstr = {};
    tr = {};
    for n1 = 1:length(vals1)
        if length(vals2)>0
            for n2 = 1:length(vals2)
                idx = find(eval(['[Trials.' par1 '] == vals1(n1) & [Trials.' ...
                    par2 '] == vals2(n2)']));
                tr{n2,n1} = idx;
                N(n2,n1) = length(idx);
                legendstr{n2} = [par2 '=' num2str(vals2(n2))];
            end
        else
            idx = find(eval(['[Trials.' par1 '] == vals1(n1)'])); 
            tr{n1} = idx;
            N(n1) = length(idx);
        end
    end
else
    disp('in using these trials')
    blTrials = [];
    Trials = iTrials;
    tr = i_tr;
    N = [];
    vals1 = x_vals(1,:);
    legendstr = {};
    par1=[];
end


[mn_,se_,cl,extra_mn_,extra_se_,rateByTrial] = getRate4Clusters(Trials,blTrials,tr,cl);
cp_=[];
if ex.exp.afc
    cp_ = computeCP(Trials,cl);
end

% now plot the data
% adjust figure position
set(gcf,'position',[1182         416         735         570]);
%initialize variables
subplot_pos = cell(1,length(mn_));

switch length(mn_)
    case 0
        return
    case 1
        subplot_pos{1} = [0.1    0.25    0.87    0.7];
    case 2
        % 2 subplots:
        subplot_pos{1} = [.1    0.60    0.87    0.35];
        subplot_pos{2} = [0.1    0.25    0.75    0.34];
    case 3
        % 3 subplots:
        subplot_pos{1} = [0.1    0.7    0.87   0.25];
        subplot_pos{2} = [ 0.1    0.47    0.75    0.22];
        subplot_pos{3} = [ 0.1    0.25    0.75    0.21];
    case 4
        % 4 subplots:
        subplot_pos{1} = [0.1    0.79    0.87   0.2];
        subplot_pos{2} = [ 0.1    0.61    0.75    0.18];
        subplot_pos{3} = [ 0.1    0.41    0.75    0.2];
        subplot_pos{4} = [ 0.1    0.23    0.75    0.18];
    case 24
        % 24 subplots:
        % adjust figure position
        set(gcf,'position',[1182         56         735         920])
        hi = 0.07;
        hi_s = 1/14;
        wi = 0.35;
        for n=1:24
            if n<13
                subplot_pos{n} = [0.1 1-(n+1)*hi_s wi hi];
            else 
                subplot_pos{n} = [0.6 1-(n-11)*hi_s wi hi];
            end

        end
    otherwise
        set(gcf,'position',[1182         56         735         920])
        hi = 0.07;  
        hi_s = 1/14;
        cn = ceil(length(mn_)/12); % number of columns

        li = 1/(cn+1).^2; % left position
        wi = 1/(cn+1);    % subplot width
        wi_s = li+wi; 
        
        for n = 1:length(mn_)
            subplot_pos{n} = [li+floor((n-1)/12)*wi_s 1-2*hi_s-(mod(n-1,12))*hi_s wi hi];
        end        
end
        

if plot_hold_on
    for n = 1:length(subplot_pos)
        y_pos(n) = subplot_pos{n}(2);
    end
    c = get(gcf,'children');
    for n=1:length(c)
        h = get(c(n));
        % we delete existing legends
        if isfield(h,'Location')
            delete(c(n));
        end
    end
    c = get(gcf,'children');
    for n = 1:length(c);
        pos = get(c(n),'position');
        y_pos(n) = pos(2);
        x_pos(n) = pos(1);
    end
    for n = 1:length(subplot_pos)
        [idx] = find(abs(y_pos-subplot_pos{n}(2))<0.001 & abs(x_pos -subplot_pos{n}(1))<0.001);
        %[min_d idx2 ] =min(abs(x_pos - subplot_pos{n}(1)));
        subplot_axis(n) = c(idx);
    end
end
    
        
cols = colormap(hsv(size(mn_{1},1)));

pre_ylim = [];
pre_xlim = [];
for n = 1:length(mn_)
    
    
    if ~plot_hold_on;
        subplot('position',subplot_pos{n});
        hold off
    else
        set(gcf,'currentaxes',subplot_axis(n));
        pre_ylim = get(gca,'ylim');
        pre_xlim = get(gca,'xlim');
        hold on;
    end
    if beh_data_flag
        mn = [fliplr(mn_{n}(1,:)) mn_{n}(2,:)];
        se = [fliplr(se_{n}(1,:)) se_{n}(2,:)];
        hold on;
    else
        mn = mn_{n};
        se = se_{n};
    end
    for n1 = 1:size(mn,1)
        if n==1;
            ms = 8;
            lw = 2;
            fs = 18;
        else fs = 10;
        end
        errorbar(vals1,mn(n1,:),se(n1,:),'s','lineStyle',lineStyle,'color',cols(n1,:),...
            'markersize',ms,'markerfacecolor',cols(n1,:),'linewidth',lw);
        hold on;
        if ~isempty(N)
            for n2 = 1:size(mn,2);
                %text(1.03*vals1(n2),1.05*mn(n1,n2),num2str(N(n1,n2)),'fontsize',fs);
            end
        end
    end
    extra_mn = extra_mn_{n};
    extra_se = extra_se_{n};
    xlim = [vals1(1)-mean(diff(vals1)) vals1(end)+mean(diff(vals1))];
    
    if ~isempty(extra_mn) && ~isempty(mn) && length(vals1)>=2 
        legendstr{length(legendstr)+1} = 'blank';
        errorbar(2*vals1(end)-vals1(end-1),extra_mn,extra_se,'ko','markersize',ms);
        xlim(2) = 2*vals1(end)-vals1(end-1) + mean(diff(vals1));
        hold on;
    end
    xlim(1) = min([xlim,pre_xlim]); xlim(2) = max([xlim,pre_xlim]);
    % are we having an adaptation stimulus? If so, mark the adapter
    if ex.stim.vals.adaptation
        plot(ones(1,2)*ex.stim.vals.adaptationOr,get(gca,'ylim'),'--k','linewidth',1);
    end

    % display the number of trials on subplot 1
    ntr = length(find((abs([Trials.Reward])>0)));
    if n == 1;
       title(['# of trials: ' num2str(ntr) ])
    end
    
    % include the legend
    if ~isempty(legendstr) && n==1
        l_h=legend(legendstr,'Location','best');
    end

    
    % format plot
    % log xscale for SF, TF, SZ and CO
    if strcmpi(par1,'sf') || strcmpi(par1,'tf') || strcmpi(par1,'sz')|| strcmpi(par1,'co')
        set(gca,'xscale','log');
    end

    if sum(isnan(mn))>0
        ylim = get(gca,'ylim');
    else
        ylim = [0 max(max(mn))+max([0 0.2*max(max(mn))+1])];
        if ~isempty(pre_ylim)
            ylim = [ylim(1) max([pre_ylim(2) ylim(2)])];
        end
    end
    set(gca,'ylim',ylim, 'fontsize',15,'fontweight','bold')
    
    if n == length(mn_)
        xlabel(par1)
        ylabel ('spike rate (ips)');
    else set(gca,'xticklabel','');
    end
    
    xlim = xlim(~isnan(xlim));
    xlim = xlim(~isinf(xlim));
    if length(xlim) ==2
        if xlim(2)>1000
            xlim = [-1.5  1.5];
        end
        set(gca,'xlim',xlim);
    end
    ylim = get(gca,'ylim');
    xp = 1;
    yp=1;
    if size(xlim,2)==2 
         xp = xlim(2) - 0.1*diff(xlim);
    end
    if size(ylim,2) ==2
        yp = ylim(1)+ 0.1*diff(ylim);
    end
    
    t(n) = text(xp,yp,['c: ' cl{n}(3:end)]);
    if ~isempty(cp_)
        yp2 = ylim(1)+0.3*diff(ylim);
        text(xp,yp2,['cp:' num2str(round(cp_(n)*1000)/1000)]);
    end
    % adjust the width of the subplots panels after plotting the legend
    if ~isempty(legendstr) && n==1
        ipos = get(gca,'position');
        for k = 2:length(mn_)
            subplot_pos{k}(3) = ipos(3);
        end
    end
end

toc
% -------------------------------------------------------------------
function [mn,se,cl_new,extra_mn,extra_se,rateByTrial] = getRate4Clusters(Trials,blTrials,tr,cl)

% check for which clusters we have spikes
for nc = 1:length(cl)
    if isfield(Trials(1).oRate,cl{nc})
        for n = 1:length(Trials)
            eval([cl{nc} '(n)= mean(Trials(n).oRate.' cl{nc} ');']);
        end
    else
        eval([cl{nc} '=NaN;'])
    end
end

for nc = 1:length(cl)
    eval([cl{nc} '=' cl{nc} '(~isnan(' cl{nc} '));']);
    % remove empty channels for single channel recordings
    if length(cl)<=5
        if isempty(eval(cl{nc})) 
            cl{nc} = {};
        elseif eval(['sum(' cl{nc} ')==0'])
            cl{nc} = {};
        end
    end
end

% get means and SEs for clusters that have spikes
cnt = 0;
cl_new = {};
mn = {};
se = {};
extra_mn = {};
extra_se = {};
rateByTrial = {};
for nc = 1:length(cl)
    if ~isempty(cl{nc})|| length(cl)==24
        cnt = cnt+1;
        cl_new{cnt} = cl{nc};
        for n1 = 1:size(tr,2)
            for n2 = 1:size(tr,1)
                itr = tr{n2,n1};
                iRate = [];
                for n3 = 1:length(itr);
                    iRate(n3) = eval(['Trials(itr(n3)).oRate.' cl{nc} ';']);
                end
                rateByTrial{cnt,n2,n1} = iRate;
                mn{cnt}(n2,n1) = mean(iRate); 
                se{cnt}(n2,n1) = std(iRate)/sqrt(length(itr)); 
            end
        end
        iRate  = [];
        extra_mn{cnt} = NaN;
        extra_mn{cnt} = NaN;
        for n1 = 1:length(blTrials)
            iRate(n1) = eval(['blTrials(n1).oRate.' cl{nc} ';']);
        end
        extra_mn{cnt}= mean(iRate); 
        extra_se{cnt}= std(iRate)/sqrt(length(iRate)); 
    end
end


% -------------------------------------------------------------------
function [cp] = computeCP(Trials,cl);
cp=[];
% check for which clusters we have spikes
for nc = 1:length(cl)
    if isfield(Trials(1).oRate,cl{nc})
        for n = 1:length(Trials)
                eval([cl{nc} '(n)= mean(Trials(n).oRate.' cl{nc} ');']);
        end
    else eval([cl{nc} '=NaN;'])
    end
end       
  
for nc = 1:length(cl)
    eval([cl{nc} '=' cl{nc} '(~isnan(' cl{nc} '));']);
    % remove empty channels for single channel recordings
    if length(cl)<=5
        if isempty(eval(cl{nc})) 
            cl{nc} = {};
        elseif eval(['sum(' cl{nc} ')==0'])
            cl{nc} = {};
        end
    end
end

% get CP for 0% signal stimuli
% assign choices
if isfield(Trials,'hdx')
    for n = 1:length(Trials)
        if (Trials(n).hdx<0 && Trials(n).Reward>0 )|| ...
                (Trials(n).hdx>0 && Trials(n).Reward<0) 
            Trials(n).Choice = -1; % near choice
        elseif (Trials(n).hdx<0 && Trials(n).Reward<0) || ...
                (Trials(n).hdx>0 && Trials(n).Reward>0)
            Trials(n).Choice = 1; % far choice
        else Trials(n).Choice = 0;
        end
    end
elseif isfield(Trials,'or')
    dxs = unique(round([Trials.or]));
    val1 = dxs;
    if length(dxs)> 2
        disp('more than two orientations')
        return
    end
    for n = 1:length(Trials)
        if (Trials(n).or==val1(1) && Trials(n).Reward>0 )|| ...
                (Trials(n).or==val1(2) && Trials(n).Reward<0) 
            Trials(n).Choice = -1; % or2  choice
        elseif (Trials(n).or==val1(1) && Trials(n).Reward<0) || ...
                (Trials(n).or == val1(2) && Trials(n).Reward>0)
            Trials(n).Choice = 1; % or1 choice
        else Trials(n).Choice = 0;
        end
    end
else
    disp('unknown experiment')
    return
end

itr = find(abs([Trials.Dc])<0.001);
size(itr)
cl_new = {};
cnt = 0;
for nc = 1:length(cl)
    if ~isempty(cl{nc})|| length(cl)==24
        cnt = cnt+1;
        cl_new{cnt} = cl{nc};
        iRate = [];
        for n3 = 1:length(itr);
            iRate(n3) = eval(['Trials(itr(n3)).oRate.' cl{nc} ';']);
        end
        nc = find([Trials(itr).Choice]<0);
        fc = find([Trials(itr).Choice]>0);
        cp(cnt) = rocN(iRate(nc),iRate(fc));
    end
end

% disp('stop')
% rt = iRate(nc),iRate(fc);
% [x,idx_s] = sort([nc,fc]);
%  bins = [50:15:150];
% figure; hist(iRate(nc(1:13)),bins);
% hold on;
% hold on; hist(iRate(fc(1:13)),bins)
% 
% figure;
% plot(iRate(nc),'ro','markerfacecolor','r')
% hold on;
% plot(iRate(fc),'bo','markerfacecolor','b')
% 
% 
% 
% 
% 
% 
