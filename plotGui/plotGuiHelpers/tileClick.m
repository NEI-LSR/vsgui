
function tileClick(src, evt, M, P, nRows, nCols, Nvalid,block, svals, svals2,tstr)
% function tileClick(src, evt, M, P, nRows, nCols, Nvalid,block, svals, svals2,tstr)
% 
% callback function for clicking on individual tiles of 
% 2D population tuning curve. 
%
%
% history
% 02/09/26  hn: wrote it

ax = ancestor(src,'axes');

% click location in data coordinates
pt = ax.CurrentPoint;
x = pt(1,1);
y = pt(1,2);

% convert to pixel indices (1-based)
colPix = floor(x) + 1;
rowPix = floor(y) + 1;

% bounds check
H = nRows*M;
W = nCols*P;
if rowPix < 1 || rowPix > H || colPix < 1 || colPix > W
    return;
end

% tile indices (1..nRows, 1..nCols)
tileR = ceil(rowPix / M);
tileC = ceil(colPix / P);

% linear tile index in your fill order (row-major like your loops)
cnt = (tileR-1)*nCols + tileC;

% ignore padded NaN tiles beyond your real slices
if cnt > Nvalid  
    return;
end

% now plot figure for individual channel
figure;
imagesc(squeeze(block(cnt,:,:))');

% figure formatting
set(gca,'box','off','xtick',[1:M],'xticklabel',svals,...
    'ytick',[1:P],'yticklabel',svals2);
xlabel(tstr{1});
ylabel(tstr{2});
title(sprintf('channel %d', cnt))