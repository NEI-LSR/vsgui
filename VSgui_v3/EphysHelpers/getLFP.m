function LFP = getSpkTimes(ex)

% t = getLFP(ex)  
% reads out the LFP in the channels specified in ex.setup.gv.elec
%
% 10/25/16  hn: wrote it
% 
% TODOs:
%-check how much time this takes for 24 channels
%-for 4Stim per Trial: maybe read out neural data only after 4 trials?
%
%

[lfp, ts] = xippmex('cont',ex.setup.gv.elec,5000,'lfp'); % max 5sec are stored in the buffer
tic
for n = 1:10
    [lfp, ts(n)] = xippmex('cont',[1:24],5000,'lfp');
    toc
end