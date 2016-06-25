function er_study(igroup)
base_dir = '~/Data/gender-role-emotion-regulation/';
in_dir = fullfile(base_dir, 'erp');
ou_dir = in_dir;

name_study = sprintf('gender_role_emo_er_group%i.study', igroup);
name_task = 'gender_role_emo_er';
note_study = 'gender role emotion regulation';
dipselect = [];
inbrain = [];
v1 = {'free', 'suppresion', 'change_view', 'free_neutral', 'change_suppression'};
tmp = dir(fullfile(in_dir, '*.set'));
filename = sort({tmp.name});
filename_prefix = get_prefix(filename, 1);

% grouping
group1 = {'1canyu', '1caominggui', '1chengchao', '1lijiahao', '1linjinmeng', ...
          '1liubo', '1shilunyong', '1shipeng', '1sunliqiang', '1tangrui', ...
          '1wangyong', '1xingyunlei', '1yangyecheng', '1yangyongbin', '1zhangyabing',...
          's19', 's25', 's26', 's30', 's39yangkai'}; % typical male
group2 = {'2fandong', '2fanxincong', '2guolei', '2huangyu', '2juyongqiang',...
          '2kexiaofeng', '2lixian', '2lizhipeng', '2qinzhaohua', '2qufarui',...
          '2yuxiangjun', '2zhanglongfei', '2zhoulibo', '2zhoumengyuan', '2zhushaoyong',...
          's7', 's8', 's34yangzheng', '3yangbin'}; % untypical male
group3 = {'3aibin', '3chenzuyan', '3huanglingling', '3leishuang', '3lihaiyan', ...
          '3liyin', '3loushuanghui', '3lvfangli', '3matingting', '3pangcanju', ...
          '3ranqiuya', '3wanghuanhuan', '3wushuang', '3xianghuiling', '3yangbin',...
          '3zhengqishan', '4zhaoyin', 's6', 's9', 's17', 's18', 's23', ...
          's40weixinhyan', 's44tiancheng', 's52yufeng'}; % typical female
group4 = {'4fanglu', '4fanqing', '4fengzuojia', '4haomeiyu', '4jiangxianghe', ...
          '4lihui', '4liuxiaofei', '4ouxianmin', '4tansiyuan', '4wangrongyan',...
          '4wangyamin', '4xiaoyuting', '4xudong', '4xuliyin', '4yangyejun', ...
          '4zhouhaixia', '4zhouhong', 's12', 's14', 's31weihaishu'}; % untypical female
group5 = {'s3', 's4', 's5', 's11', 's15', 's21', 's24',...
         's28', 's29', 's32renpu', 's36tianbin', 's41luokangshun', ...
         's43douqiang', 's46', 's48zhaotingkun', 's49liuyong',...
         's57longjie', 's58kuangyuxuan'};
group6 = {'s10', 's13', 's16', 's22', 's27', ...
          's33wangguomei', 's35wangyuhui', 's37yanhui', 's38huangxiaolin', 's42mawenyan', ...
          's45zhaijin', 's47zhouxinyu', 's50tangxia', 'Us51zhaoxiaomei', 's54bianxiaoyu', ...
          's55jiaruiqin', 's56luodanni'}; % dual

switch igroup
  case 1
    grouping = cell(size(group1));
    grouping(ismember(filename_prefix, group1)) = {'dx_male'};
    setname = sort(filename(ismember(filename_prefix, group1)));
    subjs = sort(group1);
  case 2
    grouping = cell(size(group2));
    grouping(ismember(filename_prefix, group2)) = {'fdx_male'};
    setname = sort(filename(ismember(filename_prefix, group2)));
    subjs = sort(group2);
  case 3
    grouping = cell(size(group3));
    grouping(ismember(filename_prefix, group3)) = {'dx_female'};
    setname = sort(filename(ismember(filename_prefix, group3)));
    subjs = sort(group3);
  case 4
    grouping = cell(size(group4));
    grouping(ismember(filename_prefix, group4)) = {'fdx_female'};
    setname = sort(filename(ismember(filename_prefix, group4)));
    subjs = sort(group4);
  case 5
    grouping = cell(size(group5));
    grouping(ismember(filename_prefix, group5)) = {'sxh_male'};
    setname = sort(filename(ismember(filename_prefix, group5)));
    subjs = sort(group5);
  case 6
    grouping = cell(size(group6));
    grouping(ismember(filename_prefix, group5)) = {'sxh_female'};
    setname = sort(filename(ismember(filename_prefix, group6)));
    subjs = sort(group6);
end
% load sets
ALLEEG = []; EEG = []; STUDY = [];
EEG = pop_loadset('filename', setname, 'filepath', in_dir);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'study',0);

studycommands = cell(size(setname));
for i = 1:numel(setname)
    studycommands{i} = {'index', i, 'subject', subjs{i}};
end
if ~isempty(inbrain) && ~isempty(dipselect)
	studycommands = {studycommands{:}, {'inbrain', inbrain, 'dipselect', dipselect}};
end
[STUDY ALLEEG] = std_editset( STUDY, ALLEEG, ...
                              'name', name_study, ...
                              'task', name_task, ...
                              'notes', note_study, ...
                              'commands', studycommands, ...
                              'updatedat', 'on');
% STUDY = std_makedesign(STUDY, ALLEEG, 1, ...
%                        'variable1', 'condition', 'pairing1', 'on', ...
%                        'variable2', 'group', 'pairing2', 'on', ...
%                        'values1', V1, 'values2', V2, ...
%                        'filepath', outputDir);
STUDY = pop_savestudy(STUDY, EEG, 'filename', name_study, 'filepath', ou_dir);
