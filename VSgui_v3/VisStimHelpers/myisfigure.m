function [out]= myisfigure(h)

% isfigure doesn't seem to exist in new matlab versions;  this is my
% convenience function achieving some of the same as isfigure
% out 1-- handle is a figure handle
% out 0-- handle is not a figure handle

out = 0;
if ishandle(h)
    c=get(h);
    if isfield(c,'Type') && strcmpi(c.Type,'figure')
    out = 1;
    end

end
    