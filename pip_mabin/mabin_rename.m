% merging data
% s1kan, s1ziwo, s1qingjinkan
clear, clc

base_dir = '~/Data/mabin'; %
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

for i = 1:length(in_filename)
    
    print_info(in_filename, i);
    out_filename = fullfile(output_dir, strcat(id{i}, '_rename.set'));
    if exist(out_filename, 'file')
        disp('File exists!');
        continue
    end

    % load
    try
        EEG = import_data(input_dir, in_filename{i});
    catch err
        disp(err.message);
        continue;
    end
    % rename
    switch strs{i}(1:3)
      case 'qin'
        new_marks = kan;
      case 'ziw'
        new_marks = ziwo;
      case 'kan'
        new_marks = qjk;
    end
    EEG = rename_events(EEG, old_marks, new_marks);

    % save
    EEG = pop_saveset(EEG, 'filename', out_filename);
    EEG = [];

end
