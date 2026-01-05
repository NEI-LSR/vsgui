%%
tic 
Datapixx('SetDoutValues', 1);
Datapixx('RegWrRd');
iters = 10000;
toc

for n = 1:iters 
    tic
    Datapixx('SetDoutValues', 1);
    Datapixx('RegWr');
    tocs1(n) = toc;
    tic
    Datapixx('SetDoutValues', 0);
    Datapixx('RegWr');
    tocs2(n) = toc;
end

disp(['mean duration of sending dout pulse over ' num2str(iters) ' iterations was: ' ...
    num2str(mean(tocs1)) ' and: ' num2str(mean(tocs2)) ' sec.'])