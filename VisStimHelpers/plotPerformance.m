function [x,y,n_reps,tr,xvals,yvals,N,Trials]=plotPerformance(ex,varargin)
% plot BehPerformance(ex,varargin)

% history: 2014 hn: wrote it
%          07/13/15 hn: included analysis for fixation breaks
%          10/23/15 hn: exclude two trials after tos for spatial attention
%          task
%          10/26/15 hn: also plot performance based on uncued stimulus
%          11/24/15 hn:  fixation breaks are now counted when they occur
%          after half the stimulus duration


trEye = [];
x=[];
y=[];
n_reps=[];
tr=[];
xvals=[];
yvals = [];
N = [];
Trials = [];
n_frames = ex.setup.refreshRate*ex.fix.stimDuration;
fix_duration = round(0.5*n_frames); % number of stimulus frames required to include trial 
%                   in fixation break analysis
plot_off = 0;
spike_flag = 0;
if nargin>1
    trEye = varargin{1};
end
j=2;
while j<nargin
    str = varargin{j}
    if strcmpi(str,'fix_dur') 
        fix_duration = varargin{j+1};
    elseif strcmpi(str,'no_plot');
        plot_off = 1;
    elseif strcmpi(str,'spikes')
        spike_flag = 1; % plot neural data if we recorded some
    end
    j=j+1;
end

set(gcf,'position',[1171         416         741         570]);

% plot eye position traces in bottom part of figure 
if ~isempty(trEye)
    plotEyePosTraces(ex,trEye);
end

% plot1: dx vs Dc; collapsed across target positions; separated by target
% position
% are we running an afc experiment? 
if ~ex.exp.afc  
    disp('no afc task performed')
    return
end

if ~ isfield(ex.Trials,'Reward')
    return
end

% if we have the spatial attention task exclude two trials after time-out
if isfield(ex.Trials,'to') && isfield(ex.exp,'spatialAttention') ...
        && ex.exp.spatialAttention ==1
    disp('removing 2 trials after TO')
    % first fill the empty tos with NaNs
    for n=1:length(ex.Trials)
        if isempty(ex.Trials(n).to)
            ex.Trials(n).to = NaN;
        end
    end
    idx = find([ex.Trials.to]==1);
    idx = idx(find(idx<length(ex.Trials)-1));
    % exclude the two successfully completed trials after a time-out
    idx_ex = [];
    for n = 1:length(idx)
        cnt = 1;
        n_extr = 0;
        while n_extr< 2 && cnt+idx(n)<length(ex.Trials)
            if abs([ex.Trials(idx(n)+cnt).Reward])>0
                n_extr = n_extr+1;
                idx_ex = [idx_ex,idx(n)+cnt];
            end
            cnt = cnt+1;
        end
    end
            
    idx = [1:length(ex.Trials)];
    idx(idx_ex) = [];
    ex.Trials = ex.Trials(idx);
end


% select successfully completed trials
tr = find(abs([ex.Trials.Reward])>0);
ntr = length(tr);
ncorrect = length(find([ex.Trials.Reward]>0));
if length(tr)<25
    return
end
Trials = ex.Trials(tr);    


% if we run a spatial attention task, exclude instruction trials 
iTr = Trials;
if isfield(ex.exp,'spatialAttention') && ex.exp.spatialAttention
    if isfield(iTr,'hdx_seq2')
        itr = [];
        for n=1:length(iTr)
            if ~(isempty(iTr(n).hdx_seq2)| isnan(iTr(n).hdx_seq2))
                itr = [itr,n];
            end
        end
        iTr = iTr(itr);
    else % we will just exclude the number of instruction trials as a proxy
        if isfield(ex.exp,'nInstructionTrials') && ...
                ex.exp.nInstructionTrials>length(iTr)
            iTr = iTr(ex.exp.nInstructionTrials+1:end);
        else
            disp('not sufficient non-instruction trials available')
            return
        end
    end
