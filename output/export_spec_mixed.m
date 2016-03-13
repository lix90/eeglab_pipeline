%% script for exporting spectral data
% first, load study
% then, run this script
%
% this script is suitable for one way & two way design

%% parameters initiation
% directory
outputDir = '~/Desktop/demo/';
% ROI for frequency band
fBand = [8, 12]; % or other range 
nameOfBand = 'alpha';
% ROI for channels
F = {'Fz'}; % name of channels
C = {'Cz'};
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
specdata = specdata(:);

% specdata is 3 dimentional data cell array: frequency * channels * subjects;
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

var1 = STUDY.design.variable(1).value;
var1Pairing = STUDY.design.variable(1).pairing;
var2 = STUDY.design.variable(2).value;
var2Pairing = STUDY.design.variable(2).pairing;
if strcmp(var1Pairing, 'on') && strcmp(var2Pairing, 'on')
    % so its two way repeated measure design
    wayOfMethod = 1;
elseif strcmp(var1Pairing, 'off') || strcmp(var2Pairing, 'off')
    % so it has between subject variable
    wayOfMethod = 2;
    if strcmp(var1Pairing, 'off') && strcmp(var2Pairing, 'on')
        varBetween = 1;
    elseif strcmp(var2Pairing, 'off') && strcmp(var1Pairing, 'on')
        varBetween = 2;
    elseif strcmp(var1Pairing, 'off') && strcmp(var2Pairing, 'off')
        varBetween = 12;
    end
end

switch wayOfMethod
    case 1
      if numel(var1) == 1 || numel(var2) == 1
          if numel(var1) == 1
              tmpVarStr = var2;
          elseif numel(var2) == 2
              tmpVarStr = var1;
          end
      elseif numel(var1) > 1 && numel(var2) > 1
          for iVar2 = 1:length(var2)
              for iVar1 = 1:length(var1)
                  tmpVarStr{iVar1, iVar2} = strcat(var1{iVar1}, '_', var2{iVar2});
              end
          end
      end
      varStr = tmpVarStr(:);
  case 2
    switch varBetween
      case 1
        % var1 is between variable
        for iVar2 = 1:length(var2)
            for iVar1 = 1:length(var1)
                varStr{iVar1, iVar2} = strcat(var1{iVar1}, '_', var2{iVar2});
            end
        end
        nCondition = length(varStr);
        subjects = STUDY.subject;
        nSubject = length(STUDY.subject);
      case 2
        % var2 is between variable
        for iVar2 = 1:length(var2)
            for iVar1 = 1:length(var1)
                varStr{iVar2, iVar1} = strcat(var2{iVar2}, '_', var1{iVar1});
            end
        end
      case 12
        % var1 & var2 both are between variable
        for iVar2 = 1:length(var2)
            for iVar1 = 1:length(var1)
                varStr{iVar1, iVar2} = strcat(var1{iVar1}, '_', var2{iVar2});
            end
        end
    end
end

nFrequency = length(specfreqs);
idxBand = dsearchn(specfreqs', fBand');

% compute power of ROIs
for iRegion = 1:length(ROI)

    roiNameNow = nameOfROI{iRegion};
    
    if exist(outputFileName, 'file')
        warning('file already exists!'); 
        continue;
    end
    roiNameNow = nameOfROI{iRegion};
    fprintf('start %s\n', roiNameNow);
    roiNow = ROI{iRegion};
    nChan = numel(roiNow);
    idxChannel = find(ismember(channels, roiNow));
    switch varBetween
      case 1
        roiSpecData = zeros(nFrequency, nChan, nSubject, nCondition);
        for iCondition = 1:nCondition
            tmpSpecData = specdata{iCondition}(:, idxChannel, :);
            roiSpecData(:, :, :, iCondition) = tmpSpecData;
        end
        meanRoiSpecData = squeeze(...
            mean(mean(roiSpecData(idxBand(1):idxBand(2),:,:,:),1), 2));
      case 2
        
      case 12
        
    end
    % wirte data
    switch varBetween
      case 1
        fileName = strcat(nameOfBand, '_', roiNameNow, '.txt');
        outputFileName = fullfile(outputDir, fileName);
        FID = fopen(outputFileName, 'w');
        headers = [];
        for iSubject = 1:nSubject
            subStr = [''];
            for iCondition = 1:nCondition
                headers = strcat(headers, ',', varStr{iCondition});
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
      case 2
        
      case 12
        
    end
    
    fclose(FID);
    fprintf('end %s\n', roiNameNow);
end
disp('======================');
disp('=======> DONE <=======');