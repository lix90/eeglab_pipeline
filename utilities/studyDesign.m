% load study
studyDir = '~/data/spherical-back/';
studyName = 'yang_pain_empathy_back.study';
conditions = {'Neg_Pain' 'Neg_noPain' 'Neu_Pain' ...
               'Neu_noPain' 'Pos_Pain' 'Pos_noPain'};

% load
if ~any(strcmp(who, 'STUDY')) || isempty(STUDY)
    [STUDY ALLEEG EEG CURRENTSET CURRENTSTUDY] = loadStudy(studyDir, ...
                                                      studyName, conditions);
else
    disp('study is alrealy loaded')
end
% change design if necessary
if ~isequal(STUDY.design.variable(1).value, conditions)
    STUDY = std_makedesign(STUDY, ALLEEG, 1, ...
                           'variable1', 'type', 'pairing1', 'on', ...
                           'values1', conditions);
    STUDY = pop_savestudy(STUDY, EEG, 'savemode', 'resave');
else
    disp('design does not need to change');
end