end
Trials = iTr;



if isfield(Trials,'hdx')
    dxs = unique([Trials.hdx]);
    val1 = dxs;
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
    
end

%  what\'s the parameter being discriminated?
if strcmpi(ex.stim.type,'grating')
    mypar = 'or';
    mypar2 = 'or2';
else mypar = 'hdx';
    mypar2 = 'hdx2';
end

par2 = [];
val2 = [];
if isfield(Trials,'Dc')
    par2 = 'Dc';
    val2 = unique([Trials.Dc]);
end

% separate by target position
goodT = [];
if isfield(Trials,'targ')
    for n=1:length(Trials)
        if isfield(Trials(n).targ,'goodT')
        goodT(n) = Trials(n).targ.goodT;
        else goodT(n) = NaN;
        end
    end
    goodTs = unique(goodT);
    goodTs = goodTs(~isnan(goodTs));
end

% separate by targetOnset
tOs = [];
if isfield(Trials,'targOn_delay');
    tOs = unique([Trials.targOn_delay]);
    tO_str = 'targOn_delay';

end

% separate by y_OffsetCueAmp if we use it
if length(tOs)<2 && isfield(Trials,'y_OffsetCueAmp')
    tOs = unique([Trials.y_OffsetCueAmp]);
    tO_str = 'y_OffsetCueAmp';
end

    
% separate by x0
x0s = [];
if isfield(Trials,'x0') && length(unique([Trials.x0]))>1
    x0s = unique([Trials.x0]);
end

% separate by Dc2
dc2 = [];
if isfield(Trials,'Dc2') && length(unique([Trials.Dc2]))>1
    dc2 = unique([Trials.Dc2]);
end

labelstr{1} = 'all';
mt{1} = '--o'; % marker & line type


[xvals,yvals,N,xlabel_str,tr] = getPercentFarChoice(Trials,par2,val1,val2,mypar);
mn = [];
se = [];
% if ex.setup.recording && spike_flag
%     [mn,se] = getSpikeCounts(Trials,par2,val2);
% end
if ~isempty(tOs)
    for n = 1:length(tOs);
        itr = find(eval(['[Trials.' tO_str ']']) == tOs(n));
        iTrials = Trials(itr);
        labelstr{length(labelstr)+1} = [strrep(tO_str, '_','') ':' num2str(tOs(n))];
        mt{length(mt)+1} = '--s';
        n2 = length(labelstr);
        [xvals(n2,:),yvals(n2,:),N(n2,:),xlabel_str] = getPercentFarChoice(iTrials,par2,val1,val2,mypar);
        if ~isempty(mn)
            [mn(n2,:),se(n2,:)] = getSpikeRates(iTrials,par2,val2);
        end
    end
end
if ~isempty(x0s)
    for n = 1:length(x0s);
        itr = find([Trials.x0] == x0s(n));
        iTrials = Trials(itr);
        labelstr{length(labelstr)+1} = ['x0:' num2str(x0s(n)),' n:' num2str(length(itr))];
        mt{length(mt)+1} = '-o';
        n2 = length(labelstr);
        [xvals(n2,:),yvals(n2,:),N(n2,:),xlabel_str] = getPercentFarChoice(iTrials,par2,val1,val2,mypar);
        if ~isempty(mn)
            [mn(n2,:),se(n2,:)] = getSpikeRates(iTrials,par2,val2);
        end
    end
end

if ~isempty(goodTs)
    for n = 1:length(goodTs);
        itr = find([goodT] == goodTs(n));
        iTrials = Trials(itr);
        if goodTs(n) ==1;
            labelstr{length(labelstr)+1} = ['lower target (' num2str(goodTs(n)) ')'];
        else
            labelstr{length(labelstr)+1} = ['upper target (' num2str(goodTs(n)) ')'];
        end
        mt{length(mt)+1} = '-v';
        n2 = length(labelstr);
        [xvals(n2,:),yvals(n2,:),N(n2,:),xlabel_str] = getPercentFarChoice(iTrials,par2,val1,val2,mypar);
        if ~isempty(mn)
            [mn(n2,:),se(n2,:)] = getSpikeRates(iTrials,par2,val2);
        end

    end
