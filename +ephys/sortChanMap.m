function [ind_sorted] = sortChanMap(chMap)

% function [ind_sorted] = sortChanMap(chMap)
% input:    sglx channel map (fetched via matlab)
% output:   indices that sort channel order by depth (z)
%
% history
% 03/12/26  hn: wrote it

if ~isstruct(chMap)         % currently only available for sglx channel map
    return
end

% parse field names of structure chanMap
fn = fieldnames(chMap);

pattern = '^ch(\d+)_([z,x,s,u])$';
tk = regexp(fn, pattern, 'tokens');
out = cellfun(@(x) ~isempty(x), tk);      % remove empty tokens
tokens = tk(out);
fn     = fn(out);

a = 'zxsu';                               % ch info: Zpos, Ypos, Shank U
mapA = nan(floor(length(fn)/4),4);
for n = 1:length(tokens)
    row = str2double(tokens{n}{1}{1})+1;
    col = strfind(a,tokens{n}{1}{2});
    mapA(row,col) = chMap.(fn{n});

end

[~,ind_sorted] = sort(mapA(:,1));           % sort by Z position
