function [degX,degY] = pixel2degxy(x,y,exSetup)
% translate pixels to degrees for x,y pairs
%
% [degX,degY] = pixel2degxy(x,y,exSetup)
% INPUTS:
% x, vector of x coordinates in pixels
% y, vector of y coordinates in pixels, must be same length as x
% exSetup, input ex.setup from VSGui startup


% CMZ - THIS DOESN'T WORK - complicated to go in the reverse direction, 

% make sure vectors are same length
if ~(length(x)==length(y))
    error('x and y vectors must be the same length')
end

% adjust for screen warping?
geomCorrect = isfield(exSetup,"scal");

% column vectors
x = x(:);
y = y(:);

if geomCorrect
    % Do conversion for displays that needed geometry correction through screen warping, eg the dome

    % Find index of desired position within predefined pixel grid aligned with DVA
    [~,xInd]    = min(abs(exSetup.scal.XGRID_PIXELS(end/2,:)-x),[],2);
    [~,yInd]    = min(abs(exSetup.scal.YGRID_PIXELS(:,end/2)'-y),[],2); 

    % Take corresponding degree values of the indices
    degXTmp  = exSetup.scal.XGRID_DVA(yInd,xInd)';
    degYTmp  = exSetup.scal.YGRID_DVA(yInd,xInd);

    degX     = diag(degXTmp);
    degY     = diag(degYTmp);

else
    % Do conversion everywhere else using pixels per degree value

    widthInScreenX  = exSetup.viewingDistance * tand(x);
    widthInScreenY  = exSetup.viewingDistance * tand(y);

    pixelX          = widthInScreenX/exSetup.monitorWidth * exSetup.screenRect(3);
    pixelY          = widthInScreenY/exSetup.monitorWidth * exSetup.screenRect(3);
end

return