end

% get proportion of fixation breaks per stimulus type
fb_tr = [];
for n=1:length(ex.Trials);
    if length(ex.Trials(n).Start)>fix_duration
        fb_tr = [fb_tr,n];
    end
end
fbTrials = ex.Trials(fb_tr);
labelstr{length(labelstr)+1} = 'proportion fixation breaks';
mt{length(mt)+1} = '-*';
n2 = length(labelstr);
[xvals(n2,:),yvals(n2,:),N(n2,:)] = getPercentFixBreaks(fbTrials,par2,val1,val2,mypar);

% get performance based on uncued stimulus
xvals2=[];
if ~isempty(dc2)
    labelstr2 = {};
    n2=1;
    ipar2 = 'Dc2';
    ival2 = unique([Trials.Dc2]);
    if ~isempty(x0s)
        for n = 1:length(x0s);
            itr = find([Trials.x0] == x0s(n));
            iTrials = Trials(itr);
            labelstr{length(labelstr)+1} = ['Dc2, x0:' num2str(x0s(n)),' n:' num2str(length(itr))];
            mt{length(mt)+1} = '-o';
            [xvals2(n2,:),yvals2(n2,:),N2(n2,:)] = getPercentFarChoice(iTrials,ipar2,val1,ival2,mypar2);
            if ~isempty(mn)
                [mn(n2,:),se(n2,:)] = getSpikeRates(iTrials,par2,val2);
            end
            n2 = n2+1;
        end
    else        
        labelstr{length(labelstr)+1} = ['Dc2,  n:' num2str(length(itr))];
        mt{length(mt)+1} = '-o';
        [xvals2(n2,:),yvals2(n2,:),N2(n2,:)] = getPercentFarChoice(Trials,ipar2,val1,ival2,mypar2);
        if ~isempty(mn)
            [mn(n2,:),se(n2,:)] = getSpikeRates(iTrials,par2,val2);
        end
    end
end


% output
x=xvals(1,:);
y=yvals(1,:);
n_reps = N(1,:);

if plot_off
    return
end

% now plot the behavioral results ----------------------------------------
cols = colormap(hsv(size(xvals,1)+size(xvals2,1)));

% do we have neural data to plot?
if isempty(mn)
    subplot_pos{1} = [0.1    0.27    0.87    0.68];
else
        % 2 subplots:
    subplot_pos{1} = [.1    0.60    0.87    0.35];
    subplot_pos{2} = [0.1    0.27    0.87    0.32];
end

hold off
subplot('position',subplot_pos{1})
for n = 1:size(xvals,1)
    if n==1;
        ms = 14;
        lw = 2;
    else ms = 6;
        lw = 1;
    end

    plot(xvals(n,:),yvals(n,:)*100,mt{n},'color',cols(n,:),...
        'markersize',ms,'markerfacecolor',cols(n,:),'linewidth',lw);
    hold on;
    for n2 = 1:size(xvals,2);
        text(xvals(n,n2),yvals(n,n2)*100,num2str(N(n,n2)),'fontsize',18);
    end
end

% plot performance for uncued stimulus
if ~isempty(xvals2)
    for n = 1:size(xvals2,1)
        plot(xvals2(n,:),yvals2(n,:)*100,mt{n+size(xvals,1)},'color',cols(n+size(xvals,1),:),...
            'markersize',ms,'markerfacecolor',cols(n+size(xvals,1),:),'linewidth',lw);
        hold on;
        for n2 = 1:size(xvals2,2);
            text(xvals2(n,n2),yvals2(n,n2)*100,num2str(N2(n,n2)),'fontsize',18);
        end
    end
end

