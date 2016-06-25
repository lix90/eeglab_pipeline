%% cluster ersp
clear erpData erpTimes erpFreqs
outdir = 'D:\Copy\Copy\output_iris\erp'; % output directory
if ~exist(outdir, 'dir'); mkdir(outdir); end
% c = 9; % cluster number or channel labels
% c = {'F1', 'Fz', 'F2'};
c = {'POz'};
% c = {'C3', 'C1', 'Cz', 'C2', 'C4'};
% c = {'C3', 'C1'};
% c = {'C2', 'C4'};
% c = {'P4', 'P6', 'P8', 'PO4', 'PO8', 'O2'};
% c = {'P1', 'Pz', 'P2', 'PO3', 'POz', 'PO4', 'Oz'};
% f = {[3 7], [8 13], [14 30]}; % freq range
f = {[3 5],[5 7],[8 10],[10 12],[12 14],[15 25]}; % freq range
% r = {'theta'; 'alpha'; 'beta'};
r = {'theta1'; 'theta2'; 'alpha1'; 'alpha2'; 'alpha3'; 'beta'};
% v = {'Negative', 'Neutral', 'Positive'};
v = {'Adult', 'Child', 'Old'};
% t = {[400 800]};
% t1 = 0:100:900;
% t2 = 100:100:1000;
t1 = 0:10:990;
t2 = 10:10:1000;
t = [t1; t2]';
tNew = cell(size(t, 1), 1);
for iRow = 1:size(t,1)
   tNew{iRow} = t(iRow, :); 
end
t = tNew; % time range
%%
% change design
CONDS = {'Adult_Pain' 'Adult_noPain' 'Child_Pain' ...
		 'Child_noPain' 'Old_Pain' 'Old_noPain'};
% CONDS = {'Neg_Pain' 'Neg_noPain' 'Neu_Pain' ...
		 % 'Neu_noPain' 'Pos_Pain' 'Pos_noPain'};
% load study
studyName = 'age_pain_empathy_backproj.study';
% studyName = 'age_pain_empathy_backproj.study';
% studyDir = '~/Documents/data/iris/backproj';
studyDir = 'F:\iris_pain\study';
if ~any(strcmp(who, 'STUDY')) || isempty(STUDY)
    [STUDY ALLEEG] = pop_loadstudy('filename', studyName, 'filepath', studyDir);
    [STUDY ALLEEG] = std_checkset(STUDY, ALLEEG);
    CURRENTSTUDY = 1; 
    EEG = ALLEEG; 
    CURRENTSET = 1:length(EEG);
end
if ~isequal(STUDY.design.variable(1).value, CONDS)
    STUDY = std_makedesign(STUDY, ALLEEG, 1, ...
                           'variable1', 'type', 'pairing1', 'on', ...
                           'values1', CONDS);
    STUDY = pop_savestudy(STUDY, EEG, 'savemode', 'resave');
end
%%
if iscellstr(c)
        TypeName = 'channels';
        if numel(c)==1
            chanName = c{1};
        elseif numel(c)>=2
            chanName = cellstrcat(c, '-');
        end
        filename_prefix = ['chan', chanName];
elseif isnumeric(c)
        TypeName = 'clusters';
        filename_prefix = ['clust', int2str(c)];
end
filename = strcat(filename_prefix, '_erp_10ms.csv');
output_filename = fullfile(outdir, filename);
%
[STUDY, erpData, erpTimes] = std_erpplot(STUDY, ALLEEG, ...
            'channels', c, ...
            'noplot', 'on', 'averagechan', 'on');

subj = STUDY.subject;
%%
erpDiff = {erpData{1}-erpData{2}
            erpData{3}-erpData{4}
            erpData{5}-erpData{6}};
Ns = numel(subj);
Nv = numel(v);
Nt = numel(t);
erpOut = zeros(Nt, Ns, Nv);
for iV = 1:Nv
    for iT = 1:Nt
            t_now = dsearchn(erpTimes', t{iT}');
            tmp = erpDiff{iV}(t_now(1):t_now(2), :);
            tmp = squeeze(mean(tmp,1));
            erpOut(iT,:,iV) = tmp;
    end
end
%%
erp = permute(erpOut, [2, 3, 1]);
erp = erp(:);
Subject = repmat(subj, 1, Nt*Nv)';
Variable = repmat(v', [Nt, Ns])'; Variable = Variable(:);
Time = cell(Nt, 1);
for itt = 1:Nt
    Time{itt} = strcat('t', int2str(t{itt}(1)), 'to', int2str(t{itt}(2)));
end
Time = repmat(Time, [1, Ns*Nv])'; Time = Time(:);
output.Subject = Subject; 
output.Variable = Variable; 
output.Time = Time; 
output.erp = erp;
struct2csv(output, output_filename); clear output
disp('done')