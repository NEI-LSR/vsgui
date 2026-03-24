

%% stimulus matrix
colCells = {};
tstr = {};                              % text label of experiment names
% Optional blank column 
if ex.exp.include_blank
    colCells{end+1} = [vtr.st]';         % nTrials x 1
    tstr{end+1} = 'blank';
    xtckStart = 3;
end

% Up to 5 parallel experiments
for k = 1:5
    fn = sprintf('e%d', k)
    if isfield(ex.exp, fn)
        typ = ex.exp.(fn).type;          % field name in vtr
        colCells{end+1} = [vtr.(typ)]';  % nTrials x 1
        tstr{end+1} = ['  exp: ' typ];   % experiment labels.
    end
end
%%
[~, vtr] = voltage2Spikes(ex);
S = cell2mat(colCells);                  % nTrials x nCols
nCols = size(S,2);

% --------- trial response matrix: channels x trials ---
R = [vtr.spR];                            % nCh x nTrials
nCh = size(R,1);

% Loop following two experiment columns
c = colStart;
sc = S(:,c);
sc2 = S(:,c+1);

% unique stimulus values excluding blanks (>=500 treated as blanks)
sVals = unique(sc);
sVals = sVals(sVals < 500);

% unique stimulusu values for second column
sVals2 = unique(sc2);
sVals2 = sVals2(sVals2 < 500);

% Means per stimulus value 
block = zeros(nCh, numel(sVals),numel(sVals), 'like', R);
cnt = 1;
for j = 1:numel(sVals)
    for k = 1:numel(sVals2)
        idx = (sc == sVals(j) & sc2==sVals2(k));
        block(:,j,k) = mean(R(:, idx), 2);
    end
end

%%
figure; 
for n = 261:360; subplot(10,10,n-260); 
    imagesc(squeeze(block(n,:,:))); set(gca,'box','off'); 
end
%%
figure; 
for n = 1:100; subplot(10,10,n); 
    imagesc(squeeze(block(n,:,:))); set(gca,'box','off'); 
end
%%
figure; 
for n = 101:200; subplot(10,10,n-100); 
    imagesc(squeeze(block(n,:,:))); set(gca,'box','off'); 
end
%%
figure; 
for n = 201:300; subplot(10,10,n-200); 
    imagesc(squeeze(block(n,:,:))); set(gca,'box','off'); 
end

colorbar

%%
A = nan(20*size(block,2),20*size(block,3));
cnt = 0;
for n = 1:20;
    for n2 = 1:20;
        cnt = cnt+1;
        if cnt<=size(block,1)
            a = reshape(block(cnt,:,:),size(block,2),size(block,3));
            %a = a/max(max(a)); % normalize
            A((n-1)*size(block,2)+1:n*size(block,2),(n2-1)*size(block,3)+1:n2*size(block,3)) = a;
        else
            break;
        end
    end
end



figure;
imagesc(A)
c = colorbar;
c.TickDirection = 'out';
c.Label.String = 'sp/sec';

%%
figure;
imagesc(squeeze(block(3,:,:)));
set(gca,'box','off','xtick',[1:P],'xticklabel',sVals2,'ytick',[1:M],'yticklabel',sVals)



