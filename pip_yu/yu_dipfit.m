%%%%%% set directory
baseDir = '';
inputDir = fullfile(baseDir, 'ica');
outputDir = fullfile(baseDir, 'spherical');
poolsize = 4;

%%%%%% prepare datasets
if ~exist(inputDir, 'dir'); disp('inputDir does not exist\n please reset it'); return; end
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
tmp = dir(fullfile(inputDir, '*.set'));
fileName = natsort({tmp.name});
nFile = numel(fileName);
ID = get_prefix(fileName, 2);
ID = natsort(unique(ID));

%%%%%% Open matlab pool
if matlabpool('size')<poolsize
    matlabpool('local', poolsize);
end

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

parfor i = 1:nFile

    %%%%%% prepare output filename
    name = strcat(ID{i}, '_dipfit.set');
    outName = fullfile(outputDir, name);

    %%%%%% check if file exists
    if exist(outName, 'file'); warning('files already exist'); continue; end
    fprintf('Loading (%i/%i %s)\n', i, nFile, fileName{i});

    %%%%%% load dataset
    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG = eeg_checkset( EEG );

    %% remove artifactual ICs (of eyes)
    artICs = find(EEG.reject.gcompreject);
    EEG = pop_subcomp(EEG, artICs, 0);
    EEG = eeg_checkset(EEG);
    if isempty(EEG.icaact)
        EEG.icaact = eeg_getdatact(EEG, 'component', 1:size(EEG.icaweights, 1));
    end
    EEG = eeg_checkset(EEG);

    %%%%%% dipfitting
    nbcomp = size(EEG.icaact, 1);
    nbchan = size(EEG.data, 1);
    EEG = pop_dipfit_settings( EEG, 'hdmfile','F:\\eeglab_new\\plugins\\dipfit2.3\\standard_BESA\\standard_BESA.mat','coordformat','Spherical','mrifile','F:\\eeglab_new\\plugins\\dipfit2.3\\standard_BESA\\avg152t1.mat','chanfile','F:\\eeglab_new\\plugins\\dipfit2.3\\standard_BESA\\standard-10-5-cap385.elp','chansel',[1:nbchan] );
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    EEG = pop_dipfit_gridsearch(EEG, [1:nbcomp] ,[-85:17:85] ,[-85:17:85] ,[0:17:85] ,1);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    EEG = pop_multifit(EEG, [1:nbcomp] ,'threshold',100,'plotopt',{'normlen' 'on'});
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    EEG = eeg_checkset(EEG);
    
    %%%%%% save sets
    EEG.setname = strcat(ID{i}, '_dipfit');
    EEG = pop_saveset(EEG, 'filename', outName); % save set
    EEG = eeg_checkset( EEG );
    EEG = [];

end