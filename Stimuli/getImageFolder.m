function ex =getImageFolder(ex)
% function ex =getImageFile(ex)
%
% helper function requesting experimenter to provide image directory
% then reads all png or jpg image filenames in that directory and stores
% them in 
% ex.stim.vals.imageNames
% ex.stim.vals.imageFolder
%
% history
% 08/19/24 hn: wrote i

% get directory of image files
curDir = pwd;
if isfield(ex.stim.vals,'imageFolder') && isdir(ex.stim.vals.imageFolder)
    idir = ex.stim.vals.imageFolder;
else
    idir = pwd;
end
idir = uigetdir(idir,'select directory for image files');
ex.stim.vals.imageFolder = idir; 

% get image names
cd (ex.stim.vals.imageFolder)
ims = dir('*.png'); 
if isempty(ims)
    ims = dir('*.jpg');
end
ims = ims(arrayfun(@(x) ~strcmp(x.name(1),'.'),ims)); % remove hidden files
ex.stim.vals.imageNames = {ims.name};  
cd(curDir)

% default ID = 1
ex.stim.vals.ID = 1;