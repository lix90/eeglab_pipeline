clear all, clc

%% parameters initiation
rawDir = ''; % raw continuous data file directory
outDir = ''; % output pruned file directory
epochInterval = 2; % second
outputFilenameSuffix = 'pruned'; % suffix for output filename

%% find file
fileList = dir(fullfile(rawDir, '*.set'));
fileName = {fileList.name};

% get unique subject ID for rename output file
tmp = dir(fullfile(inputDir, '*.set'));
fileName = natsort({tmp.name});
nFile = numel(fileName);
subjID = get_prefix(fileName, 1);
subjID = natsort(unique(subjID));

%% check file directory
if ~exist(rawDir, 'dir')
    error('file directory does not exist!');
end
if ~exist(outDir, 'dir')
    mkdir(outDir);
    disp(['output file directory does not ' ...
          'exist\n create output directory automatically']);
end

%% start epoch
for i = 1:nFile

    fileNameNow = fileName{i};
    EEG = pop_loadset('filename', fileNameNow, 'filepath', rawDir);
    EEG = eeg_checkset( EEG );

    eegpnts = EEG.pnts;
    trials = floor(eegpnts/(EEG.srate*epochInterval));
    EEG.trials = trials;
    EEG.xmax = (epochInterval-1/EEG.srate);
    trialLength = epochInterval*EEG.srate;
    EEG.times = EEG.times(1, 1:trialLength);
    eegdata = EEG.data;
    nbchan = size(EEG.data, 1);
<<<<<<< HEAD
    EEG.data = zeros(nbchan, trialLength, trials);k
=======
    EEG.data = zeros(nbchan, trialLength, trials);

>>>>>>> 62f55619d9928185f74e195cc4bb804e902dcc0a
    for j = 1:trials
        EEG.data(:,:,j) = eegdata(:,((j-1)*trialLength+1):j*trialLength);
    end

    EEG.pnts = trialLength;
    EEG = eeg_checkset(EEG);

    % SAVE FILE
    outName = strcat(subjID{i}, '_', outputFilenameSuffix, '.set');
    EEG = pop_saveset( EEG, 'filename', outName, 'filepath', outDir);
    EEG = eeg_checkset( EEG );

end

disp('DONE!')
