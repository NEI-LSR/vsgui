function stim = getDefaultStimulusParameters(ex)
% function stim = getDefaultStimulusParameters
% here we define the default stimulus parameters when VS is started.
%
% These definitions were previously included in 'getDefaultSettings.m' but
% I moved them here for better readability of the code.
% This function is called by 'getDefaultSettings.m'.
% parameters are stored in ex.stim.XX

% history
% 08/18/25  hn: wrote it; 

% general parameters for different types of stimuli
stim.vals.st = 1;
stim.vals.RC = 0;  % reverse correlation sequence?: yes: 1, no: 0
stim.vals.me = 0;  % binocular stimulus (1: right monocular, -1: left monocular)

%% parameters for RDS stimulus
stim.vals.dd = 100;    %: dot density
stim.vals.wi = 6;    %: width in dva
stim.vals.hi =6;    %: height in dva
stim.vals.swi = 7;    %: surround width in dva
stim.vals.shi =7;    %: surround height in dva
stim.vals.hdx =0.1;    %: horizontal dx of center patch in dva
stim.vals.vdx =0;    %: vertical dx of center in dva
stim.vals.shdx =0;   %: horizontal dx of surround in dva
stim.vals.svdx =0;   %: vertical dx of surround in dva
stim.vals.dotSz=7;  % dot size in pixels
stim.vals.co = 1;  % max. stimulus contrast
stim.vals.x0 = 3; % center of stimulus (in x) rel. to fp center in dva
stim.vals.y0 = 0; % center of stimulus (in y) rel. to fp center in dva
stim.vals.dyn = 1; % dynamic (1) or static (0) RDS?
stim.vals.dcol = 'blwi'; % dot color
stim.vals.me = 0;  % binocular stimulus (1: right monocular, -1: left monocular)
stim.vals.Dc2 = 0.5;
stim.vals.hdx2 = -0.05;
stim.vals.co2 = 0.2;
stim.vals.ce = 1; % interocular correlation: -1 (anticorrelated) 0 1
stim.vals.hdx_range = -.8 : 0.2 : .8;  % disparity values from which the noise is drawn


%% parameters for grating stimulus
stim.vals.sf = 0.5; % grating sf in cpd
stim.vals.tf = 1;
stim.vals.sz = 5;  % stimulus size in dva
stim.vals.wi = 5;  % stimulus width in dva
stim.vals.hi = 5;  % stimulus height in dva
stim.vals.or = 30; % grating orientation in degrees; 0 is horizontal
stim.vals.x0 = 10; % center of stimulus (in x) rel. to fp center in dva
stim.vals.y0 = 5; % center of stimulus (in y) rel. to fp center in dva
stim.vals.co = 1;  % max. stimulus contrast
stim.drawmask = 1;
stim.vals.adaptation = 0;
stim.vals.adaptationDur = 0;
stim.vals.adaptationOr = 0;
stim.vals.adaptationMe = 0;
stim.vals.RC = 0;
stim.masktype = 'circle';

%% parameters for bar stimulus
stim.type = 'bar';
stim.vals.or = 30;
stim.vals.hi = 5;
stim.vals.wi = .3;
stim.vals.sf = 1;
stim.vals.tf = 1;
stim.vals.flickerTF=0;
stim.vals.col = ex.idx.white;
stim.vals.me = 0;  % binocular stimulus (1: right monocular, -1: left monocular)
