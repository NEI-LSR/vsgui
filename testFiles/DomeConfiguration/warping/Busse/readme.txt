There should be two files in this folder:

DisplayUndistortionBVL.m
manual_calibrate.m

DisplayUndistortionBVL.m is the main file for the function and has to replace the original file in this folder:

~/toolbox/Psychtoolbox/PsychGLImageProcessing/

manual_calibrate.m has to be relaced here:

~/toolbox/Psychtoolbox/PsychGLImageProcessing/private/

The undistortion routine is called like that:

[scal] = DisplayUndistortionBVL(caliboutfilename, screenid, shape, xnum, ynum, referenceImage, stereomode)

If a shape is given and if it is defined as 'circle', the function will create a radial grid pattern. In every other case the square pattern will be produced.

For the radial grid xnum and ynum are irrelevant, since there will be nine circles (and one with radius 0 in the middle), each made of 12 dots. The diameters are not yet adjusted to the actual size of the dome. But when they are, they should be placed 10˚ visual angle from the mouse position apart on the dome.

To prepare a new calibration file the script usually calls [scal] = createnewcalibrationgrid(scal) and then NewCalibFile.m which would, in case of the radial grid, overwrite most parameters.
Therefore the important code is added into DisplayUndistortionBVL.m from l.388 on.

This part of the code (from NewCalibFile.m) gives wrong values for xcm and ycm, since it produces a square grid again and fills the space between the circles with dots:

            [txcm, tycm] = meshgrid([scal.XVALUES],[scal.YVALUES]);
            scal.xcm = reshape(txcm,numel(txcm),1);
            scal.ycm = reshape(tycm,numel(tycm),1);

But it still works, since xcm and ycm are not used for the file.

In manual_calibrate.m the only thing that is changed is the color of the dots. At the moment it probably just works for the radial grid and not for the squared.

