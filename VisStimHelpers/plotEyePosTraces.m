function plotEyePosTraces(ex,trEye)

% function plotEyePosTraces(ex,trEye)
% history
% 07/07/14  hn: wrote it
% 07/11/14  hn: -included field 'setup' and moved setup parameters into it
%               new parameter name          old parameter name
%               ex.setup.stereo             ex.stereo
%               ex.setup.window             ex.window
%               ex.setup.overlay            ex.overlay
%               ex.setup.refreshRate        ex.refreshrate



dpp = atan(ex.setup.monitorWidth/2/ex.setup.viewingDistance)*180/pi/(ex.setup.screenRect(3)/2);  % degrees per pixes
subplot('position',[0.1    0.03    0.87    0.145])
hold off;
plot(trEye.t-trEye.t(1),(trEye.v(1,:)-[ex.eyeCal.RX0])*ex.eyeCal.RXGain*dpp,'b-'); 
hold on;
plot(trEye.t-trEye.t(1),(trEye.v(2,:)-[ex.eyeCal.RY0])*ex.eyeCal.RYGain*dpp,'r-'); 
plot(trEye.t-trEye.t(1),ones(1,length(trEye.t))*ex.fix.WinW*dpp,'--b')
plot(trEye.t-trEye.t(1),ones(1,length(trEye.t))*ex.fix.WinH*dpp,'--r')
plot(trEye.t-trEye.t(1),-ones(1,length(trEye.t))*ex.fix.WinW*dpp,'--b')
plot(trEye.t-trEye.t(1),-ones(1,length(trEye.t))*ex.fix.WinH*dpp,'--r')
plot(trEye.t-trEye.t(1),(trEye.v(1,:)-[ex.eyeCal.RX0])*ex.eyeCal.RXGain*dpp,'b-'); 
plot(trEye.t-trEye.t(1),(trEye.v(2,:)-[ex.eyeCal.RY0])*ex.eyeCal.RYGain*dpp,'r-'); 
xlabel time[s]
ylabel vda
legend([ 'hor. eyepos'],['vert. eyepos'],['width'],['height'],'location','NorthEastOutside');

% subplot(2,2,3)
% hold off;
% v= trEye.v;
% for n = 1:size(v,1)
%     v(n,:) = v(n,:)-mean(v(n,~isnan(v(n,:))));
% end
% plot(v'); set(gca,'xlim',[0 1000]);
