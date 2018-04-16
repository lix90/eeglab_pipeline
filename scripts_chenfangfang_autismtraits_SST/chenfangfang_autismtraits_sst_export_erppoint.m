clear, close all, clc;

chenfangfang_autismtraits_sst_init_param;

input_dir = fullfile(g.base_dir, g.postica_output_folder);
output_dir = fullfile(g.base_dir, 'erppoint');
[input_fn, id] = get_fileinfo(input_dir, 'set');
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

chanlocs_file = fullfile(g.base_dir, 'chanlocs.mat');
load(chanlocs_file);

for i = 1:numel(id)
    
    fprintf('dataset %i/%i: %s\n', i, numel(id), id{i});
    
    EEG = import_data(input_dir, input_fn{i});
    
    % rej components
    EEG = pop_subcomp(EEG, [], 0);
    EEG = eeg_checkset(EEG);
    
    % interpolate
    EEG = pop_interp(EEG, chanlocs, 'spherical');
    EEG = eeg_checkset(EEG);
    
    for j = 1:numel(g.epoch_events)
        event = g.epoch_events{j};
        output_fn = fullfile(output_dir, strcat(id{i}, '_', event, '.txt'));
        points = mean(EEG.data(:,:,pick_event_index(EEG, event)),3);
        % chan * points
        chanlabels =[{'pnts'}, {chanlocs.labels}];
        data_cell = num2cellstr(points');
        data_index = transpose(num2cellstr(1:size(data_cell, 1)));
        output_data = [chanlabels; [data_index, data_cell]];
        cell2csv(output_fn, output_data, ',');
    end
   
end
