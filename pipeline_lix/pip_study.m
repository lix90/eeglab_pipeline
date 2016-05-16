%% pipepline: create study

baseDir = '~/Data/moodPain_final/';
inputDir = fullfile(baseDir, 'spherical');
outputDir = inputDir;

nameStudy = 'painEmpathy_final.study';
nameTask = 'pain empathy';
noteStudy = '1Hz-average';
dipselect = [];
inbrain = [];
V1 = {'Neg_noPain', 'Neg_Pain', 'Neu_noPain', 'Neu_Pain', 'Pos_noPain', 'Pos_Pain'};
% V2 = {'high_freq', 'low_freq'};

if ~exist(inputDir, 'dir'); disp('inputDir does not exist\n please reset it'); return; end
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

%%%%%%% prepare data
tmp = dir(fullfile(inputDir, '*.set'));
fileName = natsort({tmp.name});
ID = get_prefix(fileName, 1);
% tagGroup = cell(numel(ID), 1);
% g1 = ismember(ID, HF);
% g2 = ismember(ID, LF);
% tagGroup(g1) = V2(1);
% tagGroup(g2) = V2(2);

%%%%%%% load sets
ALLEEG = []; EEG = []; STUDY = [];
EEG = pop_loadset('filename', fileName, 'filepath', inputDir);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'study',0);

% create studycommands cell arrays
studycommands = cell(size(fileName));
for i = 1:numel(fileName)
    studycommands{i} = {'index', i, ...
                        'subject', ID{i}};
end

if ~isempty(inbrain) && ~isempty(dipselect)
	studycommands = {studycommands{:}, {'inbrain', inbrain, 'dipselect', dipselect}};
end

%%%%%%% create study
[STUDY ALLEEG] = std_editset( STUDY, ALLEEG, ...
                              'name', nameStudy, ...
                              'task', nameTask, ...
                              'notes', noteStudy, ...
                              'commands', studycommands, ...
                              'updatedat', 'on');

%%%%%%% change design
STUDY = std_makedesign(STUDY, ALLEEG, 1, ...
                       'variable1', 'type', 'pairing1', 'on', ...
                       'values1', V1, ...
                       'filepath', outputDir);

%%%%%%% save study
STUDY = pop_savestudy(STUDY, EEG, 'filename', nameStudy, 'filepath', outputDir);
