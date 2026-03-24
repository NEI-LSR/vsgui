function ex = getExptSettings(ex,type)

% function ex = getExptSettings(ex,type)
% 
% returns the default experiment settings for experiment type:
% 'or' -- orientation tuning
% 'sf' -- spatial frequency tuning
% 'tf' -- temporal frequency tuning
% 'sz' -- size tuning
%  'hdx' - hdx - values for disparity discrimination task

% history
% 04/14     hn: wrote it
% 08/02/14  hn: extended it to allow for input of multiple experiment types
%               simultaneously
%               made sure that old experiments get cleared first
% 08/28/14  hn: included monocular expt
% 08/06/18  hn: added settings for second exp x02/y02
% 04/04/23  hn: account for scmapping
% 04/20/23  hn: include Ce expt

% first clear out old experiments
for n = 1:4
    if isfield(ex.exp,['e' num2str(n)])
        ex.exp = rmfield(ex.exp,['e' num2str(n)]);
    end
end
if isstr(type)
    mytype{1} = type;
    type = mytype;
end


ex.stim.vals.RC = 0;
ex.exp.afc = 0;
for n = 1:length(type)
    ename = sprintf('e%d',n);
    switch type{n}
        case 'Tx'
            ex.exp.(ename).type = 'Tx';
            ex.exp.(ename).scale = 'lin';
            ex.exp.(ename).inc = 1;
            ex.exp.(ename).nsamples = 7;
            ex.exp.(ename).min = ex.stim.vals.x0 - ...
                ex.exp.(ename).inc * (ex.exp.(ename).nsamples - 1)/2;
            ex.stim.type = 'none';
            ex.exp.include_blank = false;
            
        case 'Ty'
            ex.exp.(ename).type = 'Ty';
            ex.exp.(ename).scale = 'lin';
            ex.exp.(ename).inc = 1;
            ex.exp.(ename).nsamples = 7;
            ex.exp.(ename).min = ex.stim.vals.y0 - ...
                ex.exp.(ename).inc * (ex.exp.(ename).nsamples - 1)/2;
            ex.stim.type = 'none';
            ex.exp.include_blank = false;
            
        case 'freeViewing'
            a = 'freeViewing';
            eval(['ex.exp.e' num2str(n) '.type=a;'])
            eval(['ex.exp.e' num2str(n) '.min=0;'])
            eval(['ex.exp.e' num2str(n) '.inc=1;'])
            a = 'lin';
            eval(['ex.exp.e' num2str(n) '.scale=a;']);
            eval(['ex.exp.e' num2str(n) '.nsamples=2;']);
            ex.stim.type = 'fullfield';
            ex.exp.include_blank = 0;
        
        case 'y_OffsetCueAmp'
            a = 'y_OffsetCueAmp';
            eval(['ex.exp.e' num2str(n) '.type=a;']) 
            eval(['ex.exp.e' num2str(n) '.min=0;']) 
            eval(['ex.exp.e' num2str(n) '.inc=.1;']) 
            a = 'lin';
            eval(['ex.exp.e' num2str(n) '.scale=a;']); 
            eval(['ex.exp.e' num2str(n) '.nsamples=3;']) 

        case 'or'
            a = 'or';
            eval(['ex.exp.e' num2str(n) '.type=a;']) 
            eval(['ex.exp.e' num2str(n) '.min=0;']) 
            eval(['ex.exp.e' num2str(n) '.inc=22.5;']) 
            a = 'lin';
            eval(['ex.exp.e' num2str(n) '.scale=a;']); 
            eval(['ex.exp.e' num2str(n) '.nsamples=16;']) 
            ex.stim.vals.wi = ex.stim.vals.sz;
            ex.stim.vals.hi = ex.stim.vals.sz;
            ex.exp.include_blank = 1;
            ex.stim.type = 'grating';
            ex.stim.masktype = 'circle';
            
        case 'sf'
            a= 'sf';
            eval(['ex.exp.e' num2str(n) '.type=a;']); 
            eval(['ex.exp.e' num2str(n) '.min=.125;']) 
            eval(['ex.exp.e' num2str(n) '.inc=2;']) 
            a = 'log';
            eval(['ex.exp.e' num2str(n) '.scale=a;']) 
            eval(['ex.exp.e' num2str(n) '.nsamples=8;']) 
            ex.stim.vals.wi = ex.stim.vals.sz;
            ex.stim.vals.hi = ex.stim.vals.sz;
            ex.exp.include_blank = 1;
            
        case 'tf'
            a='tf';
            eval(['ex.exp.e' num2str(n) '.type=a;']) 
            eval(['ex.exp.e' num2str(n) '.min=.46875;']) 
            eval(['ex.exp.e' num2str(n) '.inc=2;']) 
            a = 'log';
            eval(['ex.exp.e' num2str(n) '.scale=a;']) 
            eval(['ex.exp.e' num2str(n) '.nsamples=7;']) 
            ex.stim.vals.wi = ex.stim.vals.sz;
            ex.stim.vals.hi = ex.stim.vals.sz;
            ex.exp.include_blank = 1;
            
        case 'sz'
            a= 'sz';
            eval(['ex.exp.e' num2str(n) '.type=a;']) 
            eval(['ex.exp.e' num2str(n) '.min=.9;']) 
            eval(['ex.exp.e' num2str(n) '.inc=1.4;']) 
            a = 'log';
            eval(['ex.exp.e' num2str(n) '.scale=a;']) 
            eval(['ex.exp.e' num2str(n) '.nsamples=8;']) 
            ex.stim.vals.wi = 0;
            ex.stim.vals.hi = 0;
            ex.exp.include_blank = 1;
            
        case 'co'
            a= 'co';
            eval(['ex.exp.e' num2str(n) '.type=a;']) 
            eval(['ex.exp.e' num2str(n) '.min=0;']) 
            eval(['ex.exp.e' num2str(n) '.inc=1;']) 
            a = 'range';
            eval(['ex.exp.e' num2str(n) '.scale=a;'])
            eval(['ex.exp.e' num2str(n) '.range=[ 0.0156 0.0312 0.0625 0.125 0.25 0.5 1];'])
            eval(['ex.exp.e' num2str(n) '.nsamples=7;']) 
            
            ex.exp.include_blank = 1;
            
        case 'me'
            a= 'me';
            eval(['ex.exp.e' num2str(n) '.type=a;']) 
            eval(['ex.exp.e' num2str(n) '.min=-1;']) 
            eval(['ex.exp.e' num2str(n) '.inc=1;']) 
            a = 'lin';
            eval(['ex.exp.e' num2str(n) '.scale=a;']) 
            eval(['ex.exp.e' num2str(n) '.nsamples=3;']) 
            ex.exp.include_blank = 1;
            
        case 'x0'
            a = 'x0';
            eval(['ex.exp.e' num2str(n) '.type=a;']) 
            eval(['ex.exp.e' num2str(n) '.min=ex.stim.vals.x0-1;']) 
            eval(['ex.exp.e' num2str(n) '.inc=1;']) 
            a = 'lin';
            eval(['ex.exp.e' num2str(n) '.scale=a;']) 
            eval(['ex.exp.e' num2str(n) '.nsamples=9;']) 
            ex.stim.vals.wi = 0.2;
            ex.stim.vals.hi = 5;
            ex.exp.include_blank = 1;
            ex.exp.nreps = 4;
            ex.stim.masktype = '';
            ex.exp.StimPerTrial = 4;
            
        case 'x02'
            a = 'x02';
            eval(['ex.exp.e' num2str(n) '.type=a;']) 
            eval(['ex.exp.e' num2str(n) '.min=ex.stim.vals.x0-1;']) 
            eval(['ex.exp.e' num2str(n) '.inc=.25;']) 
            a = 'lin';
            eval(['ex.exp.e' num2str(n) '.scale=a;']) 
            eval(['ex.exp.e' num2str(n) '.nsamples=9;']) 
            ex.stim.vals.wi = 0.2;
            ex.stim.vals.hi = 5;
            ex.exp.include_blank = 1;
            ex.exp.nreps = 4;
            ex.stim.masktype = '';
            ex.exp.StimPerTrial = 4;
            ex.stim.vals.stim2 =1;
            
        case 'y0'
            a = 'y0';
            eval(['ex.exp.e' num2str(n) '.type=a;']) 
            eval(['ex.exp.e' num2str(n) '.min=ex.stim.vals.y0-1;']) 
            eval(['ex.exp.e' num2str(n) '.inc=1;']) 
            a = 'lin';
            eval(['ex.exp.e' num2str(n) '.scale=a;']) 
            eval(['ex.exp.e' num2str(n) '.nsamples=9;']) 
            ex.stim.vals.hi = 0.2;
            ex.stim.vals.wi = 5;
            ex.exp.include_blank = 1;  
            ex.exp.nreps = 4;
            ex.stim.masktype = '';
            ex.exp.StimPerTrial = 4;
            
        case 'y02'
            a = 'y02';
            eval(['ex.exp.e' num2str(n) '.type=a;']) 
            eval(['ex.exp.e' num2str(n) '.min=ex.stim.vals.y0-1;']) 
            eval(['ex.exp.e' num2str(n) '.inc=.25;']) 
            a = 'lin';
            eval(['ex.exp.e' num2str(n) '.scale=a;']) 
            eval(['ex.exp.e' num2str(n) '.nsamples=9;']) 
            ex.stim.vals.hi = 0.2;
            ex.stim.vals.wi = 5;
            ex.exp.include_blank = 1;  
            ex.exp.nreps = 4;
            ex.stim.masktype = '';
            ex.exp.StimPerTrial = 4;
            ex.stim.vals.stim2=1;
            
        case 'hdx'
            a = 'hdx';
            eval(['ex.exp.e' num2str(n) '.type=a;']) 
            eval(['ex.exp.e' num2str(n) '.min=-.2;']) 
            eval(['ex.exp.e' num2str(n) '.inc=.4;']) 
            a='lin';
            eval(['ex.exp.e' num2str(n) '.scale=a;'])
            eval(['ex.exp.e' num2str(n) '.nsamples=2;']) 
            ex.exp.afc = 1;
            ex.targ.Pos = [0 180;0 -180];
            ex.stim.vals.dd = 100;
            ex.stim.vals.wi = 3;
            ex.stim.vals.hi = 3;
            ex.stim.vals.swi = 4;
            ex.stim.vals.shi = 4;
            ex.stim.vals.square = 0;
            ex.stim.vals.dotSz = 7;
            ex.stim.vals.ce = 1;
            ex.stim.vals.co = 1;
            ex.stim.vals.x0 = 3;
            ex.stim.vals.y0 = 0;
            ex.stim.vals.dyn = 1;
            ex.stim.vals.dcol = 'blwi';
            ex.stim.vals.vdx = 0;
            ex.stim.vals.shdx = 0;
            ex.stim.vals.svdx = 0;
            ex.stim.vals.hdx = [];
            ex.exp.include_blank = 0;  
            ex.exp.include_monoc = 0;
            
        case 'ce'
            a = 'ce';
            eval(['ex.exp.e' num2str(n) '.type=a;']) 
            eval(['ex.exp.e' num2str(n) '.min=-1;']) 
            eval(['ex.exp.e' num2str(n) '.inc=2;']) 
            a='lin';
            eval(['ex.exp.e' num2str(n) '.scale=a;'])
            eval(['ex.exp.e' num2str(n) '.nsamples=2;']) 
            
            ex.stim.vals.dyn = 1;
            ex.stim.vals.dcol = 'blwi';
            ex.stim.vals.vdx = 0;
            ex.stim.vals.shdx = 0;
            ex.stim.vals.svdx = 0;
            ex.stim.vals.hdx = [];
            ex.exp.include_blank = 1;  
            ex.exp.include_monoc = 1;            
            
        case 'hdx2'
            a = 'hdx2';
            eval(['ex.exp.e' num2str(n) '.type=a;']) 
            eval(['ex.exp.e' num2str(n) '.min=-.05;']) 
            eval(['ex.exp.e' num2str(n) '.inc=.1;']) 
            a='lin';
            eval(['ex.exp.e' num2str(n) '.scale=a;'])
            eval(['ex.exp.e' num2str(n) '.nsamples=2;']) 
            ex.stim.vals.rds2 =1;
            
        case 'Dc2'
            a = 'Dc2';            
            eval(['ex.exp.e' num2str(n) '.type=a;']) 
            eval(['ex.exp.e' num2str(n) '.min=.4;']) 
            eval(['ex.exp.e' num2str(n) '.inc=.3;']) 
            a='range';
            eval(['ex.exp.e' num2str(n) '.scale=a;'])
            eval(['ex.exp.e' num2str(n) '.range=[0 .7];'])
            
        case 'Dc'
            a = 'Dc';            
            eval(['ex.exp.e' num2str(n) '.type=a;']) 
            eval(['ex.exp.e' num2str(n) '.min=.4;']) 
            eval(['ex.exp.e' num2str(n) '.inc=.3;']) 
            a='range';
            eval(['ex.exp.e' num2str(n) '.scale=a;'])
            eval(['ex.exp.e' num2str(n) '.range=[0 0.0625 0.125 .25 .5];'])
            ex.exp.afc = 1;
            ex.targ.Pos = [0 180;0 -180];
            ex.stim.vals.dd = 100;
            ex.stim.vals.wi = 3;
            ex.stim.vals.hi = 3;
            ex.stim.vals.swi = 4;
            ex.stim.vals.shi = 4;
            ex.stim.vals.square = 0;
            ex.stim.vals.dotSz = 7;
            ex.stim.vals.ce = 1;
            ex.stim.vals.co = 1;
            ex.stim.vals.x0 = 3;
            ex.stim.vals.y0 = 0;
            ex.stim.vals.dyn = 1;
            ex.stim.vals.dcol = 'blwi';
            ex.stim.vals.vdx = 0;
            ex.stim.vals.shdx = 0;
            ex.stim.vals.svdx = 0;
            ex.stim.vals.hdx = [];
             ex.stim.vals.hdx_range = [-.8:0.2:0.8];
             ex.stim.type = 'rds';
             
        case 'Dc_fine'
            a = 'Dc';            
            eval(['ex.exp.e' num2str(n) '.type=a;']) 
            eval(['ex.exp.e' num2str(n) '.min=.4;']) 
            eval(['ex.exp.e' num2str(n) '.inc=.3;']) 
            a='range';
            eval(['ex.exp.e' num2str(n) '.scale=a;'])
            eval(['ex.exp.e' num2str(n) '.range=[0 0.0625 0.125 .25 .5];'])
            ex.exp.afc = 1;
            ex.targ.Pos = [0 180;0 -180];
            ex.stim.vals.dd = 100;
            ex.stim.vals.wi = 3;
            ex.stim.vals.hi = 3;
            ex.stim.vals.swi = 4;
            ex.stim.vals.shi = 4;
            ex.stim.vals.square = 0;
            ex.stim.vals.dotSz = 7;
            ex.stim.vals.ce = 1;
            ex.stim.vals.co = 1;
            ex.stim.vals.x0 = 3;
            ex.stim.vals.y0 = 0;
            ex.stim.vals.dyn = 1;
            ex.stim.vals.dcol = 'blwi';
            ex.stim.vals.vdx = 0;
            ex.stim.vals.shdx = 0;
            ex.stim.vals.svdx = 0;
            ex.stim.vals.hdx = [];  
            ex.stim.vals.hdx_range = [-.6:0.1:0.6];
            ex.stim.type = 'rds';
            
        case 'Dc_very_fine'
            a = 'Dc';            
            eval(['ex.exp.e' num2str(n) '.type=a;']) 
            eval(['ex.exp.e' num2str(n) '.min=.4;']) 
            eval(['ex.exp.e' num2str(n) '.inc=.3;']) 
            a='range';
            eval(['ex.exp.e' num2str(n) '.scale=a;'])
            eval(['ex.exp.e' num2str(n) '.range=[0 0.0625 0.125 .25 .5];'])
            ex.exp.afc = 1;
            ex.targ.Pos = [0 180;0 -180];
            ex.stim.vals.dd = 100;
            ex.stim.vals.wi = 3;
            ex.stim.vals.hi = 3;
            ex.stim.vals.swi = 4;
            ex.stim.vals.shi = 4;
            ex.stim.vals.square = 0;
            ex.stim.vals.dotSz = 7;
            ex.stim.vals.co = 1;
            ex.stim.vals.ce = 1;
            ex.stim.vals.x0 = 3;
            ex.stim.vals.y0 = 0;
            ex.stim.vals.dyn = 1;
            ex.stim.vals.dcol = 'blwi';
            ex.stim.vals.vdx = 0;
            ex.stim.vals.shdx = 0;
            ex.stim.vals.svdx = 0;
            ex.stim.vals.hdx = [];  
            ex.stim.vals.hdx_range = [-.35:0.05:0.35];
            ex.stim.type = 'rds';
            
        case 'targOn_delay'
            a = 'targOn_delay';
            eval(['ex.exp.e' num2str(n) '.type=a;']) 
            eval(['ex.exp.e' num2str(n) '.min=0;']) 
            eval(['ex.exp.e' num2str(n) '.inc=.5;']) 
            a='lin';
            eval(['ex.exp.e' num2str(n) '.scale=a;'])
            eval(['ex.exp.e' num2str(n) '.nsamples=3;'])
            
        case 'RC'
            ex.stim.vals.RC = 1;
            ex.exp.StimPerTrial = 1;
            ex.exp.include_blank = 0;
            ex.fix.preStimDuration = 0;
            
        case 'vdx'
            a = 'vdx';
            eval(['ex.exp.e' num2str(n) '.type=a;']) 
            eval(['ex.exp.e' num2str(n) '.min=-1.2;']) 
            eval(['ex.exp.e' num2str(n) '.inc=.2;']) 
            a='lin';
            eval(['ex.exp.e' num2str(n) '.scale=a;'])
            eval(['ex.exp.e' num2str(n) '.nsamples=13;']) 
            ex.exp.afc = 0;
            ex.stim.vals.dd = 20;
            ex.stim.vals.wi = 3;
            ex.stim.vals.hi = 3;
            ex.stim.vals.swi = 4;
            ex.stim.vals.shi = 4;
            ex.stim.vals.square = 0;
            ex.stim.vals.dotSz = 7;
            ex.stim.vals.co = 1;
            ex.stim.vals.x0 = 3;
            ex.stim.vals.y0 = 0;
            ex.stim.vals.dyn = 1;
            ex.stim.vals.dcol = 'blwi';
            ex.stim.vals.hdx = 0;
            ex.stim.vals.shdx = 0;
            ex.stim.vals.svdx = 0;
            ex.stim.vals.vdx = [];
            ex.exp.include_blank = 0;  
            ex.exp.include_monoc = 0;

        case 'imID'
            a = 'imID'; % running an image ID experiment
            eval(['ex.exp.e' num2str(n) '.type=a;'])  
            
            % get directory of image folder and files
            ex = getImageFolder(ex);

            eval(['ex.exp.e' num2str(n) '.min=1;']) 
            eval(['ex.exp.e' num2str(n) '.inc=1;']) 
            a='range';
            eval(['ex.exp.e' num2str(n) '.scale=a;'])
            eval(['ex.exp.e' num2str(n) '.range=[1:length(ex.stim.vals.imageNames)];'])
            % default ID = 1
            ex.stim.vals.ID = 1;
            
        case 'bvo'
            ename = sprintf('e%s',num2str(n));
            ex.exp.(ename).type = 'bvo';
            ex.exp.(ename).min = 0;
            ex.exp.(ename).max = 1;
            ex.exp.(ename).inc = 1;
            ex.exp.(ename).scale = 'range';
            ex.exp.(ename).range = [0,1];
            ex.stim.vals.orNoise = 1;
            ex.stim.vals.wi = 6;
            ex.stim.vals.hi = 6;
            ex.stim.vals.sz = 6;
            ex.stim.vals.hdx = 0;
            ex.stim.vals.or = 135;
            ex.stim.vals.me = 0;
            ex.stim.vals.ce = 1;
        case 'optoStim'
            ename = sprintf('e%s',num2str(n));
            ex.exp.(ename).type = 'optoStim';
            ex.exp.(ename).scale = 'range';
            ex.exp.(ename).range = [0,1];
    end
end
switch ex.stim.type
    case 'grating'
        if ~isfield(ex.stim.vals,'phase')
            ex.stim.vals.phase = 1;
        end
end
% ------------ get range of values for each experiment ------------------
nsamples1 = 1; nsamples2 = 1; nsamples2 = 1; nsamples4 = 1;
[ex] = getStimulusValues(ex,'e1');
[ex] = getStimulusValues(ex,'e2');
[ex] = getStimulusValues(ex,'e3');
[ex] = getStimulusValues(ex,'e4');

if ex.stim.vals.RC
    for n = 1:4
        exp = ['e' num2str(n)];
        if isfield( ex.exp,exp)
            type = eval(['ex.exp.' exp '.type;']);
            eval(['ex.stim.vals.' type '_range = ex.exp.' exp '.vals;'])
        end
    end
end  

% how many trials?
nreps = 1;
for n = 1:4
    if isfield(ex.exp,['e' num2str(n)])
        nreps = eval(['ex.exp.e' num2str(n) '.nsamples']);
    end
end
ex.finish = ex.exp.nreps * nreps;
                
