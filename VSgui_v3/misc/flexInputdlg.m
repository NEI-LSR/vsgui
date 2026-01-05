function answer=flexInputdlg(prompt, defaults, rowNames,colNames )

% function answer=flexInputdlg(prompt, defaults, rowNames,colNames )
%
% helper function to allow for flexible user input in table format.
% usage similar to inputdlg but allowing for multiple columns of input 
% using uitable
%
% input: prompt:    character string with instructions for user
%        defaults:  cell{numRow,numColumns} with default values for each 
%                   input; variables for each column need to be of the same 
%                   type: either numeric, or character strings
%       colNames:   cell(1,numColumns} with names for each column
%       rowNames    cell(1,numRows} with names for each column
%
% history
% 01/23/25  hn: wrote it
%%
frameW = 100;
fontSize = 10;

% open the user input table
figh = figure;
t = uitable(figh,'Data',defaults,'Position',[frameW frameW size(defaults,2)*frameW frameW*3],...
    'ColumnName',colNames,'ColumnEditable',true,'RowName',rowNames,...
    'FontSize',fontSize); 
% full table visible
set(t,'Position',[frameW frameW t.Extent(3) t.Extent(4)]);
fpos = get(figh,'position');
set(figh,'Position',...
    [fpos(1),fpos(2) t.Extent(3)+2*frameW t.Extent(4)+1.5*frameW],...
    'name',prompt,'NumberTitle','off');

% wait for user input until OK button is pressed
h = uicontrol('Position',[t.Extent(3)-frameW/2 0.3*frameW 0.8*frameW frameW/2],...
    'String','OK', 'Callback','uiresume(gcbf)');
uiwait(figh)
answer = t.Data;
close(figh);
