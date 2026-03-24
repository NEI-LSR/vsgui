function ex = readSpksInTrial_sglx(ex)

% function ex = readSpksInTrial_sglx(ex)
% 
% reads the filtered IM stream for the current trial (n) and stores 
% those in  [saved channels], triggered on
% to ex.Trials(n).TrialStart in ex.Trials(n).oSpikes.
% This function should be called after each trial
% if the sglx FETCH call is unsuccessful, ex.Trials(n).oSpikes = [];
% 
% when tested (01/27/26, in NIH RigA), only streams up to 
% 1.8sec duration could be fetched

% history
% 01/21/26  hn: wrote it base on readSpksInTrial_gv

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

try
    begin_idx = ex.Trials(ex.j).TrialStartSGLX;
    end_idx   = ex.Trials(ex.j).TrialEndSGLX;
    mat = Fetch(ex.setup.sglx.handle,-2,0,begin_idx, end_idx-begin_idx,...
        chan,downsampleRatio);
    ex.Trials(ex.j).oSpikes = mat';
catch
    warning('Fetch was unsuccessful (FETCH: Too late)')
    ex.Trials(ex.j).oSpikes = [];
end

