% testDigPins
% ccnt = 0
% dig = [];
% vs = [];
% for n = 1:35;
%     sendStrobe(n);
%     pause(.002)
%     [cnt,tstamps,events]=xippmex('digin');
%     if cnt>0
%         ccnt = ccnt+1;
%         dig(ccnt) = events(1).parallel;
%         vs(ccnt) = n;
%         
%     end
% end
% 
% figure;
% 
% plot(vs,dig,'bo')
% hold on;
% plot([0 vs(end)],[0 vs(end)],'-')
%%
[cnt,tstamps,events]=xippmex('digin');
dig = [];
tocs = [];
for n = 1: 1276
    tic
    sendStrobe(n)
    tocs = [tocs,toc];
    pause(.005)
    dig(n) = getDIN;
%     Datapixx('SetDoutValues',0)
%     Datapixx('RegWr');
%     pause(.005)
end
figure; hist(tocs)
tic
[cnt,tstamps,events]=xippmex('digin');
toc

figure;
plot([1:length(dig)],dig,'bo')
hold on;
plot([0 dig(end)],[0 dig(end)],'-')