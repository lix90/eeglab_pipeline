function [STUDY ALLEEG EEG CURRENTSET CURRENTSTUDY] = loadStudy(studyDir, studyName, conditions) 

% check input parameters
if ~isdir(studyDir)
    disp('studyDir is not a real directory')
    return
end
if ~ischar(studyName)
    disp('studyName must be string')
    return
end
if ~iscellstr(conditions)
    disp('conditions must be cellstr')
end

[STUDY ALLEEG] = pop_loadstudy('filename', studyName, 'filepath', studyDir);
[STUDY ALLEEG] = std_checkset(STUDY, ALLEEG);
CURRENTSTUDY = 1;
EEG = ALLEEG;
CURRENTSET = 1:length(EEG);




