function plotEyePos(ex)
% takes the ex structure and plots eye positions of successfully completed
% trials
if ex.setup.monitorWidth
    monitor_width = ex.setup.monitorWidth;
else
    monitor_width = 61.5;
end

if isfield(ex.setup,'viewingDistance')
    vd = ex.viewingDistance;
else vd = 101;  % in cm 
end
dpp = atan(monitor_width/vd)*180/pi/ex.setup.screenRect(3);  % degrees per pixes

tr = ex.Trials;
idx = find([tr.Reward]==1);
x0 = ex.eyeCal.X0;
y0 = ex.eyeCal.Y0;
x_gain = ex.eyeCal.XGain;
y_gain = ex.eyeCal.YGain;

for n = idx
    if n<20
    figure;
    set(gcf,'position',[680         360        1061         618])
    hold off
    subplot('position',[0.0848    0.3625    0.85    0.6])
    samples = find(~isnan(tr(n).Eye.t));% & tr(n).Eye.t-tr(n).Eye.t(1)<ex.fixduration);
    t= tr(n).Eye.t(samples)-tr(n).Eye.t(1);
    xpos = (tr(n).Eye.v(1,samples)-x0)*x_gain*dpp;
    ypos = (tr(n).Eye.v(2,samples)-y0)*y_gain*dpp;
    plot(t,xpos,'-r'); hold on;
    plot(t,ypos,'-b');
    ylabel('dva')
    plot(t,ex.fixWinW*dpp*ones(1,length(t)),'--r');
    plot(t,ex.fixWinH*dpp*ones(1,length(t)),'--b');
    plot(t,-ex.fixWinH*dpp*ones(1,length(t)),'--b');
    plot(t,-ex.fixWinW*dpp*ones(1,length(t)),'--r');
    legend('hor','vert','fixWinW','fixWinH')
    title(['\sigma_x:' num2str(std(xpos)) ' \sigma_y:' num2str(std(ypos))])
    subplot('position',[0.0848    0.05    0.8202    0.2]);
    plot(t,tr(n).Eye.v(3,samples));
    title('pupil size')
    xlabel('time (s)');
    end
end
    
    
    