function loadExptSetupFile(fig_h,handles,setupfile)
% loads new setup file and updates all gui parameters
% accordingly
global ex

% return if setup file doesn't exist
if isempty(dir(setupfile))
    warning('Cannot find setup file: %s\n\n',setupfile)
    return
end

newF = load(setupfile,'-mat');
nex = newF.ex;
if ~isempty(strcmpi(ex.stim.type,'bar'))
    ex.stim.vals.sf = nex.stim.vals.sf;
end

sv = ex.stim.vals;


% set reward back to 0.15 if we ran an adaptation experiment before
if ex.stim.vals.adaptation
    ex.reward.time = 0.15;
end

% are we running an xPos or yPos experiment?
xpos_exp = 0;
ypos_exp = 0;
for n = 1:4
    if isfield(nex.exp,['e' num2str(n)])
        etype = eval(['nex.exp.e' num2str(n) '.type';]);
        if strcmpi(etype,'x0') 
            xpos_exp = 1;
            xpos_exp_n = n;
        end
        if strcmpi(etype,'y0')
            ypos_exp = 1;
            ypos_exp_n = n;
        end

    end
end

if nex.exp.afc
    sv_fix = {['or'],['sf'],['tf'],['co']}; % stim vals that should not change
else
    if xpos_exp || ypos_exp
        sv_fix = {['x0'],['y0'],['sf'],['tf'],['co']}; % stim vals that should not change
    else
        sv_fix = {['x0'],['y0'],['or'],['sf'],['tf'],['co'],['wi'],['hi'],['sz']}; % stim vals that should not change

    end
end

ex.stim.vals = nex.stim.vals;
ex.stim.type = nex.stim.type;
ex.stim.masktype = nex.stim.masktype;

if ~isempty(findstr(setupfile,'defaultSetup_'))
    disp('in default settings')
    if isfield(nex,'animal')
        ex.Header.animal = nex.animal;
    elseif isfield(nex,'Header') && isfield(nex.Header,'animal')
        ex.Header.animal = nex.Header.animal;
    end
    ex.fix = nex.fix;
else
    % keep current fixation setup parameters (WinW, WinH and PCtr)
    fW = ex.fix.WinW;
    fH = ex.fix.WinH;
    PCtr = ex.fix.PCtr;
    sD = ex.fix.stimDuration;
    fC = ex.fix.fixCross;
    lW = ex.fix.lineWidth;
    sW = ex.fix.searchW; 
    sH = ex.fix.searchH; 

    
    ex.fix = nex.fix;
    ex.fix.WinW = fW;
    ex.fix.WinH = fH;
    ex.fix.PCtr = PCtr;
    ex.fix.stimDuration = sD;
        
    ex.fix.lineWidth = lW;
    ex.fix.searchH = sH;
    ex.fix.searchW = sW;
    ex.fix.fixCross = fC;
end
    
for n = 1:length(sv_fix)
    eval(['ex.stim.vals.' sv_fix{n} ' = sv.' sv_fix{n} ';']);
end

if ex.stim.vals.adaptation
    ex.reward.time = 0.2;
    ex.reward.earlyRewardTime = [0.03];
    ex.fix.duration_forEarlyReward = [2 3.5 6];
end

if strcmpi(ex.stim.type,'bar')
    ex.stim.vals.sf = nex.stim.vals.sf;
end

ex.exp = nex.exp;
ex.targ = nex.targ;

% center x0 and y0 on the current stimulus center for XPos or YPos
% experiments
if xpos_exp
    nex = getExptSettings(ex,'x0');
    eval(['ex.exp.e' num2str(xpos_exp_n) '= nex.exp.e1;']);
end
    
if ypos_exp
    nex = getExptSettings(ex,'y0');
    eval(['ex.exp.e' num2str(ypos_exp_n) '= nex.exp.e1;']);
end

% hack to update new exp field that I added later on:
if ~isfield(ex.exp,'addInstructionTrials')
    ex.exp.addInstructionTrials = 0; 
    ex.exp.countAddInstructionTrials = 0;
    ex.exp.numberAdditionalInstructionTrials = 2;  
end

% added by ik, 2023.04.04
if ~isfield(ex.exp,'scmap')
    ex.exp.scmap = 0;
end

% run the experiment specific script if exists
[p,n] = fileparts(setupfile);
setupScript = fullfile(p,[n,'.m']);
if exist(setupScript,'file')
    run(setupScript)
end

setGuiVariables(handles);

	
	