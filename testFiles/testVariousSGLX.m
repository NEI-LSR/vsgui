%% latency test
hSGL = SpikeGL('10.101.20.29')
numT = 1200;
tocs = NaN(1,numT);
for n = 1:numT
    tic
    begin_idx = GetStreamSampleCount(hSGL,0,0);
    tocs(n) = toc;
end
figure;
hist(tocs*1000);
xlabel('ms')
%sendStrobe(testS);
%end_idx = GetStreamSampleCount(hSGL,0,0);

%% testing latency for readout of spikes

hSGL = SpikeGL('10.101.20.29')
numL = 3;
dur = 0.5; % lag in 0.5 sec increments
for n = 1:numL
  begin_idx = GetStreamSampleCount(hSGL,-2,0);
  pause(n*dur);
  disp(n*dur)
  end_idx = GetStreamSampleCount(hSGL,-2,0);
  disp(num2str(round((end_idx-begin_idx)/25)))
  mat = Fetch(hSGL,-2,0,begin_idx, end_idx-begin_idx,[0:10:300],0);
end


%% testing spike read-out
mat = cat(1,[ex.Trials(:).oSpikes]);
size(mat)


%% 
tic
% determine thresholds based on all the data available (2-times SD)
mat = cat(1,[ex.Trials(:).oSpikes]);