xlim = [min(xvals(1,:))-.1*max(xvals(1,:)) max(xvals(1,:))+.1*max(xvals(1,:))];
xlim = xlim(~isnan(xlim));
if isempty(xlim) || max(xlim) == min(xlim) || ~isempty(isnan(xlim))
    if isempty(val2)
        xlim = [-.1 .1];
    else
        xlim = [-100 100];
    end
end

set(gca,'ylim',[0 100],'xlim',xlim, 'fontsize',14)
ylabel ('% far choice');
xlabel(xlabel_str)
legend(labelstr,'Location','NorthEastOutside')
title(['N_t_o_t_a_l:' num2str(ntr) '      N_c_o_r_r_e_c_t:' num2str(ncorrect)])

if ~isempty(mn)
    subplot('position',subplot_pos{2})
    hold off
    for n = 1:size(xvals,1)
        if n==1;
            ms = 14;
            lw = 2;
        else ms = 6;
            lw = 1;
        end

        errorbar(xvals(n,:),mn(n,:),se(n,:),mt{n},'color',cols(n,:),...
            'markersize',ms,'markerfacecolor',cols(n,:),'linewidth',lw);
        hold on;
        for n2 = 1:size(xvals,2);
            text(xvals(n,n2),mn(n,n2),num2str(N(n,n2)),'fontsize',18);
        end
    end

    set(gca,'ylim',[0 100],'xlim',[min(xvals(1,:))-.1*max(xvals(1,:)) ...
        max(xvals(1,:))+.1*max(xvals(1,:))], 'fontsize',16)
    ylabel ('spike rate');
    xlabel(xlabel_str)
end

% ------------------------------------------------------------------------
% ---- subfunctions------------------------------------------------------
% -----------------------------------------------------------------------
function [xvals,yvals,N,legend_str,tr] = getPercentFixBreaks(Trials,par2,val1,val2,par1)
xvals=[]; yvals=[]; N = []; tr = {};
if ~ isempty(val2)
    for n=1:length(val2)
        idx = find(eval(['[Trials.' par2 '] == val2(n)']) & eval(['abs([Trials.' par1 ']-val1(1))<0.01']));
        fix_breaks = find([Trials(idx).Reward]==0); % fixation breaks
        fb(1,n) = length(fix_breaks)/length(idx);
        N(1,n) = length(idx);
        tr{1,n} = idx;
    end
    for n=1:length(val2)
        idx = find(eval(['[Trials.' par2 '] == val2(n)']) & eval(['abs([Trials.' par1 ']-val1(2))<0.01']));
        fix_breaks = find([Trials(idx).Reward]==0); % fixation breaks
        fb(2,n) = length(fix_breaks)/length(idx);
        N(2,n) = length(idx);
        tr{2,n} = idx;
        
    end
    xvals = [-fliplr(val2), val2]*100;
    yvals = [fliplr(fb(1,:)) fb(2,:)];
    N = [fliplr(N(1,:)) N(2,:)];
    legend_str = ['fixation breaks'];
else
    dxs = val1; %unique([Trials.hdx]);
    for n=1:length(dxs)
        idx = find([Trials.hdx]==dxs(n));
        if dxs(n)<0
            fix_breaks = find([Trials(idx).Reward]==0); % fixation breaks
            fb(1,n) = length(fix_breaks)/length(idx);
            N(1,n) = length(idx);
        else
            fix_breaks = find([Trials(idx).Reward]==0); % fixation breaks
            fb(1,n) = length(fix_breaks)/length(idx);
            N(1,n) = length(idx);
        end
    end
    xvals = [dxs];
    yvals = fc;
    legend_str = 'fixation breaks';
end



