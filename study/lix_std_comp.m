function lix_std_comp(params)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
chanorcomp = params.std.chanorcomp;
index_of_design = params.std.index_of_design;
interp = params.std.interp;
recompute = params.std.recompute;
erp = params.std.erp;
erpim = params.std.erpim;
scalp = params.std.scalp;
erpbase = params.std.erpbase;
spec = params.std.spec;
specmode = params.std.specmode;
spectime = params.std.spectime;
specfreq = params.std.specfreq;
ersp = params.std.ersp;
itc = params.std.itc;
cycles = params.std.cycles;
freqs = params.std.freqs;
nfreqs = params.std.nfreqs;
ntimesout = params.std.ntimesout;
baseline = params.std.baseline;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
erpparams = {'rmbase', erpbase};
specparams = {'specmode', specmode, ...
				'timerange', spectime, ...
				'freqrange', specfreq};
erpimparams = {'nlines' 10 'smoothing' 10};
erspparams = {'cycles', [3 0.8], ...
  			  'nfreqs', nfreqs, ...
			  'ntimesout', ntimesout, ...
			  'freqs', freqs, ...
			  'baseline', baseline};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% precompute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[STUDY ALLEEG] = std_precomp(STUDY, ALLEEG, chanorcomp, ...
	'design', index_of_design, ...
	'interp', interp, ...
	'recompute', recompute,...
	'erp', erp, 'erpparams', erpparams, ...
	'scalp', scalp, ...
	'spec', spec, 'specparams', specparams,...
	'erpim', erpim, 'erpimparams', erpimparams,...
	'ersp', ersp, 'erspparams', erspparams,...
	'itc', itc);

