function ex=playStimulus(ex,stim,stimOnDur)
% 11/06/24  ik: added 'orNoise'

switch ex.stim.type
    case 'blank'
        return 
    case 'grating'
        if ex.stim.vals.RC
            ex = playGratingRC(ex,stimOnDur);
        else
            ex = playGrating(ex,stimOnDur);
        end
    case 'rds'

        ex=playRDS(ex,stim);
    case 'bar'
        ex=playBar(ex);
        
    case 'dot'
        ex = playDot(ex);
        
    case 'fullfield'
        ex = playFullField(ex);
        
    case ('image')
        ex = playImage(ex);
        
    case 'orNoise'
        ex = playORnoise(ex);
    case 'gabor'
        ex = playStimulus_gabor(ex, relTime);
end
