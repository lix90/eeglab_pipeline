clear, clc, close all

% set directory
base_dir = '~/Data/mabin/';
input_tag = 'erp8s';
output_tag = 'single';
icamat_tag = 'pre';
file_ext = 'set';
marks = {'S 11', 'S 12', ...
         'S 21', 'S 22', ...
         'S 31', 'S 32' };
timeRange = [-1.5 8];

input_dir = fullfile(base_dir, input_tag);
output_dir = fullfile(base_dir, output_tag);
icamat_dir = fullfile(base_dir, icamat_tag);
if ~exist(output_dir, 'dir'); mkdir(output_dir); end
in_filename = get_filename(input_dir, file_ext);
id = get_id(in_filename);
in_filename_ica = strcat(id, '_', icamat_tag, '.mat');

for i = 1:numel(id)

    % load set
    print_info(id, i);
    ALLEEG = []; EEG = []; CURRENTSET = 0;
    EEG = import_data(input_dir, in_filename{i});
    load(fullfile(icamat_dir, in_filename_ica{i}));
    
    % reject
    EEG = pop_subcomp(EEG, [], 0);
    EEG = eeg_checkset(EEG);
    
    % inpterpolate channels
    EEG = pop_interp(EEG, ica.info.orig_chanlocs, 'spherical');
    EEG = eeg_checkset(EEG);
    
    origEEG = EEG;
    %% seperate dataset into single dataset by each conditions
    for j = 1:numel(marks)
        EEG = [];
        fname = strcat(id{i}, '_', strrep(marks{j}, ' ', ''));
        out_filename = fullfile(output_dir, fname);
        % skip if already exist
        if exist(out_filename, 'file'); warning('files already exist'); continue; end
        EEG = pop_epoch(origEEG, marks(j), [origEEG.xmin*1000, origEEG.xmax*1000]); 
        EEG = eeg_checkset( EEG );
    end
    
end
