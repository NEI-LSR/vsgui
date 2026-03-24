function ex = readSpksInTrial(ex)

% function ex = readSpksInTrial(ex)
% 
% helper function to distribute to function readSpksInTrial according 
% to the ephys system we use:
% 
% readSpksInTrial_gv
% readSpksInTrial_sglx


% history
% 01/21/26  hn: wrote it

switch ex.setup.ephys
    case 'sglx'
        ex = readSpksInTrial_sglx(ex);
    case 'gv'
        ex = readSpksInTrial_gv(ex);
    otherwise
        error('no valid ephys system detected;')
end
