%%

[ex,vtr] = voltage2Spikes(ex);
%%
[ind_sorted] = ephys.sortChanMap(ex.setup.(ex.setup.ephys).probe.map);
%%
itr = 7;  % selected trial
spikeTimes = vtr(itr).spT(ind_sorted);
%%
downsampleRatio = 10;
lag = 0;
if ~isempty(vtr(itr).FetchStartSGLX)
    lag = (vtr(itr).FetchStartSGLX-vtr(itr).TrialStartSGLX)/(ex.setup.sglx.sampleRate/downsampleRatio);
end
%%


allSpikes = [];
allTrials = [];

for i = 1:length(spikeTimes)
    allSpikes = [allSpikes spikeTimes{i}'];
    allTrials = [allTrials i * ones(size(spikeTimes{i}))'];
end

%%
figure
scatter([allSpikes]+lag, [allTrials], 1, 'k');

hold on
plot((ones(6,1)*(vtr(itr).Eye.t-vtr(itr).TrialStartDatapixx))',[vtr(itr).Eye.v(1:6,:)]'*10 - 15)
%%
xlabel('Time');
ylabel('Trial / Neuron');
ylim([0 length(spikeTimes)+1]);
set(gca, 'YDir','normal');
box off;
%%
figure; hold on;

for i = 1:length(spikeTimes)
    spikes = spikeTimes{i}';
    y = i * ones(size(spikes));
    plot(spikes, y, 'k.', 'MarkerSize', 4);
end

xlabel('Time');
ylabel('Trial / Neuron');
ylim([0 length(spikeTimes)+1]);
set(gca, 'YDir','normal');
box off;