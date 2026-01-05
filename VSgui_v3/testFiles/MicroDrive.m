function MicroDrive

%% default values
%md.ttyname = '/dev/tty.USA19H3d1P1.1';
md.ttyname = '/dev/tty.USA19H1d1P1.1';
md.position = 0;
md.step = 0;
md.customstep = 0;
md.stepscale = 65.6;
md.speedscale = 15000;
md.customspeed = 1; %also default
md.motorspeed = round(md.customspeed.* md.speedscale.*md.stepscale/1000);
md.alldepths = [];
md.alltimes = [];
md.offidx = []; %keep  track of when motor cut
md.maxrange = 3000000; % 30cm

% open serial port
x = instrfind('type','serial');
delete(x);
md.sPort = serial(md.ttyname,'BaudRate',9600);
fopen(md.sPort);
fprintf(md.sPort,'ANSW1\n'); %?0 would stop unwanted "OK"
fprintf(md.sPort,'SOR0\n');
fprintf(md.sPort,'NET0\n');
fprintf(md.sPort,'BAUD%d\n',9600);
fprintf(md.sPort,'SP%d\n',md.motorspeed);

fprintf(md.sPort,'APL1\n');
fprintf(md.sPort,'LL%.0f\n',-md.maxrange);
fprintf(md.sPort,'LL%.0f\n',md.maxrange);
fprintf(md.sPort,'APL1\n');
fprintf(md.sPort,'EN\n');
fprintf(md.sPort,'DI\n');




