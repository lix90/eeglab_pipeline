clear, clc, close all

%% parameters
baseDir = '~/data/iris/';
eeglabPath = '~/programs/matlabtoolbox/eeglab_dev/';
inputTag = 'ica';
outputTag = 'dipfit';
fileExtension = 'set';
prefixPosition = 1;
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

% setMatlabPool(poolSize);

setEEGLAB(eeglabPath);

for i = 1:numel(id)

    outputFilename = sprintf('%s_%s.set', id{i}, outputTag);
    outputFilenameFull = fullfile(outputDir, outputFilename);
    if exist(outputFilenameFull, 'file')
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
