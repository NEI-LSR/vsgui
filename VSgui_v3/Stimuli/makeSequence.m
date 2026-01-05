function ex = makeSequence(ex)

% generates the sequence of stimulus and trial values for an experiment
% based on the values specified in e1 (experiment 1), e2, e3, e4. I.e. we can
% vary up to 4 parameters in parallel.
% the sequence for the experiment is then stored in.
% Note that the sequence is pseudo-randomized, i.e. it contains N repeats
% of each combination of parameters
%
% ex.stim.seq, and for each experiment value a different field is used:
% ex.stim.seq.val1
% ex.stim.seq.val2  etc.
% note that before v4, the sequence was created inside runExpt.m

% 7/1/14  hn: wrote it; 
% 08/28/14  hn: include blank and monocular stimuli
% 08/31/14  hn: made pseudo-randomized sequence for non-afc stimuli and
%           prepare longer random sequence for afc experiments;
%           -included 'keepvals' to keep track of fixed stim.vals if they 
%          are changed during an experiment
% 11/03/15  hn: included option to use anticorrelated cued/uncued stimuli
% 12/09/16  hn: included two-pass of random sequence 
% 06/16/17  hn: updated two-pass: for two consecutive presentation of the
%           same set of parameters it now uses the same seed. This ensures
%           that the same seeds are close in time but doesn't take care of
%           fixation breaks.
% 05/02/23  hn: fixed bug for include_uncorr
% 02/06/24  hn: included ex.exp.monocBlank

disp('in makeSequence')
if ~isfield(ex,'exp')
    disp('we are not running an experiment')
    return
end

% ---------- make sure that experiment 1 (e1) is being assigned first-----
if isfield(ex.exp,'e2') &(~ isfield(ex.exp,'e1')| isempty(ex.exp.e1))
    ex.exp.e1 = ex.exp.e2;
    ex.exp = rmfield(ex.exp,'e2');
end
if isfield(ex.exp,'e3') 
    if ~isfield(ex.exp,'e1') | isempty(ex.exp.e1)
        ex.exp.e1 = ex.exp.e3;
        ex.exp = rmfield(ex.exp,e3);
    elseif ~isfield(ex.exp,'e2') | isempty(ex.exp.e2)
        ex.exp.e2 = ex.exp.e3;
        ex.exp = rmfield(ex.exp,'e3');
    end
end
if isfield(ex.exp,'e4')
    if ~isfield(ex.exp,'e1') | isempty(ex.exp.e1)
        ex.exp.e1 = ex.exp.e4;
        ex.exp = rmfield(ex.exp,e4);
    elseif ~isfield(ex.exp,'e2') | isempty(ex.exp.e2)
        ex.exp.e2 = ex.exp.e4;
        ex.exp = rmfield(ex.exp,e4);
    elseif ~isfield(ex.exp,'e3') | isempty(ex.exp.e3)
        ex.exp.e3 = ex.exp.e4;
        ex.exp = rmfield(ex.exp,e4);
    end
end


% ------------ get range of values for each experiment ---- (note-- can be
% removed once we no longer change experiments manually in the command
% line)
vals1 = []; vals2 =[]; vals3 = []; vals4 = [];
nsamples1 = 1; nsamples2 = 1; nsamples2 = 1; nsamples4 = 1;
[ex,vals1,nsamples1] = getStimulusValues(ex,'e1');
[ex,vals2,nsamples2] = getStimulusValues(ex,'e2');
[ex,vals3,nsamples3] = getStimulusValues(ex,'e3');
[ex,vals4,nsamples4] = getStimulusValues(ex,'e4');

myvals1= vals1;
if ex.exp.include_blank
    nsamples1 = nsamples1+1;
    blankval = max(vals1)+1000;
    vals1 = [vals1, blankval];
end
if ex.exp.include_monoc
    nsamples1 = nsamples1+2;
    leftval = max(myvals1)+2000;
    rightval = max(myvals1)+ 3000;
    vals1 = [vals1,leftval,rightval];
