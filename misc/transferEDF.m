function transferEDF(dataFolder)

currentFolder = pwd;

if nargin == 1
    cd(dataFolder)
end

d= dir('*.mat');
for i=1:length(d)
    s = load(fullfile(d(i).folder,d(i).name));
    if isfield(s,'ex') && isfield(s.ex.Header,'edfFileName')
        fn = fullfile(d(i).folder,s.ex.Header.edfFileName);
        if exist(fn,'file')
            edfName = regexprep(d(i).name,'.mat','.edf')
            if ~exist(edfName,'file')
                copyfile(s.ex.Header.edfFileName,edfName)
                keyboard
            end
        else
            keyboard
            Eyelink('ReceiveFile',s.ex.Header.edfFileName);
            edfName = regexprep(d(i).name,'.mat','.edf');
            copyfile(s.ex.Header.edfFileName,edfName)
            keyboard
        end
    end
end

cd(currentFolder)

