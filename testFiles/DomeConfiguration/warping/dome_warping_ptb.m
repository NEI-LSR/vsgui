% generae stimuli in psychtoolbox
sca;
close all;
clear;
%% setup camera, stimulus resolution
w=1920;h=1080;
highres=1;
if highres==1
    domecx=986;domecy=324; %center of dome, image extends to bottom of frame
    camsize=[3840,2160];
    %camsize= [1920x1080];
    %Resolution='1920x1080';
    Resolution='3840x2160';
else
    camsize=[640 480];
    Resolution='640x480';
    domecx=338;domecy=203;
end
%%
% make a polar plot 
% dome radius is 38 inch = 60 (quarter circumference)*4 / (3.1415*2)
% 10 inch = 10/(2*pi*38)*360= 15.1 degree
% polar plot with 15 degree rings
% this version of the code is for unwarping using geodesic distances
% measured on screen
% cardinal directions and lower diagonal have been marked
figure(101);clf;
set(gcf, 'Position', get(0, 'Screensize'));
subplot(2,3,1);
im=imread('dome_calibration.bmp');
im=imresize(im,[h w],'bilinear');
imshow(im);
% store points along circles 
% use these to find intersection wtih lines
% points along circle.
cpoints=[];np=1;
% 90 degrees is covered
for theta=10:10:90 % steps in radial direction
    y=abs(h/2*sind(theta)); % projection flat plane
    hold on;
    [xunits,yunits]=mycircle(w/2,h/2,y);
    cpoints(np).cx=xunits;
    cpoints(np).cy=yunits;
    cpoints(np).theta=theta;
    cpoints(np).r=y;
    np=np+1;
    %text(w/2,h/2+y,sprintf('%d',theta),'Color','k','FontSize',20);
    %text(w/2+y,h/2,sprintf('%d',theta),'Color','k','FontSize',20);
end
xlim([1 w]);ylim([1 h]);
axis off
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
%% sweep across 0-180
lpoints=[];
np=1;
for theta=0:45:180
    x=(0:h/2)*cosd(theta)+w/2;
    y=(0:h/2)*sind(theta)+h/2;
    hold on;
    plot(x,y);
    lpoints(np).x=x;
    lpoints(np).y=y;
    lpoints(np).theta=theta;
    np=np+1;
end


% now we have the points along every circle and line.
% we can find interection of every line with each circle
for l=1:length(lpoints)
    lpoints(l).int=[];
    for c=1:length(cpoints)
        % every circle intersects line at two points
        lpoints(l).int(c,1).x=w/2+cpoints(c).r*cosd(lpoints(l).theta);
        lpoints(l).int(c,1).y=h/2+cpoints(c).r*sind(lpoints(l).theta);
        lpoints(l).int(c,2).x=w/2+cpoints(c).r*cosd(180+lpoints(l).theta);
        lpoints(l).int(c,2).y=h/2+cpoints(c).r*sind(180+lpoints(l).theta);
        hold on;
        plot(lpoints(l).int(c,1).x,lpoints(l).int(c,1).y,'.g','MarkerSize',10);
        plot(lpoints(l).int(c,2).x,lpoints(l).int(c,2).y,'.g','MarkerSize',10);
    end
