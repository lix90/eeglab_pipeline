clear, clc, close

%% parameters
baseDir = '';
in = 'raw';
out = 'merge';
fileExt = 'eeg';
splitPos = 1;
poolsize = 4;

%%
inputDir = fullfile(baseDir, in);
outputDir = fullfile(baseDir, out);
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
tmp = dir(fullfile(inputDir, '*', fileExt));
fileName = {tmp.name};
splitID = cellfun(@(x) {regexp(x, (-|_|\.), 'split')}, fileName);
ID = cellfun(@(x) {splitID{splitPos}}, splitID);
ID = unique(ID);

if matlabpool('size') < poolsize
    matlabpool('local', poolsize);
end

eeglab_opt;
parfor i = 1:length(ID)
    ALLEEG = []; EEG = []; CURRENTSET = 0;
    name = strcat(ID{i}, '_merge.set');
    outName = fullfile(outputDir, name);
    if exist(outName, 'file'); warning('files already exist'); continue; end
    fprintf('Merging subject %i/%i\n', i, numel(ID));
    tmp = dir(fullfile(inputDir, strcat(ID{i}, '*.', ext)));
    setMerge = {tmp.name};
    setMerge = setMerge(cellfun(@isempty, regexp(setMerge, setcat('^', ID{i}, '(-|_|\.)'), 'match')));
    % load set
    for j = 1:length(setMerge)
        switch fileExt
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