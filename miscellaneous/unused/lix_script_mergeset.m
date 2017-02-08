filedir = 'E:\RawData_PainEmpathy\empathy_data_used\';
savedir = 'E:\pe\raw\';
if ~exist(savedir, 'dir'); mkdir(savedir); end
if ~exist(filedir, 'dir'); error('wrong directory'); end
lix_mergeset(filedir, savedir);