end
% the rings are how a polar plot should look like with coaxial projection
% saveas(gcf,'mypolar.bmp','bmp');
%% Here we call some default settings for setting up Psychtoolbox
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
black = BlackIndex(screenNumber);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
cam=webcam('/dev/video0');
%cam.Resolution='4096x2160';
cam.Resolution='3840x2160';
% show pure red, green, blue to identify visible dome area
% save these as reference images. These dome locations can be avoided when
% calculting mapping
Screen('FillRect',window,[1 0 0],windowRect);
Screen('Flip',window);
img=snapshot(cam);
refimgname=sprintf('./refpts/dome_ref_red.bmp');
imwrite(img,refimgname,'bmp');
pause(1);
Screen('FillRect',window,[0 0 0],windowRect);
Screen('Flip',window);
pause(1);
img=snapshot(cam);
refimgname=sprintf('./refpts/dome_ref_black.bmp');
imwrite(img,refimgname,'bmp');clear('cam');
sca;
clear('cam');
%% now show reference locations where lines in 45 degree steps intersect with
% circles of 10 dva . Capture images from webcam and extract location in webcam coordinates
%% Here we call some default settings for setting up Psychtoolbox
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
black = BlackIndex(screenNumber);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
cam=webcam('/dev/video0');
cam.Resolution=Resolution;
mkdir('./refpts');
% display cumulative image of dome
cumimg=uint8(zeros(camsize(2),camsize(1)));
% every polar line intersects evey radial line at two locations
for l=1:length(lpoints)
    for c=1:length(cpoints)
        for ipoint=1:2
            % draw one dot
            % psychtoolbox y goes from top to bottom, matlab graphing is
            % bottom to top
            xy=[lpoints(l).int(c,ipoint).x,lpoints(l).int(c,ipoint).y];
            draw_dot_white(window,windowRect,xy);
            % capture many images and average
            nimgs=1;
            img=zeros(camsize(2),camsize(1),3,nimgs);
            for i=1:nimgs
                img(:,:,:,i)=snapshot(cam);
                pause(0.05);
            end
            img=uint8(squeeze(mean(img,4)));
            %img=rgb2gray(img);
            % remove dot
            draw_dot_black(window,windowRect,xy);
            bgimg=zeros(camsize(2),camsize(1),3,nimgs);
            for i=1:nimgs 
                bgimg(:,:,:,i)=snapshot(cam);
                pause(0.05);
            end
            bgimg=uint8(squeeze(mean(bgimg,4)));
            img=rgb2gray(img-bgimg);

            img=img*(255/max(img(:)));
            [~,idx]=max(img(:));
            [row,col]=ind2sub(size(img),idx);
            % record new point
            cumimg=(cumimg+img)/2;
            subplot(2,3,2);
            imshow(cumimg);
            hold on;
            plot(col,row,'r*');

            %refimgname=sprintf('./refpts/refpt_%d_%d_%d.bmp',l,c,ipoint);
            fprintf('line %d/%d circle %d/%d p %d row %d col %d\n',lpoints(l).theta,lpoints(end).theta,...
                cpoints(c).theta,cpoints(end).theta,ipoint,row,col);
            %imwrite(img,refimgname,'bmp');
            lpoints(l).int(c,ipoint).xdome=col; %coordinate of center of projected dot in camera image
            lpoints(l).int(c,ipoint).ydome=row;
        end
    end
end
sca;
save('bijection_10r_45p.mat','lpoints','cpoints');
% store image of dome
img=snapshot(cam);
refimgname=sprintf('./refpts/dome_ref.bmp');
imwrite(img,refimgname,'bmp');
clear('cam');
%%
subplot(2,3,3);
im=imread('./refpts/dome_ref_red.bmp');
surf_mask=im(:,:,1)>150;
imshow(zeros(size(im)));
% draw the original and dome locations 
for l=1:length(lpoints)
    for c=1:length(cpoints)
        for ipoint=1:2
            xs=lpoints(l).int(c,ipoint).x;
            ys=lpoints(l).int(c,ipoint).y;
            xd=lpoints(l).int(c,ipoint).xdome;
            yd=lpoints(l).int(c,ipoint).ydome;
            % skip points that aren't in valid parts of camera image
            %if surf_mask(yd,xd)==1 %&& surf_mask(floor(ys),floor(xs))==1
                hold on;
                plot(xs,ys,'.g');
                plot(xd,yd,'.r');
                %line([xs xd],[ys yd],'color','k');
            %end
        end
    end
end
%%
subplot(2,3,4);
imshow(imread('./refpts/dome_ref.bmp'));
%show reference and projected points on dome image
% rescale reference points by the per
% 
% lpendicular from dome center to bottom
% lip.
% recenter image to domecx
% with shift
% overlay on dome image
refpts=[];domepts=[];
for l=1:length(lpoints)
    for c=1:length(cpoints)
        for ipoint=1:2
            xd=lpoints(l).int(c,ipoint).xdome;
            yd=lpoints(l).int(c,ipoint).ydome;
            hold on;
            plot(xd,yd,'.r');
            % get reference points, rescale and recenter.
            xs=lpoints(l).int(c,ipoint).x;
            ys=lpoints(l).int(c,ipoint).y;
            xs=xs-w/2;
            ys=ys-h/2;
            xs=xs*(camsize(2)-domecy)/(h/2);
            ys=ys*(camsize(2)-domecy)/(h/2);
            xs=xs+domecx;
            ys=ys+domecy;
            hold on;
            plot(xs,ys,'.g');
            line([xs xd],[ys yd],'color','g');
            title('green-desired, red-projected, yellow=ref->dome');
            refpts=[refpts;[xs ys]];
            domepts=[domepts;[xd yd]];
        end
    end
