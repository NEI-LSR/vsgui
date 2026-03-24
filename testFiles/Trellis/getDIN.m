function out = getDIN

out = NaN;

[cnt,tstamps,events]=xippmex('digin');

if cnt>0
out = [events(1).parallel];
end