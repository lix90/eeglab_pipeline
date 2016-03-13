cd('E:\data_2015_07\ica2'); savepath = '.\tf_2015_08';

if ~exist(savepath, 'dir'); mkdir(savepath); end

addpath('..\');

[pain_posi, pain_nega, pain_neut, F, T] = lix_con_sub();

save(fullfile(savepath, 'painsub.mat'), 'pain_posi', 'pain_nega', 'pain_neut', 'T', 'F');