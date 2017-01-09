function parsave(fname, data2save, datastr,opts)
% inputs:
% fname is the fullpath filename
% data is the variable to save
% datastr is the name of the variable to save
% opts are options for saving
% lix(its.lix@outlook.com) retrieved from amgordon/eegfmri

data = data2save;
eval([datastr '= data;']);
save(fname, datastr, opts);
