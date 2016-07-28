clear, clc, close all
% pipeline for preprocessing rej ICs

baseDir = '~/Data/gender-role-emotion-regulation/';
inputTag = 'ica2';
outputTag = 'rejIC';
fileExtension = 'set';
prefixPosition = 1;
hiPassHz = [];
reallyRej = true;
marks = {'S 11', 'S 22', 'S 33', 'S 44', 'S 55'};
timeRange = [-0.2, 4];
EOG = [];

%%---------
inputDir = fullfile(baseDir, inputTag);
outputDir = fullfile(baseDir, outputTag);
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
[inputFilename, id] = getFileInfo(inputDir, fileExtension, 

for i = 1:numel(id)
    
    outputFilename = sprintf('%s_%s.set', id{i}, outputTag);
    outputFilenameFull = fullfile(outputDir, outputFilename);
    
    if exist(outputFilenameFull, 'file')
        warning('files alrealy exist!')
        continue
    end

    % import dataset
    [EEG, ALLEEG, CURRENTSET] = importEEG(inputDir, inputFilename{i});

    % hi-pass & low-pass
    if exist('hiPassHz', 'var') && ~isempty(hiPassHz)
        EEG = pop_eegfiltnew(EEG, hiPassHz, 0);
        EEG = eeg_checkset(EEG);
    end
    
    % if exist('lowPassHz', 'var') && ~isempthy(lowPassHz)
    %     EEG = pop_eegfiltnew(EEG, 0, lowPassHz);
    %     EEG = eeg_checkset(EEG);
    % end
    
    % epoching
    EEG = pop_epoch(EEG, marks, timeRange);
    EEG = eeg_checkset(EEG);
    
    % identify bad ICs
    try
        EEG = rejBySASICA(EEG, EOG, reallyRej);
    catch
        disp('wrong');
    end
    
    % save dataset
    EEG = pop_saveset(EEG, 'filename', outputFilenameFull);
    EEG = []; ALLEEG = []; CURRENTSET = [];
    
end
