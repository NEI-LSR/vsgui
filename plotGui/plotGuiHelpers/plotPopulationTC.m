function [figH, figH2]=plotPopulationTC(ex,vtr)
% [figH]=plotPopulationTC(ex)

colCells = {};
tstr = {};                              % text label of experiment names
tx = [];                                % text positions above first row
xtckStart = 1;
figH2 = [];

% Optional blank column 
if ex.exp.include_blank
    colCells{end+1} = [vtr.st]';         % nTrials x 1
    tstr{end+1} = 'blank';
    xtckStart = 3;
end

% Up to 5 parallel experiments
for k = 1:5
    fn = sprintf('e%d', k);
    if isfield(ex.exp, fn)
        typ = ex.exp.(fn).type;          % field name in vtr
        colCells{end+1} = [vtr.(typ)]';  % nTrials x 1
        tstr{end+1} = ['  exp: ' typ];   % experiment labels.
    end
end

S = cell2mat(colCells);                  % nTrials x nCols
nCols = size(S,2);

% --------- trial response matrix: channels x trials ---
R = [vtr.spR];                            % nCh x nTrials
% --------- sort R according to channel map
[ind_sorted] = ephys.sortChanMap(ex.setup.(ex.setup.ephys).probe.map);
if ~isempty(ind_sorted) && max(ind_sorted)<=size(R,1)
    R = R(ind_sorted,:);
end
nCh = size(R,1);

% --- Compute popR, xtick labels, tx  ---
popCols = {};                             % collect blocks, cat once at end
xtckCells = {};                           % collect tick labels, cat once

colStart = 1;

% Handle blank column (column 1 of S) if present
if ex.exp.include_blank
    idxBlank = (S(:,1) == 0);
    popCols{end+1} = mean(R(:, idxBlank), 2);
    popCols{end+1} = NaN(nCh, 1);        % delimiter

    xtckCells{end+1} = "blk";             % label blank value as 0 (or "blank")
    xtckCells{end+1} = "_";

    tx(1) = 1;                            % text position above first row
    colStart = 2;
end

% Loop remaining experiment columns
for c = colStart:nCols
    sc = S(:,c);

    % unique stimulus values excluding blanks (>=500 treated as blanks)
    sVals = unique(sc);
    sVals = sVals(sVals < 500);

    % Means per stimulus value (fast: loop over unique values, not trials/channels)
    block = zeros(nCh, numel(sVals), 'like', R);
    for j = 1:numel(sVals)
        idx = (sc == sVals(j));
        block(:, j) = mean(R(:, idx), 2);
    end

    % append this experiment's block + delimiter
    popCols{end+1} = block;
    popCols{end+1} = NaN(nCh, 1);

    % tick labels for this block
    xtckCells{end+1} = string(sVals(:)).';  % row of strings
    xtckCells{end+1} = "_";

    % position for the experiment title above middle of its block
    curWidth = sum(cellfun(@(x) size(x,2), popCols)) - 1;  % exclude last delimiter col
    tx(c) = curWidth - floor(2*numel(sVals)/3);
end

% Final popR: concatenate popCols, then drop last delimiter
popR = cat(2, popCols{:});
if ~isempty(popR)
    popR = popR(:, 1:end-1);
end

xtckLabel = [xtckCells{:}];

% --- Plot ---
figH = figure;
imagesc(popR)

set(gca, 'TickDir','out', 'box','off');
set(gca, 'xtick', xtckStart:2:size(popR,2), ...
         'xticklabel', xtckLabel(xtckStart:2:end),'YDir','normal');

% experiment labels above first row
arrayfun(@(x) text(tx(x),-10,tstr{x},'Fontsize',12),1:length(tstr));

xlabel('Parameter Values')
ylabel('Channel Number')

%% plot 2D if we have more than one expt
if size(S,2) < colStart+1
    return
end

% Loop following two experiment columns
c = colStart;
sc = S(:,c);
sc2 = S(:,c+1);
tstr = tstr(colStart:colStart+1);

% unique stimulus values excluding blanks (>=500 treated as blanks)
sVals = unique(sc);
sVals = sVals(sVals < 500);

% unique stimulus values for second column
sVals2 = unique(sc2);
sVals2 = sVals2(sVals2 < 500);

% Means per stimulus value 
block = zeros(nCh, numel(sVals),numel(sVals), 'like', R);
for j = 1:numel(sVals)
    for k = 1:numel(sVals2)
        idx = (sc == sVals(j) & sc2==sVals2(k));
        block(:,j,k) = mean(R(:, idx), 2);
    end
end

% get dimensions
[N,M,P] = size(block);
nRows = 20;
nCols = 20;

K = nRows*nCols;                         % total tiles
pad = K - N;                       % how many empty tiles

% pad extra slices with NaNs so we have exactly 400 slices
block2 = cat(1, block, nan(pad,M,P));

% reshape into 4-D: [tileRow, tileCol, M, P]
B4 = reshape(block2, nRows, nCols, M, P);

% permute so M stacks under tileCol, and P stacks under tileRow
B4 = permute(B4, [3 2 4 1]);       % [M, tileCol, P, tileRow]

% collapse to 2-D big mosaic
A = reshape(B4, nRows*M, nCols*P);

figH2 = figure;
imH = imagesc(A);
imH.PickableParts   = 'all';
imH.HitTest         = 'on';
imH.ButtonDownFcn = @(src,evt) tileClick(src, evt, M, P, nRows, nCols,N, block,sVals, sVals2,tstr);
set(gca,'xtick',floor(P/2):P:size(A,2),'xticklabel',1:20,...
    'ytick',floor(M/2):M:size(A,1),'yticklabel',0:20:400,...
    'Box','off','TickDir','out','XAxisLocation','top','YDir','normal');

xlabel('# channel')
ylabel('# channel')

c = colorbar;
c.Label.String = 'spikes/sec';
c.TickDirection = 'out';

