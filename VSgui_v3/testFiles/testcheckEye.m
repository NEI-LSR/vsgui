function testcheckEye(ex)


idx = find([ex.Trials.Reward] ==1);

for n = 1:length(idx)
    trEye = ex.Trials(idx(n)).Eye;
    figure
    plot(trEye.t-trEye.t(1),(trEye.v(1,:)-[ex.eyeCal.X0]),'b-'); 
    hold on;
    plot(trEye.t-trEye.t(1),ones(1,length(trEye.t))*ex.fixWinW/ex.eyeCal.XGain,'--b')
    plot(trEye.t-trEye.t(1),(trEye.v(2,:)-[ex.eyeCal.Y0]),'r-'); 
    plot(trEye.t-trEye.t(1),ones(1,length(trEye.t))*ex.fixWinH/ex.eyeCal.YGain,'--r')

    xlabel time[s]
    ylabel voltage
    legend([ 'horizontal'],['width'],['vertical'],['height'])
    passX = sum(abs(trEye.v(1,:)-ex.eyeCal.X0)>ex.fixWinW/ex.eyeCal.XGain);
    passY = sum(abs(trEye.v(2,:)-ex.eyeCal.Y0)>ex.fixWinH/ex.eyeCal.YGain);
    passEye = passX+passY;
    title(['passX:' num2str(passX) ' passY:' num2str(passY) ' passEye:' num2str(passEye)]);
end