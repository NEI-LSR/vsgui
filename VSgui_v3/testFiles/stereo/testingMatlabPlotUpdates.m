

figure;
pause(1)
hold off
tic
cnt = 0;
while toc<2
    %a=randn;
    %b=randn;
    cnt = cnt+1;
    plot(cnt,cnt,'ro');
    drawnow
    hold on;
end