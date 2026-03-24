function ex = makeORnoise(ex)


%% full-field background texture section
% creates a full-field orientation-filtered white noise texture image

% generate white noise sized at xDeg, yDeg. When resized to pixels,
% this will result in noise at 0.5 cpd.
noiseDeg = rand(round(pixel2deg(ex.setup.screenRect([4,3]),ex.setup)));
noisePix = imresize(noiseDeg, ex.setup.screenRect([4,3])); %resize noise to the screen resolution
orientationCenter = ex.stim.vals.or + 90; 
orientationRange = 10;

%OrientationBandpass is a psychtoolbox function: http://psychtoolbox.org/docs/OrientationBandpass
orFilter = OrientationBandpass(size(noisePix), ...
    orientationCenter - orientationRange, ...
    orientationCenter + orientationRange);
ft = orFilter.*fftshift(fft2(noisePix)); 
backgroundImage = real(ifft2(ifftshift(ft)));
%re-normalize to range from 0 to 1
backgroundImage = (backgroundImage - min(min(backgroundImage)))./...
    (max(max(backgroundImage)) - min(min(backgroundImage)));
backgroundTexture = Screen('MakeTexture', ex.setup.window, ...
    backgroundImage, [], [], 2); % also a psychtoolbox command 


%% patch (to be displayed within receptive field) section
if ex.Trials(ex.j).bvo
    % creates a smaller orientation-filtered white noise texture image with a
    % raised cosine-filtered transparency mask
    %ppd = deg2pixel(1,ex.setup);
    squareSize = ceil(ex.stim.vals.sz * 1.5); %in degrees. 1.5 times the preferred stimulus size = 6 degrees.
    noiseDeg = rand(squareSize, squareSize);
    noisePix = imresize(noiseDeg, [1,1] * round(deg2pixel(squareSize,ex.setup))); %resize noise to the screen resolution
    orientationCenter = ex.stim.vals.or;
    orientationRange = 10;
    orFilter = OrientationBandpass(size(noisePix), ...
        orientationCenter - orientationRange,...
        orientationCenter + orientationRange);
    ft = orFilter.*fftshift(fft2(noisePix));
    objectImage = real(ifft2(ifftshift(ft)));
    
    %re-normalize image to scale from 0 to 1
    objectImage = (objectImage - min(min(objectImage)))./...
        (max(max(objectImage)) - min(min(objectImage)));
    
    mask = createCosineMask(ex, squareSize, size(objectImage,1));
    
    imgTexture = objectImage;
    imgTexture(:, :, end+1) = mask;
    objectTexture = Screen('MakeTexture', ex.setup.window, imgTexture, [], [], 2);
    objectSize = size(imgTexture,1);
else
    objectSize = 0;
    objectTexture = [];
end

ex.stim.vals.figureTexture = objectTexture;
ex.stim.vals.figureSize = objectSize;
ex.stim.vals.groundTexture = backgroundTexture;

end


function mask = createCosineMask(ex, squareSizeDeg, maskSize)

tukeyWindowWidthDeg = 1;
tukeyWindowWidth = round(deg2pixel(tukeyWindowWidthDeg,ex.setup));
alpha = 1;
tukey1 = tukeywin(tukeyWindowWidth*2, alpha); 
tukey1 = tukey1(tukeyWindowWidth+1:end);
lenTukey = length(tukey1);


% these are all in pixel unit
%maskSize = round(deg2pixel(squareSizeDeg,ex.setup));
%maskSize = round(deg2pix * squareSizeDeg);
%create mask 
mask = zeros(maskSize);

[xDeg,yDeg] = meshgrid(linspace(-1*squareSizeDeg/2, squareSizeDeg/2, maskSize));

rDeg = sqrt(xDeg.^2+yDeg.^2) - ex.stim.vals.sz/2;

mask(rDeg <= 0) = 1;

idx = rDeg > 0 & rDeg < 1;  
d = rDeg(idx);
tukeyIndex = floor(d*lenTukey) + 1;
mask(idx) = tukey1(tukeyIndex);

end