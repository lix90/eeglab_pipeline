base_dir = '~/Data/lqs_gambling/';
in_dir = fullfile(base_dir, 'pre2');
ou_dir = fullfile(base_dir, 'info');
if ~exist(ou_dir, 'dir'); mkdir(ou_dir); end
tmp_file = dir(fullfile(in_dir, '*.set'));
filename = {tmp_file.name};
id = get_prefix(filename, 2);

ou_file = fullfile(ou_dir, 'checkSubjTrialNum2.csv');
fid = fopen(ou_file, 'w');

for i = 1:numel(id)
    fprintf(fid, strcat(id{i}, ',' ));
    EEG = pop_loadset('filename', filename{i}, 'filepath', in_dir);
    numTrial = numel(EEG.epoch);
    fprintf(fid, sprintf('%i\n', numTrial));
    EEG = [];
end
fclose(fid);