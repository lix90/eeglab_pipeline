clear, clc, close all

% set directory
baseDir = '~/data/pain/';
inputTag = 'preEpoch';
outputTag = 'single';
fileExtension = 'set';
prefixPosition = 1;
marks = {'pos_pain', 'pos_nopain', ...
         'neg_nopain', 'neg_pain', ...
         'neu_nopain', 'neu_pain' };
timeRange = [-1 2];
threshTrialPerSubj = 20; % 20%
useCSD = 0;

%---------------------
if useCSD
    outputTag = [outputTag, 'CSD'];
end
inputDir = fullfile(baseDir, inputTag);
outputDir = fullfile(baseDir, outputTag);
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
[inputFilename, id] = getFileInfo(inputDir, fileExtension, prefixPosition);

for i = 1:numel(id)

    % load set
    fprintf('Loading (%i/%i %s)\n', i, length(id), inputFilename{i});
    [ALLEEG, EEG, CURRENTSET] = importEEG(inputDir, inputFilename{i});
    
    % reject
    EEG = pop_subcomp(EEG, [], 0);
    EEG = eeg_checkset(EEG);
    
    EEG = autoRejTrial(EEG, [-80, 80], [6,3], [6,3], 100, 1);
    EEG = eeg_checkset(EEG);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off', 'overwrite', ...
                                         'on');
    % inpterpolate channels
    ind = ~ismember({EEG.etc.origChanlocs.labels}, {'TP9', 'TP10'});
    EEG = pop_interp(EEG, EEG.etc.origChanlocs(ind), 'spherical');
    EEG = eeg_checkset(EEG);
    
    %% csd
    if useCSD
        if i==1
            [G, H] = getGHforEEGLAB(EEG);
        end
        if exist('G', 'var') && exist('H', 'var')
            EEG.data = getCSDforEEGLAB(EEG, G, H);
            EEG = eeg_checkset(EEG); 
        end
    end
    
    %% seperate dataset into single dataset by each conditions
    for j = 1:numel(marks)
        filename = strcat(id{i}, '_', marks{j});
        outputFilenameFull = fullfile(outputDir, filename);
        % skip if already exist
        if exist(outputFilenameFull, 'file'); warning('files already exist'); continue; end
        EEG = pop_epoch(EEG, marks(j), timeRange); % epoch into single condition
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1+j, ...
                                             'overwrite', 'off', 'gui', 'off', ...
                                             'savenew', outputFilenameFull);
        EEG = eeg_checkset( EEG );
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1+j, ...
                                             'retrieve', 1, 'study', 0); 
    end
    ALLEEG = []; EEG = []; CURRENTSET = 0;
end
