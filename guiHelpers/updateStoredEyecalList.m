function updateStoredEyecalList(handles)
% updates list of stored Eyecalibrations	
	
global ex
curr_dir = pwd;
cd ([ex.setup.VSdirRoot ]);
cd ../setupFiles/EyecalibrationSetupFiles
setup_flist = dir('*.eyeCal');
flist = {};
for n=1:length(setup_flist)
	flist{n} = strrep(setup_flist(n).name,'.eyeCal','');
end
set(handles.storedEyeCalibrations,'string',flist);
guidata(handles.figure1,handles)

cd(curr_dir);


	