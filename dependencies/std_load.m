function  std_load(inputDir, inputFilename, cfg)
% load and create study of EEGLAB
% example of input parameters
% cfg stucture contains necessary parameters this function uses
%
% cfg.subjID: is the id of subjects (numel(subjID)==numel(inputFilename))
% cfg.nVar: is the number of variable(s)
% cfg.varID: is the id of variables
%    (size(varID,1)==numel(inputFilename) && size(varID, 2)==cfg.nVar)
% cfg.varType: is the name of variable(s), (numel(cfg.varType)==cfg.nVar)
% cfg.inbrain: whether or not reject components with dipole outside of brain
% (0 or 1)
% cfg.dipselect: the threshold of the percentage of residual variances explained by dipoles,
% 0.15 is cool
% cfg.stdName: the name of a study output file
% cfg.stdTask: the task of experiment
% cfg.stdNote: the note of a study
%
% wrapper function by: lix (its.lix at outlook.com)

subjID = cfg.subjID;
nVar = cfg.nVar;
varID = cfg.varID;
varType = cfg.varType;
inbrain = cfg.inbrain;
dipselect = cfg.dipselect;
stdName = cfg.stdName;
stdTask = cfg.stdTask;
stdNote = cfg.stdNote;

% load sets
[STUDY, ALLEEG] = pop_loadset('filename', inputFilename, 'filepath', inputDir);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'study',0);

% create studycommands cell arrays
studycommands = cell(size(inputFilename));
switch nVar
  case 0
    for i = 1:numel(inputFilename)
        studycommands{i} = {'index', i, ...
                            'subject', subjID{i}};
    end
  case 1
    for i = 1:numel(inputFilename)
        studycommands{i} = {'index', i, ...
                            'subject', subjID{i}, ...
                            varType{1}, varID{i}};
    end
  case 2
    for i = 1:numel(inputFilename)
        studycommands{i} = {'index', i, ...
                            'subject', subjID{i}, ...
                            varType{1}, varID{i,1}, ...
                            varType{2}, varID{i,2}};
    end
end

if ~isempty(inbrain) && ~isempty(dipselect)
    studycommands = {studycommands{:}, {'inbrain', inbrain, 'dipselect', dipselect}};
end

[STUDY ALLEEG] = std_editset( STUDY, ALLEEG, ...
                              'name', stdName, ...
                              'task', stdTask, ...
                              'notes', stdNote, ...
                              'commands', studycommands, ...
                              'updatedat', 'on');

STUDY = pop_savestudy(STUDY, EEG, 'filename', stdName, 'filepath', ...
                      inputDir);
