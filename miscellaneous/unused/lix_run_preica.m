ext = 'eeg';
params = lix_eegSettings;
disp('===================')
disp('===merge===========')
disp('===================')
lix_run_mergeset(params, ext);
disp('===================')
disp('===prep============')
disp('===================')
lix_run_prep(params);
disp('===================')
disp('===epoch===========')
disp('===================')
lix_run_epoch(params);
disp('===================')
disp('===done============')
disp('===================')