function [ex,vals,nsamples] = getStimulusValues(ex,exp);

% function [ex,vals,nsamples] = getStimulusValues(ex,exp);
%
% calculates the stimulus values for experiment 'exp' based on the
% parameters contained in the structure ex.exp.eX (where eX = 'exp')
% vals and nsamples are also returned individually
% 
% history
% 8/8/14    hn: wrote it
% 5/17/2023 ik: added rounding off with precision of 10^-5 for lineear scale;

vals = [];
nsamples = 1;
precision = 10^5;
if isfield(ex.exp,exp) 
    if strcmpi(eval(['ex.exp.' exp '.scale']),'lin')
        vals = eval(['[ex.exp.' exp '.min:ex.exp.' exp '.inc:(ex.exp.' ...
            exp '.nsamples-1)*ex.exp.' exp '.inc + ex.exp.' exp '.min];']);
        vals = round(vals*precision)/precision;
    elseif strcmpi(eval(['ex.exp.' exp '.scale']),'log')
        vals = eval(['ex.exp.' exp '.min * ex.exp.' exp ...
            '.inc.^([0:ex.exp.' exp '.nsamples-1]);']);
    elseif strcmpi(eval(['ex.exp.' exp '.scale']),'range')
        if isfield(eval(['ex.exp.' exp ]),'range')
            vals = eval(['ex.exp.' exp '.range;']);
            eval(['ex.exp.' exp '.nsamples = length(vals);']);
        else
            vals = [];
            nsamples = NaN;
        end
    end
    eval(['ex.exp.' exp '.vals = vals;']);
    nsamples = eval(['ex.exp.' exp '.nsamples;']); 
end

