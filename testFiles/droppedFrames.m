function [fract,SD,nominalLength,len] = droppedFrames(ex);

% computes the fraction of dropped frames/trial as well as the SD of the
% fraction of dropped frames for each fully completed trial

% initialize variables
fract = NaN;
SD = NaN;
nominalLength = NaN;

% find completed trials
iTr = find(abs([ex.Trials.Reward]>0));

len = NaN(1,length(iTr));
for n=1:length(iTr);
    len(n) = length(ex.Trials(iTr(n)).Start);
end

nominalLength = floor(ex.fix.stimDuration*ex.setup.refreshRate);

% figure;
% hist(len);
% hold on;
% plot(ones(1,2)*nominalLength,get(gca,'ylim'),'-r','linewidth',2);
% xlabel('# of frames/ trial')
% ylabel N
% 

fract = mean(len(~isnan(len)))./nominalLength;
SD = std(len(~isnan(len))./nominalLength);

