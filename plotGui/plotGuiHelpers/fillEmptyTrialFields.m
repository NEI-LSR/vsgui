function ex = fillEmptyTrialFields(ex,varargin)

% function ex = fillEmptyTrialFields(ex,varargin)
%
% checks the fields in ex.Trials.field and if this field exists
% fills it with NaN if found to be empty
%
% varargin: list of fields to be filled (e.g. 'hdx2')


% history
% 12/13/14  hn: wrote it


for n=1:length(varargin)
    field = varargin{n};
    if isfield(ex.Trials,field)
        for ntr = 1:length(ex.Trials)
            if isempty(eval(['ex.Trials(ntr).' field]))
                eval(['ex.Trials(ntr).' field '= NaN;']);
            end
        end
    end
end