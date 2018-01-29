clear, close all, clc;

autism_traits_sst_init;

[input_fn, id] = get_fileinfo(fullfile(g.base_dir, g.raw_folder), g.file_ext);
output_fn = fullfile(g.base_dir, g.ica_folder, strcat(id, '_ica.mat'));

for i = 1:numel(id)
    
    fprintf('dataset %i/%i: %s\n', i, numel(id), id{i});
    if exist(output_fn{i}, 'file')
        warning('files alrealy exist!');
        continue;
    end
    EEG = import_data(fullfile(g.base_dir, g.raw_folder), input_fn{i});
    EEG = preproc_ica(EEG, g);
    parsave(output_fn{i}, EEG.bk, 'bk');
    
end
