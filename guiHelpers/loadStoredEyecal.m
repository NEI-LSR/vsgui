function loadStoredEyecal(fig_h,handles,file)
% function loadStoredEyecal(fig_h,handles,file)
% loads the stored eye calibration
% 

global ex


newF = load(file,'-mat');

ex.eyeCal = newF.eyeCal;
