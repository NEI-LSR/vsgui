function ex=playGratingRC(ex,stimOnDur)
% display flashed grating for RC sequence
% heavily based on playGrating

% history
% 08/02/14      hn: wrote it
% 04/10/15      hn: included option for different RCperiods (in number of
%               video refresh frames)
% 02/14/16      hn: to correct for bug with different RCperiods, we now
%               start on framecnt=1, seqcnt = 1. We therefore correct the
%               indices for the sequence here: seqcnt instead of seqcnt+1,
%               e.g.: or_seq(sv.seqcnt)


sv = ex.stim.vals; % stimulus values

% GET PARAMETERS OF THE CURRENT GRATING----------------------------------
% for SF and CO we need the indices to the correct grating texture
% for OR and PHASE we directly get these value from the sequence
% note that we code phases in 1:4, where 1:=0, 2:=pi/2, 3:=pi, 4:=3/2*pi
%
% SPATIAL FREQUENCY
if isempty(ex.Trials(ex.j).sf_seq) 
    nf = 1; % default is 1
else % we are running an RC expt
    nf = find(sv.sf_range == ex.Trials(ex.j).sf_seq(sv.seqcnt));
end
% CONTRAST
if isempty(ex.Trials(ex.j).co_seq)
    nc = 1; % default is 1
else
    nc = find(sv.co_range == ex.Trials(ex.j).co_seq(sv.seqcnt));
end
% ORIENTATION
if isempty(ex.Trials(ex.j).or_seq)
    or = sv.or;
else
    or = ex.Trials(ex.j).or_seq(sv.seqcnt);
end
% PHASE
if sv.RC 
    if round(sv.framecnt/sv.RCperiod)==sv.framecnt/sv.RCperiod 
        phase = ex.Trials(ex.j).phase_seq(sv.seqcnt);
    else
        phase = ex.Trials(ex.j).phase_seq(sv.seqcnt);
    end
else
    phase = ex.Trials(ex.j).phase;
end
% OCULARITY
if isempty(ex.Trials(ex.j).me_seq) 
    me = sv.me;
else 
    me = ex.Trials(ex.j).me_seq(sv.seqcnt);
end    
% BLANK
if isempty(ex.Trials(ex.j).st_seq) 
    st = sv.st;
else
    st = ex.Trials(ex.j).st_seq(sv.seqcnt);
end

% X AND Y POSITION
if length(ex.Trials(ex.j).x0_seq)<1 && length(ex.Trials(ex.j).y0_seq)<1
    dstRect = sv.dstRect;
else
    left = sv.ppd*ex.Trials(ex.j).x0_seq(sv.seqcnt)+ex.fix.PCtr(1)-sv.visiblesize/2;
    bottom = sv.ppd*ex.Trials(ex.j).y0_seq(sv.seqcnt)+ex.fix.PCtr(2)-sv.visiblesize/2;
    dstRect=[left bottom left+sv.visiblesize bottom+sv.visiblesize];    
end

if sv.adaptation && stimOnDur<sv.adaptationDur
    or = sv.adaptationOr;
    me = sv.adaptationMe;
    st = 1;  % make sure we are always displaying the adapter
    phase = ex.Trials(ex.j).phase;
    xoffset = mod(sv.period/sv.phase+sv.seqcnt*sv.shiftperframe,sv.period);
else
    % note: for RC sequence, shiftperframe = 0;
    xoffset = mod(sv.period/phase,sv.period);
end

if round(sv.framecnt/sv.RCperiod) == sv.framecnt/sv.RCperiod
    ex.stim.vals.seqcnt = sv.seqcnt+1;
end

ex.stim.vals.framecnt = sv.framecnt+1;

% Define shifted srcRect that cuts out the properly shifted rectangular
% area from the texture: We cut out the range 0 to visiblesize i
% the vertical direction although the texture is only 1 pixel in
% height! This works because the hardware will automatically
% replicate pixels in one dimension if we exceed the real borders
% of the stored texture. This allows us to save storage space here,
% as our 2-D grating is essentially only defined in 1-D:
srcRect=[xoffset 0 xoffset + sv.visiblesize sv.visiblesize];

% Draw grating texture, rotated by "angle":
if ex.setup.stereo.Display
    
    if st ==0 % draw blank frame
        %disp('blank')
        %%
        Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
        Screen('DrawTexture', ex.setup.window, sv.blanktex, srcRect, dstRect);
    
    % check ocularity for right eye image: me: 1:= R, 0:= binoc
    elseif me >=0  
        % draw right eye image
        %%
        Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
        %%
        Screen('DrawTexture', ex.setup.window, sv.gratingtex(nf,nc), srcRect, dstRect, or);
        %%
        if ex.stim.drawmask==1
            % Draw gaussian mask over grating:
            Screen('DrawTexture', ex.setup.window, sv.masktex, [0 0 sv.visiblesize sv.visiblesize], dstRect, or);
        end;
    end  
    
    if st ==0 % draw blank frame
        Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
        Screen('DrawTexture', ex.setup.window, sv.blanktex, srcRect, dstRect);

    % check ocularity for left eye image: me -1:=L, 0 :=binoc
    elseif me <=0 
        % draw left eye image
        Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
        Screen('DrawTexture', ex.setup.window, sv.gratingtex(nf,nc), srcRect, dstRect, or);
        if ex.stim.drawmask==1
            % Draw gaussian mask over grating:
            Screen('DrawTexture', ex.setup.window, sv.masktex, [0 0 sv.visiblesize sv.visiblesize], dstRect, or);
        end;
    end
else
    if st==0 % draw blank frame
        Screen('DrawTexture', ex.setup.window, sv.blanktex, srcRect, dstRect);
    else
        Screen('DrawTexture', ex.setup.window, sv.gratingtex(nf,nc), srcRect, dstRect, sv.or);
        if ex.stim.drawmask==1
            % Draw gaussian mask over grating:
            Screen('DrawTexture', ex.setup.window, sv.masktex, [0 0 sv.visiblesize sv.visiblesize], dstRect, or);
        end;
    end
end