function [strobes, t_strobes, SMA1, t_SMA1] = getRippleDIN

% [strobes, t_strobes, SMA1, t_SMA1] = getRippleDIN
% get all the strobe words and digital pulses sent by datapixx to the ripple system since the
% last 'getRippleDIN' call. currently only reading in parallel port and SMA1
% strobes:      vector of strobe words
% t_strobes:    vector of the timestamps (in sec) corresponding to the strobe
%           words
% SMA1:   vector SMA1 events (used for sync-pulses between ripple and
%         datapixx)
% t_SMA1: vector of the timestamps (in sec) corresponding to the strobe
%         words

% extension of previous getStrobes

% history
% 09/21/14  hn: wrote it

[cnt,tstamps,events]=xippmex('digin');
tstamps = [tstamps]/30000; % in sec relative to start of Trellis session

strobes = [events.parallel];
parallel_in = find(events.reason == 1);
if ~isempty(parallel_in)
    t_strobes = tstamps(parallel_in);
end

SMA1 = [events.sma1];
SMA1_in = find(events.reason == 2);
if ~isempty(SMA1_in)
    t_SMA1 = tstamps(SMA1_in);
end

