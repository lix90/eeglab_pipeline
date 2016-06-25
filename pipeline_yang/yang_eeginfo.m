%% script for arranging eegdata info across subjects and conditions

%% parameters
inputDir = '~/data/spherical-back/spherical_back/';
outputDir = '~/data/spherical-back/';
outputFilename = 'yang_mood_pain.csv';
trialName = {'Pos_Pain', 'Pos_noPain', ...
             'Neg_noPain', 'Neg_Pain', ...
             'Neu_noPain', 'Neu_Pain' };

%% get file list
if ~exist(inputDir, 'dir'); disp('inputDir does not exist\n please reset it'); return; end
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
tmp = dir(fullfile(inputDir, '*.set'));
fileName = natsort({tmp.name});
nFile = numel(fileName);
subjID = get_prefix(fileName, 1);
subjID = natsort(unique(subjID));

output = struct();
output.id = subjID';
output.Nchan = NaN(numel(subjID),1);
output.Nic = NaN(numel(subjID),1);
output.pvaf = NaN(numel(subjID),1);

%% start loop
for i = 1:nFile
    
    %% load dataset
    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    EEG = eeg_checkset(EEG);
    
    %% get trialName
    events = {EEG.event.type};
    for j = 1:numel(trialName)
        output.(trialName{j})(i,1) = numel(find(ismember(events, trialName{j})));
    end
    output.chanNum(i,1) = EEG.nbchan;
    output.icNum(i,1) = size(EEG.icaact, 1);
    %pvaf = eeg_pvaf(EEG, []);
    %output.pvaf(i,1) = pvaf(end);

    EEG = []; ALLEEG = [];

end;

%% write output
outputName = fullfile(outputDir, outputFilename);
struct2csv(output, outputName);
