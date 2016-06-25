clear, clc
baseDir = ''; % 
inputDir = fullfile(baseDir, 'raw');
outputDir = fullfile(baseDir, 'merge');

ext = 'eeg';
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
[setname, id] = get_fileinfo(inputDir, 'eeg', 1);

lix_matpool(4);

parfor i = 1:length(id)
    ALLEEG = []; EEG = []; CURRENTSET = 0;
    name = strcat(id{i}, '_merge.set');
    outName = fullfile(outputDir, name);
    if exist(outName, 'file'); warning('files already exist'); continue; end
    fprintf('Merging subject %i/%i\n', i, numel(id));
    tmp = dir(fullfile(inputDir, strcat(id{i}, '-*.', ext)));
    set_now = natsort({tmp.name});
    % load set
    for j = 1:length(set_now)
        switch ext
            case 'eeg'
                EEG = pop_fileio(fullfile(inputDir, set_now{j}));
            case 'set'
                EEG = pop_loadset('filename', set_now{j}, 'filepath', inputDir);
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