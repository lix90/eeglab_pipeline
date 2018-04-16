clear, close all, clc;

weigexin_bipolar_init_param;

input_dir = fullfile(g.base_dir, g.raw_folder);
output_dir = fullfile(g.base_dir, g.ica_output_folder);
[input_fn, id] = get_fileinfo(input_dir, g.file_ext);
output_fn = fullfile(output_dir, strcat(id, '_ica.mat'));
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

for i = 1:numel(id)
    
    fprintf('dataset %i/%i: %s\n', i, numel(id), id{i});
    if exist(output_fn{i}, 'file')
        warning('files alrealy exist!');
        continue;
    end
    EEG = import_data(input_dir, input_fn{i});
    EEG = preproc_ica(EEG, g);
    parsave(output_fn{i}, EEG.bk, 'bk');
    
end
