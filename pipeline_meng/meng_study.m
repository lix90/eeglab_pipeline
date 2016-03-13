function meng_study

baseDir = 'F:\meng';
inputDir = 'F:\meng\backproj';
if ~exist(inputDir, 'dir'); disp('inputDir does not exist\n please reset it'); return; end

outputDir = fullfile(baseDir, 'study');
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

%%%%%% study parameters
nameStudy = 'meng_aggression_backproj.study';
nameTask = 'two option oddball';
noteStudy = '1Hz-average';
dipselect = 0.1;
inbrain = 'on';

%%%%%% study design parameters
V1 = {'neutral', 'lowNegative', 'highNegative'};
V2 = {'lowAggression', 'highAggression'};

%%%%%%% prepare data
tmp = dir(fullfile(inputDir, '*.set'));
fileName = natsort({tmp.name});
ID = get_prefix(fileName, 1);
tagGroup = cellfun(@(x) {x(1:2)}, fileName);
g1 = strcmp(tagGroup, 'g1');
g2 = strcmp(tagGroup, 'g2');
tagGroup(g1) = V2(1);
tagGroup(g2) = V2(2);

%%%%%%% load sets
ALLEEG = []; EEG = []; STUDY = [];
EEG = pop_loadset('filename', fileName, 'filepath', inputDir);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'study',0);

% create studycommands cell arrays
studycommands = cell(size(fileName));
for i = 1:numel(fileName)
	studycommands{i} = {'index', i, ...
							'subject', ID{i}, ...
							'group', tagGroup{i}};
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
							'variable2', 'group', 'pairing2', 'off', ...
							'values1', V1, ...
							'values2', V2, ...
							'filepath', outputDir); % type is within, group is between

%%%%%%% save study
STUDY = pop_savestudy(STUDY, EEG, 'filename', nameStudy, 'filepath', outputDir);