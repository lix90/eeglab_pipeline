% merging data
% s1kan, s1ziwo, s1qingjinkan
clear, clc
base_dir = '/Users/lix/projects/mabin'; %
input_dir = fullfile(base_dir, 'rename');
output_dir = fullfile(base_dir, 'merge');
file_ext = 'set';
separator = '[q|z|k]';

if ~exist(output_dir, 'dir'); mkdir(output_dir); end
in_filename = get_filename(input_dir, file_ext);
id = unique(get_id(in_filename, separator));

initialize_eeg;    
for i = 1:length(id)

    print_info(id, i);
    out_filename = fullfile(output_dir, strcat(id{i}, '_merge.set'));
    if exist(out_filename, 'file'); warning('Files exist!'); continue; end;
    
    set_ind = regexp(in_filename, ['^', id{i}, '[a-z]+_rename.set$']);
    set_ind = ~(cellfun(@isempty, set_ind));
    set_now = in_filename(set_ind);

    % merge data
    EEG = merge_data(input_dir, set_now);
    
    % save data
    EEG = save_data(EEG, out_filename);

end