end
% learn linear mapping from reference to dome
mdlr = fitlm(refpts,domepts(:,1),'RobustOpts','on');
%wts=mdlr.Coefficients.Estimate;
%xpred=ones(size(refpts,1),1)*wts(1)+refpts(:,1).*refpts(:,2)*wts(2)+refpts(:,1).^2*wts(3)+...
%    refpts(:,2).^2*wts(4);
xpred = predict(mdlr,refpts);
mdlr = fitlm(refpts,domepts(:,2),'RobustOpts','on');
%wts=mdlr.Coefficients.Estimate;
%ypred=ones(size(refpts,1),1)*wts(1)+refpts(:,1).*refpts(:,2)*wts(2)+refpts(:,1).^2*wts(3)+...
%    refpts(:,2).^2*wts(4);
ypred = predict(mdlr,refpts);

hold on;
plot(xpred(:),ypred(:),'.y');

% %%
% Screen('Preference', 'SkipSyncTests', 1);
% PsychDefaultSetup(2);
% screens = Screen('Screens');
% screenNumber = max(screens);
% black = BlackIndex(screenNumber);
% [window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
% [screenXpixels, screenYpixels] = Screen('WindowSize', window);
% img = imread('polar_angle_plot_3840_2160.bmp'); 
% Texture = Screen('MakeTexture', window, img);
% rect = windowRect;
% Screen('DrawTexture', window, Texture, [], rect);
% Screen('Flip', window);
% pause();
% sca;
%%
% project image on dome back into stimulus space
subplot(2,3,4);
load('bijection_10r_45p.mat')
% rescale reference points by the perpendicular from dome center to bottom
% lip.
% recenter image to domecx
% with shift
% overlay on dome image
refpts=[];domepts=[];
for l=1:length(lpoints)
    for c=1:length(cpoints)
        for ipoint=1:2
            xd=lpoints(l).int(c,ipoint).xdome;
            yd=lpoints(l).int(c,ipoint).ydome;
            xd=xd-domecx;
            yd=yd-domecy;
            xd=xd*(h/2)/(camsize(2)-domecy);
            yd=yd*(h/2)/(camsize(2)-domecy);
            xd=xd+w/2;
            yd=yd+h/2;
            % get reference points, rescale and recenter.
            xs=lpoints(l).int(c,ipoint).x;
            ys=lpoints(l).int(c,ipoint).y;
            %line([xs xd],[ys yd],'color','g');
            refpts=[refpts;[xs ys]];
            domepts=[domepts;[xd yd]];
        end
    end
end

dome2ref=1;
if dome2ref==1
    % learn linear mapping from dome to refernce, both in stimulus space
    % then use this to shift pixels in reference image.
    mdlrx=fitlm(domepts,refpts(:,1),'poly22','RobustOpts','on');
    xpred=predict(mdlrx,domepts);
    mdlry=fitlm(domepts,refpts(:,2),'poly22','RobustOpts','on');
    ypred=predict(mdlry,domepts);
else
    % learn linear mapping from refernce to dome, both in stimulus space
    % then use this to shift pixels in reference image.
    mdlrx=fitlm(refpts,domepts(:,1),'poly22','RobustOpts','on');
    xpred=predict(mdlrx,domepts);
    mdlry=fitlm(refpts,domepts(:,2),'poly22','RobustOpts','on');
    ypred=predict(mdlry,domepts);
end
subplot(2,3,5);
im=imread('dome_calibration.bmp');
im=imresize(im,[h w],'bilinear');
imshow(im);
hold on;
plot(domepts(:,1),domepts(:,2),'r.');
plot(refpts(:,1),refpts(:,2),'g.');
plot(xpred(:),ypred(:),'.y');
title('green-desired, red-projected','magenta=dome->ref');
%% now move pixels around in original image and display prewarped image
warpim=uint8(zeros(size(im)));
for y=[-250:5:250]+size(im,1)/2
    for x=[-250:5:250]+size(im,2)/2
        xpixel=x;
        ypixel=y;
        % use dome->ref mapping to estimate where the pixel should be
        % shifted to
        xpred=predict(mdlrx,[xpixel ypixel]);
        ypred=predict(mdlry,[xpixel ypixel]);
        xpred=uint16(xpred);
        ypred=uint16(ypred);
        if xpred>1 && xpred<size(im,2) && ypred<size(im,1) && ypred>1
            warpim(ypred,xpred,:)=im(y,x,:);
            %fprintf('%d %d -> %d %d (%d,%d,%d)\n',x,y, xpred,ypred,im(y,x,1),im(y,x,2),im(y,x,3));
        end
    end
    fprintf('row %d\n',y-size(im,1)/2);
end
subplot(2,3,6);
imshow(warpim);
imwrite(warpim,'dome_calibration_warped.bmp');
% %% using custom transformation
% % inverse mapping function
% f = @(x) [];
% g = @(x, unused) f(x);
% 
% % maketform arguments
% ndims_in = 2;
% ndims_out = 2;
% forward_mapping = [];
% inverse_mapping = f;
% tdata = [];
% tform = maketform('custom', ndims_in, ndims_out, ...
%     forward_mapping, inverse_mapping, tdata);
% 
% body = imread('liftingbody.png');
% body2 = imtransform(body, tform); 

%% now show warped image
% Here we call some default settings for setting up Psychtoolbox
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
black = BlackIndex(screenNumber);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
%imageTexture = Screen('MakeTexture', window,  imresize(warpim,[size(im,1) size(im,2)*14/11],'bilinear'));
imageTexture = Screen('MakeTexture', window,  imresize(warpim,[size(im,1) size(im,2)],'bilinear'));
Screen('DrawTexture', window,imageTexture, [], [], 0);
Screen('Flip', window);
pause();
sca;

% now actually show the intended pattern on dome 
function draw_dot_white(window,windowRect,xy)
    % Get the size of the on screen window in pixels.
    % For help see: Screen WindowSize?
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);
    
    % Enable alpha blending for anti-aliasing
    % For help see: Screen BlendFunction?
    % Also see: Chapter 6 of the OpenGL programming guide
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    % Set the color of our dot to full red. Color is defined by red green
    % and blue components (RGB). So we have three numbers which
    % define our RGB values. The maximum number for each is 1 and the minimum
    % 0. So, "full red" is [1 0 0]. "Full green" [0 1 0] and "full blue" [0 0
    % 1]. Play around with these numbers and see the result.
    dotColor = [1 1 1];
    
    % Dot size in pixels
    dotSizePix = 10;
    
    %xy=xy-repmat([screenXpixels screenYpixels]/2,size(xy,1),1)
    xy=xy';

    % Draw the dot to the screen. For information on the command used in
    % this line type "Screen DrawDots?" at the command line (without the
    % brackets) and press enter. Here we used good antialiasing to get nice
    % smooth edges
    Screen('DrawDots', window,xy , dotSizePix, dotColor, [], 2);
    
    % Flip to the screen. This command basically draws all of our previous
    % commands onto the screen. See later demos in the animation section on more
    % timing details. And how to demos in this section on how to draw multiple
    % rects at once.
    % For help see: Screen Flip?
    Screen('Flip', window);
