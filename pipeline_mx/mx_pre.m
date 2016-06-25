clear, clc, close all

baseDir = '~/Desktop/data/'; % 存放数据的根目录
inputDir = fullfile(baseDir, 'raw'); % 输入数据文件夹
outputDir = fullfile(baseDir, 'pre'); % 输出数据文件夹

%% input parameters 一些参数的指派
DS = 250; % 
HP = 1;
MODEL = 'Spherical';
UNUSED = {'VEO', 'HEOR', 'VEOG', 'HEOG',  'TP9', 'TP10'};
CHANTHRESH = 0.5;
REF = 'average';
ONREF = 'FCz';
TIME = [-1, 2]; % epoch time range
MARKS = {'S 11', 'S 12', 'S 13', 'S 14'};
badChanAutoRej = 1;
n_prefix = 2;
% poolsize = 4;

%% channel location files
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

%% prepare datasets
if ~exist(inputDir, 'dir'); disp('inputDir does not exist\n please reset it'); return; end
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
tmp = dir(fullfile(inputDir, '*.eeg'));
fileName = natsort({tmp.name});
nFile = numel(fileName);
ID = get_prefix(fileName, n_prefix);
ID = natsort(unique(ID));

%% Open matlab pool
% if matlabpool('size') == 0
%     matlabpool('local', poolsize);
% elseif matlabpool('size') ~= poolsize
%     matlabpool('close')
%     matlabpool('local', poolsize);
% end

% eeglab_opt;
ALLEEG = []; EEG = []; CURRENTSET = [];
for i = 1:nFile

    % prepare output filename
    name = strcat(ID{i}, '_pre.set');
    outName = fullfile(outputDir, name);
    % check if file exists
    if exist(outName, 'file'); warning('files already exist'); continue; end

    % check file extention
    fileExt = fileName{i}(end-2:end);
    % load dataset
    switch fileExt
      case 'set'
        EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
      case 'eeg'
        EEG = pop_fileio(fullfile(inputDir, fileName{i}));
    end
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
    % remove nonbrain channels
    chanLabels = {EEG.chanlocs.labels};
    idx = find(ismember(chanLabels, UNUSED));
    EEG = pop_select(EEG,'nochannel', idx);
    EEG = eeg_checkset( EEG );
    EEG.etc.origchalocs = EEG.chanlocs; % save original chanlocs
    % downsampling to 250 Hz
    EEG = pop_resample(EEG, DS);
    EEG = eeg_checkset(EEG);
    % high pass filtering: 
    % 1 Hz for better ica results, but not proper for erp study
    EEG = pop_eegfiltnew(EEG, HP, 0);
    EEG = eeg_checkset(EEG);
    % remove bad channels
    if badChanAutoRej
        arg_flatline = 5; % default is 5
        arg_highpass = 'off';
        arg_channel = CHANTHRESH; % default is 0.85
        arg_noisy = 4;
        arg_burst = 'off';
        arg_window = 'off';
        EEG = clean_rawdata(EEG, ...
                            arg_flatline, ...
                            arg_highpass, ...
                            arg_channel, ...
                            arg_noisy, ...
                            arg_burst, ...
                            arg_window);
        % re-reference
        EEG = pop_reref(EEG, []);
        EEG = eeg_checkset(EEG);
    end
    % epoching
    EEG = pop_epoch( EEG, MARKS, TIME, 'epochinfo', 'yes');
%     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off');
    EEG = eeg_checkset( EEG );
    EEG = pop_rmbase( EEG, []);
%     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 
    % save dataset
    EEG = pop_saveset(EEG, 'filename', outName);
    EEG = [];
end