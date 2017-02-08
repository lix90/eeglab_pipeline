%% script for merging datasets

% ------------------------------------------------------------------------------
% Initialize variables
% ------------------------------------------------------------------------------

clear, clc, close all
base_dir = ''; 
input_folder = '';
output_folder = '';
file_ext = 'set';
fname_sep_pos = 1;
exp_type = 'ce';  % experiment type, close eye or open eye

% ------------------------------------------------------------------------------
% Code begins
% ------------------------------------------------------------------------------

input_dir = fullfile(base_dir, input_folder);
output_dir = fullfile(base_dir, output_folder);
mkdir_p(output_dir);

[input_fname, id] = get_fileinfo(inputDir, file_ext, fname_sep_pos);

for i = 1:length(id)
    
    fprintf('\n\n***** Merging subject %i/%i *****\n\n', i, numel(id));

    ALLEEG = []; EEG = []; CURRENTSET = 0;
    output_fname = sprintf('%s_%s_merge.set', exp_type, id{i}); 
    output_fname_full = fullfile(output_dir, output_fname);
    if exist(outName, 'file'); warning('files already exist'); continue; end
    tmp = dir(fullfile(inputDir, strcat(id{i}, '*.', ext)));
    fname_this_subject = natsort({tmp.name});

    % loading set
    for j = 1:length(fname_this_subject)
        
        [EEG, ALLEEG, CURRENTSET] = import_data(input_dir, fname_this_subject{j});
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
    
    EEG.setname = strcat(id{i}, '_merge');
    EEG = pop_saveset(EEG, 'filename', output_fname_full);
    ALLEEG = []; EEG = []; CURRENTSET = 0;

end
