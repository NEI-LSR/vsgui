function stopRecording(ephys,esetup)

% function stopRecording(ephys,hSGL)
% 
% +ephys.stopRecording 
% put EPHYS in standby
%
% 02/10/2026    hn: moved it from runExpt

switch ephys
    case 'sglx'            
        SetRecordingEnable(esetup.handle, 0);
    case 'gv'
        try % for backwards compatibility: Trellis version < 1.8; i.e. xippmex version <1.2.1.294
            oper = xippmex('opers');
            status = xippmex('trial',oper);
            if strcmpi(status.status,'recording')
                xippmex('trial',oper,'stopped',[],[],[1,[]]);
            end
        catch
            status = xippmex('trial');
            if strcmpi(status.status,'recording')
                xippmex('trial','stopped',[],[],[1,[]]);
            end
        end
end
