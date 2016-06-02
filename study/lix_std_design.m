function lix_std_design(params)

std = params.std;
in = std.dir;
ou = in;
if ~exist(ou, 'dir'); mkdir(ou); end

name_of_study = params.name_of_study;
name_of_design = params.name_of_design;
index_of_design = 1;
pairing1 = 'on';
pairing2 = 'on';
datselect = {'condition', {'Adult', 'Child', 'Old'}, 'group', {'Pain', 'noPain'}};
% subjselect = {STUDY.subject{:}};

STUDY = []; ALLEEG = []; EEG = []; CURRENTSTUDY = 0; CURRENTSET = 0; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load STUDY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[STUDY ALLEEG] = pop_loadstudy('filename', name_of_study, 'filepath', in);
[STUDY ALLEEG] = std_checkset(STUDY, ALLEEG);
CURRENTSTUDY = 1; 
EEG = ALLEEG; 
CURRENTSET = [1:length(EEG)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make design
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
STUDY = std_makedesign(STUDY, ALLEEG, index_of_design, ...
					   'variable1', 'condition', 'pairing1', pairing1, ...
					   'variable2', 'group', 'pairing2', pairing2, ...
					   'datselect', datselect, ...
					   'filepath', ou);
STUDY = pop_savestudy(STUDY, EEG, 'savemode', 'resave');