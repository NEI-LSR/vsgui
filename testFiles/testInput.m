%%
prts = [{'A1'},{'A2'},{'A3'},{'A4'},{'B1'},{'B2'},{'B3'},{'B4'},...
    {'C1'},{'C2'},{'C3'},{'C4'}];
[selection,ok] = listdlg('PromptString','select ports in use',...
    'SelectionMode','multiple','ListSize',[160 300],...
    'ListString',prts);

% format input for uitable
defaults = cell(length(selection),4);
rowNames = cell(1,length(selection));
for n = 1:length(selection)
   rowNames{n} = ['port ' prts{selection(n)}];
   defaults{n,1} = ''; 
   defaults{n,2} = 'L'; 
   defaults{n,3} = 32; 
   defaults{n,4} = ''; 
end
colNames{1} = 'recorded area'; colNames{2} = 'hemisphere (L or R)'; 
colNames{3} = '#channels'; colNames{4} = 'bank ID/descriptor';
        prompt = 'SPECIFY PORTS for NEURAL DATA';

answer=flexInputdlg(prompt, defaults, colNames, rowNames)

% % open table input
% figh = figure
% t = uitable(figh,'Data',defaults,'Position',[100 100 500 300],...
%     'ColumnName',colNames,'ColumnEditable',true,'RowName',rowNames);
% set(t,'Position',[100 100 t.Extent(3) t.Extent(4)]);
% fpos = get(figh,'position');
% set(figh,'Position',[fpos(1),fpos(2) t.Extent(3)+200 t.Extent(4)+200],...
%     'name','SPECIFY PORTS for NEURAL DATA','NumberTitle','off');
% 
% 
% 
% % wait for user input
% h = uicontrol('Position',[extent(3)-50 30 80 50],'String','OK',...
%     'Callback','uiresume(gcbf)');
% uiwait(figh)
% inputData = t.Data;
% %close(figh)
% 
% 
% % ColumnFormat',...
% %     {'char','char','numeric','char'},