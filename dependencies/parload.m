function data = parload(fname)

data = [];
eval(['data =', 'load(fname);']);