function [xvals,yvals,N,xlabel_str,tr] = getPercentFarChoice(Trials,par2,val1,val2,par1)
xvals=[]; yvals=[]; N = []; tr = {};
if ~ isempty(val2)
    for n=1:length(val2)
        idx = find(eval(['[Trials.' par2 '] == val2(n)']) & eval(['abs([Trials.' par1 ']-val1(1))<0.01']));
        
        far_c = find([Trials(idx).Choice]==1); % far choice 
        fc(1,n) = length(far_c)/length(idx);
        N(1,n) = length(idx);
        tr{1,n} = idx;
    end
    for n=1:length(val2)
        idx = find(eval(['[Trials.' par2 '] == val2(n)']) & eval(['abs([Trials.' par1 ']-val1(2))<0.01']));
        
        far_c = find([Trials(idx).Choice]==1); % far choice 
        fc(2,n) = length(far_c)/length(idx);
        N(2,n) = length(idx);
        tr{2,n} = idx;
        
    end
    xvals = [-fliplr(val2), val2]*100;
    yvals = [fliplr(fc(1,:)) fc(2,:)];
    N = [fliplr(N(1,:)) N(2,:)];
    if strcmpi(par1,'hdx')
    xlabel_str = ['                                                                    ' ...
        '   % signal' ...
        '\newline                                                     ' ...
        'near disp                      far disp'];
    elseif strcmpi(par1,'or')
    xlabel_str = ['                                                                    ' ...
        '   % signal' ...
        '\newline                                                     ' ...
        'OR:' num2str(val1(1)) '                       OR:' num2str(val1(2))];
    end
        
else
    dxs = val1; %unique([Trials.hdx]);
    for n=1:length(dxs)
        idx = find([Trials.hdx]==dxs(n));
        if dxs(n)<0
            far_c = find([Trials(idx).Choice]==1); % far choice 
            fc(1,n) = length(far_c)/length(idx);
            N(1,n) = length(idx);
        else
            far_c = find([Trials(idx).Choice]==1); % far choice 
            fc(1,n) = length(far_c)/length(idx);
            N(1,n) = length(idx);
        end
    end
    xvals = [dxs];
    yvals = fc;
    xlabel_str = 'dx';
end

% size(xvals)
% size(yvals)
% 

% ---- subfunctions------------------------------------------------------
function [mn,se] = getSpikeCounts(Trials,par2,val2)
mn = []; se = [];
if ~ isfield(Trials(1),'oRate')
    return;
end
    
if ~ isempty(val2)
    for n=1:length(val2)
        idx = find(eval(['[Trials.' par2 '] == val2(n)']) & [Trials.hdx]<0);
        far_c = find([Trials(idx).Reward]==-1); % far choice = error on near trials
        mnn(1,n) = mean([Trials(idx(far_c)).oRate]); 
        see(1,n) = std([Trials(idx(far_c)).oRate])/sqrt(length(far_c));
    end
    for n=1:length(val2)
        idx = find(eval(['[Trials.' par2 '] == val2(n)']) & [Trials.hdx]>0);
        far_c = find([Trials(idx).Reward]==1); % far choice = rew on far trials
        mnn(2,n) = mean([Trials(idx(far_c)).oRate]); 
        see(2,n) = std([Trials(idx(far_c)).oRate])/sqrt(length(far_c));
    end
    mn = [fliplr(mnn(1,:)) mnn(2,:)];
    se = [fliplr(see(1,:)) see(2,:)];
else
    dxs = unique([Trials.hdx]);
    for n=1:length(dxs)
        idx = find([Trials.hdx]==dxs(n));
        if dxs(n)<0
            far_c = find([Trials(idx).Reward]==-1); % far choice = error on near trials
            mn(1,n) = mean([Trials(idx(far_c)).oRate]); 
            se(1,n) = std([Trials(idx(far_c)).oRate])/sqrt(length(far_c));
        else
            far_c = find([Trials(idx).Reward]==-1); % far choice = error on near trials
            mn(1,n) = mean([Trials(idx(far_c)).oRate]); 
            se(1,n) = std([Trials(idx(far_c)).oRate])/sqrt(length(far_c));
        end
    end
end
