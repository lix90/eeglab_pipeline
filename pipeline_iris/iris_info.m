%% script for export infomation of channels and epoches

% only suitable for repeated measures design
inputDir = ''; % datasets
outputDir = ''; 
conditions = {'Adult_noPain', 'Adult_Pain', ...
              'Child_noPain', 'Child_Pain', ...
              'Old_noPain', 'Old_Pain'}; % marks

%% code

% check directory
if ~exist(inputDir, 'dir')
    disp('inputDir does not exist\n please reset it'); 
    return
end
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

% prepare filelist
tmp = dir(fullfile(inputDir, '*.set'));
fileName = {tmp.name};
nSubj = numel(fileName);
if size(fileName, 2)>1; fileName = fileName'; end

% prepare output data
csvName = 'datainfo.csv';
outName = fullfile(outputDir, csvName);
if exist(outName, 'file'); warning('files already exist'); continue; end

% variables
output = struct();
output.id = fileName;
nCond = numel(conditions);
nGoodEpoch = zeros(nSubj, nCond); 
nGoodChan = zeros(nSubj, 1);
nGoodICs = zeros(nSubj, 1);
EEG = [];

for i = 1:nSubj
    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    EEG = eeg_checkset(EEG);
    nGoodChan(i, 1) = EEG.nbchan;
    nGoodICs(i, 1) = size(EEG.icaweights, 1);
    for ii = 1:nCond
        tmp = eeg_getepochevent(EEG, 'type', conditions{ii});
        nGoodEpoch(i, ii) = numel(find(tmp==0));
    end
    EEG = [];
end

for iii = 1:nCond
    output.(conditions{iii}) = nGoodEpoch(:, iii);
end

output.goodChan = nGoodChan;
output.goodICs = nGoodICs;

% write
struct2csv(output, outName);
