%% eeglab pipeline for lqs: merge datasets
clear, clc, close

base_dir = '/media/lix/store/data/lqs_gambling/raw/';
in_dir = 'change_event';
ou_dir = 'merge';
ext = 'set';
splitPos = 1;
poolsize = 4;

%%
inputDir = fullfile(base_dir, in_dir);
outputDir = fullfile(base_dir, ou_dir);
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
tmp = dir(fullfile(inputDir, strcat('*', ext)));
fileName = {tmp.name};
id = get_prefix(fileName, 2);
id = unique(id);
% if matlabpool('size') < poolsize
%     matlabpool('local', poolsize);
% end

eeglab_opt;
for i = 1:2
    %length(ID)
    ALLEEG = []; EEG = []; CURRENTSET = 0;
    name = strcat(id{i}, '_merge.set');
    outName = fullfile(outputDir, name);
    if exist(outName, 'file'); warning('files already exist'); continue; end
    fprintf('Merging subject %i/%i\n', i, numel(id));
    tmp = dir(fullfile(inputDir, strcat(id{i}, '_*.', ext)));
    setMerge = {tmp.name};
    % load set
    for j = 1:length(setMerge)
        switch ext
          case 'eeg'
            EEG = pop_fileio(fullfile(inputDir, setMerge{j}));
          case 'set'
            EEG = pop_loadset('filename', setMerge{j}, 'filepath', inputDir);
          case 'cnt'
            EEG = pop_loadcnt(fullfile(inputDir, setMerge{j}), 'keystroke', 'on');
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
    EEG.setname = strcat(id{i}, '_merge');
    EEG = pop_saveset(EEG, 'filename', outName);
    ALLEEG = []; EEG = []; CURRENTSET = 0;
end