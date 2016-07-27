clear, clc, close all
% pipeline for preprocessing rej ICs

baseDir = '~/Data/gender-role-emotion-regulation/';
% eeglabPath = '';
inputTag = 'pre2';
fileExtension = 'set';
prefixPosition = 1;
isTrial = 0;
EOG = [];

%%---------
inputDir = fullfile(baseDir, inputTag);
outputDir = fullfile(baseDir, outputTag);
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
[inputFilename, id] = getFileInfo(inputDir, fileExtension, prefixPosition);
% setEEGLAB;
for i = 1:numel(id)
    % import dataset
    [EEG, ALLEEG, CURRENTSET] = importEEG(inputDir, inputFilename{i});
    % identify bad ICs
    EEG = rejBySASICA(EEG, EOG);
    % save dataset
    EEG = pop_saveset(EEG, 'savemode', 'resave');
    EEG = []; ALLEEG = []; CURRENTSET = [];
end
