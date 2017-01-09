clear, clc, close all

baseDir = '~/Data/mx_music/';
inputTag = 'pre';
outputTag = 'ica';
fileExtension = 'set';
prefixPosition = 1;
poolSize = 4;
wrongRESP = [];
offlineRef = {'TP9', 'TP10'};

%%----------------------------

inputDir = fullfile(baseDir, inputTag);
outputDir = fullfile(baseDir, outputTag);
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

[inputFilename, id] = getFileInfo(inputDir, fileExtension, prefixPosition);

if exist('poolSize', 'var') && ~isempty(poolSize)
    setMatlabPool(poolSize)
end

fprintf('start loop')
parfor i = 1:numel(id)

    outputFilename = sprintf('%s_%s.set', id{i}, outputTag);
    outputFilenameFull = fullfile(outputDir, outputFilename);
    if exist(outputFilenameFull, 'file')
        warning('files alrealy exist!')
        continue
    end
    
    % import dataset
    EEG = importEEG(inputDir, inputFilename{i});
    
    % preparing data for ica (reject epoch)
    EEG = rejEpoch(EEG, wrongRESP);

    % run ica
    try
        EEG = runBINICA(EEG, offlineRef);
    catch
        disp('binica runs into error')
        EEG = runICA(EEG, offlineRef);
    end
    
    % save dataset
    EEG.setname = strcat(id{i}, '_', outputTag);
    EEG = pop_saveset(EEG, 'filename', outputFilenameFull);
    EEG = [];

end