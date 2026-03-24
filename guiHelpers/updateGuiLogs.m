function updateGuiLogs(dailyLog)

% function updateGuiLogs(dailyLog)

% updates the experiment log and daily log values displayed on the gui

global myhandles ex



set(myhandles.nCorrectTrialsPerDay,'String',num2str(dailyLog.nCorrectTrialsPerDay));
set(myhandles.nTrialsPerDay,'String',num2str(dailyLog.nTrialsPerDay));
set(myhandles.nTrialsInExpt,'String',num2str(ex.finish));
set(myhandles.nCompletedTrialsInExpt,'String',num2str(ex.goodtrial));