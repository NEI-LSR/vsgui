function ex = getDefaultExpParameters(ex)
% function ex = getDefaultExpParameters(ex)
% here we define the default experimental parameters when VS is started.
%
% These definitions were previously included in 'getDefaultSettings.m' but
% I moved them here for better readability of the code.
% This function is called by 'getDefaultSettings.m'.
% Parameters are stored in ex.exp.XX

% history
% 08/18/25  hn: wrote it; 

%% experiment type
ex.exp.nreps = 100;
ex.exp.afc = false;
%% SC mapping  04/04/23: accounting for Incheol's SC mapping
ex.exp.scmap = false; 
ex.exp.spatialAttention = 0;
ex.exp.nInstructionTrials = 0;
ex.exp.addInstructionTrials = 0; % flag to manually add instruction trials on the fly
ex.exp.countAddInstructionTrials = 0;
ex.exp.numberAdditionalInstructionTrials = 2;  % default for additional instruction trials added on the fly
ex.exp.monocBlank = false; % added on 2/6/24

ex.exp.StimPerTrial = 1;
ex.exp.include_blank = 1;
ex.exp.include_monoc = 0;

%% experiment1 : hdx (08/18/25 HN: do we need this?)
ex.exp.e1.type = 'hdx';
ex.exp.e1.min = -.2;
ex.exp.e1.inc = 0.4;
ex.exp.e1.scale = 'lin';
ex.exp.e1.nsamples = 2;

ex.finish = ex.exp.e1.nsamples   * ex.exp.nreps;


if ~ex.exp.afc
    ex.stim.nseq = ex.finish; % number of stimuli in sequence (only used when running an experiment);
end

