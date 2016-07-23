clear, clc, close all

baseDir = '~/Data/mx_music/';
inputDir = fullfile(baseDir, 'pre');
outputDir = fullfile(baseDir, 'ica');
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

fileExtension = 'set';
prefixPosition = 1;
poolSize = 4;
rightRESP = [];
offlineRef = {'TP9', 'TP10'};

%%----------------------------
[inputFilename, id] = getFileInfo(inputDir, fileExtension, prefixPosition);

if exist('poolSize', 'var') && ~isempty(poolSize)
    setMatlabPool(poolSize)
end

fprintf('start loop')
parfor i = 1:numel(id)

    outputFilename = sprintf('%s_ica.set', id{i});
    outputFilenameFull = fullfile(outputDir, outputFilename);
    if exist(outputFilenameFull, 'file')
        warning('files alrealy exist!')
        continue
    end
    
    % import dataset
    EEG = importEEG(inputDir, inputFilename{i});
    
    % preparing data for ica (reject epoch)
    EEG = rejEpoch(EEG, rightRESP, 'channels');

    % run ica
    EEG = runBINICA(EEG, offlineRef);
    
    % save dataset
    EEG.setname = strcat(id{i}, '_ica');
    EEG = pop_saveset(EEG, 'filename', outputFilenameFull);
    EEG = [];

end