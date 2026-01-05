function [dig, tstamps] = getStrobes(ex, varargin)

% [dig tstamps] = getStrobe
% get all the strobe words sent by datapixx to the ripple system since the
% last 'getStrobe' call;
% dig:      vector of strobe words
% tstamp:   vector of the timestamps (in sec) corresponding to the strobe
%           words

% history
% 08/05/14  hn: wrote it
if nargin == 2 || nargin > 3
    error( 'Wrong number of arguments provided.' );
end
switch ex.setup.ephys
    case 'sglx'
        if nargin < 3
            error( 'You are using spikeglx. Provide begin and end idx values to read words.' );
        end
        begin_idx = varargin{1};
        end_idx = varargin{2};
        hSGL = ex.setup.sglx.handle;
        sampleRate = GetStreamSampleRate( hSGL, 0, 0 );
        nChannels = GetStreamAcqChans( hSGL, 0, 0 );
        [mat, ~] = Fetch(hSGL, 0, 0, begin_idx, end_idx-begin_idx, sum(nChannels)-2:sum(nChannels)-1);
        word_idx = find(any(diff(mat)~= 0, 2))+1;
        for i = 1:length(word_idx)
            w1 = (dec2bin(mat(word_idx(i), 1), 16)=='1')|(circshift(dec2bin(mat(word_idx(i), 2), 16)=='1', -1));
            dig(i) = bin2dec(num2str(circshift(w1(1:end-1), 7)));
            tstamps(i) = begin_idx+i;
        end
        dig2use = find(dig ~= 0);
        dig = dig(dig2use);
        tstamps = tstamps(dig2use)/sampleRate;
        
    case 'gv'
        tstamps = [];
        
        [cnt,tstamps,events]=xippmex('digin');
        
        dig = [events.parallel];
        %parallel_in = find(events.reason == 1);
        tstamps = [tstamps]/30000; % in sec relative to start of Trellis session
    otherwise
end

