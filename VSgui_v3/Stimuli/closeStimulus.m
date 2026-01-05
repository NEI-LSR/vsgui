function ex=closeStimulus(ex)
% distributes close** commands according to the stimulus;  these close the
% open texture windows for the stimuli and show background for monoc or
% stereo display

% check whether we are running a tuning experiment and make sure that the
% stimulus values that change on each trials are empty in ex.stim.vals

% history
% 07/11/14  hn: -included field 'setup' and moved setup parameters into it
%               new parameter name          old parameter name
%               ex.setup.stereo             ex.stereo
%               ex.setup.window             ex.window
%               ex.setup.overlay            ex.overlay
% 08/31/14  hn: no longer empty fields after experiment; 

pars = [];
if isfield(ex.stim,'keepvals')
    pars = fieldnames(ex.stim.keepvals);
    for n = 1:length(pars)
        eval(['ex.stim.vals.' pars{n} '= ex.stim.keepvals.' pars{n} ';']);
    end   
    ex.stim = rmfield(ex.stim,'keepvals');
end

switch ex.stim.type
    case 'grating'
        ex=closeGrating(ex);
     case 'rds'
         ex=closeRDS(ex);

    case 'image'
         ex=closeImage(ex);
end

Screen('FillRect', ex.setup.overlay,ex.idx.bg_lum);
if ex.setup.stereo.Display
    % Select left-eye image buffer for drawing:
    Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
     Screen('FillRect',ex.setup.window,ex.idx.bg_lum);  % background to start 
    % Select right-eye image buffer for drawing:
    Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
    % Draw right stim:
    Screen('FillRect',ex.setup.window,ex.idx.bg_lum);  % background to start
else 
    Screen('FillRect',ex.setup.window,ex.idx.bg_lum);
end

Screen('Flip',ex.setup.window);