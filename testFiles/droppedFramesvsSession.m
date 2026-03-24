curDir = pwd;
addpath(curDir);
animalDir = '/Users/nienborg_group/CIN_local/data/test';
currDir = cd(animalDir);

fDirs = dir;
cnt = 1;
%%
for n = length(fDirs)
    n
    if exist(fullfile(animalDir,fDirs(n).name),'dir')
        cd(fullfile(animalDir,fDirs(n).name));
        fLst = dir('*rds.DCxDX*.mat');
        if ~isempty(fLst)
            for nl = 1:length(fLst)
                ex = [];
                fLst
                load(fLst(nl).name);
                if ~isempty(ex)
                    [fract{cnt}(nl),SD{cnt}(nl),nL{cnt}(nl),lDist{cnt,nl}]=droppedFrames(ex);
                    trN{cnt}(nl) = length(lDist{cnt,nl});
                    if ex.setup.recording
                        recording{cnt} = 'r';
                        if length(ex.setup.gv.elec)>1
                            recording{cnt} = 'c';
                        end
                    else recording{cnt} = 'k';
                    end
                        
                end
            end
            dirDate{cnt} = fDirs(n).name;
            cnt=cnt+1;
        end 
    end
end
%%
%return
%%
figure;
s1=subplot(3,1,1);
s2=subplot(3,1,2);
s3=subplot(3,1,3);
xTck = [];
for n=1:cnt-1
    if isempty(fract{n})
        fract{n} = NaN;
    end
    if isnan(recording{n})
        recording{n} = [1 1 1];
    end
    if isempty(trN{n})
        trN{n} = NaN;
    end
    if isempty(nL{n})
        nL{n} = NaN;
    end
end
for n = 1:cnt-1
    axes(s1);
    hold on;
    plot(n,fract{n},'o','color',recording{n},'markerfacecolor',recording{n});
    title('fraction presented frames')
    axes(s3);
    hold on
    plot(n,nL{n},'bo');
    if n/30==round(n/30)
        xTck = [xTck,n];
        xTckLbl{length(xTck)} = dirDate{n}(1:10);
    end
    axes(s2)
    hold on;
    plot(n,trN{n},'o','color',recording{n},'markerfacecolor',recording{n})    
    title('number of trials')
end
axes(s3)
set(gca,'xtick',xTck,'xticklabel',xTckLbl)
title('nominal number of frames')

