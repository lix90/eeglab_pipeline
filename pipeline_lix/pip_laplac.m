%% pipeline: eeg_laplac

% variable
pipName = 'laplac';
poolsize = 4;

% directory
baseDir = '~/Data/yang_select/';
inputDir = fullfile(baseDir, 'ica');
outputDir = fullfile(baseDir, pipName);

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

for i = 1:n

    name = strcat(id{i}, '_', pipName, '.set');
    outName = fullfile(outputDir, name);
    if exist(outName, 'file'); warning('files already exist'); continue; end

    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    EEG = eeg_checkset(EEG);
    
    idxRejICs = find(EEG.reject.gcompreject);
    EEG.etc.numRejICs = numel(idxRejICs);

    %% delete artifactual ICs & compute pval
    % compute pval
    EEG.icaact = eeg_getdatact(EEG, 'component', 1:size(EEG.icaweights, 1));
    [pvaf, pvafs, vars] = eeg_pvaf(EEG, find(~EEG.reject.gcompreject), 'plot', 'off');
    EEG.etc.pvaf = pvaf;
    % delete artifactual ICs
    EEG = pop_subcomp(EEG, idxRejICs, 0);
    EEG = eeg_checkset(EEG);

    %% CSD transform
    laplac = eeg_laplac(EEG, 1);
    laplac = reshape(laplac, [size(EEG.data)]);
    EEG.data = laplac;
    EEG = eeg_checkset(EEG);

    % save
    EEG = pop_saveset(EEG, 'filename', outName);
    EEG = [];
    
end