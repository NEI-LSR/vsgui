function [ex, missingTrials] = rescueFile(varargin)

% when called from the temporary file directory for ex files for which a
% VisStim crash occured this script will make a normal ex-file from the
% data in this directory and stores is in the above direcory: ./..
% 
% Note that once you checked that the new ex-file is ok you should delete
% the temporary file directory

% 2021.2.23 ik: revised it to speed it up and avoid an error due to
% non-existence of the filed 'fileName' in ex.
% 01/29/26  hn: updated to allow for variable inputs and not assume call
%           from trial directory

%% Variable inputs
pa = inputParser;
addOptional(pa, 'trialDir', pwd);  % default is current directory 
addOptional(pa,'parentStruct',[]);
parse(pa, varargin{:});
inputs = pa.Results;

if isempty(inputs.parentStruct)
    % get the ex structure:
    % 2021.2.23 ik: Assuming the it will be excuted in the folder where
    % temporary individual trials are stored, and ex file in that folder has
    % the same name as the folder name, now it checks if the ex file exists in
    % the folder.
    d = pwd;
    idx = strfind(d,'/');
    fname = sprintf('%s.mat',d(idx(end)+1:end));
    a = dir(fname);  
    if length(a)~= 1
        disp('there are more than one header functions in this directory')
        disp('are you sure you are in the temporary file directory?')
        return
    end
    cur_dir = pwd;
    p_dir = strrep(cur_dir,'CIN_local','CIN_share');
    p_dir = strrep(p_dir,'CIN_share','CIN_share/Code/FileProcessing');
    addpath(p_dir)
    load(a.name,'ex')
else
    ex = inputs.parentStruct;
end

% get the trial structures
t = dir('tr*.mat');
if length(t)<1
    disp('there are no trials in this directory')
    return
end

% now fill the ex structure with all the individual trials
% 2021.2.23 ik: replaced the original double loop with a single loop and
% use ### in tr###.mat as the trial number
trialNumber = NaN(1,length(t));
for n = 1:length(t)
    [startIdx,endIdx] = regexp(t(n).name,'\d*');
    if length(startIdx) == 1
        no = str2double(t(n).name(startIdx:endIdx));
        trialNumber(n) = no;
    else
        error('something wrong')
    end
    
    if isempty(inputs.parentStruct) % keep verbose when rescuing trials
        fprintf('adding Trial #%d...\n',no);
    end
    v=load(t(n).name,'Trials');

    try
        ex.Trials(no) = v.Trials;
    catch
        [ex.Trials,v.Trials] = matchFields(ex.Trials,v.Trials);
        ex.Trials(no) = v.Trials;
    end
end


% 2021.2.23 ik: check missing trials. This might be redundant because it
% would have given an error in the above for-loop if there was a missing
% trial
idx = find(isnan(trialNumber));
missingTrials = t(idx);
for i=1:length(idx)
    warning('%s was not processed!\n',t(idx).name)
end    

if ~ isempty(inputs.parentStruct)
    return
end

% 2021.2.23 ik: use ex.Header.onlineFileName because ex does not have
% 'fileName' field.
cd ..
if isfile(ex.Header.onlineFileName)
    [idx,~] = regexp(ex.Header.onlineFileName,'.mat');
    fname = sprintf('%s.rescued.mat',ex.Header.onlineFileName(1:idx-1));
else
    fname = ex.Header.onlineFileName;
end

% ik: check the size of ex
whosEx = whos('ex');
if whosEx.bytes < 1e+9
    save(fname,'ex')
else
    save(fname,'ex','-v7.3');
end

end



function [s1,s2] = matchFields(s1,s2)

s1Fields = fieldnames(s1);
s2Fields = fieldnames(s2);

s2Missing = setdiff(s1Fields,s2Fields);
for i=1:length(s2Missing)
    s2(end).(s2Missing{i}) = [];
end

s1Missing = setdiff(s2Fields,s1Fields);
for i=1:length(s1Missing)
    s1(end).(s1Missing{i}) = [];
end

s2 = orderfields(s2,s1); 


end


