function  std_load(inputDir, inputFilename, g)
% load and create study of EEGLAB
% example of input parameters
% g stucture contains necessary parameters this function uses
%
% g.subjID: is the id of subjects (numel(subjID)==numel(inputFilename))
% g.nVar: is the number of variable(s)
% g.varID: is the id of variables
%    (size(varID,1)==numel(inputFilename) && size(varID, 2)==g.nVar)
% g.varType: is the name of variable(s), (numel(g.varType)==g.nVar)
% g.inbrain: whether or not reject components with dipole outside of brain
% (0 or 1)
% g.dipselect: the threshold of the percentage of residual variances explained by dipoles,
% 0.15 is cool
% g.stdName: the name of a study output file
% g.stdTask: the task of experiment
% g.stdNote: the note of a study
%
% wrapper function by: lix (its.lix at outlook.com)

subjID = g.subjID;
nVar = g.nVar;
varID = g.varID;
varType = g.varType;
inbrain = g.inbrain;
dipselect = g.dipselect;
stdName = g.stdName;
stdTask = g.stdTask;
stdNote = g.stdNote;

% load sets
[STUDY, ALLEEG] = pop_loadset('filename', inputFilename, 'filepath', inputDir);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'study',0);

% create studycommands cell arrays
studycommands = cell(size(inputFilename));
studycommands = build_stdcmds(subj, cond, grp);

[STUDY ALLEEG] = std_editset(STUDY, ALLEEG, ...
                             'name', stdName, ...
                             'task', stdTask, ...
                             'notes', stdNote, ...
                             'commands', studycommands, ...
                             'updatedat', 'on');

STUDY = pop_savestudy(STUDY, EEG, 'filename', ...
                      stdName, 'filepath', ...
                      inputDir);
