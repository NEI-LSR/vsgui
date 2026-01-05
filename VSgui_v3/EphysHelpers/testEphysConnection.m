function testEphysConnection(ex)
% was formerly testXippmexConnection
%
% helper script to check the connection between the machine running VisStim
% and the one running trellis, using the xippmex package.
% Error message gives a number of common issues that might cause connection
% problems. (Was previously part of the "getDefaultSettings.m" function)
%
% history
% 08/18/25  hn: wrote it
%
%TODO: generalize for use with SGLX

switch ex.setup.ephys
    case 'sglx'
        hSGL = ex.setup.sglx.handle;
        if IsRunning(hSGL)
            testS = 1;
            begin_idx = GetStreamSampleCount(hSGL,0,0);
            sendStrobe(testS);
            end_idx = GetStreamSampleCount(hSGL,0,0);
            a = getStrobes(ex, begin_idx, end_idx);
            if length(a)~=1 || a(1)~=testS
                disp('%%% faulty digital connection with SGLX');
                disp('%%% if you want to run a recording session check the following:');
                disp('%%% -is the Datapixx output connected to breakout box?');
                disp('%%% -is the connection to port 1, so it doesnt interfere with sync pulse?');
                error('faulty digital connection with SGLX;')
            else
                disp('%%% digital communication with SGLX successful!! %%%');
            end
        else
            disp('%%% faulty communication with SGLX');
            disp('%%% if you want to run a recording session check the following:');
            disp('%%% -is the connection/IP address correct?');
            disp('%%% -is SGLX console open and running acquisition?');
            disp('%%% -are the probe and NIdaq connected/detected?')
            disp('%%% -did the probe pass all the tests?');
            error('faulty communication with SGLX;')
        end
    case 'gv'
        sendStrobe(1);% for debugging
        xippmex('digin');
        getStrobes;
        testS = 1;
        sendStrobe(testS); % sending a test
        pause(.1)
        a = getStrobes;
        if length(a)<1 || a(1)~=testS
            disp('%%% faulty digital connection with grapevine NIP');
            disp('%%% if you want to run a recording session check the following:');
            disp('%%% -is the datapixx (propixx controller) switched on?');
            disp('%%% -did you check the box "Capture input on parallel bit change" in the trellis Digital I/O Options?')
            disp('%%% -is the NIP running?');
            disp('%%% -are all the grapevine digital I/O connectors connected correctly?')
            disp('%%% -is the Nienborg Active Pump Trigger (made by Jonathan Newport for reward) on power?')
            error('faulty digital connection with grapevine NIP;')
        end
    otherwise
        error('no valid ephys system detected;')
end