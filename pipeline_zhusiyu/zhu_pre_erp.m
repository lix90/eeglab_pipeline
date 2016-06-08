% function zhu_pre
%% pipeline codes for analysing eeg data of iris' pain empathy experiment

%%%%%% set directory
baseDir = 'E:\Thelma_lo\zhu';
inputDir = 'E:\Thelma_lo\zhu\merge';
if ~exist(inputDir, 'dir'); disp('inputDir does not exist\n please reset it'); return; end
infoDir = fullfile(baseDir, 'outputInfo');
load(fullfile(infoDir, 'goodChans.mat'));
load(fullfile(infoDir, 'badTrials.mat'));
load(fullfile(infoDir, 'badICs.mat'));
icaDir = fullfile(baseDir, 'icamat');

outputDir = fullfile(baseDir, 'ica_erp');
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

%%%%%% preprocessing parameters
DS			= 250; % downsampling
HP 			= 0.1;
MODEL 		= 'Spherical'; % channel loacation file type 'Spherical' or 'MNI'
UNUSED	= {'VEO', 'HEOR'}; % lin
CHANTHRESH = 0.5;
%%% epoching parameters
REF			= {'TP9', 'TP10'};
ONREF 		= 'FCz';
CHANGE 	= true; % change event name
EPOCHTIME = [-1, 2]; % epoch time range
FROM 		= {'S  3', 'S  6', 'S  7'}; 
TO			= {'self_name', 'same_surname', 'different_surname'};
STIM 		= FROM;
RESP 		= [];

%%%%%% channel location files
switch MODEL
    case 'MNI'
        locFile = 'standard_1005.elc';
    case 'Spherical'
        locFile = 'standard-10-5-cap385.elp';
end
locDir = dirname(which(locFile));

%%%%%% prepare datasets
tmp = dir(fullfile(inputDir, '*.set'));
fileName = natsort({tmp.name});
nFile = numel(fileName);
ID = get_prefix(fileName, 1);
ID = natsort(unique(ID));

%%%%%% start for loop
for i = 1:nFile
    %% prepare output filename
    name = strcat(ID{i}, '_ica.set');
    outName = fullfile(outputDir, name);
    
    %% check if file exists
    if exist(outName, 'file'); warning('files already exist'); continue; end
    
    %% load dataset
    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    EEG = eeg_checkset(EEG);
    
    %% add channel locations
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
    
    %% remove nonbrain channels
    chanLabels = {EEG.chanlocs.labels};
    if ~strcmp(fileName{i}, 's5.set')
        idx = lix_elecfind(chanLabels, UNUSED);
        EEG = pop_select(EEG,'nochannel', idx);
        EEG = eeg_checkset( EEG );
    else
        chanLabels = {EEG.chanlocs.labels};
        idx = lix_elecfind(chanLabels, {'VEOG', 'HEOG'});
        EEG = pop_select(EEG,'nochannel', idx);
        EEG = eeg_checkset( EEG );
    end
    
    %% remove bad channels
    badChans = setdiff({EEG.chanlocs.labels}, goodChans{i});
    idxBadChans = find(ismember({EEG.chanlocs.labels}, badChans));
    EEG = pop_select(EEG,'nochannel', idxBadChans);
    EEG = eeg_checkset( EEG );
    
    %% downsampling to 250 Hz
    EEG = pop_resample(EEG, DS);
    EEG = eeg_checkset(EEG);
    
    %% high pass filtering: 1 Hz for better ica results, but not proper for erp study
    EEG = pop_eegfiltnew(EEG, HP, []);
    EEG = eeg_checkset(EEG);
    
    %% re-reference
    chanLabels = {EEG.chanlocs.labels};
    if strcmpi(REF, 'average')
        EEG = pop_reref(EEG, []);
    elseif iscellstr(REF)
        indRef = lix_elecfind(chanLabels, REF);
        EEG = pop_reref(EEG, indRef);
    end
    EEG = eeg_checkset(EEG);
    
    %% change events
    EEG = readable_event(EEG, RESP, STIM, CHANGE, FROM, TO);
    
    %% epoch
    if CHANGE
        MARKS = unique(TO);
    else
        MARKS = unique(FROM);
    end
    EEG = pop_epoch(EEG, MARKS, EPOCHTIME);
    EEG = eeg_checkset(EEG);
    
    %% mark artifactual epoches
    rejmanual = badTrials{i}{1};
    EEG = eeg_checkset( EEG );
    EEG = pop_select(EEG,'notrial', find(rejmanual));
    EEG = eeg_checkset(EEG);
    
    EEG = pop_rmbase(EEG, []);
    EEG = eeg_checkset(EEG);
    
    %% add icamat
    load(fullfile(icaDir, sprintf('%s_ica.mat', ID{i})));
    EEG.icaweights = y.icaweights;
    EEG.icasphere = y.icasphere;
    EEG.icawinv = y.icawinv;
    EEG.icachansind = y.icachansind;
    EEG = eeg_checkset( EEG );
    
    %% add badICs
    EEG.reject.gcompreject = badICs{i};
    EEG = eeg_checkset(EEG);
    %% save dataset
    EEG = pop_saveset(EEG, 'filename', outName);
    EEG = [];
    
end

