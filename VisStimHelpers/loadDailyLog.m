function dailyLog = loadDailyLog(dirName)
%
% function dailyLog = loadDailyLog(dirName)
%
% loads the dailyLog from the specified directory
%

% history
% 02/10/2026    hn: wrote it (moved code from runExpt)

cur_dir = cd(dirName);

if exist('dailyLog.mat') ==2
    load('dailyLog.mat');
else
    dailyLog.nTrialsPerDay = 0;
    dailyLog.nCorrectTrialsPerDay = 0;
end
cd(cur_dir);

