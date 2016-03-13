%% pipeline: compute pvaf

% variable
pipName = 'pvaf';
poolsize = 4;

% directory
baseDir = '~/data/yang_select/';
inputDir = fullfile(baseDir, 'ica');
outputDir = fullfile(baseDir, pipName);

%% code

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
if size(id, 2)>1; id = id'; end

% matlabpool
% if matlabpool('size') < poolsize
%     matlabpool('local', poolsize);
% end
nameCSV = strcat(pipName, '.csv');
nameMAT = strcat(pipName, '.mat');
outNameCSV = fullfile(outputDir, nameCSV);
outNameMAT = fullfile(outputDir, nameMAT);
if exist(outNameCSV, 'file'); warning('files already exist'); continue; end
if exist(outNameMAT, 'file'); warning('files already exist'); continue; end

pvafALL = cell(n, 1);
pvafsALL = pvafALL;
chanLabels = pvafsALL;
out = struct();

for i = 1:n

    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    EEG = eeg_checkset(EEG);
    
    goodICs = find(EEG.reject.gcompreject);
    artICs = find(~EEG.reject.gcompreject);
    
    % compute pval
    EEG.icaact = eeg_getdatact(EEG, 'component', 1:size(EEG.icaweights, 1));
    [pvaf, pvafs, vars] = eeg_pvaf(EEG, goodICs, 'plot', 'off');
    pvafALL{i, 1} = pvaf;
    pvafsALL{i, 1} = pvafs;
    chanLabels(i, 1) = {EEG.chanlocs.labels};
    
    EEG = [];
    
end

out.id = id;
out.pvaf = pvafALL;
out.pvafs = pvafsALL;
out.chanLabels = chanLabels;
% save mat
save(outNameMAT, out);
% write csv
% struct2csv(out, outNameCSV);