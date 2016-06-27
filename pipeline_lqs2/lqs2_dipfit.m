clear, clc, close all

%% parameters
baseDir = '';
inputTag = '';
outputTag = '';
rvDipoleEstimate = 1;
brainTemplate = 'Spherical'; % 'MNI' or 'Spherical'
rvReject = 0.15;
inBrain = 1;
poolSize = 4;

%%--------
inputDir = fullfile(baseDir, 'ica');
outputDir = fullfile(baseDir, 'dipfit');
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
[inputFilename, id] = getFileInfo(inputDir, fileExtension, prefixPosition);

setMatlabPool(poolSize);

setEEGLAB;

parfor i = 1:numel(id)

    outputFilename = strcat(id{i}, '_dipfit.set'));
    outputFilenameFull = fullfile(outputDir, outputFilename);
    if exist(outName, 'file')
        warning('files already exist');
        continue
    end

    % load dataset
    [EEG, ALLEEG, CURRENTSET] = importEEG(inputDir, inputFilename{i});

    % dipfit
    [EEG, badICs] = dipReject(EEG, brainTemplate, rvDipoleEstimate, rvReject, ...
                              inBrain);
    EEG.reject.gcompreject = badICs;
    EEG = eeg_checkset(EEG);
    
    % saveset
    EEG = pop_saveset(EEG, 'filename', outputFilenameFull); 
    EEG = []; ALLEEG = []; CURRENTSET = [];

end
