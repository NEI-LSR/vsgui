function ex=makeImage(ex)
% function ex=makeImage(ex)
% creates the image textures of pregenerated images in a designated folder
%
% ex.stim.vals.imageFolder = 'designatedImageFolder'
% 
% history 
% 08/14/24  hn: written  
% 03/10/25  hn: bug fix (call getImageFolder instead of getImageFiles);
% 03/06/26  hn: crop image to screensize if they exceed it

% we only need to make the textures before the first trial
if ex.j>1
    return
end

% we query for the image directory and get the image names in
% "getExptSettings.m" to get:
% ex.stim.vals.imageFolder
% ex.stim.vals.imageNames

if ~isfield(ex.stim.vals,'imageFolder') || ~isfolder(ex.stim.vals.imageFolder)
    ex = getImageFolder(ex);
end

% make texture for each image
for n = 1:length(ex.stim.vals.imageNames)
    myim=im2gray(imread(fullfile(ex.stim.vals.imageFolder, ex.stim.vals.imageNames{n})));
    if size(myim,1)>size(myim,2)
        myim = myim';
    end
    % crop image to screensize
    if size(myim,1) > ex.setup.screenRect(3) % compare W
        margW = ceil((size(myim,1)-ex.setup.screenRect(3))/2);
        myim = myim(margW+1:end-margW,:);
    end
    if size(myim,2) > ex.setup.screenRect(4)
        margH = ceil((size(myim,2)-ex.setup.screenRect(4))/2);
        myim = myim(:,margH+1:end-margH);
    end
    imtex = Screen('MakeTexture',ex.setup.window,myim);
    ex.stim.vals.imSize(n,:) = size(myim); %WxH in pixels
    ex.stim.vals.imCntrRect(n,:) = CenterRect(Screen('Rect',imtex),ex.setup.screenRect);
    ex.stim.vals.imtex(n) = imtex;
 end

% degrees per pixes
dpp = atan(ex.setup.monitorWidth/2/ex.setup.viewingDistance)*180/pi/(ex.setup.screenRect(3)/2);  
ppd = 1/dpp; 
ex.stim.vals.ppd = ppd;
%ex.stim.vals.framecnt   = 1; (only needed for RC experiments)
        
% MAKE BLANK TEXTURE ----------------------------------------------------
% this should extend exactly over the first image texture area
% open texture only if not yet available
% obsolete- we just play a blank screen instead
% x = max(max(ex.stim.vals.imSize(1,:)));
% if ~isfield(ex.stim.vals,'blanktex') || isempty(ex.stim.vals.blanktex)
%     blank = round((ex.idx.white+e.idx.black)/2)+ zeros(size(x));
%     ex.stim.vals.blanktex = Screen('MakeTexture',ex.setup.window,blank);
% end