%ThrR = (median(abs(single(mat'))/0.6745)*3)'; % threshold for every channel
Thr = (std(single(mat'))*2)';

vtr = ex.Trials([ex.Trials.Reward]==1); % valid trials

% lag to stimulus onset for valid trials
lagS = cell2mat(arrayfun(@(x) x.Start(1)-x.TrialStart, ...
    vtr,'UniformOutput',false));
vals = num2cell(lagS);
[vtr.lagS] = vals{:};

% create array with spike times in sec, relative to stimulus onset and
% vector with stimulus-dependent spike-rate on each trial
dur = (ex.fix.stimDuration + 0.02)*1000; % window (in ms) over which to 
                                         % compute spike rate
durS = dur/1000; % window in sec
for n = 1:length(vtr)
    belowT = vtr(n).oSpikes<-Thr;
    sT= diff(belowT')'==1; 
    lagSt = round(vtr(n).lagS*1000);

    % get spike times
    vtr(n).spT = arrayfun(@(x) (find(sT(x,:))+1-lagSt)/1000, ...
        1:size(sT,1), 'UniformOutput',false);

    % get rate per channel during stimulus duration + 20ms
    vtr(n).spR = cell2mat(arrayfun(@(x) ...
        sum(find(sT(x,:)) <=dur+lagSt & find(sT(x,:))>lagSt)/durS,...
        1:size(sT,1),'UniformOutput',false))';
end

%%
%% thresholds (2*SD) — keep your logic, but avoid extra cell2mat/arrayfun overhead
mat = cat(1, [ex.Trials(:).oSpikes]);          % as in your code
Thr = (std(single(mat'), 0, 1) * 2)';          % (same result, explicit dim)

vtr = ex.Trials([ex.Trials.Reward] == 1);      % valid trials
nTr = numel(vtr);

% lag to stimulus onset for valid trials (no cells)
lagS = arrayfun(@(x) x.Start(1) - x.TrialStart, vtr);
vals = num2cell(lagS);
[vtr.lagS] = vals{:};

durS = ex.fix.stimDuration + 0.02;             % sec
dur  = round(durS * 1000);                      % ms (integer window)

% main loop over trials (looping over trials is fine; avoid looping over channels)
for n = 1:nTr
    % below-threshold logical
    belowT = vtr(n).oSpikes < -Thr;             % [nCh x nSamp] assumed
    
    % threshold crossings (same as your diff(belowT')'==1, but clearer/faster)
    % crossings where belowT goes 0->1 along time (columns)
    sT = belowT(:,2:end) & ~belowT(:,1:end-1);  % [nCh x (nSamp-1)]

    lagSt = round(vtr(n).lagS * 1000);          % ms lag for this trial

    % ---------- Spike times per channel (cell array) ----------
    % One find for all channels, then group by channel
    [ch, col] = find(sT);                       % col is index in sT (1..nSamp-1)
    % Your original used (find(...) + 1 - lagSt)/1000
    tsec = (col + 1 - lagSt) / 1000;            % seconds relative to stim onset

    nCh = size(sT,1);
    vtr(n).spT = accumarray(ch, tsec, [nCh 1], @(x){x}, {[]});

    % ---------- Spike rate per channel in (lagSt, lagSt+dur] ----------
    inWin = (col > lagSt) & (col <= (lagSt + dur));
    counts = accumarray(ch, inWin, [nCh 1], @sum, 0);  % sum logicals -> counts
    vtr(n).spR = counts / durS;                 % Hz
end

%%
% stimulus (S) in matrix form
tic
S = [];
if ex.exp.include_blank
    S = [S,[vtr.st]'];
end

cnt = 0;
for n = 1:5 % maximally 5 experiments run in parallel
    if isfield(ex.exp,sprintf('e%d',n))
        cnt = cnt+1;
        par{cnt} = ex.exp.(sprintf('e%d',n)).type;
        S = [S,[vtr.(par{cnt})]'];
    end
end

% average responses to each stimulus type: channel-by-stim type
popR = []; % matrix of average population response to each stimulus value
xtckLabel = []; % xtick labels
cnt = 1;
tstr = cellfun(@(x) ['  exp: ' x],par,'UniformOutput',false);
tx = nan(size(S,2));

if ex.exp.include_blank
    idx = S(:,1) == 0;
    popR = [popR,mean([vtr(idx).spR],2)];
    popR = [popR, NaN(size(popR,1),1)];
    cnt = 2; %keep track we have already included the first column

    % for plotting
    tstr = [{'blank'}, tstr];
    tx(1) = 0;
end
%
for n = cnt:size(S,2)
    % identify trials with unique stimulus values
    sVals = unique(S(:,n));    % unique stimulus values
    sVals = sVals(sVals<500); % remove blanks
    idx = arrayfun(@(x) S(:,n)==x, sVals,'UniformOutput',false);
    
    % keep track of parameters for plotting
    xtckLabel(end+1:end+length(sVals)) = string(sVals');
    xtckLabel(end+1) = "_";

    % spacing of column titles 
    tx(n) = size(popR,2)+floor(length(sVals)/2);

    rsp = cellfun(@(x) mean([vtr(x).spR],2),idx,'UniformOutput',false);
    popR = [popR, cell2mat(rsp')];
    popR = [popR, NaN(size(popR,1),1)];  % NaNs as delimiters between expts
end
% remove last column of nans
popR = popR(:,1:end-1);


figure;
imagesc(popR)
set(gca,'xtick',[xtckStart:2:size(popR,2)], ...
        'xticklabel',xtckLabel(xtckStart:2:end),...
        'TickDir','out','box','off');
arrayfun(@(x) text(tx(x),-10,tstr{x},'Fontsize',12),[1:length(tstr)]);
xlabel('Parameter Values')
ylabel('Channel Number')
toc
%% --- Build stimulus matrix S without repeated concatenation ---
tic

colCells = {};
tstr = {};                              % text label of experiment names
tx = [];                                % text positions above first row

% Optional blank column 
if ex.exp.include_blank
    colCells{end+1} = [vtr.st]';         % nTrials x 1
    tstr{end+1} = 'blank';
    expCols{end+1} = 'blank';
end

% Up to 5 parallel experiments
for k = 1:5
    fn = sprintf('e%d', k);
    if isfield(ex.exp, fn)
        typ = ex.exp.(fn).type;          % field name in vtr
        colCells{end+1} = [vtr.(typ)]';  % nTrials x 1
        tstr{end+1} = ['  exp: ' typ];
    end
end

S = cell2mat(colCells);                  % nTrials x nCols
nCols = size(S,2);

% --- Precompute trial response matrix: channels x trials ---
R = [vtr.spR];                            % nCh x nTrials
nCh = size(R,1);

% --- Compute popR, xtick labels, tx  ---
popCols = {};                             % collect blocks, cat once at end
xtckCells = {};                           % collect tick labels, cat once
tx = nan(1, nCols);

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
    % (current width of popR so far, minus delimiter just appended)
    curWidth = sum(cellfun(@(x) size(x,2), popCols)) - 1;  % exclude last delimiter col
    tx(c) = curWidth - floor(numel(sVals)/2);
end

% Final popR: concatenate popCols, then drop last delimiter
popR = cat(2, popCols{:});
if ~isempty(popR)
    popR = popR(:, 1:end-1);
end

xtckLabel = [xtckCells{:}];

% --- Plot ---
figure;
imagesc(popR)

set(gca, 'TickDir','out', 'box','off');
set(gca, 'xtick', xtckStart:2:size(popR,2), ...
         'xticklabel', xtckLabel(xtckStart:2:end));

for i = 1:numel(tstr)
    if ~isnan(tx(i))
        text(tx(i), -10, tstr{i}, 'Fontsize', 12);
    end
end

xlabel('Parameter Values')
ylabel('Channel Number')

