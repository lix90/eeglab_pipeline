% function iris_study
clear, clc
inputDir = '/home/lix/data/iris-age-pain/ica/';
if ~exist(inputDir, 'dir'); disp('inputDir does not exist\n please reset it'); return; end

outputDir = inputDir;
% if ~exist(outputDir, 'dir'); mkdir(outputDir); end

%%%%%% study parameters
nameStudy = 'iris_pain.study';
nameTask = 'pain empathy';
noteStudy = '1Hz-average';
dipselect = [];
inbrain = [];

%%%%%% study design parameters
V1			= {'Adult_Pain', 'Adult_noPain', ...
		   		'Child_Pain', 'Child_noPain', ...
		   		'Old_Pain', 'Old_noPain'};

%%%%%%% prepare data
tmp = dir(fullfile(inputDir, '*.set'));
fileName = natsort({tmp.name});
ID = get_prefix(fileName, 1);
% tagGroup = cellfun(@(x) {x(1:2)}, fileName);
% g1 = strcmp(tagGroup, 'g1');
% g2 = strcmp(tagGroup, 'g2');
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
							'filepath', inputDir); % type is within

%%%%%%% save study
STUDY = pop_savestudy(STUDY, EEG, 'filename', nameStudy, 'filepath', outputDir);