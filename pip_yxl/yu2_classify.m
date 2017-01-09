clear, clc, close all

% set directory
baseDir = '';
inputFolder = 'ica';
outputFolder = 'classified';
events = {{'S  1', 'S  2', 'S  3', 'S  4'},...
          {'S  5', 'S  6', 'S  7', 'S  8'},...
          {'S  9', 'S 10', 'S 11', 'S 12'},...
          {'S 13', 'S 14', 'S 15', 'S 16'}};
condID = {'c1s', 'c2s', 'c3s', 'c4s'};

% prepare datasets
inputDir = fullfile(baseDir, inputFolder);
outputDir = fullfile(baseDir, outputFolder);
if ~exist(inputDir, 'dir'); disp('inputDir does not exist\n please reset it'); return; end
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
[inputFilename, id] = get_fileinfo(inputDir, 'set', 1);

% start
for i = 1:numel(id)

    % load set
    fprintf('Loading (%i/%i %s)\n', i, length(id), id{i});
    [ALLEEG, EEG, CURRENTSET] = import_data(inputDir, inputFilename{i});
    EEG = eeg_checkset(EEG);
    
    % reject marked ICs
    EEG = pop_subcomp(EEG, [], 0);
    EEG = eeg_checkset(EEG); 
    [ALLEEG EEG CURRENTSET] = ...
        pop_newset(ALLEEG, EEG, 1,'gui','off', 'overwrite', 'on');
    
    % baseline correction
    % EEG = pop_rmbase(EEG, basetime);
    % EEG = eeg_checkset(EEG);

    % epoching time
    epochtime = [EEG.xmin, EEG.xmax];
    
    for j = 1:numel(events)

        name = sprintf('%s_%s.set', condID{j}, id{i});
        outName = fullfile(outputDir, name);
        % skip if already exist
        if exist(outName, 'file'); warning('files already exist'); continue; end
    
        % epoching
        fprintf('start epoching\n');
        EEG = pop_epoch(EEG, natsort(events(j)), epochtime); % epoch into single condition
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1+j, ...
                                             'overwrite', 'off', 'gui', 'off', ...
                                             'savenew', outName);        
        EEG = eeg_checkset(EEG);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1+j, ...
                                             'retrieve', 1, 'study', 0); 
    end

    ALLEEG = []; EEG = []; CURRENTSET = 0;

end