end
if isfield(ex.exp,'include_uncorr') && ex.exp.include_uncorr
    nsamples1 = nsamples1+1;
    ucval = max(myvals1+4000);
    vals1 = [vals1,ucval];
end
nParaCombinations = nsamples1 * nsamples2 * nsamples3 * nsamples4;
ntrials = ex.exp.nreps * nParaCombinations;
ex.finish = ntrials;
%% for simple fixation and tuning measurements we will use a pseudo-
% randomized sequence (i.e. enforcing n repeats/stimulus combination. When
% the monkey breaks fixation the stimulus is put to the end of the sequence).
% For afc tasks we prepare a long random sequence to prevent the
% the sequential dependencies of the pseudo-randomized sequence, and all
% missed trials get discarded

if nsamples1>1 && ex.exp.afc  
    %nsamples1 = nsamples1*3; 
    ex.stim.nseq = ntrials;
end

% ----------- clear sequences from previous experiments ------------------
if isfield(ex.stim,'seq')
    ex.stim = rmfield(ex.stim,'seq');
end


% ----------- make sequence for each experiment -------------------------
% make sure that each combination of parameters appears N times (N =
% ex.exp.nreps)
ex.stim.seq.st = ones(1,ntrials);
ex.stim.seq.me = ones(1,ntrials)*ex.stim.vals.me;
ex.stim.seq.ce = ones(1,ntrials);
rp = randperm(ntrials);
if ~isempty(vals1)
    nreps = nsamples2*nsamples3*nsamples4*ex.exp.nreps;
    seq1 = repmat(1:nsamples1,1,nreps);
    eval(['ex.stim.seq.' ex.exp.e1.type '= vals1(seq1(rp));']);
    if isfield(ex.stim.vals,ex.exp.e1.type)
        eval(['ex.stim.keepvals.' ex.exp.e1.type ' = ex.stim.vals.' ex.exp.e1.type ';']);
    end
end
if ~isempty(vals2)
    nreps = nsamples3*nsamples4*ex.exp.nreps;
    seq2 = reshape(repmat(1:ex.exp.e2.nsamples,nsamples1,nreps),1,ntrials);
    eval(['ex.stim.seq.' ex.exp.e2.type '= vals2(seq2(rp));']);
    if isfield(ex.stim.vals,ex.exp.e2.type)
        eval(['ex.stim.keepvals.' ex.exp.e2.type ' = ex.stim.vals.' ex.exp.e2.type ';']);
    end
end
if ~isempty(vals3)
    nreps = nsamples4*ex.exp.nreps;
    seq3 = reshape(repmat(1:ex.exp.e3.nsamples,nsamples1*nsamples2,nreps),1,ntrials);
    eval(['ex.stim.seq.' ex.exp.e3.type '= vals3(seq3(rp));']);
    if isfield(ex.stim.vals,ex.exp.e3.type)
        eval(['ex.stim.keepvals.' ex.exp.e3.type ' = ex.stim.vals.' ex.exp.e3.type ';']);
    end
end
if ~isempty(vals4)
    nreps = nsamples1*nsamples2*nsamples3;
    seq4 = reshape(repmat(1:ex.exp.e4.nsamples,nreps,ex.exp.nreps),1,ntrials);
    eval(['ex.stim.seq.' ex.exp.e4.type '= vals4(seq4(rp));']);
    if isfield(ex.stim.vals,ex.exp.e4.type)
        eval(['ex.stim.keepvals.' ex.exp.e4.type ' = ex.stim.vals.' ex.exp.e4.type ';']);
    end
end
if ex.exp.include_blank
    ex.stim.seq.st(find(eval(['ex.stim.seq.' ex.exp.e1.type '==blankval']))) = 0;
end
if ex.exp.include_monoc
    ex.stim.seq.me(find(eval(['ex.stim.seq.' ex.exp.e1.type '==leftval']))) = -1;
    ex.stim.seq.me(find(eval(['ex.stim.seq.' ex.exp.e1.type '==rightval']))) = 1;
