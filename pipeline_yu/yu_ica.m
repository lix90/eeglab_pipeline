%% script for preprocessing: ica

%%%%%% set directory
baseDir = '';
inputDir = fullfile(baseDir, 'pre');
outputDir = fullfile(baseDir, 'ica');
icaDir = fullfile(baseDir, 'icamat');

% epoch rejection
rightRESP = {'S  7'}; % if you do not need to set right reponse, then use [];
baseLine = [-1000, 0];

%%%%%% prepare directory
if ~exist(inputDir, 'dir')
    disp('inputDir does not exist\n please reset it')
    return
end
if ~exist(icaDir, 'dir'); mkdir(icaDir); end
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

%%%%%% prepare datasets
tmp = dir(fullfile(inputDir, '*.set'));
fileName = natsort({tmp.name});
nFile = numel(fileName);
ID = get_prefix(fileName, 1);
ID = natsort(unique(ID));

%%%%%% Open matlab pool
poolsize_check = matlabpool('size');
if poolsize_check==0
    matlabpool('local', poolSize);
elseif poolsize_check > 0 && poolsize_check ~= poolSize
    matlabpool close force;
    matlabpool('local', poolSize);
end

parfor i = 1:nFile
    
    %%%%%% prepare output filename
    name = strcat(ID{i}, '_ica.set');
    outName = fullfile(outputDir, name);
    EEGica = struct();
    icaName = strcat(ID{i}, '_ica.mat');
    icaOutName = fullfile(icaDir, icaName);

    %%%%%% check if file exists
    if exist(outName, 'file'); warning('files already exist'); continue; end
    fprintf('Loading (%i/%i %s)\n', i, nFile, fileName{i});

    %%%%%% load dataset
    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    EEG = eeg_checkset( EEG );
    
    %%%%%% preparing data for ica (reject epoch)
    EEG = rej_epoch(EEG, rightRESP, 'channels');

    %%%%%% run ica
    nbchan = size(EEG.data, 1);
    ref = EEG.ref;
    if ~strcmp(ref, 'averef')
        EEG = pop_runica(EEG, 'extended', 1, 'interupt', 'off');
    else
        EEG = pop_runica(EEG, 'extended', 1, ...
                         'pca', nbchan-1, ...
                         'interupt', 'off');
    end

    %%%%%% save ica matrices
    EEGica.icaweights = EEG.icaweights;
    EEGica.icasphere = EEG.icasphere;
    EEGica.icawinv = EEG.icawinv;
    EEGica.icachansind = EEG.icachansind;
    parsave(icaOutName, EEGica);
    
    %%%%%% baseline correction
    EEG = pop_rmbase(EEG, baseLine);
    EEG = eeg_checkset( EEG );

    %%%%%% save sets
    EEG.setname = strcat(ID{i}, '_ica');
    EEG = pop_saveset(EEG, 'filename', outName); % save set
    EEG = eeg_checkset( EEG ); 
    EEG = [];

end