function timestamps = getSpkTimes(ex)

% t = getSpkTimes(ex)  
% reads out the spike times in the channels specified in ex.setup.gv.elec

% history
% 08/05/14  hn: wrote it
% 11/04/16  hn: modified to allow for larger channel counts
% 04/07/23  ik: make timestamps single-precision to reduce the size

% make sure that when there are >4 channels we only read out cluster 0
disp('in getSpkTimes')
tic
if length(ex.setup.gv.elec)>4
    ex.setup.gv.cl = 0;
end

[~,t,~,u] = xippmex('spike',ex.setup.gv.elec,0);
disp('after xippmex')
timestamps = cell(size(t,1),length(ex.setup.gv.cl));
for n = 1:size(t,1)
%     clusters = unique(u{n})
%     if length(clusters)>1
%         if clusters(1)==0
%             clusters = clusters(2:end);
%         end
%         c_idx = u{n} == clusters(1);
%         timestamps{n} = t{n}(c_idx)/30000;
%     else
%         timestamps{n} = t{n}/30000;
%     end
    for nc = 1:length(ex.setup.gv.cl)
        c_idx = u{n} == ex.setup.gv.cl(nc);  % choose which cluster to plot
        timestamps{n,nc} = single(t{n}(c_idx)/30000);
    end
end
toc
%disp('in spkTimes')