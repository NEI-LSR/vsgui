function ex = readLFPInTrial(ex)

% function ex = readLFPInTrial(ex)
% 
% reads in the most recent 3 sec of LFP for the current trial (i.e. only on rewarded trials)
% if we have >1 stimulus presentations per trial. 
% Needs to be called after 'readSpksInTrial'
%
%
% Usage (copied from xippmex manual):
% [data, timestamp] = xippmex(?cont?, elec, duration, stream_type, [NIP timestamp])
% 
% elec          -List of 1-indexed desired electrode(s).
% duration      -Length of requested data (ms).
% stream_type   -String defining data stream type. 
%               Generally, should be one of ?raw?, ?lfp?, and ?hi-res?. 
%               Possible streams can be found in the ?signal? command.
% NIP timestamp -Optional. If specified, ?cont? will return data based on the given NIP timestamp. 
%               If empty, the most recent data will be retrieved. 
%               The timestamp is based on NIP 30 kHz clock ticks.
% Output
% data          -MATLAB array containing requested data (?V). 
%               The returned dimensions will be (length of elec) x 
%               (sample frequency x duration). LFP streams sample at 1 kHz,
%               hi-res streams sample at 2 kHz, and raw streams sample at 30 kHz.
% timestamp     -Timestamp for first sample of retrieved data. The timestamp is based on NIP 30-kHz clock ticks.
% Examples
% >> [data, ts] = xippmex(?cont?, 1, 100, ?lfp?);
% This returns 100 ms of lfp data for Front End channel 1, along with the NIP timestamp.
%
% history
% 11/06/16  hn: wrote it
% 01/28/17  hn: LFP timestamps no longer in sec but in 1/30000 sec  
% 11/10/2025 BT: added functionality to include multiprobe neuropixel
%                recordings
tic
disp('in readLFPInTrial')

switch ex.setup.ephys
    case 'gv'
        % read out LFP for the last 3 seconds
        [lfp, ts] = xippmex('cont',ex.setup.gv.elec,3000,'lfp');
        ex.Trials(ex.j).oLFP.v = lfp;
        %ex.Trials(ex.j).oLFP.t = ts/30000; % we store all timing information in secs
        ex.Trials(ex.j).oLFP.t = ts;  % in 1/30000 sec now; for some reason, ts values are forced to be digital after read-out.
        %   We therefore do not want to convert them in secs
    case 'sglx'
        hSGL = ex.setup.sglx.handle;
        sampleRate = GetStreamSampleRate( hSGL, 0, 0 );
        idx = GetStreamSampleCount(hSGL, 2, 0);
        saved_channel_idx = 
        for n = 1:length(ex.setup.sglx.probe)
            lfp_data = Fetch(hSGL, 2, n-1, idx-3*sampleRate+1, idx, sum(nChannels)-2:sum(nChannels)-1);
            ex.Trials(ex.j).oLFP.probe(n).v
            
        end
end

toc