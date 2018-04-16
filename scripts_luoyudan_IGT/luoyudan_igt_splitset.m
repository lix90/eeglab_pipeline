clear, close all, clc;

luoyudan_igt_init_param;
input_dir = fullfile(g.base_dir, g.postica_output_folder);
output_dir = fullfile(g.base_dir, g.split_output_folder);
[input_fn, id] = get_fileinfo(input_dir, g.file_ext);

if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

parfor i = 1:numel(id)
    
    fprintf('dataset %i/%i: %s\n', i, numel(id), id{i});
    EEG = import_data(input_dir, input_fn{i});
    for j = 1:numel(g.epoch_events)
        fname = fullfile(output_dir, strcat(id{i}, '_', g.epoch_eventnames{j}, '.set'));
        if exist(fname, 'file')
         warning('files alrealy exist!');
        continue;
        end
        split_epochs(EEG, fname, g.epoch_events(j), g.epoch_timerange);
    end
end
