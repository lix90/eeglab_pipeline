clear, close all, clc;

weigexin_bipolar_init_param;
prefix_str = 'depression';
append_str = 'pain';

input_dir = fullfile(g.base_dir, g.raw_folder);
output_dir = fullfile(g.base_dir, 'raw_set');
[input_fn, id] = get_fileinfo(input_dir, {'eeg'});
output_fn = fullfile(output_dir, strcat(prefix_str, '_', id, '_', append_str, '.set'));
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
    pop_saveset(EEG, 'filename', output_fn{i});
    
end
