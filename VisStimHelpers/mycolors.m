function res = mycolors;
g=colormap(hsv(14));
for n=1:size(colormap,1)
    res{n} = g(n,:);
end