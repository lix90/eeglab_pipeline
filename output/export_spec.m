%% script for exporting spectral data
% first, load study
% then, run this script

%% parameters initiation
% directory
outputDir = '';
% ROI for frequency band
fBand = [8, 12]; % or other range 
nameOfBand = 'alpha';
% ROI for channels
F = {'Fz', ''}; % name of channels
C = {'Cz', ''};
P = {'Pz'};
LF = {'F1'};
LC = {'C1'};
LP = {'P1'};
RF = {'F2'};
RC = {'C2'};
RP = {'P2'};
% ROI cell array 
ROI = {F, C, P, LF, LC, LP, RF, RC, RP};
nameOfROI = {'frontal', 'central', 'posterior',...
             'leftFront', 'leftCent', 'leftPost', ...
             'rightFront', 'rightCent', 'rightPost'};

%% compute power spectrum of all channels
channels = {STUDY.changrp.name};
[STUDY specdata specfreqs] = ...
    std_specplot(STUDY, ALLEEG, ...
                 'channels', channels, ...
                 'plotsubjects', 'off');
close all;

% specdata is 3 dimentional data array: frequency * channels * subjects;
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

if strcmp(STUDY.design.variable(2).value{:}, '')
    conditions = STUDY.design.variable(1).value;
elseif strcmp(STUDY.design.variable(1).value{:}, '')
    conditions = STUDY.design.variable(2).value;
else
    warning(['there are two variables in your design\n'...
             'this script may not produce expected results']);
end

nCondition = length(conditions);
subjects = STUDY.subject;
nSubject = length(STUDY.subject);
nFrequency = length(specfreqs);
idxBand = dsearchn(specfreqs', fBand');

% compute power of ROIs
for iRegion = 1:length(ROI)

    roiNameNow = nameOfROI{iRegion};
    fileName = strcat(nameOfBand, '_', roiNameNow, '.txt');
    outputFileName = fullfile(outputDir, fileName);
    if exist(outputFileName, 'file')
        warning('file already exists!'); 
        continue;
    end
    roiNameNow = nameOfROI{iRegion};
    fprintf('start %s\n', roiNameNow);
    roiNow = ROI{iRegion};
    nChan = numel(roiNow);
    idxChannel = find(ismember(channels, roiNow));
    roiSpecData = zeros(nFrequency, nChan, nSubject, nCondition);
    for iCondition = 1:nCondition
        tmpSpecData = specdata{iCondition}(:, idxChannel, :);
        roiSpecData(:, :, :, iCondition) = tmpSpecData;
    end
    meanRoiSpecData = squeeze(...
        mean(mean(roiSpecData(idxBand(1):idxBand(2),:,:,:),1), 2));

    % wirte data
    FID = fopen(outputFileName, 'w');
    headers = [];
    
    for iSubject = 1:nSubject
        subStr = [''];
        for iCondition = 1:nCondition
            headers = strcat(headers, ',', conditions{iCondition});
        end
        if iSubject == 1
            fprintf(FID, [headers, '\n']);
        end
        
        for iCondition = 1:nCondition
            tmpStr = num2str(meanRoiSpecData(iSubject, iCondition));
            if iCondition == 1
                subStr = strcat(subStr, subjects{iSubject}, ',', tmpStr);
            elseif iCondition > 1 && iCondition < nCondition
                subStr = strcat(subStr, ',', tmpStr);
            elseif iCondition == nCondition
                subStr = strcat(subStr, ',', tmpStr, '\n');
            end
        end
        fprintf(FID, subStr);
    end

    fclose(FID);
    fprintf('end %s\n', roiNameNow);
end
disp('======================');
disp('=======> DONE <=======');