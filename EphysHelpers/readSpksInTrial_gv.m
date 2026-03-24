function ex = readSpksInTrial_gv(ex)

% function ex = readSpksInTrial_gv(ex)
% 
% reads in the spike times for the current trial (n) and stores 
% those in  ex.setup.gv.elec relative
% to ex.Trials(n).TrialStart in ex.Trials(n).oSpikes.
% This function should be called after each trial
% pre-SGLX this function was called 'readSpksinTrial'


% history
% 08/05/14  hn: wrote it
% 08/25/15  hn: now also reads out gvTrialEnd
% 11/03/16  hn: upgraded to read in >4 channels
% 04/06/23  ik: activated storing spike times for SC mapping trials
% 01/21/26  hn: renamed to readSpksinTrial_gv


disp('in readSpksInTrial_gv')
tic
t = getSpkTimes(ex); % spike time % in secs
[stb, t_stb, sma1, t_sma1] = getRippleDin;  % strobes and strobe timestamps

idx = find(stb == ex.strobe.TRIAL_START,1,'last');
if ~isempty(idx)
    tr_start_GV = t_stb(idx(end)); % time stamp of trial start on ripple system
else
    disp('no trial start found');
    return
end

tr_end_GV = [];
idx = find(stb == ex.strobe.TRIAL_END,1,'last');
if ~isempty(idx)
    tr_end_GV = t_stb(idx(end)); % time stamp of trial end on ripple system
end

if ~isempty(sma1)
    ex.Trials(ex.j).Sync.type = sma1;
    ex.Trials(ex.j).Sync.t = t_sma1;
end
ex.Trials(ex.j).Sync.strobe_type = stb;
ex.Trials(ex.j).Sync.strobe_t = t_stb;
ex.Trials(ex.j).oSpikes = t{1} - tr_start_GV;  % spike times for channel 1, cluster 0, relative to TrialStart
fs = ex.Trials(ex.j).Start - ex.Trials(ex.j).TrialStart; % video Frame Starts

if length(fs)>=1
    dur = fs(end) - fs(1);
    switch size(t,1)
        case 1 % only plot the first channel
            for n=1:length(ex.setup.gv.cl)
                eval(['ex.Trials(ex.j).oRate.cl' num2str(ex.setup.gv.cl(n)) ...
                    '= length(find([t{1,n}] - tr_start_GV >= fs(1)  & [t{1,n}] ' ...
                    '- tr_start_GV <fs(end)))/(fs(end)-fs(1));']);  % spike rate (ips) during stimuls presentation            
            end

        case 2 % we are recording two channels
            cnt = 1;
            % cl1: cluster 1 on channel 1
            % cl2: cluster 0 on channel 1
            % cl3: cluster 1 on channel 2
            % cl4: cluster 0 on channel 2            
            ocl = [2 1 4 3]; % make sure the clusters get stored in the correct name
            for ch = 1:2
                for cl = 1:2
                eval(['ex.Trials(ex.j).oRate.cl' num2str(ocl(cnt)) ...
                    '= length(find([t{ch,cl}] - tr_start_GV >= fs(1)  & [t{ch,cl}] ' ...
                    '- tr_start_GV <fs(end)))/(fs(end)-fs(1));']);  % spike rate (ips) during stimuls presentation  
                    cnt = cnt+1;
                end
            end
        case 3 % we are recording three channels
            for ch = 1:3
                eval(['ex.Trials(ex.j).oRate.cl' num2str(ch) ...
                    '= length(find([t{ch,2}] - tr_start_GV >= fs(1)  & [t{ch,2}] ' ...
                    '- tr_start_GV <fs(end)))/(fs(end)-fs(1));']);  % spike rate (ips) during stimuls presentation  
            end
        case 4 % we are recording four channels
            for ch = 1:4
                eval(['ex.Trials(ex.j).oRate.cl' num2str(ch) ...
                    '= length(find([t{ch,2}] - tr_start_GV >= fs(1)  & [t{ch,2}] ' ...
                    '- tr_start_GV <fs(end)))/(fs(end)-fs(1));']);  % spike rate (ips) during stimuls presentation  
            end
        otherwise % we are recording >4 channels
            % get cluster 0 in each of them:
            % cluster x (clx) is then defined as cluster 0 on channel x
            for n=1:length(ex.setup.gv.elec)
                ex.Trials(ex.j).oRate.(sprintf('cl%d',ex.setup.gv.elec(n))) = ...
                    sum(t{n,1} - tr_start_GV >= fs(1) & ...
                    t{n,1} - tr_start_GV < fs(end)) / dur;
                
            end
    end
    
else
    for n=1:length(ex.setup.gv.cl)
        eval(['ex.Trials(ex.j).oRate.cl' num2str(ex.setup.gv.cl(n)) '= [];']);
    end
end

% run this only for sc mapping assuming number of channels > 4, ik
if ex.exp.scmap
    ex.Trials(ex.j).oSpikes = cell(size(t));

    if ex.exp.scmap == 3    % mapping with flashing dots, 2023.07.28. ik
        stimOn = ex.Trials(ex.j).times.stimOn - ex.Trials(ex.j).TrialStart;
        dur = ex.fix.stimDuration;
    else
        stimOn = ex.Trials(ex.j).times.targOn - ex.Trials(ex.j).TrialStart;
        % defualt spike count window for sc mapping: 500 ms interval starting at target onset
        dur = 0.5;
    end
    
    for n = 1:length(ex.setup.gv.elec)
        ex.Trials(ex.j).oRate.(sprintf('cl%d',ex.setup.gv.elec(n))) = ...
            sum(t{n} - tr_start_GV >= stimOn & ...
            t{n} - tr_start_GV < stimOn + dur) / dur;
        
        ex.Trials(ex.j).oSpikes{n} = t{n} - tr_start_GV;  % spike times for channel 1, cluster 0, relative to TrialStart
    end
    %ex.Trials(ex.j).oRate = rmfield(ex.Trials(ex.j).oRate,'cl0');
end

ex.Trials(ex.j).gvTrialStart = tr_start_GV;
ex.Trials(ex.j).gvTrialEnd = tr_end_GV;
toc
%disp('in read spks')

    




