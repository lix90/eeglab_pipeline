% merging data
% s1kan, s1ziwo, s1qingjinkan
clear, clc

base_dir = '/Users/lix/projects/mabin'; %
input_dir = fullfile(base_dir, 'raw');
output_dir = fullfile(base_dir, 'rename');
file_ext = 'eeg';
old_marks = {'S  1', 'S  2'};
kan = {'S 11', 'S 12'};
ziwo = {'S 21', 'S 22'};
qjk = {'S 31', 'S 32'};

if ~exist(output_dir, 'dir'); mkdir(output_dir); end
in_filename = get_filename(input_dir, file_ext);
strs = get_str(in_filename, 's\d+([a-z])+\.eeg');
id = get_id(in_filename);

initialize_eeg;
for i = 1:length(in_filename)
    
    print_info(in_filename, i);
    out_filename = fullfile(output_dir, strcat(id, '_rename.set'));
    if exist(out_filename, 'file')
        disp('File exists!');
        continue
    end

    % load
    EEG = import_data(input_dir, in_filename{i});

    % rename
    switch strs{i}
      case 'qingjinkan'
        new_marks = kan;
      case 'ziwo'
        new_marks = ziwo;
      case 'kan'
        new_marks = qjk;
    end
    EEG = rename_events(EEG, old_marks, new_marks);

    % save
    EEG = save_data(EEG, out_filename);

end
