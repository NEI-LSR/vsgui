function pixels = deg2pixel(theta,exSetup)

widthInScreen = exSetup.viewingDistance * tand(theta);
pixels = widthInScreen/exSetup.monitorWidth * exSetup.screenRect(3);

return

