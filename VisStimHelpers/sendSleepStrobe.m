function ex=sendSleepStrobe(ex,strobe)
% function ex=sendSleepStrobe(ex,ex.strobe.SLEEP_ON)
% send sleep strobe and register the time in the ex file
%
% history
% 12/05/17  hn: wrote it

sendStrobe(strobe);
if strobe == 10011
    disp('sending sleep ON strobe')
elseif strobe == 10012
    disp('sending sleep OFF strobe')
else disp('in sending sleep strobe')
end

sleepTime = GetSecs;
cnt =0;
if isfield(ex.Trials(length(ex.Trials)),'sleepStrobe')
    cnt = length(ex.Trials(length(ex.Trials)).sleepStrobe);
end

ex.Trials(length(ex.Trials)).Trials.sleepStrobe(cnt+1).value = strobe;
ex.Trials(length(ex.Trials)).Trials.sleepStrobe(cnt+1).t = sleepTime;