end
function draw_dot_black(window,windowRect,xy)
    % Get the size of the on screen window in pixels.
    % For help see: Screen WindowSize?
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);
    
    % Enable alpha blending for anti-aliasing
    % For help see: Screen BlendFunction?
    % Also see: Chapter 6 of the OpenGL programming guide
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    % Set the color of our dot to full red. Color is defined by red green
    % and blue components (RGB). So we have three numbers which
    % define our RGB values. The maximum number for each is 1 and the minimum
    % 0. So, "full red" is [1 0 0]. "Full green" [0 1 0] and "full blue" [0 0
    % 1]. Play around with these numbers and see the result.
    dotColor = [0 0 0];
    
    % Dot size in pixels
    dotSizePix = 20;
    
    %xy=xy-repmat([screenXpixels screenYpixels]/2,size(xy,1),1)
    xy=xy';

    % Draw the dot to the screen. For information on the command used in
    % this line type "Screen DrawDots?" at the command line (without the
    % brackets) and press enter. Here we used good antialiasing to get nice
    % smooth edges
    Screen('DrawDots', window,xy , dotSizePix, dotColor, [], 2);
    
    % Flip to the screen. This command basically draws all of our previous
    % commands onto the screen. See later demos in the animation section on more
    % timing details. And how to demos in this section on how to draw multiple
    % rects at once.
    % For help see: Screen Flip?
    Screen('Flip', window);
end

% draw a circle at x,y or radius r and return points along circle
function [xunit,yunit] = mycircle(x,y,r)
    th = 0:pi/50:2*pi;
    xunit = r * cos(th) + x;
    yunit = r * sin(th) + y;
    plot(xunit, yunit,'Color','k','LineWidth',1);
end