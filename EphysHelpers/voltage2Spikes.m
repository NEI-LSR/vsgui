function [ex, vtr] = voltage2Spikes(ex)
% function [ex, vtr] = voltage2Spikes(ex)
%
% helper function for recordings with SGLX  to convert voltage traces to
% spikes.
%
% extracts spike times and spike rates from voltage traces that are stored
% in ex.Trials.oSpikes 
% the (neg) spike threshold is 2*SD of noise
% 
% input:    ex
% output:   ex with valid trials and additional fields: ex.Trials.spT
%                                                       ex.Trials.spR
%           vtr valid trials with fields vtr.spT
%                                        vtr.spR
% history
% 01/29/26  hn: wrote it

dsRatio        =10;                           % default downsampleRatio
noiseThreshold = 4;                           % default threshold is 4*SD
sR             = 25000;                       % default sampleRate of signal [Hz]
if isfield(ex.setup.(ex.setup.ephys),'noiseThreshold') && ...
        isnumeric(ex.setup.(ex.setup.ephys).noiseThreshold)
    noiseThreshold = ex.setup.(ex.setup.ephys).noiseThreshold;
end
if isfield(ex.setup.(ex.setup.ephys),'downsampleRatio') && ...
        isnumeric(ex.setup.(ex.setup.ephys).downsampleRatio)
    dsRatio = ex.setup.(ex.setup.ephys).downsampleRatio;
end
sR = 25000;                                 
if isfield(ex.setup.(ex.setup.ephys),'sampleRate') && ...
        isnumeric(ex.setup.(ex.setup.ephys).sampleRate)
    sR = ex.setup.(ex.setup.ephys).sampleRate;
end

sF = sR/dsRatio;                              % effective sampling frequency 

%% thresholds (noiseThreshold*SD, default is 4*SD) 
mat = cat(1, [ex.Trials(:).oSpikes]);          
Thr = (std(single(mat'), 0, 1) * noiseThreshold)'; % 

% % more robust detection
% sigma = (median(abs(mat'), 1)./ 0.6745);
% k = 8;                                 % typical 3–6
% Thr = -k * sigma';                         % for negative-going spikes
% 
%a = find( ~isempty([ex.Trials.Start]));

%vtr = ex.Trials([ex.Trials.Reward] == 1 && ~isempty([ex.Trials.Start]));      % valid trials
%vtr = ex.Trials(itr);      % valid trials
tr = ex.Trials([ex.Trials.Reward] == 1);
includeTr = arrayfun(@(x) ~isempty(x.Start), tr);
vtr = tr(includeTr);
nTr = numel(vtr);

% lag to stimulus onset for valid trials in seconds
lagS = arrayfun(@(x) x.Start(1) - x.TrialStart, vtr);
vals = num2cell(lagS);
[vtr.lagS] = vals{:};

durS = ex.fix.stimDuration + 0.06;              % [sec] (window for spike rate, including  response latency)
dur  = round(durS * sF);                        % in samples (integer window)



% create array with spike times in sec, relative to stimulus onset and
% vector with stimulus-dependent spike-rate on each trial

for n = 1:nTr
    %if ~isempty(vtr(n).oSpikes)
    % below-threshold logical
    if isempty(vtr(n).oSpikes)
        vtr(n).oSpikes = zeros(size(Thr));
    end
    belowT = vtr(n).oSpikes < -Thr;             % [nCh x nSamp]
    
    % threshold crossings 
    sT = belowT(:,2:end) & ~belowT(:,1:end-1);  % [nCh x (nSamp-1)]

    lagSt = round(vtr(n).lagS * sF);            % lag in samples for this trial

    % ---------- Spike times per channel (cell array) ----------
    [ch, col] = find(sT);                       % col is index in sT (1..nSamp-1)
    tsec = (col + 1 - lagSt) / sF;              % in seconds relative to stim onset

    nCh = size(sT,1);
    vtr(n).spT = accumarray(ch, tsec, [nCh 1], @(x){x}, {[]});

    % ---------- Spike rate per channel in [lagSt, lagSt+dur] 
    inWin = (col > lagSt) & (col <= (lagSt + dur));
    counts = accumarray(ch, inWin, [nCh 1], @sum, 0);  % spike counts
    vtr(n).spR = counts / durS;                 % Hz
    %end
end