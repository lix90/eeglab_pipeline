clear, clc, close all;
% set directory
baseDir = '~/Data/dingyi/';
inputDir = fullfile(baseDir, 'ica_noRemoveWindows_1hz');
outputDir = fullfile(baseDir, 'output_noRemoveWindows_1hz');
eeglabDir = fileparts(which('eeglab.m'));
addpath(genpath(eeglabDir));
% prepare datasets
if ~exist(inputDir, 'dir'); disp('inputDir does not exist'); return; end
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
tmp = dir(fullfile(inputDir, '*.set'));
fileName = {tmp.name};
nFile = numel(fileName);
ID = get_prefix(fileName, 1);
ID = unique(ID);

outName = fullfile(outputDir, 'NumOfICsAndChans.csv');
fid = fopen(outName, 'w');
firstLine = 'subject,numOfIcs,pvaf,numOfChans\n';
fprintf(fid, firstLine);

for i = 1:nFile
    fprintf(fid, [ID{i}, ',']);
    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    EEG = eeg_checkset(EEG);
    nIC = numel(find(~EEG.reject.gcompreject));
    fprintf(fid, sprintf('%i,', nIC));
    % compute pvafs
    if isempty(EEG.icaact)
        EEG.icaact = eeg_getdatact(EEG, ...
                                   'component', 1:size(EEG.icaweights, 1));
    end
    [pvaf, pvafs, vars] = eeg_pvaf(EEG, find(~EEG.reject.gcompreject), ...
                                   'plot', 'off');
    fprintf(fid, sprintf('%f,', pvaf));
    nChan = EEG.nbchan;
    fprintf(fid, sprintf('%i\n', nChan));
    EEG = [];

end
fclose(fid);
