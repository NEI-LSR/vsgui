function [pixelX,pixelY] = deg2pixelxy(x,y,exSetup)
% translate degrees to pixels for x,y pairs
%
% [pixelX,pixelY] = deg2pixelxy(x,y,exSetup)
% INPUTS:
% x, vector of x coordinates in degrees
% y, vector of y coordinates in degrees, must be same length as x
% exSetup, input ex.setup from VSGui startup

% 11/19/2024    cmz
% 11/02/2025    cmz: modified to work correctly with vector inputs

% make sure vectors are same length
if ~(length(x)==length(y))
    error('x and y vectors must be the same length')
end

% adjust for dome warping?
geomCorrect = isfield(exSetup,"scal");

% column vectors
x = x(:);
y = y(:);

if geomCorrect
    % Do conversion in the dome in B1 A19 using lookup table in scal

    % Find index of desired position within predefined DVA grid
    [~,xInd]    = min(abs(exSetup.scal.XGRID_DVA(1,:)-x),[],2);
    [~,yInd]    = min(abs(exSetup.scal.YGRID_DVA(:,1)'-y),[],2);

    % Take corresponding pixel values of the indices
    pixelXTmp  = exSetup.scal.XGRID_PIXELS(yInd,xInd)';
    pixelYTmp  = exSetup.scal.YGRID_PIXELS(yInd,xInd);

    pixelX      = diag(pixelXTmp);
    pixelY      = diag(pixelYTmp);

else
    % Do conversion everywhere else using pixels per degree value

    widthInScreenX  = exSetup.viewingDistance * tand(x);
    widthInScreenY  = exSetup.viewingDistance * tand(y);

    pixelX          = widthInScreenX/exSetup.monitorWidth * exSetup.screenRect(3);
    pixelY          = widthInScreenY/exSetup.monitorWidth * exSetup.screenRect(3);
end

return