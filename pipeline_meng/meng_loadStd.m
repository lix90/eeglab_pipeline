%% script for loading study

% parameters initiation
studyDir = '~/Data/meng-backproj/';
studyName = 'meng_aggression_backproj.study';
var1 = {'neutral', 'lowNegative', 'highNegative'};
var2 = {'lowAggression', 'highAggression'};

% loading study
if ~any(strcmp(who, 'STUDY')) || isempty(STUDY)
    [STUDY ALLEEG] = pop_loadstudy('filename', studyName, ...
                                   'filepath', studyDir);
    [STUDY ALLEEG] = std_checkset(STUDY, ALLEEG);
    CURRENTSTUDY = 1;
    EEG = ALLEEG;
    CURRENTSET = 1:length(EEG);
else
    disp('study is alrealy loaded')
end

% change design if necessary
var1Std = STUDY.design.variable(1).value;
var2Std = STUDY.design.variable(2).value;
if ~isequal(var1Std, var1) && ~isequal(var2Std, var2)
    STUDY = std_makedesign(STUDY, ALLEEG, 1, ...
                           'variable1', 'type', ...
                           'variable2', 'group', ...
                           'pairing1', 'on', ...
                           'pairing2', 'off', ...
                           'values1', var1, ...
                           'values2', var2);
    STUDY = pop_savestudy(STUDY, EEG, 'savemode', 'resave');
else
    disp('design does not need to change');
end

