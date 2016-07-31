clear, clc, close all

% set directory
baseDir = '~/Data/moodPain_final/';
inputTag = 'preEpoch';
outputTag = 'single';
fileExtension = 'set';
prefixPosition = 1;
marks = {'pos_Pain', 'pos_nopain', ...
         'neg_nopain', 'neg_pain', ...
         'neu_nopain', 'neu_pain' };;
timeRange = [-0.2 1];
threshTrialPerSubj = 20; % 20%
rejectTrial = 1;

%---------------------
inputDir = fullfile(baseDir, inputTag);
outputDir = fullfile(baseDir, outputTag);
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
[inputFilename, id] = getFileInfo(inputDir, fileExtension, prefixPosition);

for i = 1:numel(id)

    % load set
    fprintf('Loading (%i/%i %s)\n', i, length(id), inputFilename{i});
    [ALLEEG, EEG, CURRENTSET] = importEEG(inputDir, inputFilename{i});
    
    % reject components
    EEG = pop_subcomp(EEG, [], 0);
    EEG = eeg_checkset(EEG);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off', 'overwrite', ...
                                         'on');
    %% csd
    % disp('laplacian');
    % laplac = eeg_laplac(EEG, 1);
    % laplac = reshape(laplac, [size(EEG.data)]);
    % EEG.data = laplac;
    % EEG = eeg_checkset(EEG);
    % [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off', 'overwrite', ...
    %                                      'on');
    
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
