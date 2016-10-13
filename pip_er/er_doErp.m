% script for manipulate erp data
filedir = '~/Desktop/outErp3.mat';
outputdir = '~/Desktop/';
tag = 'lppEarly';
chan = {'Pz'};
timeRange = [500, 1000];

group1 = {'1canyu', '1caominggui', '1chengchao', '1lijiahao', '1linjinmeng', ...
          '1liubo', '1shilunyong', '1shipeng', '1sunliqiang', '1tangrui', ...
          '1wangyong', '1xingyunlei', '1yangyecheng', '1yangyongbin', '1zhangyabing',...
          's19', 's25', 's26', 's30', 's39yangkai'}; % typical male

group2 = {'2fandong', '2fanxincong', '2guolei', '2huangyu', '2juyongqiang',...
          '2kexiaofeng', '2lixian', '2lizhipeng', '2qinzhaohua', '2qufarui',...
          '2yuxiangjun', '2zhanglongfei', '2zhoulibo', '2zhoumengyuan', '2zhushaoyong',...
          's7', 's8', 's34yangzheng', '3yangbin', '2chengang'}; % untypical male

group3 = {'3aibin', '3chenzuyan', '3huanglingling', '3leishuang', '3lihaiyan', ...
          '3liyin', '3loushuanghui', '3lvfangli', '3matingting', '3pangcanju', ...
          '3ranqiuya', '3wanghuanhuan', '3wushuang', '3xianghuiling', '3yangbin',...
          '3zhengqishan', '4zhaoyin', 's6', 's9', 's17', 's18', 's23', ...
          's40weixinhyan', 's44tiancheng', 's52yufen'}; % typical female

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
          's45zhaijin', 's47zhouxinyu', 's50tangxia', 'Us51zhaoxiaomei', 's54bianxiangyu', ...
          's55jiaruiqin', 's56luodanni'}; % dual

load(filedir);
n = size(erp, 1);

structEmpty = ones(n, 1);
for i = 1:n
    if isempty(erp(i, 1).id)
        structEmpty(i) = 0;
    end
end
erp2 = erp(logical(structEmpty), :);

%%
erpdata = reshape({erp2.data}, size(erp2));
subj = unique({erp2.id});
var = {erp2(1,:).event};
times = erp2(1).times;
chanlocs = erp2(1).chanlocs;
pnts = erp2(1).pnts;
srate = erp2(1).srate;
trials = reshape({erp2.trials}, size(erp2));

srole = zeros(length(subj), 1);
sex = zeros(length(subj), 1);
srole(ismember(subj, union(group1, group4)))=1;
srole(ismember(subj, union(group2, group3)))=2;
srole(ismember(subj, union(group5, group6)))=3;
sex(ismember(subj, union(group1, union(group2, group5))))=1;
sex(ismember(subj, union(group3, union(group4, group6))))=2;

%% subset erp
chanlabels = {erp2(1).chanlocs.labels};
chanROI = ismember(chanlabels, chan);
timeROI = dsearchn(times', timeRange');
erpSubset = ...
    cellfun(@(x) {squeeze(mean(mean(x(chanROI, ...
                                      timeROI(1):timeROI(2)),1),2))}, erpdata);
varCell = [var{:}];
header = {'id', 'srole', 'sex', varCell{:}};
groups = cat(2, srole, sex);
erpCell = num2cellstr(reshape([erpSubset{:}], size(erpSubset)));
erpCellstr = cat(2, subj', num2cellstr(groups), erpCell);
erpOut = cat(1, header, erpCellstr);
% lpp_chan_time.csv
fname = sprintf('%s_%s_f%s.csv', tag, strjoin(chan, '-'), strjoin(timeRange, ...
                                                  '-'));
fnamefull = fullfile(outputdir, fname);
cell2csv(fnamefull, erpOut);
% plot
% s11: free view negative
% s22: suppression
% s33: free view neutral
% s44: cognitive reappraisal
% s55: suppression + cognitive reappraisal
