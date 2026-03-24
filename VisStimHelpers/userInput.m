function outpt = userInput(type,hSGL)

% function outpt = userInput(type)
%
% helper function to request and format user input
% input:
%   ex      ex-structure
%   type    input type (currently only 'MBA', input on the ports that 
%           were recorded)
%
% history
% 01/24/25  hn: wrote it
% 08/18/25  hn: simplified to not require ex as input and allow for 
%           more general purpose use
% 01/21/26  hn: added input for NPP
% 01/26/26  hn: added gridX and gridY for NPP
outpt.type = type;

switch type
    case 'MBA'
        
        %% available ports
        prts = [{'A1'},{'A2'},{'A3'},{'A4'},{'B1'},{'B2'},{'B3'},{'B4'},...
            {'C1'},{'C2'},{'C3'},{'C4'}, {'D1'},{'D2'},{'D3'},{'D4'}];
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
           defaults{n,4} = 1; 
           defaults{n,5} = '';
        end
        colNames{1} = 'recorded area'; colNames{2} = 'hemisphere (L or R)'; 
        colNames{3} = '#channels'; colNames{4} = 'bank ID';
        colNames{5} = 'bank descriptor';
        prompt = 'SPECIFY PORTS for NEURAL DATA';
        
        inputData = flexInputdlg(prompt,defaults,rowNames,colNames);
        
        % format the user input for use in ex-structure: ex.setup.gv.port
        for n = 1:size(inputData,1)
            outpt(n).Name = prts{selection(n)}; 
            outpt(n).Area = inputData{n,1}; 
            outpt(n).Hemisphere = inputData{n,2};  
            outpt(n).numChannels = inputData{n,3}; 
            outpt(n).bankID = inputData{n,4};
        end
        
    case 'NPP'
        if nargin<2
            error('sglx handle required as input')
        end        
        %% number of probes 
        prbs = [{'1'},{'2'},{'3'},{'4'},{'5'},{'6'},{'7'},{'8'}];
        [selection,ok] = listdlg('PromptString','# of probes?',...
            'SelectionMode','single','ListSize',[160 200],...
            'ListString',prbs);
        
        % format for uitable
        defaults = cell(length(selection),4);
        rowNames = cell(1,length(selection));
        for n = 1:length(selection)
           rowNames{n} = ['probe ' prbs{selection(n)}];
           defaults{n,1} = ''; 
           defaults{n,2} = 'L'; 
           defaults{n,3} = NaN;
           defaults{n,4} = NaN;
           defaults{n,5} = 1; 
           defaults{n,6} = ''; 
        end
        colNames{1} = 'Recorded Area  '; 
        colNames{2} = ' Hemisphere (L/R) '; 
        colNames{3} = ' GridX ';
        colNames{4} = ' GridY ';
        colNames{5} = ' Motor ID (e.g.NAN tower) '; 
        colNames{6} = '          Comment         ';
        prompt = 'Specify Probe(s)';
        
        inputData = flexInputdlg(prompt,defaults,rowNames,colNames);
        
        % format the user input for use in ex-structure:
        % ex.setup.sglx.probe
        for n = 1:size(inputData,1)
            outpt(n).Area = inputData{n,1}; 
            outpt(n).Hemisphere = inputData{n,2};  
            outpt(n).gridX   = inputData{n,3};
            outpt(n).gridY   = inputData{n,4};
            outpt(n).motorID = inputData{n,5};
            outpt(n).comment = inputData{n,6};
            
            % also get probe information from SGLX
            outpt(n).map = GetGeomMap( hSGL, n-1 );
            outpt(n).savedChannels = GetStreamSaveChans( hSGL, 2, n-1 );
            outpt(n).serial = GetStreamSN(hSGL, 2, n-1);
            
        end
        
end

