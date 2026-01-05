function ex=closeRDS(ex)
% blank screen for stereo display
% history
% ca 2013   hn: wrote it
% 05/05/24  hn: now close all offscreen windows

idx = [];
if isfield(ex.stim.vals,'blanktex')
    idx = [idx,ex.stim.vals.blanktex];
    ex.stim.vals.blanktex = [];
end

% if ~isempty(idx)
%     Screen('Close',idx);
% end
% 

% close all offscreen textures
Screen('Close');