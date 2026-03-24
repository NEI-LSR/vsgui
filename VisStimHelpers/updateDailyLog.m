function dailyLog = updateDailyLog(dailyLog, dailyLog_old,ex,dirName)
% function dailyLog = updateDailyLog(dailylog, dailyLog_old,ex,dirName)
%
% updates dailyLog and saves if to data directory (dirName)
%

% history
% 02/10/2026    hn: wrote it (moved code from runEpxt)

dailyLog.nTrialsPerDay = dailyLog_old.nTrialsPerDay+ex.goodtrial;
if isfield(ex,'Trials') && isfield(ex.Trials,'Reward')
    correct = length(find([ex.Trials.Reward]==1));
    dailyLog.nCorrectTrialsPerDay = dailyLog.nCorrectTrialsPerDay + correct;
else 
    
    dailyLog.nCorrectTrialsPerDay = dailyLog_old.nTrialsPerDay + ex.goodtrial;
end
cur_dir = cd(dirName);
save('dailyLog','dailyLog');

cd(cur_dir);


