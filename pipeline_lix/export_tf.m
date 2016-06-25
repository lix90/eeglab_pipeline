%% script for exporting erspROI
c = {'Cz'}; % cluster number or channel labels
f = [10 14]; % freq range
t = [800 1000];
dataFormat = 'long';

outDir = 'E:\iris_channel_output'; % output directory
CONDITIONS = {'Adult_Pain' 'Adult_noPain' 'Child_Pain' ...
              'Child_noPain' 'Old_Pain' 'Old_noPain'};
studyName = 'age_pain_empathy_backproj.study';
studyDir = 'E:\iris-age-pain';

%% check if study is loaded
if ~any(strcmp(who, 'STUDY')) || isempty(STUDY)
    [STUDY ALLEEG] = pop_loadstudy('filename', studyName, 'filepath', studyDir);
    [STUDY ALLEEG] = std_checkset(STUDY, ALLEEG);
    CURRENTSTUDY = 1; 
    EEG = ALLEEG; 
    CURRENTSET = 1:length(EEG);
end
if ~isequal(STUDY.design.variable(1).value, CONDITIONS)
    STUDY = std_makedesign(STUDY, ALLEEG, 1, ...
                           'variable1', 'type', 'pairing1', 'on', ...
                           'values1', CONDITIONS);
    STUDY = pop_savestudy(STUDY, EEG, 'savemode', 'resave');
end
if ~exist(outDir, 'dir'); mkdir(outDir); end
if numel(c)>1
    chanName = cellstrcat(c, '-');
elseif numel(c) == 1
    chanName = char(c);
end
filename_prefix = ['chan', chanName];
filename = strcat(filename_prefix, ...
                  '_f', int2str(f(1)), 'to', int2str(f(2)), ...
                  '_t', int2str(t(1)), 'to', int2str(t(2)), '.csv');
output_filename = fullfile(outDir, filename);

%% compute erspdata
[STUDY, erspData, erspTimes, erspFreqs] = ...
    std_erspplot(STUDY, ALLEEG, ...
                 'plotsubjects', 'off', 'channels', c,...
                 'plotmode', 'none',...
                 'subbaseline', 'on');
range = [t, f];
output = export_roi_chanersp(STUDY, erspData, ...
                             erspTimes, erspFreqs, range, dataFormat);
output.var1 = ;
output.var2 = ;
struct2csv(output, output_filename);
disp('done')