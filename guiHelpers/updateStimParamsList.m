function updateStimParamsList(handles)
% updates stimulus parameter list of gui

% history
% 12/29/14  hn: wrote it

disp('starting updateStimParamsList')	
global ex

% get stimulus parameters in use
par_names = fieldnames(ex.stim.vals);

% get definitions of stimulus parameters 
params = getStimParamDefinitions;

% find stimulus parameters that are not included the definitions (in case
% we add a new one on the fly)
found = zeros(1,length(par_names));
for n = 1:length(par_names)
    for n2 = 1:length(params)
        if strcmp(par_names{n},params(n2).name)
            found(n) = 1;
            break
        end
    end
    if ~found(n)
        params(length(params)+1).name = par_names{n};
        params(length(params)).definition = '';
    end
end

% sort parameters alphabetically; capitalization is not ignored,
% unfortunately
a = {params.name};
[para_sort,sort_idx] = sort(a);
for n = 1:length(para_sort)
    params2(n).name = para_sort{n};
    params2(n).definition = params(sort_idx(n)).definition;
end

ex.stim.params = params2;

% make parameter list for gui
plist = {};
for n=1:length(params2)
    plist{n} = [params2(n).name  '  ' params2(n).definition];
end

% update gui
set(handles.stimParams,'string',plist)
guidata(handles.figure1,handles)

disp('update stim params list done')