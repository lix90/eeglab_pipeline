%% parameters initialization
% prepare directory
baseDir = '~/Data/gender-role-emotion-regulation/'; % directory storing data
inputDir = fullfile(baseDir, 'merge'); % input directory: 'merge' or 'raw'
outputDir = fullfile(baseDir, 'erp');
pre_dir = fullfile(baseDir, 'pre');
ica_dir = fullfile(baseDir, 'dipfit');

% preprocessing parameters
DS			= 250; % downsampling frequency
HP 			= 0.1; 
MODEL  	= 'Spherical'; % channel loacation file type 'Spherical' or 'MNI'
UNUSED	= {'HEOL', 'HEOR', 'VEOD',...
           'VEOU', 'M2', 'VEO', ...
           'TP9', 'TP10', 'HEOG', 'VEOG', 'M1'};

% epoching parameters
REF = 'average'; % offline rereference electrodes
EPOCHTIME = [-1, 5]; % epoch time range
FROM	= {'S 11', 'S 22', 'S 33', 'S 44', 'S 55'}; % original marks of
                                                    % stimulus
TO = {'free', 'suppresion', 'change_view', 'free_neutral', 'change_suppression'};
CHANGE = true;

% check directory
if ~exist(inputDir, 'dir')
    disp('inputDir does not exist\n please reset it'); 
    return
end
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

% channel location files
switch MODEL
  case 'MNI'
    locFile = 'standard_1005.elc';
  case 'Spherical'
    locFile = 'standard-10-5-cap385.elp';
end
locDir = which(locFile);
if ispc
    locDir = strrep(locDir, '\', '/');
end

% prepare datasets
tmp = dir(fullfile(inputDir, '*.set'));
fileName1 = natsort({tmp.name});
tmp2 = dir(fullfile(inputDir, '*.eeg'));
fileName2 = natsort({tmp2.name});
fileName = natsort(union(fileName1, fileName2));
nFile = numel(fileName);
ID = get_prefix(fileName, 2);
ID = natsort(unique(ID));

tmp_pre = dir(fullfile(pre_dir, '*.set'));
pre_filename = natsort({tmp_pre.name});
ID_pre = natsort(unique(get_prefix(pre_filename, 2)));

tmp_ica = dir(fullfile(ica_dir, '*.set'));
ica_filename = natsort({tmp_ica.name});
ID_ica = natsort(unique(get_prefix(ica_filename, 2)));

% check subj number
if numel(pre_filename)==numel(ica_filename) && numel(pre_filename)==nFile
    disp('go on');
else
    disp('The number of subjects dismatch');
    setdiff(ID, ID_pre)
    setdiff(ID, ID_ica)
    return
end

% start for loop
for i = 1:nFile

    fileExt = fileName{i}(end-2:end);
    EEG = [];
    name = strcat(ID{i}, '_erp.set');
    outName = fullfile(outputDir, name);
    if exist(outName, 'file'); warning('files already exist'); continue; end
    
    % load dataset
    switch fileExt
      case 'set'
        EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
      case 'eeg'
        EEG = pop_fileio(fullfile(inputDir, fileName{i}));
    end
    EEG = eeg_checkset(EEG);

    % add channel locations
    EEG = pop_chanedit(EEG, 'lookup', locDir); % add channel location
    EEG = eeg_checkset(EEG);
    
    nbchan = size(EEG.data, 1);
    
    chanlabels = {EEG.chanlocs.labels};
    
    if any(ismember(chanlabels, {'M2'}))
        ONREF = [];
    else
        ONREF = 'FCz';
    end
    
    if ~isempty(ONREF)
        % add online reference
        EEG = pop_chanedit(EEG, 'lookup', locDir); % add channel location
        EEG = eeg_checkset(EEG);
        nchan = size(EEG.data, 1);
        EEG = pop_chanedit(EEG, 'append', nchan, ...
                           'changefield',{nchan+1, 'labels', ONREF}, ...
                           'lookup', locDir, ...
                           'setref',{['1:',int2str(nchan+1)], ONREF}); % add online reference
        EEG = eeg_checkset(EEG);
        outStruct = chanLocCreate(ONREF, nchan+1);
        EEG = pop_reref(EEG, [], 'refloc', outStruct); % retain online reference data back
        EEG = eeg_checkset(EEG);
        EEG = pop_chanedit(EEG, 'lookup', locDir, 'setref',{['1:', int2str(size(EEG.data, 1))] 'average'});
        EEG = eeg_checkset(EEG);
        chanlocs = pop_chancenter(EEG.chanlocs, []);
        EEG.chanlocs = chanlocs;
        EEG = eeg_checkset(EEG);
    end
    % remove nonbrain channels
    chanLabels = {EEG.chanlocs.labels};
    idx = find(ismember(chanLabels, UNUSED));
    EEG = pop_select(EEG, 'nochannel', idx);
    EEG = eeg_checkset(EEG);

    % downsampling
    EEG = pop_resample(EEG, DS);
    EEG = eeg_checkset(EEG);

    % high pass filtering: 
    % 1 Hz for better ica results, but not proper for erp study
    EEG = pop_eegfiltnew(EEG, HP, []); 
    EEG = eeg_checkset(EEG);
    
    % re-reference
    if iscellstr(REF)
        chanLabels = {EEG.chanlocs.labels};
        indRef = find(ismember(chanLabels, REF));
        EEG = pop_reref(EEG, indRef);
    end
    EEG = eeg_checkset(EEG);
    
    % change events
    EEG = lix_change_event(EEG, FROM, TO);
    EEG = pop_epoch(EEG, TO, EPOCHTIME);
    EEG = eeg_checkset(EEG);    
    
    % mark artifactual epoches
    EEG2 = pop_loadset('filename', pre_filename{i}, 'filepath', pre_dir);
    EEG3 = pop_loadset('filename', ica_filename{i}, 'filepath', ica_dir);
    
    % remove bad channels
    goodChans = {EEG3.chanlocs.labels};
    badChans = setdiff({EEG.chanlocs.labels}, goodChans);
    idxBadChans = find(ismember({EEG.chanlocs.labels}, badChans));
    EEG = pop_select(EEG,'nochannel', idxBadChans);
    EEG = eeg_checkset(EEG);
    
    % if average reference, rereference again
    if strcmp(REF, 'average')
        EEG = pop_reref(EEG, []);
        EEG = eeg_checkset(EEG);
    end
    
    reject = EEG2.reject.rejmanual + EEG2.reject.rejkurt + EEG2.reject.rejjp;
    idx_rej = find(reject);
    EEG = eeg_checkset(EEG);
    
    EEG = pop_select(EEG, 'notrial', idx_rej);
    EEG = eeg_checkset(EEG);
    
    EEG = pop_rmbase(EEG, []);
    EEG = eeg_checkset(EEG);
    
    EEG2 = [];
    
    %% add icamat
    
    EEG.icaweights = EEG3.icaweights;
    EEG.icasphere = EEG3.icasphere;
    EEG.icawinv = EEG3.icawinv;
    EEG.icachansind = EEG3.icachansind;
    EEG = eeg_checkset( EEG );
        
    %% add badICs
    EEG.reject.gcompreject = EEG3.reject.gcompreject;
    EEG = eeg_checkset(EEG);
    EEG3 = [];
    
    % save dataset
    EEG = pop_saveset(EEG, 'filename', outName);
    
end

