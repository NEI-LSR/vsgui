function ex=closeGrating(ex)
% function ex=closeGrating(ex)
%
% closes textures needed for drifing grating stimulus or for all grating
% stimuli on the last trial
% ca 2013   hn: wrote it
% 05/05/24  hn: now close all offscreen windows

idx =[];
if ~ ex.stim.vals.RC || ex.quit>2 || ex.goodtrial == ex.finish 
    if isfield(ex.stim.vals,'gratingtex')        
        idx = [idx, reshape(ex.stim.vals.gratingtex,1,prod(size(ex.stim.vals.gratingtex)))];
        ex.stim.vals.gratingtex = [];
    end
    if isfield(ex.stim.vals,'masktex')
        idx = [idx,ex.stim.vals.masktex];
        ex.stim.vals.masktex = [];
    end
    if isfield(ex.stim.vals,'blanktex')
        idx = [idx,ex.stim.vals.blanktex];
        ex.stim.vals.blanktex = [];
    end

end

% if ~isempty(idx)
%     Screen('Close',idx);
% end
% 

% close all offscreen textures
Screen('Close');