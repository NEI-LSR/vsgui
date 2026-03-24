function fig_h=ppRC(ex)

% function ppRC(ex)
% plots the psychophysical kernel for the coarse disparity discrimination
% task. If we have two stimuli (uncued and cued), plot the kernels for each of
% them.

% history
% 2014      hn: written
% 12/15/14  hn: now plots the kernels for the cued and uncued stimulus,
%           separated by which side was cued
% 10/23/15 hn: exclude two trials after tos for spatial attention
%          task
% 10/26/15 hn: exclude instruction trials; average kernels for different
% stimuli for Dc2

fig_h=[];
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


% use only trials for which a choice was made
tr = find(abs([ex.Trials.Reward])>0);
disp(['number of completed trials: ' num2str(length(tr))])

% make sure we only include frames that were shown and that we have the
% same number of frames for each trial
cnt = 1;
for n = 1:length(tr)
        itr(cnt) = tr(n);
        l(cnt) = length(ex.Trials(tr(n)).Start);
        cnt = cnt+1;
end
len = min(l);
iTr = ex.Trials(itr);

% if we run a spatial attention task, exclude instruction trials 
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
    % in the later version (v > 1.0.12) we label the instruction
    % trials directly.  Make sure we exclude these
    if isfield(iTr,'instructionTrial')
        % make sure we don't consider empty fields
        if length([iTr.instructionTrial]) == length(iTr)
            idx = find([iTr.instructionTrial]==0);
        else 
            idx = [];
            for n=1:length(iTr)
                if iTr(n).instructionTrial == 0
                    idx = [idx,n];
                end
            end
        end
        iTr = iTr(idx);
    end 
end


% exclude blank or monocular stimuli if they were accidentally included
itr = 1:length(iTr);
if isfield(iTr,'hdx')
    itr = find([iTr.hdx]<1000);
elseif isfield(iTr,'or')
    itr = find([iTr.or]<1000);
end
iTr = iTr(itr);

% require at least 10 valid trials for the analysis
if length(itr)<10
    disp(['number of valid trials: ' num2str(length(itr)) '; too few trials'])
    return
end


for n = 1:length(iTr);
    iTr(n).hdx_seq = iTr(n).hdx_seq(1:len);
    
    % if we have a second stimulus, make sure we have the same number of
    % frames for each trial for these, too.
    if isfield(iTr(n),'hdx_seq2') & ~isempty(iTr(n).hdx_seq2) & ~isnan(iTr(n).hdx_seq2)
        iTr(n).hdx_seq2 = iTr(n).hdx_seq2(1:len);
    elseif isfield(iTr(n),'hdx_seq2') & isnan(iTr(n).hdx_seq2)
        iTr(n).hdx_seq2 = [];
    end
end


% check whether we collapsed blocks for which the relevant stimulus was
% shown on the left or right
x0_str{1} = '';
cued_str = {['cued'],['cued L'],['cued R']};
uncued_str = {['uncued'],['uncued R'],['uncued L']};
if isfield(iTr,'x0')
    x0s = unique(sign([iTr.x0]));
    if length(x0s)>1
        x0_str = {['&[iTr.x0]>=-inf'],['&[iTr.x0]<0'],['&[iTr.x0]>0']};
    end
end

% check whether the signal disparity was included in the noise for the 
% distractor stimulus. If not, set
% it to NaN in hdx_seq2 such that we can exclude it.
if isfield(iTr,'hdx_seq2');
    dx_noise2 = unique([iTr.hdx_seq2]);
    dx_noise2 = unique(round(dx_noise2*200))/200;
end
if isfield(iTr,'Dc2')
    idx = find([iTr.Dc2] ==0);
    if ~isempty(idx)
        dx_noise2 = unique([iTr(idx).hdx_seq2]);
        dx_noise2 = unique(round(dx_noise2*200))/200;
    end
    if isfield(iTr,'hdx2') && ~isempty(dx_noise2)
        dx_signal = unique([iTr.hdx2]);
        for n = 1:length(dx_signal)
            if ~ismember(dx_signal,dx_noise2)
                for n2 =1:length(iTr)
                    iTr(n2).hdx_seq2(abs(iTr(n2).hdx_seq2-dx_signal(n))<0.05) = NaN;
                end
            end
        end
    end
end


% check whether the signal disparity was included in the noise. If not, set
% it to NaN in hdx_seq such that we can exclude it.
idx = find([iTr.Dc] ==0);
dx_noise =[];
if ~isempty(idx)
    dx_noise = unique([iTr(idx).hdx_seq]);
    dx_noise = unique(round(dx_noise*200))/200;
else
    disp('no 0% signal trials');
    return
