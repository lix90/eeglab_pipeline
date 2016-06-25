%% script for loading study

clear, clc, close all;
% parameters initiation
studyDir = '~/data/iris-age-pain/backproj_sph/';
studyName = 'iris_pain_sph_bkproj.study';
conditions = {'Adult_Pain' 'Adult_noPain' 'Child_Pain' ...
              'Child_noPain' 'Old_Pain' 'Old_noPain'};

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
if ~isequal(STUDY.design.variable(1).value, conditions)
    STUDY = std_makedesign(STUDY, ALLEEG, 1, ...
                           'variable1', 'type', ...
                           'pairing1', 'on', ...
                           'values1', conditions);
    STUDY = pop_savestudy(STUDY, EEG, 'savemode', 'resave');
else
    disp('design does not need to change');
end

