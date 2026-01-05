function ex=makeFullField(ex)
% function ex=makeFullFieldRC(ex)
% creates the temporal sequence for a fullfield stimulus
%
%
% ex.stim.vals.pulseDur = [0.05 ];
% ex.stim.vals.interPulseInterval = [0.233];
% ex.stim.vals.pulseType = [2] ; % unimodal: 1, bimodal: 2
% 
% history 
% 2022  written
% 05/24/24  hn: use white/black index from ptb to accommodate settings in
%           dome


seq = [];
%white = ex.idx.white;  (hn: creates issues in dome)
%black = ex.idx.black;

white = WhiteIndex(ex.setup.window);
black = BlackIndex(ex.setup.window);

if isfield(ex.stim.vals,'pulseDur') && ~isempty(ex.stim.vals.pulseDur) && ...
        isfield(ex.stim.vals,'interPulseInterval') && ~isempty(ex.stim.vals.interPulseInterval)

    % make sequence 
    numFrPulse  = round(ex.setup.refreshRate*ex.stim.vals.pulseDur);
    numFrIPI    = round(ex.setup.refreshRate*ex.stim.vals.interPulseInterval);
    numFrTrial  = round(ex.setup.refreshRate*ex.fix.stimDuration);

    
    switch ex.stim.vals.pulseType
        case 1
            lu = round(white*ex.Trials(ex.j).co);

            if lu<black 
                lu = black;
            end
            if lu>white
                lu = white;
            end
            seqPart = [ones(1,numFrPulse)*lu, ones(1,numFrIPI)*ex.idx.bg];

        case 2
            [~,vals1] = getStimulusValues(ex,'e1');

            for n = 1:2
                lu(n) = round(white*vals1(n));
                if lu(n)<black
                    lu(n) = black;
                end
                if lu(n)>white
                    lu(n) = white;
                end
            end

            seqPart = [ones(1,numFrPulse)*lu(1), ones(1,numFrPulse)*lu(2), ...
                ones(1,numFrIPI)*ex.idx.bg];
    end

    while length(seq) < numFrTrial
        seq     = [seq,seqPart];
    end
    %seq         = [seq,seqPart];
end

ex.stim.vals.lu_seq     = seq;
ex.stim.vals.framecnt   = 1;
        


