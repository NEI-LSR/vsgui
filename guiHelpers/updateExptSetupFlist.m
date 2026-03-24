function updateExptSetupFlist(handles)
% updates expt setup file list	
	
global ex
curr_dir = pwd;
cd ([ex.setup.VSdirRoot ]);
cd ../setupFiles/ExptSetupFiles
setup_flist = dir('*.setup');
for n=1:length(setup_flist)
	flist{n} = strrep(setup_flist(n).name,'.setup','');
end
set(handles.storedExperiments,'string',flist);
guidata(handles.figure1,handles)
cd(curr_dir);
	