end
dx_signal = unique([iTr.hdx]);
for n = 1:length(dx_signal)
    if ~ismember(dx_signal,dx_noise)
        for n2 =1:length(iTr)
            iTr(n2).hdx_seq(abs(iTr(n2).hdx_seq-dx_signal(n))<0.05) = NaN;
        end
    end
end
    
% get the kernels for the different conditions for the relevant stimulus
cs = unique([iTr.Dc]);
pkt={};
for ix = 1:length(x0_str)
    cnt = 1;
    for c = 1:min([3 length(cs)-1]);
        if cs(c) == 0
            Tr = eval(['iTr(find([iTr.Dc]==0 ' x0_str{ix} '));']);
            % near choices
            nc = find([Tr.hdx]<0 & [Tr.Reward]>0);
            nc = [nc,find([Tr.hdx]>0 & [Tr.Reward]<0)];

            % far choices
            fc = find([Tr.hdx]>0 & [Tr.Reward]>0);
            fc = [fc,find([Tr.hdx]<0 & [Tr.Reward]<0)];
            if ~isempty(nc) && ~isempty(fc)
                [pkt{ix}(cnt,:), nk{ix}(cnt,:),fk{ix}(cnt,:), N{ix}(cnt,:)] = getKernel(Tr,nc,fc,'hdx_seq',dx_noise);
                dcs(cnt) = 0;
                cnt = cnt+1;
            end
            
    %        % for development only; comment out-------------------------
    %
    %         figure;
    %         for n = 1:5;
    %             subplot(2,5,2*n-1)
    %             hist([Tr(fc(n)).hdx_seq]);
    %             subplot(2,5,2*n)
    %             hist([Tr(nc(n)).hdx_seq]);
    %         end

    %         figure;
    %         subplot(2,2,1);
    %         imagesc(reshape([Tr(fc).hdx_seq],length(Tr(1).hdx_seq),length(fc))',[-.8 0.8])
    %         subplot(2,2,3)
    %         plot(mean(reshape([Tr(fc).hdx_seq],length(Tr(1).hdx_seq),length(fc))'))
    %         title(num2str(mean(mean([Tr(fc).hdx_seq]))))
    %         subplot(2,2,2)
    %         imagesc(reshape([Tr(nc).hdx_seq],length(Tr(1).hdx_seq),length(nc))',[-.8 0.8])  
    %         subplot(2,2,4)
    %         plot(mean(reshape([Tr(nc).hdx_seq],length(Tr(1).hdx_seq),length(nc))'))
    %         title(num2str(mean(mean([Tr(nc).hdx_seq]))))
    %
    %        %end of development code:-----------------------------------
    
        else
            Tr = eval(['iTr(find([iTr.Dc] == cs(c) & [iTr.hdx]<0' x0_str{ix} '));']);
            % near choices
            nc = find( [Tr.Reward]>0);
            % far choices
            fc = find([Tr.Reward]<0);
            if ~isempty(nc) && ~isempty(fc)
                [pkt{ix}(cnt,:), nk{ix}(cnt,:),fk{ix}(cnt,:),N{ix}(cnt,:) ]= getKernel(Tr,nc,fc,'hdx_seq',dx_noise);
                dcs(cnt) = -cs(c) ;
                cnt = cnt+1;
            end
            
    %        % for development only; comment out-------------------------
    %         figure;
    %         for n = 1:5;
    %             subplot(2,5,2*n-1)
    %             hist([Tr(fc(n)).hdx_seq]);
    %             subplot(2,5,2*n)
    %             hist([Tr(nc(n)).hdx_seq]);
    %         end
    %       % end of development code -----------------------------------
        
            Tr = eval(['iTr(find([iTr.Dc] == cs(c) & [iTr.hdx]>0' x0_str{ix} '));']);
            % near choices
            nc = find( [Tr.Reward]<0);
            % far choices
            fc = find([Tr.Reward]>0);
            if ~isempty(nc) && ~isempty(fc)
                [pkt{ix}(cnt,:), nk{ix}(cnt,:),fk{ix}(cnt,:),N{ix}(cnt,:)] = getKernel(Tr,nc,fc,'hdx_seq',dx_noise);
                dcs(cnt) = cs(c) ;
                cnt = cnt+1;
            end
        end
    end
end
% round the x-values with 0.05 deg resolution
dxs = unique([iTr(:).hdx_seq]);
dxs = unique(round(dxs*200))/200;
dxs = dxs(~isnan(dxs));

% get kernel for second stimulus if we have one
pkt2 = [];
pkt1 = []; % kernel for cued stimulus but for both cued and uncued stimulus have no signal

if isfield(iTr,'hdx_seq2')
    % round disparity values for second stimulus with 0.05 deg resolution
    if isfield(iTr,'hdx2')
        dx2 = unique(round(unique([iTr.hdx2])*200)/200);
        dx2= dx2(~isnan(dx2));
    else dx2 = NaN;
    end
    if isfield(iTr,'Dc2')
        cs2 = unique([iTr.Dc2]);
        cs2 = cs2(~isnan(cs2));
        cs2 = cs2(cs2<=0.5);
    else cs2 = NaN;
    end
    
    
    for ix = 1:length(x0_str)
        cnt = 1;
        for n2 = 1:2
            cntDc0 = 0;
            for nDc = 1:length(cs2) % Dc2 values
                for ndx = 1:length(dx2) % hdx2 values
                    pass = 0;
                    if isnan(cs2(nDc))
                        c_str = '';
                    else c_str = '& [iTr.Dc2]==cs2(nDc)';
                    end
                    if cs2(nDc) ==0 
                        hdx_str = '';
                    else
                        if isfield(iTr,'hdx2')
                            hdx_str = '& abs([iTr.hdx2]-dx2(ndx))<=0.01';
                        else
                            hdx_str = '';
                        end
                    end
                    if n2==1

                        itr = eval(['find([iTr.Dc]==0'  c_str hdx_str x0_str{ix} ');']);
                        if cs2(nDc) ==0
                            legend_str2{cnt} = ['Dc2=' num2str(cs2(nDc))  '  Dc=0%'];
                            pass = 1;
                        end
                    else
                        itr = eval(['find([iTr.Dc]>=-inf' c_str hdx_str x0_str{ix} ');']);
                        if cs2(nDc) ==0
                            legend_str2{cnt} = ['Dc2=' num2str(cs2(nDc))  '  all stimuli'];
                        else
                            legend_str2{cnt} = ['Dc2=<0.5, all stimuli'];
                        end
                        pass = 1;
                    end
                    
                    if pass
                        % remove the instruction trials with only one stimulus 
                        for n = 1:length(itr) 
                            if isempty([iTr(itr(n)).hdx_seq2]) & isnan(iTr(itr(n)).hdx_seq2)
                                itr(n) = NaN;
                            end
                        end
                        itr = itr(find(~isnan(itr)));
                        Tr = iTr(itr);

                        % near choices
                        nc = find([Tr.hdx]<0 & [Tr.Reward]>0);
                        nc = [nc,find([Tr.hdx]>0 & [Tr.Reward]<0)];

                        % far choices
                        fc = find([Tr.hdx]>0 & [Tr.Reward]>0);
                        fc = [fc,find([Tr.hdx]<0 & [Tr.Reward]<0)];
                        if ~isempty(nc) && ~isempty(fc)
                            [pkt2{ix}(cnt,:), nk2{ix}(cnt,:),fk2{ix}(cnt,:)] = getKernel(Tr,nc,fc,'hdx_seq2',dx_noise2);
                            if ~cntDc0 || cs2(nDc)>0
                                cnt = cnt+1;
                                cntDc0 = 1;
                            end
                        end
                    end

            %        %this part of the code is for development of the stimulus and debugging only
            % ---------------------------------------------------------------------------------------
            %         figure
            %         for n = 1:5;
            %             subplot(2,5,2*n-1)
            %             hist([Tr(fc(n)).hdx_seq2]);
            %             subplot(2,5,2*n)
            %             hist([Tr(nc(n)).hdx_seq2]);
            %         end
            %         figure;
            %         subplot(2,2,1);
            %         %imagesc(reshape([Tr(fc).hdx_seq2],length(Tr(1).hdx_seq2),length(fc))',[-.8 0.8])
            %         nf = hist(reshape([Tr(fc).hdx_seq2],1,length(Tr(1).hdx_seq2)*length(fc))',dxs);
            %         hist(reshape([Tr(fc).hdx_seq2],1,length(Tr(1).hdx_seq2)*length(fc))',dxs);
            %         subplot(2,2,3)
            %         plot(mean(reshape([Tr(fc).hdx_seq2],length(Tr(1).hdx_seq2),length(fc))'))
            %         title(num2str(mean(mean([Tr(fc).hdx_seq2]))))
            %         subplot(2,2,2)
            %         %imagesc(reshape([Tr(nc).hdx_seq2],length(Tr(1).hdx_seq2),length(nc))',[-.8 0.8])  
            %         nn=hist(reshape([Tr(nc).hdx_seq2],1,length(Tr(1).hdx_seq2)*length(nc))',dxs);
            %         hist(reshape([Tr(nc).hdx_seq2],1,length(Tr(1).hdx_seq2)*length(nc))',dxs)
            %         subplot(2,2,4)
            %         plot(mean(reshape([Tr(nc).hdx_seq2],length(Tr(1).hdx_seq2),length(nc))'))
            %         title(num2str(mean(mean([Tr(nc).hdx_seq2]))))
            %         figure;
            %         plot(dxs,nn/length(nc)-nf/length(fc));
            % ------------------------------------------------------------------------
            %         % end of piece of code used for development
            
                end
            end
        end
    end
end

% now plot the data
fig_h=figure;
if isempty(pkt)
    return
end
cnt = 1;
for n = 1:length(x0_str)
    if ~isempty(pkt2)
        h(cnt) = subplot('position',[0.13  0.04+(length(x0_str)-n)*0.32    0.35    0.8/length(x0_str)]);
    else 
        h(cnt) = subplot('position',[0.13  0.04+(length(x0_str)-n)*0.32    0.7738    0.8/length(x0_str)]);
    end
    if length(x0_str) ==1
        if ex.stim.vals.x0 > 1, xstr = 'R'; else xstr = 'L'; end
    title([cued_str{n} xstr ' Dc0 N_n:' num2str(N{n}(1,2)) ' N_f:' ...
        num2str(N{n}(1,3)) ' Dc<=25% N_n:' num2str(sum(N{n}(:,2))) ...
        ' N_f:' num2str(sum(N{n}(:,3)))] )
    else
    title([cued_str{n} ' Dc0 N_n:' num2str(N{n}(1,2)) ' N_f:' ...
        num2str(N{n}(1,3)) ' Dc<=25% N_n:' num2str(sum(N{n}(:,2))) ...
        ' N_f:' num2str(sum(N{n}(:,3)))] )
    end
    cnt = cnt+1;
    hold on;
    if length(dx_noise) == length(pkt{1}) 
        % average kernels for all trials with signal <= 25%
        errorbar(dx_noise,mean(pkt{n},1),std(pkt{n},0,1)/sqrt(size(nk{n},1)-1),'-r','linewidth',2);
    end
    % kernel for 0% signal trials
    plot(dxs,pkt{n}(1,:),'k-','linewidth',2); 
    
    % mark signal disparities
    for ds = 1:length(dx_signal)
        plot(ones(1,2)*dx_signal(ds),get(gca,'ylim'),'k--')
    end
    
    % mark zero values
    plot([0 0],get(gca,'ylim'),'k-');
    plot(dxs,zeros(size(dx_noise)),'k-');
       
    if n==1
        legend({['Dc<=' num2str(cs(end-1)*100) '%'],['Dc=0%'],['signal disparities']},'location','NorthEast');
    end
    if n<length(x0_str)
        set(gca,'xticklabel','');
    end
    
    % plot kernel for the uncued stimulus if we have one
    if ~isempty(pkt2)
        h(cnt)=subplot('position',[0.53  0.04+(length(x0_str)-n)*0.32    0.35    0.8/length(x0_str)]);
        cnt = cnt+1;
        hold on;
        col = colormap(hsv(3));
        
        % kernel for Dc2=Dc= 0% signal trials 
        plot(dx_noise2,pkt2{n}(1,:),'color',col(1,:),'linewidth',2);
        
        % kernel for Dc2=Dc= 0% signal trials 
        plot(dx_noise2,pkt2{n}(2,:),'color',col(2,:),'linewidth',2);
        
        % average kernels for all trials with signal <50%
        errorbar(dx_noise2,mean(pkt2{n}(3:end,:),1),std(pkt2{n}(3:end,:))/sqrt(size(pkt2{n},1)-2),'color',col(3,:),'linewidth',2);
        if n==1
            legend(legend_str2,'location','NorthEast')
        end
        plot([0 0],get(gca,'ylim'),'k--');
        plot(dx_noise2,zeros(size(dx_noise2)),'k--');
        title(uncued_str{n} )
    end
end
   
% additional formatting of the figure/axes
ylim = [];
for n = 1 %[1:2:length(h)]
    ylim = [ylim, get(h(n),'ylim')];
end
ylim = [-max(abs(ylim)) max(abs(ylim))];
for n = 1:length(h)
    set(h(n),'ylim',ylim);
end
set(gcf,'position',[201         200        839         805])

% ------------------------- subfunctions
function [pkt,nk,fk,n] = getKernel(iTr,nc,fc,seq,dxs);
        
% convert trials into dx density matrix
% dxs = unique(eval(['[iTr(:).' seq '];']));
% dxs = unique(round(dxs*20))/20;
% dxs = dxs(~isnan(dxs));
for t = 1:length(iTr)
    for d = 1:length(dxs)
        m(t,d) = length(find(abs(eval(['[iTr(t).' seq ']'])-dxs(d))<0.005));
    end
end
pkt = mean(m(nc,:),1) - mean(m(fc,:),1);
nk = mean(m(nc,:),1);
fk = mean(m(fc,:),1);
n = [length(nc)+length(fc),length(nc),length(fc)];

