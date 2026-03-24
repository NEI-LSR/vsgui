function drawOverlayHelperLines(ex)

% draw the stored helper lines on overlay screen to help orient the
% experimenter (e.g. RF borders).  
% To draw a new line type 'l' on the keybord while Trials are running.  
% The mouse position during the first and second keypress will be the 
% enpoints of the new line.
% To clear all lines press 'l' and 'a' and 'c'

% history
% 08/02/14  hn: wrote it

if isfield(ex.extras,'line') && size(ex.extras.line,2)>1
    l = size(ex.extras.line,2);
    % if we have pairs of line endpoints defined use all points
    if round(l/2) == l/2
        Screen('DrawLines',ex.setup.overlay,ex.extras.line,1,ex.idx.overlay);
    else % other omit the last line endpoint
        Screen('DrawLines',ex.setup.overlay,ex.extras.line(:,1:end-1),1,ex.idx.overlay);
    end
end