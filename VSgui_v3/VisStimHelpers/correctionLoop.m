function [goodTPos,good_targ,ex] = correctionLoop(goodTPos,good_targ,ex);  

% function [goodTPos,good_targ,ex] = correctionLoop(goodTPos,good_targ,ex); 
%
% checks whether the observer has a response bias, and if so, changes the
% target positions to counter this bias.
%
% history
% 11/28/17  hn: wrote it
%%
idx = [];
if isfield(ex.Trials,'Reward')
    idx = find(abs([ex.Trials.Reward])>0);
end

%%
if ~isempty(idx)
    tr = ex.Trials(idx);
    targ = [tr.targ];
    lTarg = find([targ.goodT]==1);
    uTarg = find([targ.goodT]==2);
    if length(uTarg)>2 && sum([tr(uTarg(end-2:end)).Reward]==1)==0
        goodTPos = ex.targ.Pos(2,:); % upper target is correct
        good_targ = [0,1]; % upper target is correct
        
        disp('correction loop on towards upper target')
        ex.Trials(ex.j).correctionLoop = 1;
        return
    end
    if length(lTarg)>2 && sum([tr(lTarg(end-2:end)).Reward]==1)==0
        goodTPos = ex.targ.Pos(1,:); % lower target is correct
        good_targ = [1,0]; % lower target is correct
        
        disp('correction loop on towards lower target')
        ex.Trials(ex.j).correctionLoop = 1;
        return
    end
        
end