% merging data
% s1kan, s1ziwo, s1qingjinkan
clear, clc

base_dir = '/Users/lix/projects/mabin'; %
input_dir = fullfile(base_dir, 'rename');
output_dir = fullfile(base_dir, 'merge');
file_ext = 'set';
if ~exist(output_dir, 'dir'); mkdir(output_dir); end
in_filename = get_filename(input_dir, file_ext);
id = unique(get_ids(in_filename, '(s\d{1,2})'));
out_filename = fullfile(output_dir, strcat(id, '_merge.set'));

for i = 1:length(id)

    ALLEEG = []; EEG = []; CURRENTSET = 0;
    if exist(out_filename, 'file'); warning('files already exist'); continue; end
    fprintf('Merging subject %i/%i\n', i, numel(id));

    tmp = dir(fullfile(input_dir, strcat(id{i}, '*.', file_ext)));
    set_now = natsort({tmp.name});

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
    
    % merge set
    N = length(ALLEEG);
    if N > 1
        EEG = pop_mergeset(ALLEEG, 1:N, 0);
        EEG = eeg_checkset(EEG);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,...
            'overwrite','on');
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        EEG = eeg_checkset(EEG);
    end
    
    EEG = pop_saveset(EEG, 'filename', out_filename{i});
    ALLEEG = []; EEG = []; CURRENTSET = 0;

end
