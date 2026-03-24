function [ex,newBegin_idx] = fetchSpks(ex,begin_idx)

% function [ex,newBegin_idx] = fetchSpks(ex,begin_idx)
% 
% reads the filtered IM stream for the current trial (n) and appends
% those in  [saved channels], 
% to ex.Trials(n).TrialStart in ex.Trials(n).oSpikes.
%
% this function is called multiple times during a trial to avoid missing
% spikes due to limited buffer size in sglx
%

% history
% 03/11/26  hn: wrote it base on readSpksInTrial_sglx

% read out all AP channels unless only a subset is saved
if length(ex.setup.sglx.probe.savedChannels)<384
    chan = ex.setup.sglx.savedChannels;
else
    chan = [0:383];
end

downsampleRatio = 10;                             % default downsampleRatio
if isfield(ex.setup.sglx,'downsampleRatio') && ...
        isnumeric(ex.setup.sglx.downsampleRatio)
    downsampleRatio = ex.setup.sglx.downsampleRatio;
end

end_idx = GetStreamSampleCount(ex.setup.(ex.setup.ephys).handle,-2,0);
try
    
    mat = Fetch(ex.setup.sglx.handle,-2,0,begin_idx, end_idx-begin_idx,...
        chan,downsampleRatio);
    ex.Trials(ex.j).oSpikes = [ex.Trials(ex.j).oSpikes,mat']; %nCh x nSamp
    newBegin_idx = end_idx+1;  % avoid overlap
    
    %disp('in fetch spks')
catch
    warning('Fetch was unsuccessful (FETCH: Too late)')
    ex.Trials(ex.j).oSpikes = [];
    ex.Trials(ex.j).FetchStartSGLX = end_idx;
    newBegin_idx = end_idx;                              % failure

end

