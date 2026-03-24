function testDatapixxTiming()

% we test compare timestamps we receive from datapixx using 
% 1) Datapixx('GetTime')
% 2) Datapixx('SetMarker'), using the syntax in
% PsychDatapixx('GetPreciseTime')
% to check for which one the mismatch with PTB clock is smaller

%%
% first synchronize clocks
[getsecs, boxsecs, confidence] = PsychDataPixx('GetPreciseTime')

% testing Datapixx('GetTime')
ptb = [];
tbox = [];
for n = 1:20;   
    ptb(1,n) = GetSecs;
    tbox(1,n) = Datapixx('GetTime');
    ptb(2,n) = GetSecs;
    
    pause(.5); % mimic trial
    
    ptb(3,n) = GetSecs;
    tbox(2,n) = Datapixx('GetTime');
    ptb(4,n) = GetSecs;
end
dur_pre1 = ptb(3,:)-ptb(1,:);
dur_post1 = ptb(4,:)-ptb(2,:);
dur_dp1 = tbox(2,:)-tbox(1,:);

% testing Datapixx('SetMarker')
ptb2 = [];
tbox2=[];
for n = 1:20;  
    Datapixx('SetMarker'); % prepare clock
    pause(.1)
    ptb2(1,n) = GetSecs;
    Datapixx('RegWr');
    ptb2(2,n) = GetSecs;
    Datapixx('RegWrRd');
    tbox2(1,n) = Datapixx('GetMarker');
    
    pause(.5);
    
    Datapixx('SetMarker'); % prepare clock
    ptb2(3,n) = GetSecs;
    Datapixx('RegWr');
    ptb2(4,n) = GetSecs;
    Datapixx('RegWrRd');
    tbox2(2,n) = Datapixx('GetMarker');
end
dur_pre2 = ptb2(3,:)-ptb2(1,:);
dur_post2 = ptb2(4,:)-ptb2(2,:);
dur_dp2 = tbox2(2,:)-tbox2(1,:);

figure;
subplot(2,2,1)
hist(dur_pre1-dur_dp1);
title('pre - datapixx')

subplot(2,2,2)
hist(dur_post1-dur_dp1);
title('post - datapixx')

subplot(2,2,3)
hist(dur_pre2-dur_dp2);
title('pre - datapixx')

subplot(2,2,4)
hist(dur_post2-dur_dp2);
title('post - datapixx')

disp(['the mean difference of "trial duration" between GetTime' ...
    ' and GetSecs is' [num2str(mean(dur_pre1-dur_dp1))] 'sec'])
disp(['the mean difference of "trial duration" between GetPreciseTime' ...
    ' and GetSecs is' [num2str(mean(dur_pre2-dur_dp2))] 'sec'])

