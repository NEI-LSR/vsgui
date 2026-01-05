function [f1,f2] = matchTrialFields(f1,f2)

% function [f1,f2] = matchTrialFields(f1,f2)
%
% convenience function to match the fields between two ex-structures f1 and
% f2.
% If a field in f1.Trials is found that is not present in f2 this field is
% generated in f2.Trials and filled with NaN, and vice versa for f1 with
% fields in f2.Trials not present in f1.Trials.

% history
% 12/17/14  hn: generated it

% get fields for f1 and f2
f1Fields = fieldnames(f1.Trials);
f2Fields = fieldnames(f2.Trials);

unionFields = union(f1Fields,f2Fields,'stable');

% add missing fields to f1
missing_f1 = setdiff(f2Fields,f1Fields);
for i=1:length(missing_f1)
    f1.Trials(end).(missing_f1{i}) = [];
end

% add missing fields to f2
missing_f2 = setdiff(f1Fields,f2Fields);
for i=1:length(missing_f2)
    f2.Trials(end).(missing_f2{i}) = [];
end

% order fields so that both structures have the same fields in the same
% order
f1.Trials = orderfields(f1.Trials,unionFields);
f2.Trials = orderfields(f2.Trials,unionFields);

unmatched_fields = [missing_f1;missing_f2]';
reason = [ones(1,length(missing_f1)),ones(1,length(missing_f2))*2];


%{
unmatched_fields = {};
cnt = 1;

% check fields in f1 and generate them filled with NaN if not present in f2
for n = 1:length(f1Fields)
    if ~isfield(f2.Trials,f1Fields{n})
        for ntr = 1:length(f2.Trials)
            eval(['f2.Trials(ntr).' f1Fields{n} '=NaN;';]);
        end
        unmatched_fields{cnt} = f1Fields{n};
        reason(cnt) = 1;
        cnt=cnt+1;    
    end
end

% check fields in f2 and generate them filled with NaN if not present in f1
for n = 1:length(f2Fields)
    if ~isfield(f1.Trials,f2Fields{n})
        for ntr = 1:length(f1.Trials)
            eval(['f1.Trials(ntr).' f2Fields{n} '=NaN;';]);
        end
        unmatched_fields{cnt} = f2Fields{n};
        reason(cnt) = 2;
        cnt = cnt+1;
    end
end
%}

% inform user about mismatch
if ~isempty(unmatched_fields)
    str = [];
    for n=1:length(unmatched_fields)
        str = [str,' ' unmatched_fields{n}];
    end
    disp(['The following Trial fields did not match:' str]);
    disp(['reason: ' num2str(reason) ])
end
    

