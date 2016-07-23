clear, clc, close all;
% set directory
baseDir = '~/Data/lqs_gambling/';
inputDir = fullfile(baseDir, 'dipfit');
outputDir = fullfile(baseDir, 'output');
fileExtension = 'set';
prefixPostion = 2;
% trialName = {'Neg_noPain', 'Neg_Pain', 'Neu_noPain', ...
%              'Neu_Pain', 'Pos_noPain', 'Pos_Pain'};
%%------------------------------------------------------------
eeglabDir = fileparts(which('eeglab.m'));
addpath(genpath(eeglabDir));
% prepare datasets
if ~exist(inputDir, 'dir'); disp('inputDir does not exist'); return; end
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
[inputFilename, id] = getFileInfo(inputDir, fileExtension, prefixPosition);

outName = fullfile(outputDir, 'NumOfICsAndChans_rv15.csv');
fid = fopen(outName, 'w');
firstLine = sprintf('subject,numOfIcs,pvaf,numOfChans,%s\n', ...
                    cellstrcat(trialName,','));
fprintf(fid, firstLine);

for i = 1:numel(id)
    fprintf(fid, [ID{i}, ',']);
    EEG = pop_loadset('filename', inputFilename{i}, 'filepath', inputDir);
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
    fprintf(fid, sprintf('%i,', nChan));
    % events = {EEG.event.type};
    % for j = 1:numel(trialName)
    %     nTrial = numel(find(ismember(events, trialName{j})));
    %     if j==numel(trialName)
    %         fprintf(fid, sprintf('i\n', nTrial));
    %     else
    %         fprintf(fid, sprintf('i,', nTrial));
    %     end
    % end
    EEG = [];
end
fclose(fid);
