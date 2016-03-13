function p = lix_run_params
% You must initiate these parameters before you use pipeline functions


% pipeline
% prepare dataset >>> (check data by inspection) >>> epoch dataset >>>
% (check data by inspection) >>> run ica >>> (check data by inspection) >>>
% reject bad ICs & run ica 2 >>> epoch into single condition >>> dipole fit 
% >>> create study >>> edit study >>> precompute >>> cluster components
% directory = fileparts(which('lix_run_p.m'));
% addpath(genpath(directory));
% EEG.etc.referenceOut.interpolatedChannels.all

p = struct();
%=============> directory <=============
p.dir.base 		= '~/Documents/data/yang_all/';
p.dir.raw          = fullfile(p.dir.base, 'raw');
1p.dir.merge 		= fullfile(p.dir.base, 'merge');
p.dir.pre			= fullfile(p.dir.base, 'pre');
p.dir.pre_erp     	= fullfile(p.dir.base, 'pre_erp');
p.dir.clean		= fullfile(p.dir.base, 'clean');
p.dir.epoch 		= fullfile(p.dir.base, 'epoch');
p.dir.epoch_erp 	= fullfile(p.dir.base, 'epoch_erp');
p.dir.ica			= fullfile(p.dir.base, 'ica');
p.dir.ica_erp      = fullfile(p.dir.base, 'ica_erp');
p.dir.ica2 			= fullfile(p.dir.base, 'ica2');
p.dir.ica_single 	= fullfile(p.dir.base, 'ica_single');
p.dir.dip 			= fullfile(p.dir.base, 'dipole');
p.dir.std 			= fullfile(p.dir.base, 'study');
p.dir.bad          = fullfile(p.dir.base, 'bad');
p.dir.icamat       = fullfile(p.dir.base, 'icamat');
p.dir.backproj      = fullfile(p.dir.base, 'backprojsets');
p.dir.output        = fullfile(p.dir.base, 'output');
%=============> merge <=============
p.pre.ext 			= 'eeg'; % exstention of input data
p.pre.pos           = 1;
%=============> preprocessing <=============
p.pre.ds			= 250; % downsampling
p.pre.hp 			= 1; 
p.pre.hp_erp 		= 0.01; % high pass filtering
p.pre.model 		= 'Spherical'; % channel loacation file type 'Spherical'
p.pre.online_ref 	= 'FCz';
% p.preica.offline_ref	= {'TP9', 'TP10'}; % [] -> average; {'TP9', 'TP10'}
p.pre.ref_type	= 'average';
% p.pre.unused 		= {'VEO', 'HEOR', 'TP9', 'TP10'};
p.pre.unused 		= {'VEOG', 'HEOG', 'TP9', 'TP10'}; % lin
p.epoch.changeEvent 	= true; % change event name
p.epoch.from  		= {'S 11', 'S 12',...
				   				'S 21', 'S 22',...
				   				'S 31', 'S 32'}; 
p.epoch.resp          	= {'S  7', 'S  8', 'S  9'};
p.epoch.to 			= {'Pos_Pain', 'Pos_noPain', ...
				   				'Neg_noPain', 'Neg_Pain', ...
				   				'Neu_noPain', 'Neu_Pain' };
