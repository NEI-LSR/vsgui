function ex=playTargetIconGrating(ex,gT,or,tC)
% ex=playTargetIconRDS(ex,goodT,gR)
% display TargetIconRDS
% or : or for "good_response": determines the orientation of the correct target icon
% gT : "good_target": determines the target position for the correct target
% tC:   "target color": 0: higher contrast (presented during go period)
%                       1: lower contrast (presented during stimulus when
%                       teaching them not to respond to the targets
%                       immediately while stimulus is present)
%                       note: not yet implemented for orientation icons
%ex.Trials(ex.j).targ.goodT = find(good_targ); %1: lower target; 2: upper target
%
% history
% 11/02/15  hn: wrote it
% 11/06/15  hn: include phase randomization
% 01/05/15  hn: removed phase randomization; set phase to 0

sv = ex.stim.vals; % stimulus values
% OCULARITY
if ~isfield(ex.Trials(ex.j),'me_seq') || isempty(ex.Trials(ex.j).me_seq) 
    me = sv.me;
else 
    me = ex.Trials(ex.j).me_seq(sv.seqcnt+1);
end    

ti = ex.targ.icon;

% PHASE
if sv.RC 
    if round(sv.framecnt/sv.RCperiod)==sv.framecnt/sv.RCperiod
        phase = ex.Trials(ex.j).phase_seq(sv.seqcnt+1);
    else
        phase = ex.Trials(ex.j).phase_seq(sv.seqcnt+1);
    end
else
    phase = ex.Trials(ex.j).phase;
end

% the properly shifted cut out area from the tecture (in case we want to
% randomize phase or display a drifting grating)
% randomize the phase in sync with the stimulus (don't think it's an issue)
%xoffset = mod(sv.period/phase,sv.period);;
xoffset = 0;
%srcRect=[0 0 ti.visiblesize ti.visiblesize];
srcRect=[xoffset 0 xoffset + sv.visiblesize sv.visiblesize];
or_dist = mod(or-90,180);

% Draw grating texture, rotated by "angle":
if ex.setup.stereo.Display
    if me >=0  
        % draw right eye image
        %%
        Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
        
        %% draw the correct target
        Screen('DrawTexture', ex.setup.window, ti.RDS(1), srcRect, ti.dstRect(gT==1,:), or);
        % Draw gaussian mask over grating:
        Screen('DrawTexture', ex.setup.window, ti.masktex, [0 0 ti.visiblesize ti.visiblesize], ti.dstRect(gT==1,:), or);
        %% draw the error target
        Screen('DrawTexture', ex.setup.window, ti.RDS(2), srcRect, ti.dstRect(gT==0,:), or_dist);
        % Draw gaussian mask over grating:
        Screen('DrawTexture', ex.setup.window, ti.masktex, [0 0 ti.visiblesize ti.visiblesize], ti.dstRect(gT==0,:), or_dist);
    end
    if me <=0  
        % draw left eye image
        %%
        Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
        
        %% draw the correct target
        Screen('DrawTexture', ex.setup.window, ti.RDS(1), srcRect, ti.dstRect(gT==1,:), or);
        % Draw gaussian mask over grating:
        Screen('DrawTexture', ex.setup.window, ti.masktex, [0 0 ti.visiblesize ti.visiblesize], ti.dstRect(gT==1,:), or);
        %% draw the error target
        Screen('DrawTexture', ex.setup.window, ti.RDS(2), srcRect, ti.dstRect(gT==0,:), or_dist);
        % Draw gaussian mask over grating:
        Screen('DrawTexture', ex.setup.window, ti.masktex, [0 0 ti.visiblesize ti.visiblesize], ti.dstRect(gT==0,:), or_dist);
    end
else
        %% draw the correct target
        Screen('DrawTexture', ex.setup.window, ti.RDS(1), srcRect, ti.dstRect(gT==1,:), or);
        % Draw gaussian mask over grating:
        Screen('DrawTexture', ex.setup.window, ti.masktex, [0 0 ti.visiblesize ti.visiblesize], ti.dstRect(gT==1,:), or);
        %% draw the error target
        Screen('DrawTexture', ex.setup.window, ti.RDS(2), srcRect, ti.dstRect(gT==0,:), or_dist);
        % Draw gaussian mask over grating:
        Screen('DrawTexture', ex.setup.window, ti.masktex, [0 0 ti.visiblesize ti.visiblesize], ti.dstRect(gT==0,:), or_dist);
end


        