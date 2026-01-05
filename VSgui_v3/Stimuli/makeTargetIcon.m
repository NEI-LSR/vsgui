function ex=makeTargetIcon(ex)

% distributes make** commands according to the experiment and stimulus

% 07/11/14  hn: -included field 'setup' and moved setup parameters into it
%               new parameter name          old parameter name
%               ex.setup.stereo             ex.stereo
%               ex.setup.window             ex.window
%               ex.setup.overlay            ex.overlay

switch ex.stim.type
    case 'grating'
        ex = makeTargetIconGrating(ex);
    case 'rds'
        ex=makeTargetIconRDS(ex);
end



% if ex.setup.stereo.Display
%     Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
%     Screen('FillRect', ex.setup.window, ex.idx.bg_lum);
%     Screen('FillRect', ex.setup.window, [0] , ex.setup.stereo.b_ROn);
%     Screen('FillRect', ex.setup.window, [0] ,ex.setup.stereo.b_ROff);
% 
%     Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
%     Screen('FillRect', ex.setup.window, ex.idx.bg_lum);
%     Screen('FillRect', ex.setup.window, [1] , ex.setup.stereo.b_LOn);
%     Screen('FillRect', ex.setup.window, [0] ,ex.setup.stereo.b_LOff);
%     Screen('Flip', ex.setup.window);
% else
%     Screen('FillRect', ex.setup.window, ex.idx.bg_lum);
%     Screen('Flip', ex.setup.window);
% end