function ex = probeSettings(ex)
% function ex = probeSettings(ex)
%
% ex = ephys.probeSettings(ex)
%
% here we define the default probe settings for the recording .
%
% These definitions were previously included in 'getDefaultSettings.m' but
% I moved them here for better readability of the code.
% This function is called by 'getDefaultSettings.m'.
% probe parameters are stored in ex.setup.gv.probe.XX

% history
% 08/18/25  hn: wrote it; 
% 01/21/26  hn: moved input for NPP to 'userInput' to be more user friendly
% 02/11/26  hn: moved code to package +ephys

button = questdlg('what probe are we using?' ,'','MBA','NPP','VP', 'VP'); 
ex.setup.(ex.setup.ephys).probe.type = button;

switch button
    
    case 'MBA'
        ex.setup.gv.probe = userInput('MBA');

    case 'NPP'
        hSGL                = ex.setup.sglx.handle;
        ex.setup.sglx.probe = userInput('NPP',hSGL);

        
    otherwise
        promt = {'how many electrodes (probes):'};
        dlg_title = '# electrodes (probes)';
        num_lines = 1;
        def = {'1'};
        answer = inputdlg(promt,dlg_title,num_lines,def);
        if ~isempty(answer)
            num_probes = str2double(answer{1});
        end
        if ~isnumeric(num_probes)
            promt = {'how many electrodes (probes); (integer value) :'};
            dlg_title = '# electrodes (probes)';
            num_lines = 1;
            def = {'1'};
            answer = inputdlg(promt,dlg_title,num_lines,def);
            if ~isempty(answer)
                num_probes = str2double(answer{1});
            end
        end
        if ~isnumeric(num_probes)
            num_probes = 1;
            warndlg('input undefined; setting num_probes to default value 1');
        end
                

        % get grid position
        %%
        for n=1:num_probes
            promt = {'hemisphere (L, R, B(both)):','grid location; enter x-position:','grid location; enter y-position'};
            dlg_title = ['probe #' num2str(num_probes)];
            num_lines = 1;
            def = {'L','100','100'};
            answer = inputdlg(promt,dlg_title,num_lines,def);
            % hn: 05/05=3/18: check whether it works
            if ~isempty(answer)        
                if strcmpi(answer{1},'l')          
                    ex.setup.leftHemisphereRecorded = 1; 
                    ex.setup.rightHemisphereRecorded = 0;
                    ex.setup.Left_Hemisphere_gridX = str2num(answer{2});
                    ex.setup.Left_Hemisphere_gridY = str2num(answer{3}); 
                    ex.setup.gv.probe(n).leftHemisphereRecorded = 1;
                    ex.setup.gv.probe(n).rightHemisphereRecorded = 0;
                    ex.setup.gv.probe(n).gridX = str2num(answer{2});
                    ex.setup.gv.probe(n).gridY = str2num(answer{3});
                elseif strcmpi(answer{1},'r')
                    ex.setup.leftHemisphereRecorded = 0; 
                    ex.setup.rightHemisphereRecorded = 1;
                    ex.setup.Right_Hemisphere_gridX = str2num(answer{2});
                    ex.setup.Right_Hemisphere_gridY = str2num(answer{3});
                    ex.setup.gv.probe(n).leftHemisphereRecorded = 0;
                    ex.setup.gv.probe(n).rightHemisphereRecorded = 1;
                    ex.setup.gv.probe(n).gridX = str2num(answer{2});
                    ex.setup.gv.probe(n).gridY = str2num(answer{3});
                elseif strcmpi(answer{1},'b')
                    ex.setup.leftHemisphereRecorded = 1; 
                    ex.setup.Right_Hemisphere_gridX = [];  
                    ex.setup.Right_Hemisphere_gridY = []; 
                    ex.setup.Left_Hemisphere_gridX = []; 
                    ex.setup.Left_Hemisphere_gridY = [];           
    
                else
                    promt = {'hemisphere undefined; please enter left (L), right (R) or both (B):'};
                    dlg_title = [' probe #' num2str(num_probes)];
                    num_lines = 1;
                    def = {'L'};    
                        answer = inputdlg(promt,dlg_title,num_lines,def);
                    if strcmpi(answer{1},'l')          
                        ex.setup.leftHemisphereRecorded = 1; 
                        ex.setup.rightHemisphereRecorded = 0;
                    elseif strcmpi(answer{1},'r')
                        ex.setup.leftHemisphereRecorded = 0; 
                        ex.setup.rightHemisphereRecorded = 1;
                    elseif strcmpi(answer{1},'b')
                        ex.setup.leftHemisphereRecorded = 1; 
                        ex.setup.rightHemisphereRecorded = 1;
                    else
                        ex.setup.leftHemisphereRecorded = []; 
                        ex.setup.rightHemisphereRecorded = [];
                    end
                end
            end
        end
end
