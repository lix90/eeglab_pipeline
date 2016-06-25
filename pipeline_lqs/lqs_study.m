% set parameters
baseDir = '~/Data/moodPain_final/';
inputDir = fullfile(baseDir, 'interp');
outputDir = inputDir;

nameStudy = 'lqs_gambling.study';
nameTask = 'emotion regulation & gambling';
noteStudy = '1Hz-average';
dipselect = [];
inbrain = [];
tmp = dir(fullfile(inputDir, '*.set'));
setname = natsort({tmp.name});
setname_prefix = get_prefix(setname, 2);

% load sets
ALLEEG = []; EEG = []; STUDY = [];
EEG = pop_loadset('filename', setname, 'filepath', inputDir);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'study',0);

[group, tmp_] = strtok(setname, '_');
[subj, ~] = strtok(tmp_, '_');

% create studycommands cell arrays
studycommands = cell(size(setname));
for i = 1:numel(setname)
		studycommands{i} = {'index', i, ...
                        'subject', subj{i}, ...
                        'group', group{i}};
end

if ~isempty(inbrain) && ~isempty(dipselect)
	studycommands = {studycommands{:}, {'inbrain', inbrain, 'dipselect', dipselect}};
end

[STUDY ALLEEG] = std_editset( STUDY, ALLEEG, ...
                              'name', nameStudy, ...
                              'task', nameTask, ...
                              'notes', noteStudy, ...
                              'commands', studycommands, ...
                              'updatedat', 'on');

% STUDY = std_makedesign(STUDY, ALLEEG, 1, ...
% 					   'variable1', 'condition', 'pairing1', 'on', ...
% 					   'variable2', 'group', 'pairing2', 'on', ...
%                        'values1', V1, 'values2', V2, ...
%                        'filepath', outputDir);

STUDY = pop_savestudy(STUDY, EEG, 'filename', nameStudy, 'filepath', ...
                      outputDir);
