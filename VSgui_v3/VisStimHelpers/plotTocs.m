function plotTocs(ex)

% function plotTocs(ex)
% 
% convenience function for checking timing issues plots the mean and max
% time spent on different sections of the code for each trial and plots
% this.

% get the toc-fields
fn = fieldnames(ex);
cnt = 1;
for n = 1:length(fn);
    if findstr(fn{n},'tocs')
        fnames{cnt} = fn{n};
        cnt = cnt+1;
    end
end

% extract the times
max_t = [];
mean_t = []; 
for n=1:length(fnames)
    for t = 1:length(eval(['ex.' fnames{n}]))
        if ~isempty(eval(['ex.' fnames{n} '{t}']))
            max_t(n,t) = eval(['max(ex.' fnames{n} '{t});']);
            mean_t(n,t) = eval(['mean(ex.' fnames{n} '{t});']);
        else
            max_t(n,t) = NaN;
            mean_t(n,t) = NaN;
        end
    end
    figure;
    plot(max_t(n,:),'-bo');
    hold on;
    plot(mean_t(n,:),'-ro');
    title(fnames{n});
end

% check dropped frames and whether sequence and Start field match in size
tr = find(abs([ex.Trials.Reward])>0);
size(tr)
d =[];
cnt = 1;
for t = 1: length(tr) 
    l(t) = length(ex.Trials(tr(t)).Start);
    if isfield(ex.Trials(tr(t)),'hdx_seq')&& length(ex.Trials(tr(t)).Start) ~= length(ex.Trials(tr(t)).hdx_seq)
        d(cnt,1) = length(ex.Trials(tr(t)).Start);
        d(cnt,2) = length(ex.Trials(tr(t)).hdx_seq);
        cnt = cnt+1;
    end
end
figure;
plot(l,'-bo');
title('stimulus frames')
figure
if ~isempty(d)
    plot(d(:,1),d(:,2),'bo');
end