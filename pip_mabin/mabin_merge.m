% merging data
% s1kan, s1ziwo, s1qingjinkan
clear, clc
<<<<<<< HEAD

base_dir = '~/Data/mabin'; %
=======
base_dir = '/Users/lix/projects/mabin'; %
>>>>>>> 01cb313b0356144b94e95d546c20ca0fc36ddc29
input_dir = fullfile(base_dir, 'rename');
output_dir = fullfile(base_dir, 'merge');
file_ext = 'set';
separator = '[q|z|k]';

if ~exist(output_dir, 'dir'); mkdir(output_dir); end
in_filename = get_filename(input_dir, file_ext);
<<<<<<< HEAD
id = unique(get_id(in_filename, '[q|z|k]'));
=======
id = unique(get_id(in_filename, separator));
>>>>>>> 01cb313b0356144b94e95d546c20ca0fc36ddc29

initialize_eeg;    
for i = 1:length(id)

<<<<<<< HEAD
    ALLEEG = []; EEG = []; CURRENTSET = 0;
    out_filename = fullfile(output_dir, strcat(id{i}, '_merge.set'));
    if exist(out_filename, 'file'); warning('files already exist'); continue; end
    fprintf('Merging subject %i/%i\n', i, numel(id));

    set_ind = regexp(in_filename, ['^', id{i}, '[a-z]+_rename.set$']);
    set_ind = cellfun(@(x) ~isempty(x), set_ind);
    set_now = in_filename(set_ind);
    
    % load set
    for j = 1:length(set_now)
        switch file_ext
            case 'eeg'
                EEG = pop_fileio(fullfile(input_dir, set_now{j}));
            case 'set'
                EEG = pop_loadset('filename', set_now{j}, 'filepath', input_dir);
        end
        [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, j);
        EEG = eeg_checkset(EEG);
    end
=======
    print_info(id, i);
    out_filename = fullfile(output_dir, strcat(id{i}, '_merge.set'));
    if exist(out_filename, 'file'); warning('Files exist!'); continue; end;
>>>>>>> 01cb313b0356144b94e95d546c20ca0fc36ddc29
    
    set_ind = regexp(in_filename, ['^', id{i}, '[a-z]+_rename.set$']);
    set_ind = ~(cellfun(@isempty, set_ind));
    set_now = in_filename(set_ind);

    % merge data
    EEG = merge_data(input_dir, set_now);
    
<<<<<<< HEAD
    EEG = pop_saveset(EEG, 'filename', out_filename);
    ALLEEG = []; EEG = []; CURRENTSET = 0;
=======
    % save data
    EEG = save_data(EEG, out_filename);
>>>>>>> 01cb313b0356144b94e95d546c20ca0fc36ddc29

end
