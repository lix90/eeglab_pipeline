clear, clc, close all

baseDir = '~/Data/moodPain_final/';
inputDir = fullfile(baseDir, 'ica');
outputDir = fullfile(baseDir, 'dipfit');
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

rvDipoleEstimate = 1;
brainTemplate = 'Spherical'; % 'MNI' or 'Spherical'
rvReject = 15;
inBrain = 1;

[inputFilename, id] = getFileInfo(inputDir, fileExtension, prefixPosition);

for i = 1:numel(id)

    % prepare output filename
    outputFilename = strcat(id{i}, '_dipfit.set'));
    outputFilenameFull = fullfile(outputDir, outputFilename);
    if exist(outName, 'file')
        warning('files already exist');
        continue
    end

    % load dataset
    EEG = importEEG(inputDir, inputFilename{i});

    % dipfit
    [EEG, badICs] = dipReject(EEG, brainTemplate, rvDipoleEstimate, rvReject, ...
                              inBrain);
    EEG.reject.gcompreject = badICs;
    EEG = eeg_checkset(EEG);
    
    % epoch
    EEG = pop_epoch(EEG, markse, timeRange);
    EEG = eeg_checkset(EEG);
    
    % saveset
    EEG = pop_saveset(EEG, 'filename', outputFilenameFull); 
    EEG = eeg_checkset(EEG);
    EEG = [];
end
