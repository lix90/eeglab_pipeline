% set parameters
baseDir = '~/data/pain/';
inputTag = 'single';
fileExtension = 'set';
prefixposition = 1;

nvar = 2; % number of variables
nameStudy = 'painEmpathy.study';
nameTask = 'pain empathy';
noteStudy = 'average of mastoids';
dipselect = [];
inbrain = [];
V1 = {'neg', 'neu', 'pos'};
V2 = {'nopain', 'pain'};

inputDir = fullfile(baseDir, inputTag);
outputDir = inputDir;
[inputFilename, id] = getFileInfo(inputDir, fileExtension, prefixPosition)

% load sets
ALLEEG = []; EEG = []; STUDY = [];
EEG = pop_loadset('filename', inputFilename, 'filepath', inputDir);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'study',0);

[sb, sb_remain] = strtok(inputFilename, '_');
[con, con_remain] = strtok(sb_remain, '_');
[grp, grp_remain] = strtok(con_remain, '_');
[grp, grp_remain] = strtok(grp, '.');
% create studycommands cell arrays
studycommands = cell(size(id));
switch nvar
  case 0
	for i = 1:numel(inputFilename)
		studycommands{i} = {'index', i, ...
                            'subject', sb{i}};
 end	
  case 1
	for i = 1:numel(inputFilename)
		studycommands{i} = {'index', i, ...
                            'subject', sb{i}, ...
                            'condition', con{i}};
 end	
  case 2
	for i = 1:numel(inputFilename)
		studycommands{i} = {'index', i, ...
                            'subject', sb{i}, ...
                            'condition', con{i}, ...
                            'group', grp{i}};
 end
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
