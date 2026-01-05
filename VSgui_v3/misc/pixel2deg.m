function theta = pixel2deg(pixels,exSetup)
% function theta = pixel2deg(pixels,exSetup)

widthInScreen = pixels/exSetup.screenRect(3) * exSetup.monitorWidth;
theta = atand(widthInScreen/exSetup.viewingDistance);

return