end
if isfield(ex.exp,'include_uncorr') && ex.exp.include_uncorr
    %ex.stim.seq.ce = ones(size(ex.stim.seq.st)); 
    ex.stim.seq.ce(find(eval(['ex.stim.seq.' ex.exp.e1.type '==ucval']))) = 0;
end

% allowing for simple monocular fixation marker
% value of ex.exp.monocBlank is the proportion of monocular blank
if isfield(ex.exp,'monocBlank')
    %idx = [ex.stim.seq.me] ~= 0 & ...
    %    rand(size([ex.stim.seq.me])) < ex.exp.monocBlank;
    idxME = find([ex.stim.seq.me] == -1);
    idx = randperm(length(idxME),round(length(idxME)*ex.exp.monocBlank));
    ex.stim.seq.st(idxME(idx)) = 0;

    idxME = find([ex.stim.seq.me] == 1);
    idx = randperm(length(idxME),round(length(idxME)*ex.exp.monocBlank));
    ex.stim.seq.st(idxME(idx)) = 0;
    %ex.stim.seq.st(abs([ex.stim.seq.me])>0) = 0;
end

% for this we need the signal disparities to be symmetrical
% set the disparity of the distractor to the opposite sign of the cued
% stimulus
if isfield(ex.exp,'cuedUncuedAntiCorrelated') && ...
        ex.exp.cuedUncuedAntiCorrelated==1
    if isfield(ex.stim.seq,'hdx') && isfield(ex.stim.seq,'hdx2')
        ex.stim.seq.hdx2 = ex.stim.seq.hdx*(-1);
    end
end


% % two-pass for afc experiment
% if isfield(ex.exp,'two_pass') && ex.exp.two_pass
%     
%     % double the sequence as random permutation of the first
%     rp = randperm(ex.stim.nseq);
%     fnames = fieldnames(ex.stim.seq)
%     for n=1:length(fnames)
%         disp(['ex.stim.seq2pass.' fnames{n} '=[ex.stim.seq.' fnames{n} '(rp)];'])
%         eval(['ex.stim.seq2pass.' fnames{n} '=[ex.stim.seq.' fnames{n} '(rp)];'])
%     end
%     % save the indices for the second stimulus of the 2pass pairs
%     ex.stim.idx_2pass = rp;
%     ex.finish = ex.stim.nseq*2;
%     
% end
    
 % two-pass for afc experiment- note this requires an even number of nreps
if isfield(ex.exp,'two_pass') 
    switch ex.exp.two_pass
        case 1
            nSeeds = ex.stim.nseq/2; % we will use each seed twice
            seeds = [1:nSeeds] + now;  % add a number based on date/time to avoid overlap
            rp_m = mod(rp,nParaCombinations)+1;
            ex.stim.seedSeq = NaN(size(rp));
            cnt = 1;
            for n = 1: nParaCombinations
                idx = find(rp_m==n);
                % use the same seed for consecutive presentations of the same
                % ParameterCombinations
                for n2 = 1:length(idx)/2
                    ex.stim.seedSeq(idx(n2*2-1:n2*2)) = deal(seeds(cnt));
                    ex.stim.seedPairIdx_2pass(:,cnt) = idx(n2*2-1:n2*2); % to keep track of each pair
                    cnt = cnt+1;
                end
            end    
        case 2
            ex.stim.seedSeq = now;
            if ~isfield(ex.stim,'fixedSeedEveryN')
                ex.stim.fixedSeedEveryN = 2; % default is every second stimulus has a frozen seed
            end
        otherwise
    end
            
end

% maybe for each parameter combination (including x0 for spatial attention)
% we make sure to remember that seed. If it's used, we will use a new
% random seed
% i.e. we will have a lookup-table for each parameter combination; we
% either fill it, if it has a NaN, or we sample it


   