% p.epoch.from 		= {'S 11', 'S 12', 'S 13', 'S 14',...
% 						   		'S 21', 'S 22', 'S 23', 'S 24',...
% 						   		'S 31', 'S 32', 'S 33', 'S 34'};  % iris-pain
% p.epoch.to			= {'Old_Pain', 'Old_noPain', 'Old_Pain', 'Old_noPain', ...
% 						   		'Adult_Pain', 'Adult_noPain', 'Adult_Pain', 'Adult_noPain', ...
% 						   		'Child_Pain', 'Child_noPain', 'Child_Pain', 'Child_noPain'};
% p.epoch.from 		= {'S 11', 'S 22', 'S 44', 'S 55'};  % regulation
% p.epoch.to 		= {'free-view', 'repression', 'reappraisal', 'repression+reappraisal'};
% p.epoch.resp 		= [];
% p.epoch.epochtime 	= [-1, 2]; % epoch time range
p.epoch.basetime = [-800, 0]; % [] represents whole epoch data, baseline time range
% p.epoch.basetime 	= [-1000, 0]; % [] represents whole epoch data, baseline time range
p.epoch.epochtime = [-0.8, 1.6]; % epoch time range
% p.epoch.epochtime = [-2, 4];
%=============> ica <=============
p.ica.ranknum1 			= 50;
p.ica.ranknum2			= 50;
p.rej.rightRESP		= {'S  7'};
% p.rej.rightRESP      = [];
p.rej.rejthreshold 	= 2;
% p.rej.eegthresh 	= [-500 500];
% p.rej.jointprob 	= [6, 3]; % for example: [6, 3]
% p.rej.rejkurt 		= [6, 3]; % for example: [6, 3]
% p.rej.rejtrend 	= [75, 0.3];
p.rej.eegthresh 	= [];
p.rej.jointprob 	= []; % for example: [6, 3]
p.rej.rejkurt 		= []; % for example: [6, 3]
p.rej.rejtrend 		= [];
p.rej.chanorcomp  = 1; % 1 channel & 2 component
p.rej2.epoch 		= false;
p.rej2.comp 		= false;
p.rej2.trials 		= 32;
% p.rej2.trials 		= 48;
p.rej2.rightRESP    = [];
p.rej2.rejthreshold = 1;
p.rej2.eegthresh    = [];
p.rej2.jointprob 	= [6, 3];
p.rej2.rejkurt 		= [];
p.rej2.rejtrend 		= [];
p.rej2.chanorcomp 	= 0; % 1 stands for channel
%=============> dipfit <=============
p.dip.RV = 1;
p.dip.type = 'Spherical'; % 'MNI' or 'Spherical'
%=============> study <=============
p.std.name_study = 'mood_pain_clean.study';
% p.std.name_study = 'age_pain_empathy_backproj.study';
% p.std.name_task = 'age_pain_empathy';
p.std.name_task = 'mood_pain_empathy';
p.std.note_study = 'average reference | 1hz hi-pass filtered';
% p.std.name_design = 'allconds';
p.std.nvar = 0;
p.std.dipselect = 0.15;
p.std.inbrain = 'on';
% p.std.dipselect = [];
% p.std.inbrain = [];
p.std.chanorcomp = 'components'; % components or channels
p.std.index_of_design = 1;
p.std.interp = 'on';
p.std.recompute = 'on';
p.std.erp = 'on';
p.std.erpim = 'on';
p.std.scalp = 'on';
p.std.spec = 'on';
p.std.ersp = 'on';
p.std.itc = 'on';
p.std.erpbase = [-200, 0];
p.std.specmode = 'fft';
p.std.spectime = [0, 1000];
p.std.specfreq = [3, 30];
p.std.cycles = [3, 0.8];
p.std.freqs = [3, 100];
p.std.nfreqs = 100;
p.std.ntimesout = 200;
p.std.baseline = [-300 -100];
%%%%%%%%%%%%%%%%%%%%
% clustering
%%%%%%%%%%%%%%%%%%%%
p.cluster.npca.spec = 5;
p.cluster.npca.erp = 5;
p.cluster.npca.scalp = 7;
% p.cluster.npca.dipoles = 3; % which is default setting
% p.cluster.npca.
p.cluster.weight.spec = 2;
p.cluster.weight.erp = 1;
p.cluster.weight.scalp = 3;
p.cluster.weight.dipoles = 10;
p.cluster.specfreqrange = [3 30];
p.cluster.erptimewindow = [0 500];
%%%%%%%%%%%%%%%%%%%%
% save p
%%%%%%%%%%%%%%%%%%%%
% save([p.baseDIR, filesep, 'yang_avg_p'], 'p');
% p.prepDIR 		= fullfile(p.baseDIR, 'prep');
% p.reportDIR 		= fullfile(p.baseDIR, 'report');
% p.singleDIR 		= fullfile(p.baseDIR, 'single');
% p.appicaDIR		= fullfile(p.baseDIR, 'epoch'); % or some else directory you set
% p.cleanDIR 		= fullfile(p.baseDIR, 'epoch'); % or some else directory you set
% p.condDIR 		= fullfile(p.baseDIR, 'cond');
% p.icamatDIR 		= fullfile(p.baseDIR, 'icamat');
% pre-processing (PREP pipeline, high-pass filtering, downsampling etc.)
% p.mergepos 		= 1;
% p.unusedChans 	= {'VEOG', 'HEOG', 'TP9', 'TP10'};
% p.unusedChans 	= {'VEO', 'HEOR', 'TP9', 'TP10'};

