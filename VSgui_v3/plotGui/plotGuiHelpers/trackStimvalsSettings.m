function [f1,f2,unmatched_fields] = trackSimvalsSettings(f1,f2);
% function [f1,f2] = trackSimvalsSettings(f1,f2);
% 
% convenience function for concatenation of ex-structure.  
% It goes through all stim.vals in the ex-structures
% f1 and f2 to check whether they match.
% For the stim.vals that differ the respective values are stored for each
% Trial in f1.Trials.field and f2.Trials.field.

% history
% 12/11/14  hn: wrote it


% get all the fields of stim.vals across both files
fnames1 = fieldnames(f1.stim.vals);
fnames2 = fieldnames(f2.stim.vals);
fnames = fnames1;
for n = 1:length(fnames2)
    found = 0;
    for n2 = 1:length(fnames1)
        if strcmp(fnames2{n},fnames1{n2})
            found = 1;
            break
        end
    end
    if ~ found
        fnames{length(fnames)+1} = fnames2{n};
    end
end
reason = [];  % just for debugging purpose
unmatched_fields = {};
for n = 1:length(fnames)
    fields_matched = 1;    
    if ~isfield(f2.stim.vals,fnames{n}) 
        if ~isfield(f1.Trials,fnames{n})
            for ntr = 1:length(f1.Trials)
                eval(['f1.Trials(ntr).' fnames{n} '= f1.stim.vals.' fnames{n} ';'])
            end
        end
        f1.stim.vals = rmfield(f1.stim.vals,fnames{n} );
        if ~isfield(f2.Trials,fnames{n})
            for ntr = 1:length(f2.Trials)
                eval(['f2.Trials(ntr).' fnames{n} '= [];'])
            end
        end
        unmatched_fields{length(unmatched_fields)+1} = fnames{n};
        reason(length(reason)+1) = 1;
    elseif ~isfield(f1.stim.vals,fnames{n}) 
        if ~isfield(f2.Trials,fnames{n})
            for ntr = 1:length(f2.Trials)
                eval(['f2.Trials(ntr).' fnames{n} '= f2.stim.vals.' fnames{n} ';'])            
            end
        end
        f2.stim.vals = rmfield(f2.stim.vals,fnames{n});
        if ~isfield(f1.Trials,fnames{n})
            for ntr = 1:length(f1.Trials)
                eval(['f1.Trials(ntr).' fnames{n} '= [];'])
            end
        end
        unmatched_fields{length(unmatched_fields)+1} = fnames{n};
        reason(length(reason)+1) = 1;
    elseif ~ischar(eval(['f2.stim.vals.' fnames{n} ])) && ... 
        ~ischar(eval(['f2.stim.vals.' fnames{n} ])) && ...
        eval(['~isequal(f2.stim.vals.' fnames{n} ',f1.stim.vals.' fnames{n} ');'])
        reason(length(reason)+1) = 2;
        fields_matched = 0;
    elseif ischar(eval(['f2.stim.vals.' fnames{n} ])) && ... 
        ischar(eval(['f2.stim.vals.' fnames{n} ])) && ...
        eval(['~strcmp(f2.stim.vals.' fnames{n} ',f1.stim.vals.' fnames{n} ')'])
        reason(length(reason)+1) = 3;
        fields_matched = 0;        
    end
    if ~fields_matched
        [f1,f2] = storeFieldInTrials(f1,f2,fnames{n});
        unmatched_fields{length(unmatched_fields)+1} = fnames{n};
    end
end

% inform user about mismatch
if ~isempty(unmatched_fields)
    str = [];
    for n=1:length(unmatched_fields)
        str = [str,' ' unmatched_fields{n}];
    end
    disp(['The following stimulus values did not match:' str]);
    disp(['reason: ' num2str(reason) ])
end
    


% -----------------------------------------------
%----------------------------------subfunctions

function [f1,f2]= storeFieldInTrials(f1,f2,field)

for ntr = 1:length(f1.Trials)
    
    if ~(isfield(f1.Trials,field) && ~isempty(eval(['f1.Trials(ntr).' field])) )
        %disp(['in ' field ' val:' num2str(eval(['f1.stim.vals.' field])) ] )
        eval(['f1.Trials(ntr).' field '= f1.stim.vals.' field ';'])
    else %disp(['f1 trval: ' num2str(eval(['f1.Trials(ntr).' field]))])
    end
end
f1.stim.vals = rmfield(f1.stim.vals,field); 

for ntr = 1:length(f2.Trials)
    if ~(isfield(f2.Trials,field) && ~isempty(eval(['f2.Trials(ntr).' field]))) 
        %disp(['in2 ' field ' val:' num2str(eval(['f2.stim.vals.' field])) ] )
    eval(['f2.Trials(ntr).' field '= f2.stim.vals.' field ';'])
    else %disp(['f2 trval: ' num2str(eval(['f2.Trials(ntr).' field]))])
    end
end
f2.stim.vals = rmfield(f2.stim.vals,field);




