clear, clc, close all
% pipeline for preprocessing rej epochs

baseDir = '~/Data/gender-role-emotion-regulation/';
inputTag = 'ica2';
outputTag = 'rejEpoch';
fileExtension = 'set';
prefixPosition = 1;
thresh = [-100, 100];
prob = [6, 3];
kurt = [6, 3];
threshTrialPerChan = 20;
threshTrialPerSubj = 20;

%%---------
inputDir = fullfile(baseDir, inputTag);
outputDir = fullfile(baseDir, outputTag);
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
[inputFilename, id] = getFileInfo(inputDir, fileExtension, prefixPosition);

for i = 1:numel(id)
    
    outputFilename = sprintf('%s_%s.set', id{i}, outputTag);
    outputFilenameFull = fullfile(outputDir, outputFilename);
    
    if exist(outputFilenameFull, 'file')
        warning('files alrealy exist!')
        continue
    end

    % import dataset
    [EEG, ALLEEG, CURRENTSET] = importEEG(inputDir, inputFilename{i});
    
    % reject epochs
    [EEG, rejSubj] = autoRejTrial(EEG, thresh, prob, kurt, threshTrialPerChan, ...
                                  threshTrialPerSubj);
    if rejSubj
        textFile = fullfile(outputDir, sprintf('%s_subjRejected.txt', id{i}));
        fid = fopen(textFile, 'w');
        fprintf(fid, sprintf('subject %s rejected for too many bad epochs\n', ...
                             id{i}));
        fclose(fid);
    else
        % save dataset
        EEG = pop_saveset(EEG, 'filename', outputFilenameFull);
    end
    EEG = []; ALLEEG = []; CURRENTSET = [];
    
end