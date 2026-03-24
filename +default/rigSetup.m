function ex = rigSetup(ex,type)
% function ex = rigSetup(ex)
%
% +default.rigSetup
%
% here we define the default Rig parameters when VS is started.
%
% These definitions were previously included in 'getDefaultSettings.m' but
% I moved them here for better readability of the code.
% This function is called by 'default.getSettings.m'.
% Parameters are stored in ex.setup.XX

% history
% 08/18/25  hn: wrote it; 
% 02/11/26  hn: moved to package +default

% double check that we have the name of the system
if ~isfield(ex,'setup') || ...
        ~isfield(ex.setup,'computerName')|| isempty(ex.setup.computerName)
    ex.setup.computerName = getComputerName;
end

switch ex.setup.computerName
    case 'hn-stim-1'
        ex = neiRigB(ex,type);
    case 'lab-ms-98h9'
        ex = nimhB1A19Dome(ex,type);
    case 'klab-mouse-3'
        ex = neiRigA(ex,type);
    case 'vpixx'
        ex = neiRigC(ex,type);
    otherwise
        ex = unknownRig(ex,type);
end
        