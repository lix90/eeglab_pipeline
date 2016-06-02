%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
baseDir = '~/Data/moodPain_final/';
inputDir = fullfile(baseDir, 'single_rv15_2_csd');
outputDir = inputDir;

nvar = 2; % number of variables
nameStudy = 'painEmpathy_rv15_2_csd.study';
nameTask = 'pain empathy';
noteStudy = '1Hz-average';
dipselect = [];
inbrain = [];
V1 = {'Neg', 'Neu', 'Pos'};
V2 = {'noPain', 'Pain'};
tmp = dir(fullfile(inputDir, '*.set'));
setname = natsort({tmp.name});
setname_prefix = get_prefix(setname, 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% start
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load sets
ALLEEG = []; EEG = []; STUDY = [];
EEG = pop_loadset('filename', setname, 'filepath', inputDir);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'study',0);

[sb, sb_remain] = strtok(setname, '_');
[con, con_remain] = strtok(sb_remain, '_');
[grp, grp_remain] = strtok(con_remain, '_');
[grp, grp_remain] = strtok(grp, '.');
% create studycommands cell arrays
studycommands = cell(size(setname));
switch nvar
  case 0
	for i = 1:numel(setname)
		studycommands{i} = {'index', i, ...
                            'subject', sb{i}};
 end	
  case 1
	for i = 1:numel(setname)
		studycommands{i} = {'index', i, ...
                            'subject', sb{i}, ...
                            'condition', con{i}};
 end	
  case 2
	for i = 1:numel(setname)
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
