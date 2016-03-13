%% pipeline: get IAF

pipname = 'IAF';
chanLabels = {};
timeRange = [-1000 0];
epochLabels = {};

% directory
baseDir = '';
inputDir = fullfile(baseDir, 'laplac');
outputDir = fullfile(baseDir, pipname);

%% code -------------------------------------------------------------------------
% check directory
if ~exist(inputDir, 'dir')
    disp('inputDir does not exist\n please reset it'); 
    return
end
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

% prepare filelist
tmp = dir(fullfile(inputDir, '*.set'));
fileName = natsort({tmp.name});
n = numel(fileName);
id = get_prefix(fileName, 1);
id = natsort(unique(id));

% matlabpool
if matlabpool('size') < poolsize
    matlabpool('local', poolsize);
end

IAF = struct();

parfor i = 1:n

    namecsv = strcat(id{i}, '_', pipname, '.csv');
    namemat = strcat(id{i}, '_', pipname, '.mat');
    outNameCSV = fullfile(outputDir, namecsv);
    outNameMAT = fullfile(outputDir, namemat);
    if exist(outNameCSV, 'file'); warning('files already exist'); continue; end
    if exist(outNameMAT, 'file'); warning('files already exist'); continue; end
    
    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    EEG = eeg_checkset(EEG);
    
    chanIdx = ismember({EEG.chanlocs.labels}, chanLabels);
    t = dsearchn(EEG.times', timeRange');
    timeIdx = t(1):t(2);
    
    nEpochLabel = numel(epochLabels);
    meanIAF = zeros(n, nEpochLabel);
    
    for iEpochLabel = 1:nEpochLabel
        
        tmp = eeg_getepochevent(EEG, 'type', epochLabels{iEpochLabel});
        nEpoch = size(EEG.data, 3);
        data = EEG.data(chanIdx, timeIdx, (tmp==0));
        data = squeeze(mean(data, 1));
        tmpIAF = zeros(nEpoch, 1);
        
        for iEpoch = 1:nEpoch
            fprintf('epoch %i\n', iEpoch);
            pfo = lix_doPeakFit(data(:, iEpoch), EEG.srate);
            tmpIAF(iEpoch, 1) = pfo.FrequencyBands{1}(13,1);
        end % iEpoch loop ends
        meanIAF(i, iEpochLabel) = mean(tmpIAF);
    end % iEpochLabel loop ends
end % subject loop ends

IAF.id = id;
IAF.var = epochLabels;
IAF.meanIAF = meanIAF;
save(outNameMAT, 'IAF');

%% write file
FID = fopen(outNameCSV, 'w');
firstRow = 'subject';
for iiEpoch = 1:nEpochLabel
    firstRow = [firstRow, ',', epochLabels{iiEpoch}];
end
fprintf(FID, [firstRow, '\n']);
for iiSubj = 1:n
    rowStr = [];    
    rowStr = [rowStr, ',', id{iiSubj}];
   for iiEpoch2 = 1:nEpochLabel
       rowStr = [rowStr, ',', num2str(meanIAF(iiSubj, iiEpoch2))]
   end
   fprintf(FID, [rowStr, '\n']);
end
fclose(FID);