%-----------------
% iris's settings
%-----------------
% p.fromEvents 	= {'S 11', 'S 12', 'S 13', 'S 14',...
% 						   'S 21', 'S 22', 'S 23', 'S 24',...
% 						   'S 31', 'S 32', 'S 33', 'S 34'}; % cell array
% p.resp 			= {'S  7', 'S  8', 'S  9'};
% p.rightRESP		= {'S  7'};
% p.toEvents 		= {'Old_Pain', 'Old_noPain', 'Old_Pain', 'Old_noPain', ...
% 						   'Adult_Pain', 'Adult_noPain', 'Adult_Pain', 'Adult_noPain', ...
% 						   'Child_Pain', 'Child_noPain', 'Child_Pain', 'Child_noPain'}; % cell array

%-----------------
% lix's settings
%-----------------
%

% p.ASR 				= false; % if you want to use ASR to remove burst, set it true
% p.burstThresh		= 20; % ASR burst threshold

% ica
% p.reepoch 			= false;
% p.icatype 			= 'infomax'; % infomax | amica (string)
% p.modnum 			= []; % only for amica
% dipole

% % if ~isempty(p.mergeEXT)
% 	p.ignoreBoundaryEvents = true;
% % else
% % 	p.ignoreBoundaryEvents = false;
% % end
% p.detrendType = 'high pass';
% p.detrendCutoff = 1;
% p.lineFrequencies = [50 120];

% p.robustDeviationThreshold = 5;
% p.highFrequencyNoiseThreshold = 5;
% p.correlationThreshold = 0.4;
% p.badTimeThreshold = 0.01;

% if isempty(refchan)
% 	p.referenceType = 'robust';
% else
% 	p.referenceType = 'specific';
% end

% p.reportMode = 'skip'; % normal | skip | reportOnly
% p.keepFiltered = false; % true | false
% p.removeInterpolatedChannels = false; % true | false
% p.cleanupReference = false; % true | false
EEG = pop_dipfit_settings( EEG, 'hdmfile','D:\\eeglab\\plugins\\dipfit2.3\\standard_BEM\\standard_vol.mat','coordformat','MNI','mrifile','D:\\eeglab\\plugins\\dipfit2.3\\standard_BEM\\standard_mri.mat','chanfile','D:\\eeglab\\plugins\\dipfit2.3\\standard_BEM\\elec\\standard_1005.elc','coord_transform',[0.62244 -15.8791 2.2964 0.083536 0.0031531 -1.5735 1.1655 1.0643 1.1499] ,'chansel',[1:55] );
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = pop_dipfit_gridsearch(EEG, [1:50] ,[-85:17:85] ,[-85:17:85] ,[0:17:85] ,1);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = pop_dipfit_settings( EEG, 'hdmfile','D:\\eeglab\\plugins\\dipfit2.3\\standard_BEM\\standard_vol.mat','coordformat','MNI','mrifile','D:\\eeglab\\plugins\\dipfit2.3\\standard_BEM\\standard_mri.mat','chanfile','D:\\eeglab\\plugins\\dipfit2.3\\standard_BEM\\elec\\standard_1005.elc','coord_transform',[1.0078 -15.5729 2.27 0.079814 -0.0015648 -1.5725 1.1701 1.0601 1.1492] ,'chansel',[1:57] );
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
[tmp tmptransf] = coregister(tmploc1{1}, tmploc2, ''mesh'', tmpmodel,' ...
                       '                       ''transform'', str2num(tmptransf), ''chaninfo1'', tmploc1{2}, ''helpmsg'', ''on'');
if ~isempty(tmptransf), set( findobj(gcbf, ''tag'', ''coregtext''), ''string'', num2str(tmptransf)); end;
	    cb_selectcoreg = [ 'tmpmodel = get( findobj(gcbf, ''tag'', ''model''), ''string'');' ...
                       'tmploc2  = get( findobj(gcbf, ''tag'', ''meg'')  , ''string'');' ...
                       'tmploc1  = get( gcbo, ''userdata'');' ...
                       'tmptransf = get( findobj(gcbf, ''tag'', ''coregtext''), ''string'');' ...
                       '[tmp tmptransf] = coregister(tmploc1{1}, tmploc2, ''mesh'', tmpmodel,' ...
                       '                       ''transform'', str2num(tmptransf), ''chaninfo1'', tmploc1{2}, ''helpmsg'', ''on'');' ...
                       'if ~isempty(tmptransf), set( findobj(gcbf, ''tag'', ''coregtext''), ''string'', num2str(tmptransf)); end;' ...
OUTEEG.dipfit.coord_transform = g.coord_transform;