clear, clc, close all
% pipeline for preprocessing rej ICs

baseDir = '~/Data/gender-role-emotion-regulation/';
% eeglabPath = '';
inputTag = 'ica2';
outputTag = 'rejIC';
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
    
    outputFilename = sprintf('%s_%s.set', id{i}, outputTag);
    outputFilenameFull = fullfile(outputDir, outputFilename);
    
    if exist(outputFilenameFull, 'file')
        warning('files alrealy exist!')
        continue
    end

    % import dataset
    [EEG, ALLEEG, CURRENTSET] = importEEG(inputDir, inputFilename{i});

    % identify bad ICs
    try
        EEG = rejBySASICA(EEG, EOG);
    catch
        disp('wrong');
    end
    
    % save dataset
    EEG = pop_saveset(EEG, 'filename', outputFilenameFull);
    % EEG = pop_saveset(EEG, 'savemode', 'resave');
    EEG = []; ALLEEG = []; CURRENTSET = [];
    
end
