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

for n = 1:30
Datapixx('SetDoutValues',n );
     Datapixx('RegWr');
    pause(.5)
    Datapixx('SetDoutValues',0)
     Datapixx('RegWr');
%     pause(.005)
end