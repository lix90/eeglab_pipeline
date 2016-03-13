%% yangjm's pain empathy experiment
%  data analysis pipeline
%  create study
%%%%%% directory settings
baseDir = '~/Data/yang_select';
inputDir = fullfile(baseDir, 'whole_back');
outputDir = fullfile(baseDir, 'study');

%%%%%% study parameters
nameStudy = 'yang_pain_empathy_back_whole.study';
nameTask = 'pain empathy';
noteStudy = '1Hz-average';
dipselect = 0.15;
inbrain = 'on';

%%%%%% study design parameters
V = { 'Neg_noPain', 'Neg_Pain', ...
      'Neu_noPain', 'Neu_Pain', 'Pos_Pain', 'Pos_noPain',};
S = {'caihuayu', 'chenfang', 'chenxu', 'dengguirong', 'dingsanpeng', ...
    'huniping', 'jiaming', 'liangbaishun', 'liangnian', 'liushuang', ...
    'liuyanan', 'longfan', 'mazhen', 'wangdan', 'wangjiangbo', ...
     'xujin', 'yuanbingtao', 'yuanjianmei', 'yueliang', 'zhangting', ...
    'zhangyandi', 'zhoujiahua'};

%%%%%%% prepare data
if ~exist(inputDir, 'dir'); disp('inputDir does not exist\n please reset it'); return; end
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
tmp = dir(fullfile(inputDir, '*.set'));
fileName = natsort({tmp.name});
ID = get_prefix(fileName, 1);
[x, ia, ib] = intersect(ID, S);
fileName = fileName(ia);
ID = ID(ia);

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
                       'values1', V, ...
                       'filepath', outputDir); % type is within, group is between

%%%%%%% save study
STUDY = pop_savestudy(STUDY, EEG, 'filename', nameStudy, 'filepath', ...
                      outputDir);
eeglab redraw;