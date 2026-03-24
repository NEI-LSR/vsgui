function [figH]=plotRaster(ex,vtr)
% [figH]=plotRaster(ex,vtr)
%
% history
% 03/13/26  hn: wrote it
%

% --- resort channels according to channel Map
[ind_sorted] = ephys.sortChanMap(ex.setup.(ex.setup.ephys).probe.map);

% --- use only spokes of first valid trial ---
spikeTimes = vtr(1).spT(ind_sorted);

% --- format spike times for population raster plot ----
allSpikes = [];
allTrials = [];

for i = 1:length(spikeTimes)
    allSpikes = [allSpikes spikeTimes{i}'];
    allTrials = [allTrials i * ones(size(spikeTimes{i}))'];
end

% --- Plot ---
figH = figure;
scatter(allSpikes, allTrials, 1, 'k');

xlabel('time [sec]');
ylabel('channel #');
ylim([0 length(spikeTimes)+1]);
set(gca, 'YDir','normal');
box off;

