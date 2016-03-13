% function meng_precomp

%%%%%%%
inputDir = 'F:\meng\study';
nameStudy = 'meng_aggression.study';
V1 = {'neutral', 'lowNegative', 'highNegative'};
V2 = {'lowAggression', 'highAggression'};

%%%%%%% parameters
chanorcomp = 'components'; % components or channels
designIdx = 1;
interp = 'on';
recompute = 'on';
erp = 'on';
erpim = 'off';
scalp = 'on';
spec = 'on';
ersp = 'off';
itc = 'off';
erpbase = [-100, 0];
specmode = 'fft';
spectime = [0, 1000];
specfreq = [3, 30];
cycles = [3, 0.8];
freqs = [3, 100];
nfreqs = 100;
ntimesout = 200;
baseline = [-300 -100];

%%%%%%%% set paramters
erpparams = {'rmbase', erpbase};
specparams = {'specmode', specmode, ...
				'timerange', spectime, ...
				'freqrange', specfreq};
erpimparams = {'nlines' 10 'smoothing' 10};
erspparams = {'cycles', cycles, ...
  			  'nfreqs', nfreqs, ...
			  'ntimesout', ntimesout, ...
			  'freqs', freqs, ...
			  'baseline', baseline};

%%%%%%% load study
% check if STUDY exist
if ~any(strcmp(who, 'STUDY')) || isempty(STUDY)
	[STUDY ALLEEG] = pop_loadstudy('filename', nameStudy, 'filepath', inputDir);
	[STUDY ALLEEG] = std_checkset(STUDY, ALLEEG);
	CURRENTSTUDY = 1; 
	EEG = ALLEEG; 
	CURRENTSET = [1:length(EEG)];
end
% check design
if ~isequal(STUDY.design.variable(1).value, V1) && ~isequal(STUDY.design.variable(2).value, V2)
	STUDY = std_makedesign(STUDY, ALLEEG, 1, ...
	                     'variable1', 'type', 'pairing1', 'on', ...
	                     'variable2', 'group', 'pairing2', 'off', ...
	                     'values1', V1, ...
	                     'values2', V2);
	STUDY = pop_savestudy(STUDY, EEG, 'savemode', 'resave');
end

%%%%%%%% start matlabpool
lix_matpool(4);

%%%%%%%% precompute
[STUDY ALLEEG] = std_precomp(STUDY, ALLEEG, chanorcomp, ...
	'design', designIdx, ...
	'interp', interp, ...
	'recompute', recompute,...
	'erp', erp, 'erpparams', erpparams, ...
	'scalp', scalp, ...
	'spec', spec, 'specparams', specparams,...
	'erpim', erpim, 'erpimparams', erpimparams,...
	'ersp', ersp, 'erspparams', erspparams,...
	'itc', itc);