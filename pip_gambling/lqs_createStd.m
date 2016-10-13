% set parameters
clear, clc
baseDir = '~/Data/lqs_gambling/';
inputDir = fullfile(baseDir, 'rest_preEpoch');
outputDir = inputDir;
fileExtension = 'set';
prefixPosition = 2;
nameTask = 'emotion regulation & gambling';
noteStudy = '';
dipselect = [];
inbrain = [];
group_tag = 'cn';
nameStudy = ['lqs_gambling_', group_tag, '.study'];
[inputFilename, id] = get_fileinfo(inputDir, fileExtension, prefixPosition);

[group, ~] = strtok(id, '_');
idx_group = strcmpi(group, group_tag);
group = group(idx_group);
id = id(idx_group);
inputFilename = inputFilename(idx_group);

% load sets
ALLEEG = []; EEG = []; STUDY = [];
EEG = pop_loadset('filename', inputFilename, 'filepath', inputDir);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'study',0);

% create studycommands cell arrays
studycommands = cell(size(id));
for i = 1:numel(id)
    studycommands{i} = {'index', i, ...
                        'subject', id{i}, ...
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
