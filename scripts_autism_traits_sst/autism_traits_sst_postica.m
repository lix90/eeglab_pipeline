clear, close all, clc;

autism_traits_sst_init;

[input_fn, id] = get_fileinfo(fullfile(g.base_dir, g.raw_folder), g.file_ext);
output_fn = fullfile(g.base_dir, g.postica_folder, strcat(id, '_postica.set'));
if ~exist(fullfile(g.base_dir, g.postica_folder), 'dir')
    mkdir(fullfile(g.base_dir, g.postica_folder));
end

for i = 1:numel(id)
    
    fprintf('dataset %i/%i: %s\n', i, numel(id), id{i});
    if exist(output_fn{i}, 'file')
        warning('files alrealy exist!');
        continue;
    end
    EEG = import_data(fullfile(g.base_dir, g.raw_folder), input_fn{i});
    mat = parload(fullfile(g.base_dir, g.ica_folder, strcat(id{i}, '_ica.mat')));
    EEG = preproc_postica(EEG, g, mat.bk);
    EEG = pop_saveset(EEG, 'filename', output_fn{i});
    
end
